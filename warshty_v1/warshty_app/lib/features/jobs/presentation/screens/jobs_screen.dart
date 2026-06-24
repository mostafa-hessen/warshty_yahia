import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/presentation/widgets/app_modal.dart';
import '../../../../core/presentation/widgets/empty_state.dart';
import '../../../../core/presentation/widgets/loading_state.dart';
import '../../../../core/presentation/widgets/search_bar.dart';
import '../../../../core/theme/app_colors.dart';

import '../../../../core/utils/formatters.dart';
import '../../../workshop/data/datasources/workshop_local_datasource.dart';
import '../../../workshop/data/models/workshop_model.dart';
import '../../data/models/job_model.dart';
import '../../data/models/job_payment_model.dart';
import '../cubits/job_cubit.dart';
import '../cubits/job_state.dart';
import '../widgets/add_job_form.dart';
import '../widgets/job_card.dart';

class JobsScreen extends StatefulWidget {
  const JobsScreen({super.key});

  @override
  State<JobsScreen> createState() => _JobsScreenState();
}

class _JobsScreenState extends State<JobsScreen> {
  final _searchCtrl = TextEditingController();
  int? _filterWorkshopId;
  String? _filterStatus;
  String _searchQuery = '';
  List<WorkshopModel> _workshops = [];
  bool _loadingWorkshops = true;

  @override
  void initState() {
    super.initState();
    _loadWorkshops();
  }

  Future<void> _loadWorkshops() async {
    try {
      final ds = sl<WorkshopLocalDataSource>();
      final workshops = await ds.getAll();
      if (mounted) {
        setState(() {
          _workshops = workshops;
          _loadingWorkshops = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loadingWorkshops = false);
    }
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  List<JobModel> _filterJobs(List<JobModel> jobs) {
    return jobs.where((j) {
      if (_filterWorkshopId != null && j.workshopId != _filterWorkshopId) return false;
      if (_searchQuery.isNotEmpty) {
        final q = _searchQuery.toLowerCase();
        if (!j.name.toLowerCase().contains(q) &&
            !(j.personName?.toLowerCase().contains(q) ?? false)) { return false; }
      }
      if (_filterStatus != null) {
        if (_filterStatus == 'قيد' && j.status != 'قيد') return false;
        if (_filterStatus == 'مكتملة' && j.status != 'مكتملة') return false;
        if (_filterStatus == 'باقي' && j.remaining <= 0) return false;
      }
      return true;
    }).toList();
  }

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
                  SnackBar(content: Text(state.message), backgroundColor: AppColors.danger, behavior: SnackBarBehavior.floating),
                );
              }
            },
            builder: (ctx, state) {
              if (state is JobLoading) return const LoadingState();
              if (state is JobError) return Center(child: Text(state.message));
              if (state is JobLoaded) {
                final filtered = _filterJobs(state.jobs);
                return Column(
                  children: [
                    _buildFilters(context),
                    if (filtered.isEmpty)
                      Expanded(
                        child: EmptyState(
                          icon: Icons.construction_outlined,
                          title: _hasActiveFilters ? 'لا توجد نتائج' : 'لا توجد شغلانات',
                          subtitle: _hasActiveFilters ? 'حاول تغيير معايير البحث' : 'أضف أول شغلانة من ورشة معينة',
                        ),
                      )
                    else
                      Expanded(
                        child: ListView.separated(
                          padding: EdgeInsets.all(AppConstants.spacing16),
                          itemCount: filtered.length,
                          separatorBuilder: (_, __) => SizedBox(height: AppConstants.spacing10),
                          itemBuilder: (_, i) => JobCard(
                            key: ValueKey(filtered[i].id),
                            job: filtered[i],
                            onTap: () async {
                              await context.push('/job/${filtered[i].id}');
                              if (context.mounted) context.read<JobCubit>().load();
                            },
                          ),
                        ),
                      ),
                  ],
                );
              }
              return const SizedBox.shrink();
            },
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () => _showAddModal(context),
            backgroundColor: AppColors.darkAccent,
            child: const Icon(Icons.add, color: Colors.black),
          ),
        ),
      ),
    );
  }

  bool get _hasActiveFilters => _filterWorkshopId != null || _searchQuery.isNotEmpty || _filterStatus != null;

  Widget _buildFilters(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(AppConstants.spacing16, AppConstants.spacing12, AppConstants.spacing16, 0),
      child: Column(
        children: [
          AppSearchBar(
            controller: _searchCtrl,
            hintText: 'ابحث باسم الشغلانة أو العميل...',
            onChanged: (v) => setState(() => _searchQuery = v),
          ),
          SizedBox(height: AppConstants.spacing10),
          if (!_loadingWorkshops && _workshops.isNotEmpty)
            SizedBox(
              height: 34,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: _workshops.length + 1,
                separatorBuilder: (_, __) => SizedBox(width: AppConstants.spacing6),
                itemBuilder: (_, i) {
                  if (i == 0) {
                    return _filterChip('الكل', _filterWorkshopId == null, () => setState(() => _filterWorkshopId = null));
                  }
                  final w = _workshops[i - 1];
                  return _filterChip(w.name, _filterWorkshopId == w.id, () => setState(() => _filterWorkshopId = w.id));
                },
              ),
            ),
          SizedBox(height: AppConstants.spacing10),
          SizedBox(
            height: 34,
            child: Row(
              children: [
                _filterChip('الكل', _filterStatus == null, () => setState(() => _filterStatus = null)),
                SizedBox(width: AppConstants.spacing6),
                _filterChip('قيد التصنيع', _filterStatus == 'قيد', () => setState(() => _filterStatus = 'قيد')),
                SizedBox(width: AppConstants.spacing6),
                _filterChip('مكتملة', _filterStatus == 'مكتملة', () => setState(() => _filterStatus = 'مكتملة')),
                SizedBox(width: AppConstants.spacing6),
                _filterChip('باقي تحصيل', _filterStatus == 'باقي', () => setState(() => _filterStatus = 'باقي')),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _filterChip(String label, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.darkAccent.withValues(alpha: 0.15) : AppColors.darkBgCard,
          borderRadius: BorderRadius.circular(AppConstants.radiusChip),
          border: Border.all(color: isSelected ? AppColors.darkAccent : AppColors.darkBorder),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            color: isSelected ? AppColors.darkAccent : AppColors.darkTextSecondary,
          ),
        ),
      ),
    );
  }

  void _showAddModal(BuildContext context) {
    AppModal.show(
      context,
      AppModal(
        title: 'إضافة شغلانة',
        child: AddJobForm(
          onSubmit: (job, paidAmount) async {
            try {
              final cubit = context.read<JobCubit>();
              final jobId = await cubit.add(job);

              if (paidAmount > 0 && jobId > 0) {
                await cubit.addPayment(JobPaymentModel(
                  jobId: jobId,
                  partialId: 0,
                  amount: paidAmount,
                  date: AppFormatters.today(),
                ));
              }

              if (context.mounted) Navigator.pop(context);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('تمت الإضافة'), backgroundColor: AppColors.success, behavior: SnackBarBehavior.floating),
                );
              }
            } catch (e) {
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('خطأ: $e'), backgroundColor: AppColors.danger, behavior: SnackBarBehavior.floating),
                );
              }
            }
          },
        ),
      ),
    );
  }
}
