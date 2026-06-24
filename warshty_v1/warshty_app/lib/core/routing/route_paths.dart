abstract final class RoutePaths {
  static const home = '/home';
  static const persons = '/persons';
  static const jobs = '/jobs';
  static const categories = '/categories';
  static const treasury = '/treasury';
  static const reports = '/reports';

  // للمسارات الديناميكية (لما نضيفها بعدين)
  static String workshop(int id) => '/workshop/$id';
  static String person(int id) => '/person/$id';
  static String job(int id) => '/job/$id';
  static String treasuryTransaction(int id) => '/treasury/transaction/$id';
}
