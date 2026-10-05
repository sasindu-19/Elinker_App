-- ============================================================
-- ELINKER APP - SUPABASE DATABASE SETUP SQL
-- Run this in your Supabase SQL Editor:
-- https://supabase.com/dashboard/project/YOUR_PROJECT/sql
-- ============================================================

-- Enable required extensions
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- ============================================================
-- 1. PROFILES TABLE
-- ============================================================
CREATE TABLE IF NOT EXISTS public.profiles (
    id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    email TEXT NOT NULL,
    full_name TEXT NOT NULL,
    phone TEXT,
    avatar_url TEXT,
    bio TEXT,
    city TEXT,
    user_type TEXT DEFAULT 'both' CHECK (user_type IN ('worker', 'client', 'both')),
    rating DECIMAL(3,2) DEFAULT 0.00,
    review_count INTEGER DEFAULT 0,
    is_verified BOOLEAN DEFAULT false,
    skills TEXT[] DEFAULT '{}',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- ============================================================
-- 2. JOBS TABLE
-- ============================================================
CREATE TABLE IF NOT EXISTS public.jobs (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    title TEXT NOT NULL,
    description TEXT,
    category TEXT NOT NULL,
    category_icon TEXT,
    city TEXT NOT NULL,
    address TEXT,
    latitude DECIMAL(10, 8),
    longitude DECIMAL(11, 8),
    budget DECIMAL(12, 2) NOT NULL DEFAULT 0,
    budget_type TEXT DEFAULT 'fixed' CHECK (budget_type IN ('fixed', 'hourly', 'daily')),
    job_type TEXT DEFAULT 'part_time' CHECK (job_type IN ('full_time', 'part_time', 'freelance', 'remote')),
    status TEXT DEFAULT 'open' CHECK (status IN ('open', 'in_progress', 'completed', 'cancelled')),
    posted_by_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE,
    posted_by_name TEXT NOT NULL,
    posted_by_avatar TEXT,
    is_verified BOOLEAN DEFAULT false,
    is_featured BOOLEAN DEFAULT false,
    application_count INTEGER DEFAULT 0,
    skills TEXT[] DEFAULT '{}',
    image_urls TEXT[] DEFAULT '{}',
    deadline TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- ============================================================
-- 3. APPLICATIONS TABLE
-- ============================================================
CREATE TABLE IF NOT EXISTS public.applications (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    job_id UUID REFERENCES public.jobs(id) ON DELETE CASCADE,
    applicant_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE,
    cover_letter TEXT,
    proposed_budget DECIMAL(12, 2),
    status TEXT DEFAULT 'pending' CHECK (status IN ('pending', 'accepted', 'rejected', 'withdrawn')),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(job_id, applicant_id)
);

-- ============================================================
-- 4. REVIEWS TABLE
-- ============================================================
CREATE TABLE IF NOT EXISTS public.reviews (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    job_id UUID REFERENCES public.jobs(id) ON DELETE CASCADE,
    reviewer_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE,
    reviewee_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE,
    rating INTEGER NOT NULL CHECK (rating BETWEEN 1 AND 5),
    comment TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- ============================================================
-- 5. NOTIFICATIONS TABLE
-- ============================================================
CREATE TABLE IF NOT EXISTS public.notifications (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE,
    title TEXT NOT NULL,
    body TEXT NOT NULL,
    type TEXT DEFAULT 'general',
    is_read BOOLEAN DEFAULT false,
    data JSONB DEFAULT '{}',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- ============================================================
-- 6. HELPER FUNCTION: Increment application count
-- ============================================================
CREATE OR REPLACE FUNCTION increment_application_count(job_id UUID)
RETURNS void AS $$
BEGIN
    UPDATE public.jobs
    SET application_count = application_count + 1
    WHERE id = job_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ============================================================
-- 7. AUTO-UPDATE updated_at TRIGGER
-- ============================================================
CREATE OR REPLACE FUNCTION update_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER update_profiles_updated_at
    BEFORE UPDATE ON public.profiles
    FOR EACH ROW EXECUTE FUNCTION update_updated_at();

CREATE TRIGGER update_jobs_updated_at
    BEFORE UPDATE ON public.jobs
    FOR EACH ROW EXECUTE FUNCTION update_updated_at();

-- ============================================================
-- 8. ROW LEVEL SECURITY (RLS) POLICIES
-- ============================================================

-- Enable RLS
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.jobs ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.applications ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.reviews ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.notifications ENABLE ROW LEVEL SECURITY;

-- PROFILES: Anyone can view profiles, only own profile can be updated
CREATE POLICY "Anyone can view profiles" ON public.profiles
    FOR SELECT USING (true);

CREATE POLICY "Users can update own profile" ON public.profiles
    FOR UPDATE USING (auth.uid() = id);

CREATE POLICY "Users can insert own profile" ON public.profiles
    FOR INSERT WITH CHECK (auth.uid() = id);

-- JOBS: Anyone can view open jobs, only poster can update/delete
CREATE POLICY "Anyone can view open jobs" ON public.jobs
    FOR SELECT USING (status = 'open' OR posted_by_id = auth.uid());

CREATE POLICY "Authenticated users can post jobs" ON public.jobs
    FOR INSERT WITH CHECK (auth.uid() = posted_by_id);

CREATE POLICY "Job posters can update their jobs" ON public.jobs
    FOR UPDATE USING (auth.uid() = posted_by_id);

CREATE POLICY "Job posters can delete their jobs" ON public.jobs
    FOR DELETE USING (auth.uid() = posted_by_id);

-- APPLICATIONS: Applicants and job posters can see applications
CREATE POLICY "Users can see their own applications" ON public.applications
    FOR SELECT USING (
        auth.uid() = applicant_id OR 
        auth.uid() IN (SELECT posted_by_id FROM public.jobs WHERE id = job_id)
    );

CREATE POLICY "Authenticated users can apply" ON public.applications
    FOR INSERT WITH CHECK (auth.uid() = applicant_id);

-- REVIEWS: Anyone can view, authenticated can insert
CREATE POLICY "Anyone can view reviews" ON public.reviews
    FOR SELECT USING (true);

CREATE POLICY "Authenticated users can leave reviews" ON public.reviews
    FOR INSERT WITH CHECK (auth.uid() = reviewer_id);

-- NOTIFICATIONS: Users can only see their own
CREATE POLICY "Users see own notifications" ON public.notifications
    FOR SELECT USING (auth.uid() = user_id);

-- ============================================================
-- 9. STORAGE BUCKETS
-- ============================================================
INSERT INTO storage.buckets (id, name, public) 
VALUES 
    ('profile-images', 'profile-images', true),
    ('job-images', 'job-images', true)
ON CONFLICT DO NOTHING;

-- Storage policies
CREATE POLICY "Anyone can view profile images" ON storage.objects
    FOR SELECT USING (bucket_id = 'profile-images');

CREATE POLICY "Users can upload own profile image" ON storage.objects
    FOR INSERT WITH CHECK (
        bucket_id = 'profile-images' AND 
        auth.uid()::text = (storage.foldername(name))[1]
    );

CREATE POLICY "Anyone can view job images" ON storage.objects
    FOR SELECT USING (bucket_id = 'job-images');

CREATE POLICY "Users can upload job images" ON storage.objects
    FOR INSERT WITH CHECK (
        bucket_id = 'job-images' AND auth.role() = 'authenticated'
    );

-- ============================================================
-- 10. SAMPLE DATA (optional - for testing)
-- ============================================================
-- Uncomment below to insert sample jobs for testing

/*
INSERT INTO public.jobs (title, description, category, city, budget, budget_type, job_type, posted_by_id, posted_by_name, is_featured)
VALUES 
    ('Fix Plumbing Leak - Bathroom', 'Need an experienced plumber to fix a leaking pipe under the bathroom sink. Job should take 1-2 hours.', 'construction', 'Colombo', 5000, 'fixed', 'part_time', 'REPLACE_WITH_USER_ID', 'Test User', true),
    ('React Native Developer Needed', 'Looking for a React Native developer to add new features to our existing mobile app. Remote work available.', 'tech', 'Colombo', 75000, 'fixed', 'freelance', 'REPLACE_WITH_USER_ID', 'Test User', true),
    ('House Cleaning - 3 BHK', 'Need thorough cleaning of a 3 bedroom house. Cleaning supplies will be provided.', 'domestic', 'Kandy', 3500, 'daily', 'part_time', 'REPLACE_WITH_USER_ID', 'Test User', false);
*/
