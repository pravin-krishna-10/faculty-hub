import 'package:flutter/material.dart';
import '../models/posting_filters.dart';
import '../utils/theme.dart';

class SegmentToggle extends StatelessWidget {
  final PostingSegment selected;
  final ValueChanged<PostingSegment> onChanged;

  const SegmentToggle({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.border, width: 0.5)),
      ),
      child: Row(
        children: [
          _buildSegment('All', PostingSegment.all),
          const SizedBox(width: 8),
          _buildSegment('Faculty', PostingSegment.faculty),
          const SizedBox(width: 8),
          _buildSegment('Research', PostingSegment.research),
        ],
      ),
    );
  }

  Widget _buildSegment(String label, PostingSegment value) {
    final isSelected = selected == value;
    return InkWell(
      onTap: () => onChanged(value),
      borderRadius: BorderRadius.circular(6),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
            width: 0.8,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
            color: isSelected ? Colors.white : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}
