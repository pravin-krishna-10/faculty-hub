import 'package:flutter/material.dart';
import '../models/posting_filters.dart';
import '../utils/disciplines.dart';
import '../utils/posting_constants.dart';
import '../utils/theme.dart';

class FilterBar extends StatelessWidget {
  final PostingFilters filters;
  final ValueChanged<PostingFilters> onFiltersChanged;

  const FilterBar({
    super.key,
    required this.filters,
    required this.onFiltersChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.border, width: 0.5)),
      ),
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          _buildChip(
            label: filters.discipline ?? 'Discipline',
            isActive: filters.discipline != null,
            onTap: () => _openDisciplinePicker(context),
            onClear: () =>
                onFiltersChanged(filters.copyWith(clearDiscipline: true)),
          ),
          _buildChip(
            label: filters.positionType != null
                ? PositionType.displayLabel(filters.positionType!)
                : 'Position',
            isActive: filters.positionType != null,
            onTap: () => _openPositionTypePicker(context),
            onClear: () =>
                onFiltersChanged(filters.copyWith(clearPositionType: true)),
          ),
          _buildChip(
            label: filters.city ?? 'City',
            isActive: filters.city != null,
            onTap: () => _openCityPicker(context),
            onClear: () => onFiltersChanged(filters.copyWith(clearCity: true)),
          ),
          _buildChip(
            label: filters.source != null
                ? (filters.source == 'official' ? 'Official' : 'Heard')
                : 'Source',
            isActive: filters.source != null,
            onTap: () => _openSourcePicker(context),
            onClear: () =>
                onFiltersChanged(filters.copyWith(clearSource: true)),
          ),
        ],
      ),
    );
  }

  Widget _buildChip({
    required String label,
    required bool isActive,
    required VoidCallback onTap,
    VoidCallback? onClear,
  }) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: isActive ? AppColors.primaryLight : Colors.transparent,
            border: Border.all(
              color: isActive ? AppColors.primary : AppColors.border,
              width: 0.8,
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: isActive ? FontWeight.w500 : FontWeight.normal,
                  color: isActive ? AppColors.primary : AppColors.textSecondary,
                ),
              ),
              if (isActive && onClear != null) ...[
                const SizedBox(width: 6),
                GestureDetector(
                  onTap: onClear,
                  child: Icon(Icons.close, size: 14, color: AppColors.primary),
                ),
              ] else ...[
                const SizedBox(width: 4),
                Icon(
                  Icons.arrow_drop_down,
                  size: 16,
                  color: AppColors.textSecondary,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  void _openDisciplinePicker(BuildContext context) {
    _showPicker(
      context: context,
      title: 'Select discipline',
      options: Disciplines.all,
      currentValue: filters.discipline,
      onSelect: (value) {
        onFiltersChanged(filters.copyWith(discipline: value));
      },
    );
  }

  void _openPositionTypePicker(BuildContext context) {
    // Build a list of display labels, keep the key->label map for lookup
    final entries = PositionType.values.entries.toList();
    _showPicker(
      context: context,
      title: 'Select position type',
      options: entries.map((e) => e.value).toList(),
      currentValue: filters.positionType != null
          ? PositionType.displayLabel(filters.positionType!)
          : null,
      onSelect: (selectedLabel) {
        // Map back from label to key
        final key = entries.firstWhere((e) => e.value == selectedLabel).key;
        onFiltersChanged(filters.copyWith(positionType: key));
      },
    );
  }

  void _openCityPicker(BuildContext context) {
    // For v0, hardcode common Indian cities. Later, derive from postings or institutes.
    const cities = [
      'Delhi',
      'Mumbai',
      'Bangalore',
      'Hyderabad',
      'Chennai',
      'Kolkata',
      'Pune',
      'Ahmedabad',
      'Greater Noida',
      'Gurgaon',
      'Kanpur',
      'Roorkee',
      'Guwahati',
      'Bhubaneswar',
      'Jaipur',
      'Indore',
      'Chandigarh',
    ];
    _showPicker(
      context: context,
      title: 'Select city',
      options: cities,
      currentValue: filters.city,
      onSelect: (value) {
        onFiltersChanged(filters.copyWith(city: value));
      },
    );
  }

  void _openSourcePicker(BuildContext context) {
    _showPicker(
      context: context,
      title: 'Select source',
      options: const ['Official', 'Heard'],
      currentValue: filters.source != null
          ? (filters.source == 'official' ? 'Official' : 'Heard')
          : null,
      onSelect: (selectedLabel) {
        final key = selectedLabel == 'Official' ? 'official' : 'heard';
        onFiltersChanged(filters.copyWith(source: key));
      },
    );
  }

  void _showPicker({
    required BuildContext context,
    required String title,
    required List<String> options,
    required String? currentValue,
    required ValueChanged<String> onSelect,
  }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 12),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              const Divider(height: 1, color: AppColors.border),
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: options.length,
                  itemBuilder: (_, index) {
                    final opt = options[index];
                    final isSelected = opt == currentValue;
                    return InkWell(
                      onTap: () {
                        Navigator.of(sheetContext).pop();
                        onSelect(opt);
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                opt,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: isSelected
                                      ? AppColors.primary
                                      : AppColors.textPrimary,
                                  fontWeight: isSelected
                                      ? FontWeight.w500
                                      : FontWeight.normal,
                                ),
                              ),
                            ),
                            if (isSelected)
                              const Icon(
                                Icons.check,
                                size: 16,
                                color: AppColors.primary,
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }
}
