import 'package:flutter/material.dart';

import '../../theme/app_text_styles.dart';

class SectionTitle extends StatelessWidget {
  final String title;
  final Widget? trailing;

  const SectionTitle({
    super.key,
    required this.title,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        children: [
          Text(title, style: AppTextStyles.sectionTitle(context)),
          const Spacer(),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}
