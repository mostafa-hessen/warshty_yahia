import 'package:intl/intl.dart';

/// تنسيق العملة والتواريخ لتطبيق ورشتي
abstract final class AppFormatters {
  // ── Currency ───────────────────────────────────────────────

  /// تنسيق العملة بالجنيه المصري — "١٬٥٠٠ ج.م"
  /// مأخوذ من دالة fmt() في الـ JavaScript
  static final NumberFormat _currencyFormat = NumberFormat.currency(
    locale: 'ar_EG',
    symbol: 'ج.م',
    decimalDigits: 0,
  );

  /// تنسيق مبلغ بالعملة: 15000 → "١٥٬٠٠٠ ج.م"
  static String currency(double amount) {
    return _currencyFormat.format(amount);
  }

  /// تنسيق مبلغ بدون عملة: 15000 → "١٥٬٠٠٠"
  static final NumberFormat _numberFormat = NumberFormat('#,##0', 'ar_EG');

  static String formatNumber(double amount) {
    return _numberFormat.format(amount);
  }

  // ── Date Formatting ────────────────────────────────────────

  /// تنسيق تاريخ عربي — "٢٠ يونيو ٢٠٢٦"
  /// يقبل ISO date string (yyyy-MM-dd)
  static String formatDate(String? isoDate) {
    if (isoDate == null || isoDate.isEmpty) return '—';
    try {
      final date = DateTime.parse(isoDate);
      return DateFormat('d MMMM yyyy', 'ar').format(date);
    } catch (_) {
      return isoDate;
    }
  }

  /// تنسيق تاريخ + وقت — "٢٠ يونيو ٢٠٢٦ ٢:٣٠ م"
  static String formatDateTime(String? isoDateTime) {
    if (isoDateTime == null || isoDateTime.isEmpty) return '—';
    try {
      final date = DateTime.parse(isoDateTime);
      return DateFormat('d MMMM yyyy h:mm a', 'ar').format(date);
    } catch (_) {
      return isoDateTime;
    }
  }

  /// تنسيق التاريخ المختصر — "20/06/2026"
  static String formatDateShort(String? isoDate) {
    if (isoDate == null || isoDate.isEmpty) return '—';
    try {
      final date = DateTime.parse(isoDate);
      return DateFormat('dd/MM/yyyy').format(date);
    } catch (_) {
      return isoDate;
    }
  }

  /// تاريخ اليوم بصيغة ISO — "2026-06-20"
  static String today() {
    return DateTime.now().toIso8601String().split('T').first;
  }

  /// تاريخ ووقت الآن بصيغة ISO
  static String now() {
    return DateTime.now().toIso8601String();
  }
}
