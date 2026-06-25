import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/presentation/widgets/app_filter_chip.dart';
import '../cubits/reports_state.dart';

enum DatePreset { today, thisWeek, thisMonth, thisYear, custom }

extension DatePresetLabel on DatePreset {
  String get label {
    switch (this) {
      case DatePreset.today: return 'اليوم';
      case DatePreset.thisWeek: return 'هذا الأسبوع';
      case DatePreset.thisMonth: return 'هذا الشهر';
      case DatePreset.thisYear: return 'هذا العام';
      case DatePreset.custom: return 'مخصص';
    }
  }
}

class DateFilterBar extends StatefulWidget {
  final DatePreset? selected;
  final ValueChanged<DatePreset> onPresetChanged;
  final VoidCallback? onCustomTap;
  final String? customLabel;

  const DateFilterBar({
    super.key,
    this.selected,
    required this.onPresetChanged,
    this.onCustomTap,
    this.customLabel,
  });

  @override
  State<DateFilterBar> createState() => _DateFilterBarState();
}

class _DateFilterBarState extends State<DateFilterBar> {
  @override
  Widget build(BuildContext context) {
    final presets = DatePreset.values;
    return SizedBox(
      height: 36,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: presets.length,
        separatorBuilder: (_, __) => SizedBox(width: AppConstants.spacing6),
        padding: EdgeInsets.symmetric(horizontal: AppConstants.spacing4),
        itemBuilder: (_, i) {
          final preset = presets[i];
          final isActive = widget.selected == preset;
          if (preset == DatePreset.custom) {
            return GestureDetector(
              onTap: () {
                widget.onPresetChanged(DatePreset.custom);
                widget.onCustomTap?.call();
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: isActive ? context.accentColor.withValues(alpha: 0.15) : context.bgCard,
                  borderRadius: BorderRadius.circular(AppConstants.radiusChip),
                  border: Border.all(color: isActive ? context.accentColor : context.borderColor),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.date_range, size: AppConstants.iconSm,
                      color: isActive ? context.accentColor : context.textSecondary),
                    SizedBox(width: 4),
                    Text(
                      widget.customLabel ?? 'مخصص',
                      style: AppTextStyles.categoryChip(context).copyWith(
                        color: isActive ? context.accentColor : context.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }
          return AppFilterChip(
            label: preset.label,
            isActive: isActive,
            onTap: () => widget.onPresetChanged(preset),
          );
        },
      ),
    );
  }
}

DateRange dateRangeFromPreset(DatePreset preset) {
  final today = DateTime.now();
  switch (preset) {
    case DatePreset.today:
      final s = '${today.year.toString().padLeft(4, '0')}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';
      return DateRange(from: s, to: s);
    case DatePreset.thisWeek:
      final weekStart = today.subtract(Duration(days: today.weekday - 1));
      return DateRange(from: _fmt(weekStart), to: _fmt(today));
    case DatePreset.thisMonth:
      return DateRange(from: '${today.year}-${today.month.toString().padLeft(2, '0')}-01', to: _fmt(today));
    case DatePreset.thisYear:
      return DateRange(from: '${today.year}-01-01', to: _fmt(today));
    case DatePreset.custom:
      return const DateRange();
  }
}

String _fmt(DateTime d) => '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
