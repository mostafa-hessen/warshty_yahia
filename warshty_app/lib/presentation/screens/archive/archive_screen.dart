import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/theme/app_theme.dart';
import '../../../domain/entities/job.dart';
import '../../cubits/jobs/jobs_cubit.dart';
import '../../widgets/app_widgets.dart';
import '../jobs/job_detail_screen.dart';

class ArchiveScreen extends StatefulWidget {
  const ArchiveScreen({super.key});

  @override
  State<ArchiveScreen> createState() => _ArchiveScreenState();
}

class _ArchiveScreenState extends State<ArchiveScreen> {
  final _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    context.read<JobsCubit>().setStatusFilter('archived');
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
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
            controller: _searchCtrl,
            onChanged: (v) => context.read<JobsCubit>().setSearchQuery(v),
            style: TextStyle(color: c.textPrimary),
            decoration: InputDecoration(
              hintText: 'بحث في الأرشيف ...',
              prefixIcon: Icon(Icons.search, color: c.textMuted),
              suffixIcon: _searchCtrl.text.isNotEmpty
                  ? IconButton(
                      icon: Icon(Icons.clear, color: c.textMuted),
                      onPressed: () {
                        _searchCtrl.clear();
                        context.read<JobsCubit>().setSearchQuery('');
                      },
                    )
                  : null,
              contentPadding: const EdgeInsets.symmetric(vertical: 12),
            ),
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
                final archived = state.jobs.where((j) => j.status == 'archived').toList();
                if (archived.isEmpty) {
                  return const EmptyState(
                    icon: Icons.archive_outlined,
                    title: 'لا توجد شغلانات مؤرشفة',
                    subtitle: 'الشغلانات المنتهية تظهر هنا بعد الأرشفة',
                  );
                }
                return ListView.builder(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 80),
                  itemCount: archived.length,
                  itemBuilder: (_, i) => _archiveCard(c, archived[i]),
                );
              }
              return const SizedBox();
            },
          ),
        ),
      ],
    );
  }

  Widget _archiveCard(AppColors c, Job job) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
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
                    Icon(Icons.archive, size: 18, color: c.textMuted),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(job.name,
                          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: c.textPrimary)),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _infoChip(c, Icons.person_outline, job.clientDisplay),
                    const SizedBox(width: 12),
                    _infoChip(c, Icons.category_outlined, job.productType),
                  ],
                ),
                const SizedBox(height: 4),
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
