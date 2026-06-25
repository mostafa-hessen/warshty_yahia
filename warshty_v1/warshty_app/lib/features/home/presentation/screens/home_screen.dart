import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/presentation/widgets/theme_toggle_button.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/formatters.dart';
import '../cubits/home_cubit.dart';
import '../cubits/home_state.dart';
import '../widgets/home_stat_card.dart';
import '../widgets/home_action_card.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<HomeCubit>()..load(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('ورشتي'),
          actions: [const ThemeToggleButton()],
        ),
        body: BlocBuilder<HomeCubit, HomeState>(
          builder: (context, state) {
            if (state is HomeLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state is HomeError) {
              return Center(
                child: Padding(
                  padding: EdgeInsets.all(AppConstants.spacing16),
                  child: Text(state.message, style: AppTextStyles.emptyText(context)),
                ),
              );
            }
            if (state is HomeLoaded) {
              return _buildDashboard(context, state);
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  Widget _buildDashboard(BuildContext context, HomeLoaded state) {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: EdgeInsets.all(AppConstants.spacing16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildDateHeader(context),
          SizedBox(height: AppConstants.spacing20),
          _buildStatsRow(context, state),
          SizedBox(height: AppConstants.spacing24),
          Text('الأقسام', style: AppTextStyles.sectionTitle(context)),
          SizedBox(height: AppConstants.spacing12),
          _buildActionsList(context),
          SizedBox(height: AppConstants.spacing20),
        ],
      ),
    );
  }

  Widget _buildDateHeader(BuildContext context) {
    final now = DateTime.now();
    final dayNames = ['الإثنين', 'الثلاثاء', 'الأربعاء', 'الخميس', 'الجمعة', 'السبت', 'الأحد'];
    final dayName = dayNames[now.weekday - 1];
    final dateStr = AppFormatters.formatDate(AppFormatters.today());
    return Text('$dayName, $dateStr', style: AppTextStyles.balanceLabel(context));
  }

  Widget _buildStatsRow(BuildContext context, HomeLoaded state) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: [
          HomeStatCard(
            icon: Icons.account_balance_rounded,
            label: 'الخزينة',
            value: AppFormatters.currency(state.treasuryBalance),
            accentColor: state.treasuryBalance >= 0 ? AppColors.success : AppColors.danger,
          ),
          SizedBox(width: AppConstants.spacing10),
          HomeStatCard(
            icon: Icons.construction_rounded,
            label: 'قيد التنفيذ',
            value: AppFormatters.formatNumber(state.jobsInProgress.toDouble()),
            accentColor: context.accentColor,
          ),
          SizedBox(width: AppConstants.spacing10),
          HomeStatCard(
            icon: Icons.check_circle_rounded,
            label: 'مكتملة',
            value: AppFormatters.formatNumber(state.jobsCompleted.toDouble()),
            accentColor: AppColors.success,
          ),
          SizedBox(width: AppConstants.spacing10),
          HomeStatCard(
            icon: Icons.people_rounded,
            label: 'الأشخاص',
            value: AppFormatters.formatNumber(state.totalPersons.toDouble()),
            accentColor: AppColors.info,
          ),
        ],
      ),
    );
  }

  Widget _buildActionsList(BuildContext context) {
    return Column(
      children: [
        HomeActionCard(
          icon: Icons.people_rounded,
          label: 'الأشخاص',
          onTap: () {
            final shell = StatefulNavigationShell.of(context);
            shell.goBranch(1);
          },
        ),
        SizedBox(height: AppConstants.spacing10),
        HomeActionCard(
          icon: Icons.construction_rounded,
          label: 'الشغلانات',
          onTap: () {
            final shell = StatefulNavigationShell.of(context);
            shell.goBranch(2);
          },
        ),
        SizedBox(height: AppConstants.spacing10),
        HomeActionCard(
          icon: Icons.account_balance_rounded,
          label: 'الخزينة',
          onTap: () {
            final shell = StatefulNavigationShell.of(context);
            shell.goBranch(3);
          },
        ),
        SizedBox(height: AppConstants.spacing10),
        HomeActionCard(
          icon: Icons.bar_chart_rounded,
          label: 'التقارير',
          onTap: () {
            final shell = StatefulNavigationShell.of(context);
            shell.goBranch(4);
          },
        ),
        SizedBox(height: AppConstants.spacing10),
        HomeActionCard(
          icon: Icons.category_rounded,
          label: 'التصنيفات',
          onTap: () => context.push('/categories'),
        ),
      ],
    );
  }
}
