import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('الرئيسية')),
      body: Padding(
        padding: EdgeInsets.all(AppConstants.spacing16),
        child: Column(
          children: [
            _navCard(
              context,
              icon: Icons.category_outlined,
              label: 'التصنيفات',
              onTap: () => context.push('/categories'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _navCard(BuildContext context, {required IconData icon, required String label, required VoidCallback onTap}) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.darkBgCard,
        borderRadius: BorderRadius.circular(AppConstants.radiusXl),
        border: Border.all(color: AppColors.darkBorder),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppConstants.radiusXl),
          child: Padding(
            padding: EdgeInsets.all(AppConstants.spacing16),
            child: Row(
              children: [
                Icon(icon, color: AppColors.darkAccent, size: AppConstants.iconXl),
                SizedBox(width: AppConstants.spacing12),
                Text(label, style: AppTextStyles.sectionTitle(context)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
