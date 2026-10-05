import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';

class PostJobScreen extends StatefulWidget {
  const PostJobScreen({super.key});

  @override
  State<PostJobScreen> createState() => _PostJobScreenState();
}

class _PostJobScreenState extends State<PostJobScreen> {
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  final _payController = TextEditingController();

  String _category = 'ICT Based Skills';
  String _difficulty = 'Easy';
  String _gender = 'Any';
  String _workMode = 'Physical (On-site)';
  String _postingAs = 'Individual';
  int _workersNeeded = 1;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgDark,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Post a new job', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold, fontFamily: 'Poppins')),
              const SizedBox(height: 4),
              const Text('Describe your task so the right workers can find it', style: TextStyle(color: AppColors.textMuted, fontSize: 12, fontFamily: 'Poppins')),
              const SizedBox(height: 24),

              _buildSectionTitle('JOB DETAILS'),
              _buildTextField('Job Title', 'e.g. painting', _titleController),
              _buildTextField('Description', 'Describe the task, tools needed...', _descController, maxLines: 4),
              Row(
                children: [
                  Expanded(child: _buildDropdown('Category', ['ICT Based Skills', 'Construction', 'Other'], _category, (v) => setState(() => _category = v!))),
                  const SizedBox(width: 16),
                  Expanded(child: _buildTextField('Pay Rate (LKR)', '2000', _payController)),
                ],
              ),
              const SizedBox(height: 16),

              _buildSectionTitle('DIFFICULTY LEVEL'),
              Row(
                children: [
                  Expanded(child: _buildSelectCard('Easy', 'Light tasks', _difficulty == 'Easy', () => setState(() => _difficulty = 'Easy'))),
                  const SizedBox(width: 8),
                  Expanded(child: _buildSelectCard('Medium', 'Moderate effort', _difficulty == 'Medium', () => setState(() => _difficulty = 'Medium'))),
                  const SizedBox(width: 8),
                  Expanded(child: _buildSelectCard('Hard', 'Heavy physical', _difficulty == 'Hard', () => setState(() => _difficulty = 'Hard'))),
                ],
              ),
              const SizedBox(height: 24),

              _buildSectionTitle('WORKER REQUIREMENTS'),
              const Text('Gender Requirement', style: TextStyle(color: AppColors.textMuted, fontSize: 12, fontFamily: 'Poppins')),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(child: _buildSelectCard('Any', '', _gender == 'Any', () => setState(() => _gender = 'Any'))),
                  const SizedBox(width: 8),
                  Expanded(child: _buildSelectCard('Male Only', '', _gender == 'Male Only', () => setState(() => _gender = 'Male Only'))),
                  const SizedBox(width: 8),
                  Expanded(child: _buildSelectCard('Female Only', '', _gender == 'Female Only', () => setState(() => _gender = 'Female Only'))),
                ],
              ),
              const SizedBox(height: 16),
              
              _buildSectionTitle('WORK MODE'),
              Row(
                children: [
                  Expanded(child: _buildSelectCard('Physical (On-site)', '', _workMode == 'Physical (On-site)', () => setState(() => _workMode = 'Physical (On-site)'))),
                  const SizedBox(width: 8),
                  Expanded(child: _buildSelectCard('Online / Remote', '', _workMode == 'Online / Remote', () => setState(() => _workMode = 'Online / Remote'))),
                ],
              ),
              const SizedBox(height: 24),
              
              _buildSectionTitle('POSTING AS'),
              Row(
                children: [
                  Expanded(child: _buildSelectCard('Individual', '', _postingAs == 'Individual', () => setState(() => _postingAs = 'Individual'))),
                  const SizedBox(width: 8),
                  Expanded(child: _buildSelectCard('Business', '', _postingAs == 'Business', () => setState(() => _postingAs = 'Business'))),
                ],
              ),
              const SizedBox(height: 32),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    // post job action
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Job posted!')));
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: const Text('Post Job Now →', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontFamily: 'Poppins')),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(width: 3, height: 14, color: Colors.tealAccent),
          const SizedBox(width: 8),
          Text(title, style: const TextStyle(color: AppColors.textMuted, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1, fontFamily: 'Poppins')),
        ],
      ),
    );
  }

  Widget _buildTextField(String label, String hint, TextEditingController controller, {int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: AppColors.textMuted, fontSize: 11, fontFamily: 'Poppins')),
          const SizedBox(height: 8),
          TextField(
            controller: controller,
            maxLines: maxLines,
            style: const TextStyle(color: Colors.white, fontSize: 13, fontFamily: 'Poppins'),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: const TextStyle(color: AppColors.borderDefault),
              filled: true,
              fillColor: AppColors.bgDark,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: AppColors.borderDefault)),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Colors.tealAccent)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdown(String label, List<String> items, String value, void Function(String?) onChanged) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: AppColors.textMuted, fontSize: 11, fontFamily: 'Poppins')),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: AppColors.bgDark,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.borderDefault),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: value,
                isExpanded: true,
                dropdownColor: AppColors.bgCard,
                icon: const Icon(Icons.keyboard_arrow_down, color: Colors.white),
                style: const TextStyle(color: Colors.white, fontSize: 13, fontFamily: 'Poppins'),
                onChanged: onChanged,
                items: items.map((item) => DropdownMenuItem(value: item, child: Text(item))).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSelectCard(String title, String subtitle, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? Colors.tealAccent.withOpacity(0.1) : AppColors.bgDark,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: isSelected ? Colors.tealAccent : AppColors.borderDefault),
        ),
        child: Column(
          children: [
            Text(title, textAlign: TextAlign.center, style: TextStyle(color: isSelected ? Colors.tealAccent : Colors.white, fontSize: 12, fontWeight: FontWeight.bold, fontFamily: 'Poppins')),
            if (subtitle.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(subtitle, textAlign: TextAlign.center, style: const TextStyle(color: AppColors.textMuted, fontSize: 9, fontFamily: 'Poppins')),
            ]
          ],
        ),
      ),
    );
  }
}
