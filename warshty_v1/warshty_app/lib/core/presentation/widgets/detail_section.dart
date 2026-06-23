import 'package:flutter/material.dart';

import '../../theme/app_text_styles.dart';
import '../../theme/app_colors.dart';
import '../../constants/app_constants.dart';

class DetailSection extends StatelessWidget {
  final String title;
  final Widget? trailing;
  final List<Widget> children;
  final EdgeInsetsGeometry? padding;

  const DetailSection({
    super.key,
    required this.title,
    this.trailing,
    required this.children,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Row(
            children: [
              Text(title, style: AppTextStyles.detailSectionTitle(context)),
              const Spacer(),
              if (trailing != null) trailing!,
            ],
          ),
        ),
        Container(
          width: double.infinity,
          padding: padding ?? EdgeInsets.all(AppConstants.spacing14),
          decoration: BoxDecoration(
            color: AppColors.darkBgCard,
            borderRadius: BorderRadius.circular(AppConstants.radiusXl),
            border: Border.all(color: AppColors.darkBorder),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: children,
          ),
        ),
      ],
    );
  }
}
