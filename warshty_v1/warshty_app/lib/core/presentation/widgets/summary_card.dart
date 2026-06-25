import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../constants/app_constants.dart';

class SummaryRowData {
  final String label;
  final String value;
  final Color? valueColor;

  const SummaryRowData({
    required this.label,
    required this.value,
    this.valueColor,
  });
}

class SummaryCard extends StatelessWidget {
  final List<SummaryRowData> rows;
  final String? totalLabel;
  final String? totalValue;
  final Color? totalColor;
  final Color? borderColor;

  const SummaryCard({
    super.key,
    required this.rows,
    this.totalLabel,
    this.totalValue,
    this.totalColor,
    this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(AppConstants.spacing14),
      decoration: BoxDecoration(
        color: context.bgCard,
        borderRadius: BorderRadius.circular(AppConstants.radiusXl),
        border: Border.all(color: borderColor ?? context.borderColor),
      ),
      child: Column(
        children: [
          ...rows.asMap().entries.map((entry) => _buildRow(context,
            entry.value.label,
            entry.value.value,
            entry.value.valueColor,
            isLast: entry.key == rows.length - 1 && totalLabel == null,
          )),
          if (totalLabel != null && totalValue != null) ...[
            Divider(height: 20, color: context.borderColor),
            _buildTotalRow(context, totalLabel!, totalValue!, totalColor),
          ],
        ],
      ),
    );
  }

  Widget _buildRow(BuildContext context, String label, String value, Color? color, {bool isLast = false}) {
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 8),
      child: Row(
        children: [
          Text(label, style: AppTextStyles.summaryLabel(context)),
          const Spacer(),
          Text(value, style: AppTextStyles.summaryValue(context).copyWith(color: color)),
        ],
      ),
    );
  }

  Widget _buildTotalRow(BuildContext context, String label, String value, Color? color) {
    return Row(
      children: [
        Text(label, style: AppTextStyles.summaryTotal(context)),
        const Spacer(),
        Text(value, style: AppTextStyles.summaryTotal(context).copyWith(color: color ?? context.accentColor)),
      ],
    );
  }
}
