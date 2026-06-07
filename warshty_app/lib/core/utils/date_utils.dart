class DateUtilsApp {
  static String today() {
    return DateTime.now().toIso8601String().split('T')[0];
  }

  static bool isInPeriod(String dateStr, String period, {String? from, String? to}) {
    if (period == 'all') return true;
    final d = DateTime.parse(dateStr);
    final now = DateTime.now();

    switch (period) {
      case 'today':
        return d.year == now.year && d.month == now.month && d.day == now.day;
      case 'week':
        final weekAgo = now.subtract(const Duration(days: 7));
        return d.isAfter(weekAgo) || d.isAtSameMomentAs(weekAgo);
      case 'month':
        return d.year == now.year && d.month == now.month;
      case 'year':
        return d.year == now.year;
      case 'custom':
        if (from != null && d.isBefore(DateTime.parse(from))) return false;
        if (to != null && d.isAfter(DateTime.parse(to))) return false;
        return true;
      default:
        return true;
    }
  }
}
