import 'package:flutter/material.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/presentation/widgets/action_button.dart';
import '../../../../core/theme/app_colors.dart';

class PersonBottomBar extends StatelessWidget {
  final VoidCallback? onTake;
  final VoidCallback? onGive;

  const PersonBottomBar({
    super.key,
    required this.onTake,
    required this.onGive,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(AppConstants.spacing16),
      decoration: BoxDecoration(
        color: context.bgSecondary,
        border: Border(top: BorderSide(color: context.borderColor)),
      ),
      child: Row(
        children: [
          Expanded(
            child: ActionButton(
              label: '+ أخذت',
              type: ActionButtonType.green,
              onPressed: onTake ?? () {},
            ),
          ),
          SizedBox(width: AppConstants.spacing12),
          Expanded(
            child: ActionButton(
              label: '- عطيت',
              type: ActionButtonType.red,
              onPressed: onGive ?? () {},
            ),
          ),
        ],
      ),
    );
  }
}
