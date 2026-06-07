import 'package:intl/intl.dart';

class NumberUtils {
  static final _fmt = NumberFormat('#,##0', 'ar_EG');

  static String format(num n) {
    return _fmt.format(n);
  }

  static String formatWithCurrency(num n) {
    return '${_fmt.format(n)} ج.م';
  }
}
