import 'package:flutter/material.dart';

import '../../theme/app_text_styles.dart';

class DetailRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;
  final Widget? trailing;

  const DetailRow({
    super.key,
    required this.label,
    required this.value,
    this.valueColor,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Text(label, style: AppTextStyles.detailLabel(context)),
          const Spacer(),
          if (trailing != null) ...[
            trailing!,
            const SizedBox(width: 8),
          ],
          Text(value, style: AppTextStyles.detailValue(context).copyWith(color: valueColor)),
        ],
      ),
    );
  }
}
