import 'package:flutter/material.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

class PersonDetailTabs extends StatelessWidget {
  final bool isJobsTab;
  final VoidCallback onToggle;

  const PersonDetailTabs({
    super.key,
    required this.isJobsTab,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: context.bgCard,
        borderRadius: BorderRadius.circular(AppConstants.radiusMd),
        border: Border.all(color: context.borderColor),
      ),
      child: Row(
        children: [
          Expanded(child: _tab(
            context,
            'حساب شخصي',
            !isJobsTab,
            () => onToggle(),
          )),
          Expanded(child: _tab(
            context,
            'الشغلانات',
            isJobsTab,
            () => onToggle(),
          )),
        ],
      ),
    );
  }

  Widget _tab(BuildContext context, String label, bool isActive, VoidCallback onTap) {
    return GestureDetector(
      onTap: isActive ? null : onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: isActive ? context.accentColor : Colors.transparent,
          borderRadius: BorderRadius.circular(AppConstants.radiusSm),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: AppTextStyles.detailTab(context).copyWith(
            color: isActive ? context.textPrimary : context.textSecondary,
          ),
        ),
      ),
    );
  }
}
