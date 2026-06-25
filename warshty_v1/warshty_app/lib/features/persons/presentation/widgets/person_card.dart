import 'package:flutter/material.dart';

import '../../../../core/presentation/widgets/app_card.dart';
import '../../../../core/presentation/widgets/avatar_widget.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_colors.dart';
import '../../data/models/person_model.dart';

/// PersonCard — بتظهر في قائمة الأشخاص
///
/// بتجمع بين:
///   - AvatarWidget (أحرف من اسمه)
///   - اسم + تلفون
///   - الرصيد الحقيقي (balance computed)
///   - عدد الشغلانات
class PersonCard extends StatelessWidget {
  final PersonModel person;
  final VoidCallback? onTap;

  const PersonCard({
    super.key,
    required this.person,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final balanceColor = person.balance >= 0 ? AppColors.success : AppColors.danger;

    return AppCard(
      onTap: onTap,
      child: Row(
        children: [
          AvatarWidget(name: person.name, size: 40),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(person.name, style: AppTextStyles.cardTitle(context), maxLines: 1, overflow: TextOverflow.ellipsis),
                if (person.phone != null && person.phone!.isNotEmpty)
                  Text(person.phone!, style: AppTextStyles.cardSub(context)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(person.balance.toStringAsFixed(0), style: AppTextStyles.cardAmount(context).copyWith(color: balanceColor)),
              const SizedBox(height: 4),
              Text('${person.jobsCount} شغلانات', style: AppTextStyles.cardSub(context)),
            ],
          ),
        ],
      ),
    );
  }
}
