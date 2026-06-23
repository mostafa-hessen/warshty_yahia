import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/presentation/widgets/empty_state.dart';
import '../../../../core/presentation/widgets/loading_state.dart';
import '../../../../core/theme/app_colors.dart';
import '../cubits/job_cubit.dart';
import '../cubits/job_state.dart';
import '../widgets/job_card.dart';

class JobsScreen extends StatelessWidget {
  const JobsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<JobCubit>()..load(),
      child: Builder(
        builder: (context) => Scaffold(
          appBar: AppBar(title: const Text('الشغلانات')),
          body: BlocConsumer<JobCubit, JobState>(
            listener: (ctx, state) {
              if (state is JobError) {
                ScaffoldMessenger.of(ctx).showSnackBar(
                  SnackBar(
                    content: Text(state.message),
                    backgroundColor: AppColors.danger,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            },
            builder: (ctx, state) {
              if (state is JobLoading) return const LoadingState();
              if (state is JobError) return Center(child: Text(state.message));
              if (state is JobLoaded) {
                if (state.jobs.isEmpty) {
                  return const EmptyState(
                    icon: Icons.construction_outlined,
                    title: 'لا توجد شغلانات',
                    subtitle: 'أضف أول شغلانة من ورشة معينة',
                  );
                }
                return ListView.separated(
                  padding: EdgeInsets.all(AppConstants.spacing16),
                  itemCount: state.jobs.length,
                  separatorBuilder: (_, __) => SizedBox(height: AppConstants.spacing10),
                  itemBuilder: (_, i) => JobCard(
                    job: state.jobs[i],
                    onTap: () => context.push('/job/${state.jobs[i].id}'),
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ),
      ),
    );
  }
}
