import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/theme_cubit.dart';
import '../../data/repositories/job_repository_impl.dart';
import '../../data/repositories/treasury_repository_impl.dart';
import '../../data/repositories/category_repository_impl.dart';
import '../../domain/entities/transaction.dart';
import '../cubits/jobs/jobs_cubit.dart';
import '../cubit/dashboard_cubit/dashboard_cubit.dart';
import '../cubit/treasury_cubit/treasury_cubit.dart';
import '../cubit/report_cubit/report_cubit.dart';
import '../widgets/app_widgets.dart';
import '../screens/dashboard/dashboard_screen.dart';
import '../screens/jobs/jobs_screen.dart';
import '../screens/jobs/create_job_screen.dart';
import '../screens/treasury/treasury_screen.dart';
import '../screens/reports/reports_screen.dart';
import '../screens/archive/archive_screen.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;
  String _workshopFilter = 'all';

  final _jobRepo = JobRepositorySQLite();
  final _treasuryRepo = TreasuryRepositorySQLite();
  final _catRepo = CategoryRepositorySQLite();
  late final JobsCubit _jobsCubit;
  late final DashboardCubit _dashboardCubit;
  late final TreasuryCubit _treasuryCubit;
  late final ReportCubit _reportCubit;

  @override
  void initState() {
    super.initState();
    _jobsCubit = JobsCubit(_jobRepo);
    _dashboardCubit = DashboardCubit(_jobRepo, _treasuryRepo);
    _treasuryCubit = TreasuryCubit(_treasuryRepo, _catRepo);
    _reportCubit = ReportCubit(_jobRepo, _treasuryRepo, _catRepo);
  }

  void _showAddTransactionDialog(BuildContext context) {
    final typeCtrl = ValueNotifier<String>('expense');
    final descCtrl = TextEditingController();
    final amtCtrl = TextEditingController();
    final catCtrl = TextEditingController(text: 'cat_misc_exp');
    final catNames = {
      'expense': ['cat_elec', 'cat_water', 'cat_rent', 'cat_salary', 'cat_labor', 'cat_transport', 'cat_maint', 'cat_materials', 'cat_admin', 'cat_misc_exp'],
      'income': ['cat_deposit', 'cat_payment', 'cat_sale', 'cat_misc_inc'],
    };
    final catLabels = <String, String>{
      'cat_elec': 'كهرباء', 'cat_water': 'مياه', 'cat_rent': 'إيجار',
      'cat_salary': 'رواتب', 'cat_labor': 'مصنعيات', 'cat_transport': 'نقل',
      'cat_maint': 'صيانة', 'cat_materials': 'خامات', 'cat_admin': 'مصروف إداري',
      'cat_misc_exp': 'مصروف متنوع', 'cat_deposit': 'عربون عميل',
      'cat_payment': 'دفعة من عميل', 'cat_sale': 'إيراد بيع', 'cat_misc_inc': 'إيراد متنوع',
    };

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('إضافة معاملة'),
        content: StatefulBuilder(
          builder: (ctx, setDialogState) => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  _txTypeBtn(ctx, typeCtrl, 'expense', 'صادر', setDialogState, catCtrl),
                  const SizedBox(width: 8),
                  _txTypeBtn(ctx, typeCtrl, 'income', 'وارد', setDialogState, catCtrl),
                ],
              ),
              const SizedBox(height: 12),
              TextField(controller: descCtrl, decoration: const InputDecoration(hintText: 'الوصف'), textDirection: TextDirection.rtl),
              const SizedBox(height: 8),
              TextField(controller: amtCtrl, decoration: const InputDecoration(hintText: 'المبلغ'), keyboardType: TextInputType.number),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: catCtrl.text,
                items: catNames[typeCtrl.value]!.map((id) => DropdownMenuItem(value: id, child: Text(catLabels[id] ?? id))).toList(),
                onChanged: (v) => catCtrl.text = v ?? catCtrl.text,
                decoration: InputDecoration(
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('إلغاء')),
          ElevatedButton(
            onPressed: () async {
              if (descCtrl.text.isEmpty || amtCtrl.text.isEmpty) return;
              await _treasuryCubit.addTransaction(
                Transaction(
                  type: typeCtrl.value,
                  date: DateTime.now().toIso8601String(),
                  amount: double.parse(amtCtrl.text),
                  description: descCtrl.text,
                  categoryId: catCtrl.text,
                  workshopId: _workshopFilter,
                  jobId: null,
                ),
              );
              if (ctx.mounted) Navigator.pop(ctx);
            },
            child: const Text('إضافة'),
          ),
        ],
      ),
    );
  }

  Widget _txTypeBtn(BuildContext ctx, ValueNotifier<String> typeCtrl, String value, String label, StateSetter setDialogState, TextEditingController catCtrl) {
    return Expanded(
      child: GestureDetector(
        onTap: () {
          typeCtrl.value = value;
          catCtrl.text = value == 'expense' ? 'cat_misc_exp' : 'cat_deposit';
          setDialogState(() {});
        },
        child: ValueListenableBuilder<String>(
          valueListenable: typeCtrl,
          builder: (_, v, __) {
            final isActive = v == value;
            return Container(
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: isActive ? (value == 'income' ? Colors.green : Colors.red) : Colors.grey[800],
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(label, textAlign: TextAlign.center,
                  style: TextStyle(fontWeight: FontWeight.w700, color: isActive ? Colors.white : Colors.grey[400])),
            );
          },
        ),
      ),
    );
  }

  @override
  void dispose() {
    _jobsCubit.close();
    _dashboardCubit.close();
    _treasuryCubit.close();
    _reportCubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: _jobsCubit),
        BlocProvider.value(value: _dashboardCubit),
        BlocProvider.value(value: _treasuryCubit),
        BlocProvider.value(value: _reportCubit),
      ],
      child: Scaffold(
        appBar: AppBar(
          title: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                      colors: [Color(0xFFa0522d), Color(0xFF00d4aa)]),
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                        color: const Color(0xFFa0522d).withValues(alpha: 0.4),
                        blurRadius: 12)
                  ],
                ),
                child: const Icon(Icons.construction_rounded,
                    color: Colors.white, size: 20),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('ورش نجارة م. مصطفى',
                      style: TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 16,
                          color: c.textPrimary)),
                  Text('ERP Pro',
                      style: TextStyle(
                          fontSize: 9,
                          color: c.warning,
                          fontWeight: FontWeight.w800)),
                ],
              ),
            ],
          ),
          actions: [
            IconButton(
              icon: Icon(
                context.read<ThemeCubit>().isDark
                    ? Icons.light_mode_outlined
                    : Icons.dark_mode_outlined,
                color: c.textSecondary,
              ),
              onPressed: () {
                context.read<ThemeCubit>().toggleTheme();
              },
            ),
            IconButton(
              icon: Icon(Icons.notifications_outlined, color: c.textSecondary),
              onPressed: () {},
            ),
          ],
        ),
        body: Column(
          children: [
            if (_currentIndex == 0 || _currentIndex == 1 || _currentIndex == 3)
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: WorkshopToggle(
                  current: _workshopFilter,
                  onChanged: (v) {
                    setState(() => _workshopFilter = v);
                    _jobsCubit.setWorkshopFilter(v);
                    _dashboardCubit.load(workshop: v);
                    _treasuryCubit.setWorkshop(v);
                    _reportCubit.setWorkshop(v);
                  },
                ),
              ),
            Expanded(
              child: IndexedStack(
                index: _currentIndex,
                children: _screens,
              ),
            ),
          ],
        ),
        bottomNavigationBar: Container(
          decoration: BoxDecoration(
            border: Border(top: BorderSide(color: c.border)),
          ),
          child: BottomNavigationBar(
            currentIndex: _currentIndex,
            onTap: (index) {
              setState(() => _currentIndex = index);
              if (index == 0) _dashboardCubit.load(workshop: _workshopFilter == 'all' ? null : _workshopFilter);
              if (index == 2) _treasuryCubit.load();
              if (index == 3) _reportCubit.load();
            },
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.home_outlined),
                activeIcon: Icon(Icons.home),
                label: 'الرئيسية',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.work_outline),
                activeIcon: Icon(Icons.work),
                label: 'الشغلانات',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.account_balance_wallet_outlined),
                activeIcon: Icon(Icons.account_balance_wallet),
                label: 'الخزنة',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.bar_chart_outlined),
                activeIcon: Icon(Icons.bar_chart),
                label: 'التقارير',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.archive_outlined),
                activeIcon: Icon(Icons.archive),
                label: 'الأرشيف',
              ),
            ],
          ),
        ),
        floatingActionButton: _currentIndex == 0 || _currentIndex == 1 || _currentIndex == 2
            ? FloatingActionButton(
                onPressed: () {
                  if (_currentIndex == 1) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => BlocProvider.value(
                          value: _jobsCubit,
                          child: const CreateJobScreen(),
                        ),
                      ),
                    );
                  } else if (_currentIndex == 2) {
                    _showAddTransactionDialog(context);
                  }
                },
                backgroundColor: c.accent,
                child: const Icon(Icons.add, color: Colors.black),
              )
            : null,
      ),
    );
  }

  List<Widget> get _screens => [
        const DashboardScreen(),
        const JobsScreen(),
        const TreasuryScreen(),
        const ReportsScreen(),
        const ArchiveScreen(),
      ];
}
