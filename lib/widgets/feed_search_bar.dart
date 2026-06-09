import 'package:flutter/material.dart';
import '../utils/theme.dart';

class FeedSearchBar extends StatefulWidget {
  final String? initialValue;
  final ValueChanged<String?> onChanged;

  const FeedSearchBar({super.key, this.initialValue, required this.onChanged});

  @override
  State<FeedSearchBar> createState() => _FeedSearchBarState();
}

class _FeedSearchBarState extends State<FeedSearchBar> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue ?? '');
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.border, width: 0.5)),
      ),
      child: TextField(
        controller: _controller,
        onChanged: (value) {
          widget.onChanged(value.isEmpty ? null : value);
        },
        style: const TextStyle(fontSize: 13, color: AppColors.textPrimary),
        decoration: InputDecoration(
          hintText: 'Search by institute, discipline, keyword...',
          hintStyle: const TextStyle(
            fontSize: 13,
            color: AppColors.textTertiary,
          ),
          prefixIcon: const Icon(
            Icons.search,
            size: 18,
            color: AppColors.textSecondary,
          ),
          suffixIcon: _controller.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(
                    Icons.close,
                    size: 16,
                    color: AppColors.textSecondary,
                  ),
                  onPressed: () {
                    _controller.clear();
                    widget.onChanged(null);
                    setState(() {});
                  },
                )
              : null,
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(
            vertical: 8,
            horizontal: 8,
          ),
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
      ),
    );
  }
}
