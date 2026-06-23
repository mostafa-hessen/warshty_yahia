import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../constants/app_constants.dart';

enum ActionButtonType { green, red }

class ActionButton extends StatelessWidget {
  final String label;
  final ActionButtonType type;
  final VoidCallback onPressed;

  const ActionButton({
    super.key,
    required this.label,
    required this.type,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final isGreen = type == ActionButtonType.green;
    return Expanded(
      child: GestureDetector(
        onTap: onPressed,
        child: Container(
          padding: EdgeInsets.symmetric(vertical: AppConstants.spacing12),
          decoration: BoxDecoration(
            color: isGreen ? AppColors.success.withValues(alpha: 0.15) : AppColors.danger.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(AppConstants.radiusMd),
            border: Border.all(color: isGreen ? AppColors.success.withValues(alpha: 0.3) : AppColors.danger.withValues(alpha: 0.3)),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: AppTextStyles.personActionBtn(context).copyWith(
              color: isGreen ? AppColors.success : AppColors.danger,
            ),
          ),
        ),
      ),
    );
  }
}
