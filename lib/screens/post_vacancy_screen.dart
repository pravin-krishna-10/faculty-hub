import 'package:flutter/material.dart';
import '../utils/theme.dart';

class PostVacancyScreen extends StatefulWidget {
  const PostVacancyScreen({super.key});

  @override
  State<PostVacancyScreen> createState() => _PostVacancyScreenState();
}

class _PostVacancyScreenState extends State<PostVacancyScreen> {
  bool _isSubmitting = false;

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
      body: const Center(child: Text('Form coming up')),
    );
  }
}
