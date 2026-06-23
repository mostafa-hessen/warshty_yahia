import 'package:flutter/material.dart';

import '../../constants/app_constants.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';

class AppModal extends StatelessWidget {
  final String title;
  final Widget child;
  final VoidCallback? onClose;

  const AppModal({
    super.key,
    required this.title,
    required this.child,
    this.onClose,
  });

  static Future<void> show(BuildContext context, AppModal modal) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => modal,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.darkBgSecondary,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(AppConstants.radius3xl)),
        border: Border(
          top: BorderSide(color: AppColors.darkBorder),
          left: BorderSide(color: AppColors.darkBorder),
          right: BorderSide(color: AppColors.darkBorder),
        ),
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(AppConstants.radius3xl)),
        child: Padding(
          padding: EdgeInsets.all(AppConstants.spacing20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildHeader(context),
              SizedBox(height: AppConstants.spacing20),
              Flexible(child: SingleChildScrollView(child: child)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        Text(title, style: AppTextStyles.modalTitle(context)),
        const Spacer(),
        GestureDetector(
          onTap: onClose ?? () => Navigator.pop(context),
          child: Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: AppColors.darkBgCard,
              borderRadius: BorderRadius.circular(15),
            ),
            child: Icon(Icons.close, size: 16, color: AppColors.darkTextSecondary),
          ),
        ),
      ],
    );
  }
}
