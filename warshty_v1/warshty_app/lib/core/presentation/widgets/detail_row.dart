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
          Flexible(child: Text(label, style: AppTextStyles.detailLabel(context), overflow: TextOverflow.ellipsis)),
          const Spacer(),
          if (trailing != null) ...[
            trailing!,
            const SizedBox(width: 8),
          ],
          Flexible(child: Text(value, style: AppTextStyles.detailValue(context).copyWith(color: valueColor), overflow: TextOverflow.ellipsis)),
        ],
      ),
    );
  }
}
