import 'package:flutter/material.dart';
import '../utils/theme.dart';
import '../utils/posting_constants.dart';
import '../utils/disciplines.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/posting.dart';
import '../services/postings_service.dart';

class PostVacancyScreen extends StatefulWidget {
  const PostVacancyScreen({super.key});

  @override
  State<PostVacancyScreen> createState() => _PostVacancyScreenState();
}

class _PostVacancyScreenState extends State<PostVacancyScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isSubmitting = false;

  // Field values
  String? _positionType;
  String? _employmentType;
  String? _discipline;
  final _specializationController = TextEditingController();
  final _instituteController = TextEditingController();
  final _cityController = TextEditingController();
  DateTime? _deadline;
  final _howToApplyController = TextEditingController();
  String _source = 'official';
  final _salaryController = TextEditingController();
  final _durationController = TextEditingController();
  final _descriptionController = TextEditingController();

  @override
  void dispose() {
    _specializationController.dispose();
    _instituteController.dispose();
    _cityController.dispose();
    _howToApplyController.dispose();
    _salaryController.dispose();
    _durationController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Widget _sectionHeader(String text) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: AppColors.textSecondary,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _fieldLabel(String text, {bool required = false}) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, right: 16, bottom: 4),
      child: Row(
        children: [
          Text(
            text,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
          if (required)
            const Text(' *', style: TextStyle(fontSize: 12, color: Colors.red)),
        ],
      ),
    );
  }

  Widget _buildPositionTypeField() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: DropdownButtonFormField<String>(
        value: _positionType,
        decoration: _dropdownDecoration('Select position type'),
        isExpanded: true,
        items: PositionType.values.entries.map((e) {
          return DropdownMenuItem(
            value: e.key,
            child: Text(e.value, style: const TextStyle(fontSize: 13)),
          );
        }).toList(),
        onChanged: (value) => setState(() => _positionType = value),
        validator: (value) => value == null ? 'Required' : null,
      ),
    );
  }

  InputDecoration _dropdownDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(fontSize: 13, color: AppColors.textTertiary),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      isDense: true,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(6),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(6),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(6),
        borderSide: const BorderSide(color: AppColors.primary),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    bool isRequired = false,
    int maxLines = 1,
    TextInputType? keyboardType,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        keyboardType: keyboardType,
        style: const TextStyle(fontSize: 13, color: AppColors.textPrimary),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(
            fontSize: 13,
            color: AppColors.textTertiary,
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 10,
          ),
          isDense: true,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(6),
            borderSide: const BorderSide(color: AppColors.border),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(6),
            borderSide: const BorderSide(color: AppColors.border),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(6),
            borderSide: const BorderSide(color: AppColors.primary),
          ),
        ),
        validator: isRequired
            ? (value) =>
                  (value == null || value.trim().isEmpty) ? 'Required' : null
            : null,
      ),
    );
  }

  Widget _buildDeadlineField() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: InkWell(
        onTap: () async {
          final now = DateTime.now();
          final picked = await showDatePicker(
            context: context,
            initialDate: _deadline ?? now.add(const Duration(days: 14)),
            firstDate: now,
            lastDate: now.add(const Duration(days: 365)),
          );
          if (picked != null) {
            setState(() => _deadline = picked);
          }
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.border),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  _deadline == null
                      ? 'Pick a deadline'
                      : _formatDate(_deadline!),
                  style: TextStyle(
                    fontSize: 13,
                    color: _deadline == null
                        ? AppColors.textTertiary
                        : AppColors.textPrimary,
                  ),
                ),
              ),
              const Icon(
                Icons.calendar_today,
                size: 16,
                color: AppColors.textSecondary,
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  Widget _buildSourceField() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: _sourceOption(
              'official',
              'Official',
              'Posted on institute website',
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _sourceOption(
              'heard',
              'Heard',
              'Internal info, not yet official',
            ),
          ),
        ],
      ),
    );
  }

  Widget _sourceOption(String value, String label, String subtitle) {
    final isSelected = _source == value;
    return InkWell(
      onTap: () => setState(() => _source = value),
      borderRadius: BorderRadius.circular(6),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryLight : Colors.transparent,
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
            width: isSelected ? 1.2 : 0.8,
          ),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: isSelected ? AppColors.primary : AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: const TextStyle(
                fontSize: 11,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill all required fields'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    if (_deadline == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please pick an application deadline'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception('Not signed in');

      final now = DateTime.now();
      final posting = Posting(
        id: '', // Firestore generates this
        positionType: _positionType!,
        employmentType: _employmentType!,
        discipline: _discipline!,
        specialization: _specializationController.text.trim().isEmpty
            ? null
            : _specializationController.text.trim(),
        instituteName: _instituteController.text.trim(),
        city: _cityController.text.trim(),
        deadline: _deadline!,
        howToApply: _howToApplyController.text.trim(),
        source: _source,
        salaryRange: _salaryController.text.trim().isEmpty
            ? null
            : _salaryController.text.trim(),
        duration: _durationController.text.trim().isEmpty
            ? null
            : _durationController.text.trim(),
        description: _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
        postedByUid: user.uid,
        postedByName: user.email ?? 'Unknown',
        postedByInstitute: 'Unknown',
        postedByRole: 'faculty',
        createdAt: now,
        updatedAt: now,
        expiresAt: _deadline!.add(const Duration(days: 7)),
        status: 'active',
      );

      await PostingsService().createPosting(posting);

      if (!mounted) return;
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Posting shared with the community'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );
    } catch (e) {
      if (mounted) {
        setState(() => _isSubmitting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not share posting: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  Widget _buildEmploymentTypeField() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: DropdownButtonFormField<String>(
        value: _employmentType,
        decoration: _dropdownDecoration('Select employment type'),
        isExpanded: true,
        items: EmploymentType.values.entries.map((e) {
          return DropdownMenuItem(
            value: e.key,
            child: Text(e.value, style: const TextStyle(fontSize: 13)),
          );
        }).toList(),
        onChanged: (value) => setState(() => _employmentType = value),
        validator: (value) => value == null ? 'Required' : null,
      ),
    );
  }

  Widget _buildDisciplineField() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: DropdownButtonFormField<String>(
        value: _discipline,
        decoration: _dropdownDecoration('Select discipline'),
        isExpanded: true,
        items: Disciplines.all.map((d) {
          return DropdownMenuItem(
            value: d,
            child: Text(d, style: const TextStyle(fontSize: 13)),
          );
        }).toList(),
        onChanged: (value) => setState(() => _discipline = value),
        validator: (value) => value == null ? 'Required' : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
        title: const Text(
          'Share an opening',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: AppColors.textPrimary,
          ),
        ),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _sectionHeader('POSITION DETAILS'),
              _fieldLabel('Position type', required: true),
              _buildPositionTypeField(),
              const SizedBox(height: 12),
              _fieldLabel('Employment type', required: true),
              _buildEmploymentTypeField(),
              const SizedBox(height: 12),
              _fieldLabel('Discipline', required: true),
              _buildDisciplineField(),
              const SizedBox(height: 24),
              _sectionHeader('LOCATION & TIMING'),
              _fieldLabel('Specialization (optional)'),
              _buildTextField(
                controller: _specializationController,
                hint: 'e.g. Machine Learning, Organic Chemistry',
              ),
              const SizedBox(height: 12),
              _fieldLabel('Institute', required: true),
              _buildTextField(
                controller: _instituteController,
                hint: 'e.g. IIT Bombay',
                isRequired: true,
              ),
              const SizedBox(height: 12),
              _fieldLabel('City', required: true),
              _buildTextField(
                controller: _cityController,
                hint: 'e.g. Mumbai',
                isRequired: true,
              ),
              _fieldLabel('Application deadline', required: true),
              _buildDeadlineField(),
              const SizedBox(height: 24),
              _sectionHeader('APPLICATION & SOURCE'),
              _fieldLabel('How to apply', required: true),
              _buildTextField(
                controller: _howToApplyController,
                hint: 'Email, website link, or instructions',
                isRequired: true,
                maxLines: 2,
              ),
              const SizedBox(height: 12),
              _fieldLabel('Source', required: true),
              _buildSourceField(),
              const SizedBox(height: 24),
              _sectionHeader('OPTIONAL DETAILS'),
              _fieldLabel('Salary range (optional)'),
              _buildTextField(
                controller: _salaryController,
                hint: 'e.g. 8-12 LPA or 37000/month',
              ),
              const SizedBox(height: 12),
              if (_employmentType != null &&
                  _employmentType != 'full_time_permanent') ...[
                _fieldLabel('Duration', required: true),
                _buildTextField(
                  controller: _durationController,
                  hint: 'e.g. 2 years, 1 semester, 8 weeks',
                  isRequired: true,
                ),
                const SizedBox(height: 12),
              ],
              _fieldLabel('Description (optional)'),
              _buildTextField(
                controller: _descriptionController,
                hint: 'Additional context, qualifications, expectations...',
                maxLines: 4,
              ),
              const SizedBox(height: 32),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: _isSubmitting ? null : _handleSubmit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: AppColors.border,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                      elevation: 0,
                    ),
                    child: _isSubmitting
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Text(
                            'Share with community',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
