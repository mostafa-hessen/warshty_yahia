import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

class BalanceCard extends StatelessWidget {
  final double balance;
  final double totalIncome;
  final double totalExpense;

  const BalanceCard({
    super.key,
    this.balance = 0,
    this.totalIncome = 0,
    this.totalExpense = 0,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: c.accent),
        gradient: const LinearGradient(
          colors: [Color(0x2600d4aa), Color(0x1A0066ff)],
        ),
      ),
      child: Column(
        children: [
          Text('💰 رصيد الخزنة الحالي',
              style: TextStyle(color: c.textSecondary, fontSize: 14)),
          const SizedBox(height: 8),
          Text(formatAmount(balance),
              style: TextStyle(
                  color: c.accent, fontSize: 36, fontWeight: FontWeight.w900)),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('↑ وارد: ${formatAmount(totalIncome)}',
                  style: TextStyle(
                      color: c.success,
                      fontWeight: FontWeight.bold,
                      fontSize: 13)),
              const SizedBox(width: 16),
              Text('↓ صادر: ${formatAmount(totalExpense)}',
                  style: TextStyle(
                      color: c.danger,
                      fontWeight: FontWeight.bold,
                      fontSize: 13)),
            ],
          ),
        ],
      ),
    );
  }

  static String formatAmount(double n) {
    return '${n.toInt().toString()} ج.م';
  }
}

class StatCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;

  const StatCard({
    super.key,
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: c.bgCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: c.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 12),
          Text(value,
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: c.textPrimary)),
          const SizedBox(height: 4),
          Text(label,
              style: TextStyle(
                  fontSize: 11, color: c.textSecondary)),
        ],
      ),
    );
  }
}

class EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle = '',
  });

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 60, horizontal: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 64, color: c.textMuted),
            const SizedBox(height: 16),
            Text(title,
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: c.textPrimary)),
            if (subtitle.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(subtitle,
                  style: TextStyle(fontSize: 14, color: c.textSecondary)),
            ],
          ],
        ),
      ),
    );
  }
}

class SectionTitle extends StatelessWidget {
  final String title;
  final String? actionText;
  final VoidCallback? onAction;

  const SectionTitle({
    super.key,
    required this.title,
    this.actionText,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title,
            style: TextStyle(
                fontSize: 16, fontWeight: FontWeight.w700, color: c.textPrimary)),
        if (actionText != null)
          GestureDetector(
            onTap: onAction,
            child: Text(actionText!,
                style: TextStyle(fontSize: 13, color: c.accent)),
          ),
      ],
    );
  }
}

class WorkshopToggle extends StatelessWidget {
  final String current;
  final ValueChanged<String> onChanged;

  const WorkshopToggle({
    super.key,
    required this.current,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Container(
      decoration: BoxDecoration(
        color: c.bgCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: c.border),
      ),
      padding: const EdgeInsets.all(4),
      child: Row(
        children: [
          _buildBtn(context, 'all', 'كل الورش'),
          _buildBtn(context, 'sila', 'ورشة سيلا'),
          _buildBtn(context, 'fayoum', 'ورشة الفيوم'),
        ],
      ),
    );
  }

  Widget _buildBtn(BuildContext context, String value, String label) {
    final c = context.colors;
    final isActive = current == value;
    return Expanded(
      child: GestureDetector(
        onTap: () => onChanged(value),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isActive ? c.accent : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: isActive ? c.bgPrimary : c.textSecondary,
            ),
          ),
        ),
      ),
    );
  }
}

class PeriodFilter extends StatelessWidget {
  final String current;
  final ValueChanged<String> onChanged;

  const PeriodFilter({
    super.key,
    required this.current,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final periods = [
      ('all', 'الكل'),
      ('today', 'اليوم'),
      ('week', 'أسبوع'),
      ('month', 'شهر'),
      ('year', 'سنة'),
    ];
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: periods.map((p) {
          final isActive = current == p.$1;
          return Padding(
            padding: const EdgeInsets.only(left: 6),
            child: GestureDetector(
              onTap: () => onChanged(p.$1),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: isActive ? c.accent : c.bgCard,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: c.border),
                ),
                child: Text(
                  p.$2,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: isActive ? c.bgPrimary : c.textSecondary,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class CashflowChart extends StatelessWidget {
  final List<double> incomeData;
  final List<double> expenseData;
  final List<String> labels;

  const CashflowChart({
    super.key,
    required this.incomeData,
    required this.expenseData,
    required this.labels,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final allValues = [...incomeData, ...expenseData];
    final maxVal = allValues
        .reduce((a, b) => a > b ? a : b)
        .clamp(1.0, double.infinity);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text('■ وارد', style: TextStyle(fontSize: 11, color: c.accent)),
            const SizedBox(width: 12),
            Text('■ مصروف', style: TextStyle(fontSize: 11, color: c.danger)),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 130,
          child: CustomPaint(
            painter: _BarChartPainter(
              incomeData: incomeData,
              expenseData: expenseData,
              labels: labels,
              maxVal: maxVal,
              accent: c.accent,
              danger: c.danger,
              textSecondary: c.textSecondary,
            ),
          ),
        ),
      ],
    );
  }
}

class _BarChartPainter extends CustomPainter {
  final List<double> incomeData;
  final List<double> expenseData;
  final List<String> labels;
  final double maxVal;
  final Color accent;
  final Color danger;
  final Color textSecondary;

  _BarChartPainter({
    required this.incomeData,
    required this.expenseData,
    required this.labels,
    required this.maxVal,
    required this.accent,
    required this.danger,
    required this.textSecondary,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final barAreaH = size.height - 18;
    final count = labels.length;
    if (count == 0) return;
    final groupW = size.width / count;

    for (int i = 0; i < count; i++) {
      final cx = groupW * i + groupW / 2;
      final incomeH = (incomeData[i] / maxVal) * barAreaH;
      final expenseH = (expenseData[i] / maxVal) * barAreaH;

      final ih = incomeH.clamp(1.0, barAreaH);
      final incomeRect = Rect.fromLTWH(
        cx - 9,
        barAreaH - ih,
        8,
        ih,
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(incomeRect, const Radius.circular(3)),
        Paint()..color = accent,
      );

      final eh = expenseH.clamp(1.0, barAreaH);
      final expenseRect = Rect.fromLTWH(
        cx + 1,
        barAreaH - eh,
        8,
        eh,
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(expenseRect, const Radius.circular(3)),
        Paint()..color = danger,
      );

      final tp = TextPainter(
        text: TextSpan(
          text: labels[i],
          style: TextStyle(color: textSecondary, fontSize: 9),
        ),
        textDirection: TextDirection.rtl,
      )..layout(maxWidth: groupW);
      tp.paint(canvas, Offset(cx - tp.width / 2, size.height - 16));
    }
  }

  @override
  bool shouldRepaint(_BarChartPainter old) =>
      old.incomeData != incomeData ||
      old.expenseData != expenseData ||
      old.labels != labels;
}
