import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/theme/app_theme.dart';
import '../../../domain/entities/job.dart';
import '../../cubits/jobs/jobs_cubit.dart';
import '../../widgets/app_widgets.dart';
import 'job_detail_screen.dart';

class JobsScreen extends StatefulWidget {
  const JobsScreen({super.key});

  @override
  State<JobsScreen> createState() => _JobsScreenState();
}

class _JobsScreenState extends State<JobsScreen> {
  final _searchController = TextEditingController();
  String _statusFilter = 'active';

  @override
  void initState() {
    super.initState();
    context.read<JobsCubit>().setStatusFilter(_statusFilter);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 4),
          child: TextField(
            controller: _searchController,
            onChanged: (v) => context.read<JobsCubit>().setSearchQuery(v),
            style: TextStyle(color: c.textPrimary),
            decoration: InputDecoration(
              hintText: 'بحث ...',
              prefixIcon: Icon(Icons.search, color: c.textMuted),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: Icon(Icons.clear, color: c.textMuted),
                      onPressed: () {
                        _searchController.clear();
                        context.read<JobsCubit>().setSearchQuery('');
                      },
                    )
                  : null,
              contentPadding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
          child: Row(
            children: [
              _statusChip('active', 'نشط'),
              const SizedBox(width: 8),
              _statusChip('completed', 'مكتمل'),
              const SizedBox(width: 8),
              _statusChip('archived', 'أرشيف'),
            ],
          ),
        ),
        Expanded(
          child: BlocBuilder<JobsCubit, JobsState>(
            builder: (context, state) {
              if (state is JobsLoading) {
                return const Center(child: CircularProgressIndicator());
              }
              if (state is JobsError) {
                return Center(
                  child: Text(state.message, style: TextStyle(color: c.danger)),
                );
              }
              if (state is JobsLoaded) {
                if (state.jobs.isEmpty) {
                  return EmptyState(
                    icon: Icons.inbox_outlined,
                    title: 'لا توجد شغلانات',
                    subtitle: 'اضغط + لإضافة شغلانة جديدة',
                  );
                }
                return ListView.builder(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 80),
                  itemCount: state.jobs.length,
                  itemBuilder: (_, i) => _JobCard(job: state.jobs[i]),
                );
              }
              return const SizedBox();
            },
          ),
        ),
      ],
    );
  }

  Widget _statusChip(String value, String label) {
    final c = context.colors;
    final isActive = _statusFilter == value;
    return GestureDetector(
      onTap: () {
        setState(() => _statusFilter = value);
        context.read<JobsCubit>().setStatusFilter(value);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: isActive ? c.accent : c.bgCard,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: isActive ? c.accent : c.border),
        ),
        child: Text(label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: isActive ? c.bgPrimary : c.textSecondary,
            )),
      ),
    );
  }
}

class _JobCard extends StatelessWidget {
  final Job job;
  const _JobCard({required this.job});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final map = {
      'active': ('نشط', c.accent),
      'completed': ('مكتمل', c.success),
      'archived': ('أرشيف', c.textMuted),
    };
    final (statusLabel, statusColor) = map[job.status] ?? ('نشط', c.accent);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: c.bgCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: c.border),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => BlocProvider.value(
                value: context.read<JobsCubit>(),
                child: JobDetailScreen(jobId: job.id!),
              ),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.construction_rounded, size: 18, color: c.accent),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(job.name,
                          style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: c.textPrimary)),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: statusColor.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(statusLabel,
                          style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: statusColor)),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    _infoChip(c, Icons.person_outline, job.clientDisplay),
                    const SizedBox(width: 12),
                    _infoChip(c, Icons.category_outlined, job.productType),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _infoChip(c, Icons.currency_pound, 'اتفاق: ${_fmt(job.agreedAmount)}'),
                    if (job.workshopId != 'all') ...[
                      const SizedBox(width: 12),
                      _infoChip(c, Icons.location_on_outlined,
                          job.workshopId == 'sila' ? 'سيلا' : 'الفيوم'),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _infoChip(AppColors c, IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 13, color: c.textMuted),
        const SizedBox(width: 4),
        Text(text, style: TextStyle(fontSize: 11, color: c.textSecondary)),
      ],
    );
  }

  String _fmt(double v) => '${v.toInt().toString()} ج.م';
}
