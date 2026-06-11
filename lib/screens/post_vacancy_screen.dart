import 'package:flutter/material.dart';
import '../utils/theme.dart';
import '../utils/posting_constants.dart';
import '../utils/disciplines.dart';

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
            ],
          ),
        ),
      ),
    );
  }
}
