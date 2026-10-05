import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/constants/app_colors.dart';
import '../../data/models/job_model.dart';
import '../../data/repositories/job_repository.dart';

class JobDetailScreen extends StatefulWidget {
  final String jobId;
  const JobDetailScreen({super.key, required this.jobId});

  @override
  State<JobDetailScreen> createState() => _JobDetailScreenState();
}

class _JobDetailScreenState extends State<JobDetailScreen> {
  final _jobRepo = JobRepository();
  JobModel? _job;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadJob();
  }

  Future<void> _loadJob() async {
    try {
      final job = await _jobRepo.getJobById(widget.jobId);
      if (mounted) setState(() => _job = job);
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to load job')));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _launchWhatsApp() async {
    final url = Uri.parse("https://wa.me/?text=Hi, I am interested in the job: ${_job?.title}");
    if (!await launchUrl(url)) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Could not launch WhatsApp')));
    }
  }

  Future<void> _launchCall() async {
    final url = Uri.parse("tel:"); // Replace with actual phone number if available
    if (!await launchUrl(url)) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Could not launch Dialer')));
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: AppColors.bgDark,
        body: Center(child: CircularProgressIndicator(color: AppColors.primary)),
      );
    }

    if (_job == null) {
      return Scaffold(
        backgroundColor: AppColors.bgDark,
        appBar: AppBar(backgroundColor: AppColors.bgDark, elevation: 0),
        body: const Center(child: Text('Job not found', style: TextStyle(color: Colors.white, fontFamily: 'Poppins'))),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.bgDark,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.bgCard,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.borderDefault),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(_job!.title, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold, fontFamily: 'Poppins')),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(color: AppColors.bgElevated, borderRadius: BorderRadius.circular(4)),
                                child: const Text('Individual', style: TextStyle(color: AppColors.textMuted, fontSize: 10, fontFamily: 'Poppins')),
                              ),
                              const SizedBox(width: 8),
                              const Icon(Icons.location_on_outlined, color: AppColors.error, size: 14),
                              const SizedBox(width: 4),
                              Text('${_job!.city} / ${_job!.jobType}', style: const TextStyle(color: AppColors.textMuted, fontSize: 12, fontFamily: 'Poppins')),
                            ],
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: AppColors.textMuted),
                      onPressed: () => context.pop(),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Info Cards
                Row(
                  children: [
                    Expanded(child: _buildInfoCard('DAILY PAY', 'Rs. ${_job!.budget.toStringAsFixed(0)}')),
                    const SizedBox(width: 12),
                    Expanded(child: _buildInfoCard('CATEGORY', _job!.category)),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(child: _buildInfoCard('WORKERS NEEDED', '1 worker', valueColor: Colors.tealAccent)),
                    const SizedBox(width: 12),
                    Expanded(child: _buildInfoCard('POSTED', 'Oct 1, 2026')), // Hardcoded for demo to match SS
                  ],
                ),
                const SizedBox(height: 16),

                // Chips
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _buildChip('Open', Colors.tealAccent),
                    _buildChip('Hard', AppColors.error),
                    _buildChip('Male Only', Colors.blue),
                    _buildChip('18+', Colors.orange),
                    _buildChip('1 needed', AppColors.textMuted),
                  ],
                ),
                const SizedBox(height: 24),

                // Job Description Section
                const Text('JOB DESCRIPTION', style: TextStyle(color: AppColors.textMuted, fontSize: 10, fontWeight: FontWeight.bold, fontFamily: 'Poppins')),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.bgElevated.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.borderDefault),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('WORK SCHEDULE', style: TextStyle(color: AppColors.textMuted, fontSize: 10, fontWeight: FontWeight.bold, fontFamily: 'Poppins')),
                      const SizedBox(height: 12),
                      const Text('Start: 2026-10-30 at 8:40 PM', style: TextStyle(color: AppColors.textMuted, fontSize: 12, fontFamily: 'Poppins')),
                      const SizedBox(height: 8),
                      const Text('End: 2026-10-31 at 8:40 PM', style: TextStyle(color: AppColors.textMuted, fontSize: 12, fontFamily: 'Poppins')),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  _job!.description.isNotEmpty ? _job!.description : 'No description provided.',
                  style: const TextStyle(color: AppColors.textSecondary, fontSize: 13, height: 1.5, fontFamily: 'Poppins'),
                ),
                const SizedBox(height: 32),

                // Contact Section
                const Text('CONTACT THE POSTER', style: TextStyle(color: AppColors.textMuted, fontSize: 10, fontWeight: FontWeight.bold, fontFamily: 'Poppins')),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.bgElevated,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle, 
                          color: AppColors.bgDark,
                          image: _job!.postedByAvatar != null
                              ? DecorationImage(image: NetworkImage(_job!.postedByAvatar!), fit: BoxFit.cover)
                              : null,
                        ),
                        child: _job!.postedByAvatar == null
                            ? const Icon(Icons.person, color: AppColors.textMuted)
                            : null,
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(_job!.postedByName, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold, fontFamily: 'Poppins')),
                          const SizedBox(height: 2),
                          const Text('Individual Client', style: TextStyle(color: AppColors.textMuted, fontSize: 11, fontFamily: 'Poppins')),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Buttons
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _launchWhatsApp,
                        icon: const Icon(Icons.wechat, color: Colors.white, size: 18),
                        label: const Text('WhatsApp', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontFamily: 'Poppins')),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.teal,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _launchCall,
                        icon: const Icon(Icons.call, color: Colors.white, size: 18),
                        label: const Text('Call Now', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontFamily: 'Poppins')),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blueAccent,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard(String label, String value, {Color valueColor = Colors.white}) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.bgElevated.withOpacity(0.5),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.borderDefault),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: AppColors.textMuted, fontSize: 9, fontWeight: FontWeight.bold, fontFamily: 'Poppins')),
          const SizedBox(height: 6),
          Text(value, style: TextStyle(color: valueColor, fontSize: 13, fontWeight: FontWeight.bold, fontFamily: 'Poppins')),
        ],
      ),
    );
  }

  Widget _buildChip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(100),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Text(label, style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold, fontFamily: 'Poppins')),
    );
  }
}
