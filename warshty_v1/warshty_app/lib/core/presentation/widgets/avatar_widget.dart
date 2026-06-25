import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';

class AvatarWidget extends StatelessWidget {
  final String name;
  final double size;

  const AvatarWidget({
    super.key,
    required this.name,
    this.size = 36,
  });

  @override
  Widget build(BuildContext context) {
    final colors = _getColors(context);
    final initials = _getInitials(name);
    final colorIndex = name.hashCode % colors.length;
    final bgColor = colors[colorIndex];

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: bgColor.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(size / 2),
        border: Border.all(color: bgColor.withValues(alpha: 0.4)),
      ),
      alignment: Alignment.center,
      child: Text(
        initials,
        style: AppTextStyles.badge(context).copyWith(
          color: bgColor,
          fontSize: size * 0.35,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  List<Color> _getColors(BuildContext context) => [
    AppColors.success,
    AppColors.info,
    AppColors.purple,
    AppColors.warning,
    AppColors.danger,
    context.accentColor,
  ];

  String _getInitials(String name) {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
    }
    return name.isNotEmpty ? name[0].toUpperCase() : '?';
  }
}
