import 'package:flutter/material.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/enums/category_type.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../data/models/category_model.dart';

class CategoryCard extends StatelessWidget {
  final CategoryModel category;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;

  const CategoryCard({
    super.key,
    required this.category,
    this.onTap,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final typeColor = _typeColor(category.type);

    return Container(
      decoration: BoxDecoration(
        color: context.bgCard,
        borderRadius: BorderRadius.circular(AppConstants.radiusXl),
        border: Border.all(color: context.borderColor),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppConstants.radiusXl),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: AppConstants.spacing16,
              vertical: AppConstants.spacing14,
            ),
            child: Row(
              children: [
                Container(
                  width: 4,
                  height: 32,
                  decoration: BoxDecoration(
                    color: typeColor,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                SizedBox(width: AppConstants.spacing12),
                Expanded(
                  child: Text(
                    category.name,
                    style: AppTextStyles.cardTitle(context),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: typeColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(AppConstants.radiusChip),
                  ),
                  child: Text(
                    category.type.displayName,
                    style: AppTextStyles.categoryChip(context).copyWith(
                      color: typeColor,
                      fontSize: 11,
                    ),
                  ),
                ),
                if (onDelete != null) ...[
                  SizedBox(width: AppConstants.spacing8),
                  InkWell(
                    onTap: onDelete,
                    borderRadius: BorderRadius.circular(AppConstants.radiusSm),
                    child: Padding(
                      padding: EdgeInsets.all(AppConstants.spacing4),
                      child: Icon(Icons.delete_outline, size: AppConstants.iconMd, color: AppColors.danger),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _typeColor(CategoryType type) {
    switch (type) {
      case CategoryType.expense:
        return AppColors.danger;
      case CategoryType.income:
        return AppColors.success;
      case CategoryType.labor:
        return AppColors.info;
      case CategoryType.cost:
        return AppColors.warning;
    }
  }
}
