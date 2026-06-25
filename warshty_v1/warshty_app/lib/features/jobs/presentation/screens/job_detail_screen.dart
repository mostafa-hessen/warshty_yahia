import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/presentation/widgets/app_modal.dart';
import '../../../../core/presentation/widgets/loading_state.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/formatters.dart';
import '../../data/models/job_labor_model.dart';
import '../../data/models/job_material_model.dart';
import '../../data/models/job_other_cost_model.dart';
import '../../data/models/job_payment_model.dart';
import '../cubits/job_cubit.dart';
import '../cubits/job_state.dart';
import '../widgets/add_job_item_form.dart';
import '../widgets/edit_job_form.dart';
import '../widgets/job_detail_section.dart';

class JobDetailScreen extends StatefulWidget {
  final int jobId;

  const JobDetailScreen({super.key, required this.jobId});

  @override
  State<JobDetailScreen> createState() => _JobDetailScreenState();
}

class _JobDetailScreenState extends State<JobDetailScreen> {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<JobCubit>()..loadDetail(widget.jobId),
      child: Builder(
        builder: (context) => Scaffold(
          appBar: AppBar(
            leading: IconButton(
              icon: Icon(Icons.arrow_forward, color: AppColors.darkTextSecondary),
              onPressed: () => context.pop(),
            ),
            title: const Text('تفاصيل الشغلانة'),
            actions: [
              IconButton(
                icon: Icon(Icons.edit_outlined, color: AppColors.darkTextSecondary),
                onPressed: () => _showEditJobModal(context),
              ),
              IconButton(
                icon: Icon(Icons.delete_outline, color: AppColors.danger),
                onPressed: () => _confirmDeleteJob(context),
              ),
            ],
          ),
          body: BlocConsumer<JobCubit, JobState>(
            listener: (ctx, state) {
              if (state is JobError) {
                ScaffoldMessenger.of(ctx).showSnackBar(
                  SnackBar(content: Text(state.message), backgroundColor: AppColors.danger, behavior: SnackBarBehavior.floating),
                );
              }
            },
            builder: (ctx, state) {
              if (state is JobDetailLoading || state is JobLoading) return const LoadingState();
              if (state is JobError) return Center(child: Text(state.message));
              if (state is JobDetailLoaded) return _buildContent(ctx, state);
              return const SizedBox.shrink();
            },
          ),
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, JobDetailLoaded state) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(context, state),
          _buildSummaryCards(context, state),
          SizedBox(height: AppConstants.spacing12),
          _buildMaterialsSection(context, state),
          _buildLaborsSection(context, state),
          _buildOtherCostsSection(context, state),
          _buildPaymentsSection(context, state),
          _buildTotalsSection(context, state),
          SizedBox(height: AppConstants.spacing32),
        ],
      ),
    );
  }

  // ── Header ─────────────────────────────────────────────────────

  Widget _buildHeader(BuildContext context, JobDetailLoaded state) {
    final j = state.job;
    final isActive = j.status == 'قيد';
    return Container(
      margin: EdgeInsets.all(AppConstants.spacing16),
      padding: EdgeInsets.all(AppConstants.spacing16),
      decoration: BoxDecoration(
        color: AppColors.darkBgCard,
        borderRadius: BorderRadius.circular(AppConstants.radiusXl),
        border: Border.all(color: AppColors.darkBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: Text(j.name, style: AppTextStyles.detailSectionTitle(context))),
              if (isActive)
                InkWell(
                  onTap: () => _toggleStatus(context, j),
                  borderRadius: BorderRadius.circular(AppConstants.radiusChip),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.success.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(AppConstants.radiusChip),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.check_circle, size: AppConstants.iconSm, color: AppColors.success),
                        SizedBox(width: AppConstants.spacing3),
                        Text('تسليم', style: AppTextStyles.badge(context).copyWith(color: AppColors.success)),
                      ],
                    ),
                  ),
                )
              else
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.success.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(AppConstants.radiusChip),
                  ),
                  child: Text('مكتملة',
                    style: AppTextStyles.badge(context).copyWith(color: AppColors.success),
                  ),
                ),
            ],
          ),
          SizedBox(height: AppConstants.spacing10),
          _headerRow('الورشة', j.workshopName ?? '—'),
          SizedBox(height: AppConstants.spacing4),
          _headerRow('العميل', j.personName ?? '—'),
          if (j.productType != null) ...[
            SizedBox(height: AppConstants.spacing4),
            _headerRow('نوع المنتج', j.productType!),
          ],
          if (j.startDate != null) ...[
            SizedBox(height: AppConstants.spacing4),
            _headerRow('تاريخ البداية', AppFormatters.formatDate(j.startDate)),
          ],
          if (j.notes != null && j.notes!.isNotEmpty) ...[
            SizedBox(height: AppConstants.spacing8),
            Text(j.notes!, style: AppTextStyles.detailLabel(context), maxLines: 3, overflow: TextOverflow.ellipsis),
          ],
        ],
      ),
    );
  }

  Widget _headerRow(String label, String value) {
    return Row(
      children: [
        Text('$label: ', style: AppTextStyles.detailLabel(context)),
        Text(value, style: AppTextStyles.detailValue(context)),
      ],
    );
  }

  // ── Summary Cards ──────────────────────────────────────────────

  Widget _buildSummaryCards(BuildContext context, JobDetailLoaded state) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: AppConstants.spacing16),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(child: _bigCard(context, 'المتفق عليه', AppFormatters.currency(state.job.agreedAmount), AppColors.darkAccent, Icons.check_circle_outline)),
              SizedBox(width: AppConstants.spacing10),
              Expanded(child: _bigCard(context, 'المتبقي', AppFormatters.currency(state.remaining),
                  state.remaining > 0 ? AppColors.warning : AppColors.success, Icons.currency_exchange)),
            ],
          ),
          SizedBox(height: AppConstants.spacing8),
          Row(
            children: [
              Expanded(child: _smallCard(context, 'التكاليف', AppFormatters.currency(state.totalCosts), AppColors.warning)),
              SizedBox(width: AppConstants.spacing10),
              Expanded(child: _smallCard(context, state.isProfitable ? 'الربح' : 'الخسارة',
                  AppFormatters.currency(state.profit.abs()), state.isProfitable ? AppColors.success : AppColors.danger)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _bigCard(BuildContext context, String label, String value, Color color, IconData icon) {
    return Container(
      padding: EdgeInsets.all(AppConstants.spacing14),
      decoration: BoxDecoration(
        color: AppColors.darkBgCard,
        borderRadius: BorderRadius.circular(AppConstants.radiusXl),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, size: AppConstants.iconLg, color: color),
          SizedBox(width: AppConstants.spacing10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(value, style: AppTextStyles.cardAmount(context).copyWith(color: color, fontSize: 16)),
                Text(label, style: AppTextStyles.statLabel(context)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _smallCard(BuildContext context, String label, String value, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: AppConstants.spacing12, vertical: AppConstants.spacing10),
      decoration: BoxDecoration(
        color: AppColors.darkBgCard,
        borderRadius: BorderRadius.circular(AppConstants.radiusMd),
        border: Border.all(color: AppColors.darkBorder),
      ),
      child: Row(
        children: [
          Text(value, style: AppTextStyles.cardAmount(context).copyWith(color: color, fontSize: 13)),
          Spacer(),
          Text(label, style: AppTextStyles.statLabel(context)),
        ],
      ),
    );
  }

  // ── Sections ───────────────────────────────────────────────────

  Widget _buildMaterialsSection(BuildContext context, JobDetailLoaded state) {
    return JobDetailSection(
      title: 'المواد',
      onAdd: () => _showItemModal(context, JobItemType.material),
      emptyMessage: 'لا توجد خامات',
      items: state.materials.map((m) => _itemRow(
        context,
        leading: Text(m.name, style: AppTextStyles.cardTitle(context), maxLines: 1, overflow: TextOverflow.ellipsis),
        amount: m.amount,
        desc: m.description,
        date: m.date,
        onTap: () => _showItemModal(context, JobItemType.material, existingItem: m),
        onDelete: () => _confirmDelete(context, 'الخامة', () async {
          await context.read<JobCubit>().deleteMaterial(m.jobId, m.partialId);
        }),
      )).toList(),
    );
  }

  Widget _buildLaborsSection(BuildContext context, JobDetailLoaded state) {
    return JobDetailSection(
      title: 'المصنعيات',
      onAdd: () => _showItemModal(context, JobItemType.labor),
      emptyMessage: 'لا توجد مصنعيات',
      items: state.labors.map((l) => _itemRow(
        context,
        leading: l.categoryName != null ? Text(l.categoryName!, style: AppTextStyles.cardTitle(context), maxLines: 1, overflow: TextOverflow.ellipsis) : null,
        amount: l.amount,
        desc: l.description,
        date: l.date,
        onTap: () => _showItemModal(context, JobItemType.labor, existingItem: l),
        onDelete: () => _confirmDelete(context, 'المصنعية', () async {
          await context.read<JobCubit>().deleteLabor(l.jobId, l.partialId);
        }),
      )).toList(),
    );
  }

  Widget _buildOtherCostsSection(BuildContext context, JobDetailLoaded state) {
    return JobDetailSection(
      title: 'التكاليف الأخرى',
      onAdd: () => _showItemModal(context, JobItemType.otherCost),
      emptyMessage: 'لا توجد تكاليف أخرى',
      items: state.otherCosts.map((o) => _itemRow(
        context,
        leading: o.categoryName != null ? Text(o.categoryName!, style: AppTextStyles.cardTitle(context), maxLines: 1, overflow: TextOverflow.ellipsis) : null,
        amount: o.amount,
        desc: o.description,
        date: o.date,
        onTap: () => _showItemModal(context, JobItemType.otherCost, existingItem: o),
        onDelete: () => _confirmDelete(context, 'التكلفة', () async {
          await context.read<JobCubit>().deleteOtherCost(o.jobId, o.partialId);
        }),
      )).toList(),
    );
  }

  Widget _buildPaymentsSection(BuildContext context, JobDetailLoaded state) {
    return JobDetailSection(
      title: 'الدفعات',
      onAdd: () => _showItemModal(context, JobItemType.payment),
      emptyMessage: 'لا توجد دفعات',
      items: state.payments.map((p) => _itemRow(
        context,
        amount: p.amount,
        desc: p.description,
        date: p.date,
        onTap: () => _showItemModal(context, JobItemType.payment, existingItem: p),
        onDelete: () => _confirmDelete(context, 'الدفعة', () async {
          await context.read<JobCubit>().deletePayment(p.jobId, p.partialId);
        }),
      )).toList(),
    );
  }

  // ── Totals ─────────────────────────────────────────────────────

  Widget _buildTotalsSection(BuildContext context, JobDetailLoaded state) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: AppConstants.spacing16),
      child: Container(
        padding: EdgeInsets.all(AppConstants.spacing16),
        decoration: BoxDecoration(
          color: AppColors.darkBgCard,
          borderRadius: BorderRadius.circular(AppConstants.radiusXl),
          border: Border.all(color: AppColors.darkBorder),
        ),
        child: Column(
          children: [
            _totalRow(context, 'إجمالي المواد', state.totalMaterials, AppColors.darkTextSecondary),
            SizedBox(height: AppConstants.spacing6),
            _totalRow(context, 'إجمالي المصنعيات', state.totalLabors, AppColors.darkTextSecondary),
            SizedBox(height: AppConstants.spacing6),
            _totalRow(context, 'إجمالي التكاليف الأخرى', state.totalOtherCosts, AppColors.darkTextSecondary),
            Divider(height: AppConstants.spacing20, color: AppColors.darkBorder),
            _totalRow(context, 'إجمالي التكاليف', state.totalCosts, AppColors.warning),
            SizedBox(height: AppConstants.spacing6),
            _totalRow(context, 'المتفق عليه', state.job.agreedAmount, AppColors.darkAccent),
            SizedBox(height: AppConstants.spacing6),
            _totalRow(context, state.isProfitable ? 'الربح' : 'الخسارة',
                state.profit.abs(), state.isProfitable ? AppColors.success : AppColors.danger),
            SizedBox(height: AppConstants.spacing6),
            _totalRow(context, 'المتبقي', state.remaining, AppColors.info),
          ],
        ),
      ),
    );
  }

  Widget _totalRow(BuildContext context, String label, double amount, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: AppTextStyles.detailLabel(context)),
        Text(AppFormatters.currency(amount), style: AppTextStyles.detailValue(context).copyWith(color: color)),
      ],
    );
  }

  // ── Shared Item Row ────────────────────────────────────────────

  Widget _itemRow(
    BuildContext context, {
    Widget? leading,
    required double amount,
    String? desc,
    String? date,
    VoidCallback? onTap,
    VoidCallback? onDelete,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppConstants.radiusSm),
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: AppConstants.spacing16, vertical: AppConstants.spacing2),
        padding: EdgeInsets.symmetric(horizontal: AppConstants.spacing12, vertical: AppConstants.spacing8),
        decoration: BoxDecoration(
          color: AppColors.darkBgSecondary,
          borderRadius: BorderRadius.circular(AppConstants.radiusSm),
        ),
        child: Row(
          children: [
            if (leading != null) ...[
              Flexible(child: leading),
              SizedBox(width: AppConstants.spacing8),
            ],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(AppFormatters.currency(amount), style: AppTextStyles.detailValue(context).copyWith(color: AppColors.darkAccent)),
                  if (desc != null && desc.isNotEmpty)
                    Text(desc, style: AppTextStyles.detailLabel(context), maxLines: 1, overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
            if (date != null) ...[
              SizedBox(width: AppConstants.spacing8),
              Text(AppFormatters.formatDate(date), style: AppTextStyles.txDateLabel(context)),
            ],
            if (onDelete != null) ...[
              SizedBox(width: AppConstants.spacing8),
              InkWell(
                onTap: onDelete, borderRadius: BorderRadius.circular(AppConstants.radiusSm),
                child: Padding(
                  padding: EdgeInsets.all(AppConstants.spacing4),
                  child: Icon(Icons.close, size: AppConstants.iconSm, color: AppColors.darkTextMuted),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // ── Actions ────────────────────────────────────────────────────

  void _showEditJobModal(BuildContext context) {
    final state = context.read<JobCubit>().state;
    if (state is! JobDetailLoaded) return;
    AppModal.show(
      context,
      AppModal(
        title: 'تعديل الشغلانة',
        child: EditJobForm(
          job: state.job,
          onSubmit: (updated) async {
            try {
              await context.read<JobCubit>().update(updated);
              if (context.mounted) Navigator.pop(context);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('تم التعديل بنجاح'), backgroundColor: AppColors.success, behavior: SnackBarBehavior.floating),
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

  void _toggleStatus(BuildContext context, dynamic job) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.darkBgSecondary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppConstants.radiusLg)),
        title: const Text('تسليم الشغلانة'),
        content: const Text('هل أنت متأكد من تسليم الشغلانة؟'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('إلغاء')),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              try {
                await context.read<JobCubit>().update(job.copyWith(status: 'مكتملة'));
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('تم التسليم'), backgroundColor: AppColors.success, behavior: SnackBarBehavior.floating),
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
            child: const Text('تسليم', style: TextStyle(color: AppColors.success)),
          ),
        ],
      ),
    );
  }

  void _showItemModal(BuildContext context, JobItemType type, {dynamic existingItem}) {
    final isEdit = existingItem != null;
    AppModal.show(
      context,
      AppModal(
        title: isEdit ? 'تعديل' : 'إضافة',
        child: AddJobItemForm(
          jobId: widget.jobId,
          itemType: type,
          existingItem: existingItem,
          onSubmit: (item) async {
            try {
              final cubit = context.read<JobCubit>();
              if (isEdit) {
                switch (type) {
                  case JobItemType.material: await cubit.updateMaterial(item as JobMaterialModel);
                  case JobItemType.labor: await cubit.updateLabor(item as JobLaborModel);
                  case JobItemType.otherCost: await cubit.updateOtherCost(item as JobOtherCostModel);
                  case JobItemType.payment: await cubit.updatePayment(item as JobPaymentModel);
                }
              } else {
                switch (type) {
                  case JobItemType.material: await cubit.addMaterial(item as JobMaterialModel);
                  case JobItemType.labor: await cubit.addLabor(item as JobLaborModel);
                  case JobItemType.otherCost: await cubit.addOtherCost(item as JobOtherCostModel);
                  case JobItemType.payment: await cubit.addPayment(item as JobPaymentModel);
                }
              }
              if (context.mounted) Navigator.pop(context);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(isEdit ? 'تم التعديل' : 'تمت الإضافة'), backgroundColor: AppColors.success, behavior: SnackBarBehavior.floating),
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
          onAddAnother: type == JobItemType.material && !isEdit
              ? (item) async {
                  try {
                    await context.read<JobCubit>().addMaterial(item as JobMaterialModel);
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('تمت الإضافة'), backgroundColor: AppColors.success, behavior: SnackBarBehavior.floating, duration: Duration(seconds: 1)),
                      );
                    }
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('خطأ: $e'), backgroundColor: AppColors.danger, behavior: SnackBarBehavior.floating),
                      );
                    }
                  }
                }
              : null,
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context, String label, Future<void> Function() action) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.darkBgSecondary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppConstants.radiusLg)),
        title: Text('حذف $label'),
        content: Text('هل أنت متأكد من حذف $label؟'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('إلغاء')),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              try {
                await action();
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('تم الحذف'),
                      backgroundColor: AppColors.success,
                      behavior: SnackBarBehavior.floating,
                      duration: const Duration(seconds: 4),
                      action: SnackBarAction(
                        label: 'تراجع',
                        textColor: AppColors.darkAccent,
                        onPressed: () {
                          context.read<JobCubit>().undoLastDelete();
                        },
                      ),
                    ),
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
            child: const Text('حذف', style: TextStyle(color: AppColors.danger)),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteJob(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.darkBgSecondary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppConstants.radiusLg)),
        title: const Text('حذف الشغلانة'),
        content: const Text('سيتم حذف الشغلانة وجميع بياناتها. هل أنت متأكد؟'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('إلغاء')),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              try {
                await context.read<JobCubit>().delete(widget.jobId);
                if (context.mounted) context.pop();
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('تم حذف الشغلانة'), backgroundColor: AppColors.success, behavior: SnackBarBehavior.floating),
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
            child: const Text('حذف', style: TextStyle(color: AppColors.danger)),
          ),
        ],
      ),
    );
  }
}
