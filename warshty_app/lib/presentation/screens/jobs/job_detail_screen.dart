import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/theme/app_theme.dart';
import '../../../domain/entities/job.dart';
import '../../../domain/entities/job_material.dart';
import '../../../domain/entities/labor.dart';
import '../../../domain/entities/payment.dart';
import '../../cubits/jobs/jobs_cubit.dart';
import '../../widgets/app_widgets.dart';
import 'create_job_screen.dart';

class JobDetailScreen extends StatefulWidget {
  final int jobId;
  const JobDetailScreen({super.key, required this.jobId});

  @override
  State<JobDetailScreen> createState() => _JobDetailScreenState();
}

class _JobDetailScreenState extends State<JobDetailScreen> {
  Map<String, dynamic>? _data;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final data = await context.read<JobsCubit>().getJobDetail(widget.jobId);
    if (mounted) setState(() { _data = data; _loading = false; });
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Scaffold(
      appBar: AppBar(
        title: Text(_data != null ? (_data!['job'] as Job?)?.name ?? 'تفاصيل' : 'تفاصيل'),
        actions: [
          if (_data != null)
            IconButton(
              icon: Icon(Icons.edit_outlined, color: c.textSecondary),
              onPressed: () => _editJob(context),
            ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _data == null
              ? const Center(child: Text('لم يتم العثور على الشغلانة'))
              : _buildContent(c),
    );
  }

  Widget _buildContent(AppColors c) {
    final job = _data!['job'] as Job?;
    if (job == null) return const Center(child: Text('لم يتم العثور على الشغلانة'));

    final materials = _data!['materials'] as List<JobMaterial>;
    final labors = _data!['labors'] as List<Labor>;
    final expenses = _data!['expenses'] as List<Map<String, dynamic>>;
    final payments = _data!['payments'] as List<Payment>;
    final totalCost = _data!['totalCost'] as double;
    final totalPaid = _data!['totalPaid'] as double;
    final remaining = job.agreedAmount - totalPaid;
    final netProfit = job.agreedAmount - totalCost;

    return RefreshIndicator(
      onRefresh: _load,
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _headerSection(c, job),
          const SizedBox(height: 20),
          _financeSection(c, totalCost, totalPaid, remaining, netProfit),
          const SizedBox(height: 20),
          _sectionHeader(c, 'الخامات', Icons.inventory_2_outlined, onAdd: () => _addMaterial(c, job.id!)),
          ...materials.map((m) => _materialTile(c, m)),
          if (materials.isEmpty) EmptyState(icon: Icons.inventory_2_outlined, title: 'لا توجد خامات'),
          const SizedBox(height: 20),
          _sectionHeader(c, 'المصنعيات', Icons.construction, onAdd: () => _addLabor(c, job.id!)),
          ...labors.map((l) => _laborTile(c, l)),
          if (labors.isEmpty) EmptyState(icon: Icons.construction, title: 'لا توجد مصنعيات'),
          const SizedBox(height: 20),
          _sectionHeader(c, 'مصاريف أخرى', Icons.receipt_long_outlined, onAdd: () => _addExpense(c, job.id!)),
          ...expenses.map((e) => _expenseTile(c, e)),
          if (expenses.isEmpty) EmptyState(icon: Icons.receipt_long_outlined, title: 'لا توجد مصاريف أخرى'),
          const SizedBox(height: 20),
          _sectionHeader(c, 'المدفوعات', Icons.payments_outlined, onAdd: () => _addPayment(c, job.id!)),
          ...payments.map((p) => _paymentTile(c, p)),
          if (payments.isEmpty) EmptyState(icon: Icons.payments_outlined, title: 'لا توجد مدفوعات'),
          const SizedBox(height: 80),
        ],
      ),
    );
  }

  Widget _headerSection(AppColors c, Job job) {
    final statusMap = {
      'active': ('نشط', c.accent),
      'completed': ('مكتمل', c.success),
      'archived': ('أرشيف', c.textMuted),
    };
    final (statusLabel, statusColor) = statusMap[job.status] ?? ('نشط', c.accent);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: c.bgCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: c.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(job.name,
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: c.textPrimary)),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(statusLabel, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: statusColor)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _detailRow(c, Icons.person_outline, 'العميل', job.clientDisplay),
          _detailRow(c, Icons.category_outlined, 'النوع', job.productType),
          _detailRow(c, Icons.location_on_outlined, 'الورشة',
              job.workshopId == 'sila' ? 'سيلا' : 'الفيوم'),
          _detailRow(c, Icons.calendar_today_outlined, 'تاريخ الإنشاء', job.createdAt.substring(0, 10)),
          _detailRow(c, Icons.currency_pound, 'المتفق عليه', '${job.agreedAmount.toInt().toString()} ج.م'),
          if (job.notes != null && job.notes!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text('ملاحظات: ${job.notes}', style: TextStyle(color: c.textSecondary, fontSize: 12)),
          ],
        ],
      ),
    );
  }

  Widget _detailRow(AppColors c, IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 15, color: c.textMuted),
          const SizedBox(width: 8),
          Text('$label: ', style: TextStyle(fontSize: 13, color: c.textMuted)),
          Text(value, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: c.textPrimary)),
        ],
      ),
    );
  }

  Widget _financeSection(AppColors c, double totalCost, double totalPaid, double remaining, double netProfit) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: c.bgCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: c.border),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(child: _financeItem(c, 'التكلفة', '${totalCost.toInt().toString()} ج.م', c.danger)),
              Container(width: 1, height: 40, color: c.border),
              Expanded(child: _financeItem(c, 'المدفوع', '${totalPaid.toInt().toString()} ج.م', c.success)),
              Container(width: 1, height: 40, color: c.border),
              Expanded(child: _financeItem(c, 'صافي الربح', '${netProfit.toInt().toString()} ج.م', netProfit >= 0 ? c.accent : c.danger)),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _financeItem(c, 'المستحقات', '${remaining.toInt().toString()} ج.م', remaining > 0 ? c.warning : c.success)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _financeItem(AppColors c, String label, String value, Color color) {
    return Column(
      children: [
        Text(value, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: color)),
        const SizedBox(height: 4),
        Text(label, style: TextStyle(fontSize: 11, color: c.textSecondary)),
      ],
    );
  }

  Widget _sectionHeader(AppColors c, String title, IconData icon, {VoidCallback? onAdd}) {
    return Row(
      children: [
        Icon(icon, size: 18, color: c.accent),
        const SizedBox(width: 8),
        Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: c.textPrimary)),
        const Spacer(),
        if (onAdd != null)
          GestureDetector(
            onTap: onAdd,
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: c.accent.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(Icons.add, size: 18, color: c.accent),
            ),
          ),
      ],
    );
  }

  Widget _materialTile(AppColors c, JobMaterial m) {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: c.bgCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: c.border),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(m.description, style: TextStyle(fontWeight: FontWeight.w600, color: c.textPrimary)),
                const SizedBox(height: 4),
                Text('عدد ${m.quantity} × ${m.costPerUnit.toInt().toString()} ج.م = ${m.totalCost.toInt().toString()} ج.م',
                    style: TextStyle(fontSize: 12, color: c.textSecondary)),
              ],
            ),
          ),
          GestureDetector(
            onTap: () => _deleteItem(m.id!, 'material'),
            child: Icon(Icons.delete_outline, size: 18, color: c.danger.withValues(alpha: 0.7)),
          ),
        ],
      ),
    );
  }

  Widget _laborTile(AppColors c, Labor l) {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: c.bgCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: c.border),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l.description, style: TextStyle(fontWeight: FontWeight.w600, color: c.textPrimary)),
                const SizedBox(height: 4),
                Text('${l.amount.toInt().toString()} ج.م',
                    style: TextStyle(fontSize: 12, color: c.textSecondary)),
              ],
            ),
          ),
          GestureDetector(
            onTap: () => _deleteItem(l.id!, 'labor'),
            child: Icon(Icons.delete_outline, size: 18, color: c.danger.withValues(alpha: 0.7)),
          ),
        ],
      ),
    );
  }

  Widget _expenseTile(AppColors c, Map<String, dynamic> e) {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: c.bgCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: c.border),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(e['description'] as String,
                    style: TextStyle(fontWeight: FontWeight.w600, color: c.textPrimary)),
                const SizedBox(height: 4),
                Text('${(e['amount'] as num).toInt().toString()} ج.م',
                    style: TextStyle(fontSize: 12, color: c.textSecondary)),
              ],
            ),
          ),
          GestureDetector(
            onTap: () => _deleteItem(e['id'] as int, 'expense'),
            child: Icon(Icons.delete_outline, size: 18, color: c.danger.withValues(alpha: 0.7)),
          ),
        ],
      ),
    );
  }

  Widget _paymentTile(AppColors c, Payment p) {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: c.bgCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: c.border),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${p.amount.toInt().toString()} ج.م',
                    style: TextStyle(fontWeight: FontWeight.w600, color: c.success)),
                const SizedBox(height: 4),
                Text(p.date.substring(0, 10), style: TextStyle(fontSize: 12, color: c.textSecondary)),
              ],
            ),
          ),
          GestureDetector(
            onTap: () => _deleteItem(p.id!, 'payment'),
            child: Icon(Icons.delete_outline, size: 18, color: c.danger.withValues(alpha: 0.7)),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteItem(int id, String type) async {
    final cubit = context.read<JobsCubit>();
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('تأكيد الحذف'),
        content: const Text('هل أنت متأكد؟'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('إلغاء')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('حذف')),
        ],
      ),
    );
    if (confirm != true) return;

    switch (type) {
      case 'material': await cubit.deleteMaterial(id); break;
      case 'labor': await cubit.deleteLabor(id); break;
      case 'expense': await cubit.deleteExpense(id); break;
      case 'payment': await cubit.deletePayment(id); break;
    }
    _load();
  }

  void _addMaterial(AppColors c, int jobId) {
    final descCtrl = TextEditingController();
    final qtyCtrl = TextEditingController();
    final costCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('إضافة خامة'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: descCtrl, decoration: const InputDecoration(hintText: 'وصف الخامة'), textDirection: TextDirection.rtl),
            const SizedBox(height: 8),
            TextField(controller: qtyCtrl, decoration: const InputDecoration(hintText: 'العدد / الكمية'), keyboardType: TextInputType.number),
            const SizedBox(height: 8),
            TextField(controller: costCtrl, decoration: const InputDecoration(hintText: 'سعر الوحدة'), keyboardType: TextInputType.number),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('إلغاء')),
          ElevatedButton(
            onPressed: () async {
              if (descCtrl.text.isEmpty || qtyCtrl.text.isEmpty || costCtrl.text.isEmpty) return;
              await context.read<JobsCubit>().addMaterial(JobMaterial(
                jobId: jobId,
                description: descCtrl.text,
                quantity: double.parse(qtyCtrl.text),
                costPerUnit: double.parse(costCtrl.text),
              ));
              if (ctx.mounted) Navigator.pop(ctx);
              _load();
            },
            child: const Text('إضافة'),
          ),
        ],
      ),
    );
  }

  void _addLabor(AppColors c, int jobId) {
    final descCtrl = TextEditingController();
    final amtCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('إضافة مصنعية'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: descCtrl, decoration: const InputDecoration(hintText: 'الوصف'), textDirection: TextDirection.rtl),
            const SizedBox(height: 8),
            TextField(controller: amtCtrl, decoration: const InputDecoration(hintText: 'المبلغ'), keyboardType: TextInputType.number),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('إلغاء')),
          ElevatedButton(
            onPressed: () async {
              if (descCtrl.text.isEmpty || amtCtrl.text.isEmpty) return;
              await context.read<JobsCubit>().addLabor(Labor(
                jobId: jobId,
                description: descCtrl.text,
                amount: double.parse(amtCtrl.text),
                categoryId: 'cat_labor',
              ));
              if (ctx.mounted) Navigator.pop(ctx);
              _load();
            },
            child: const Text('إضافة'),
          ),
        ],
      ),
    );
  }

  void _addExpense(AppColors c, int jobId) {
    final descCtrl = TextEditingController();
    final amtCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('إضافة مصروف'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: descCtrl, decoration: const InputDecoration(hintText: 'الوصف'), textDirection: TextDirection.rtl),
            const SizedBox(height: 8),
            TextField(controller: amtCtrl, decoration: const InputDecoration(hintText: 'المبلغ'), keyboardType: TextInputType.number),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('إلغاء')),
          ElevatedButton(
            onPressed: () async {
              if (descCtrl.text.isEmpty || amtCtrl.text.isEmpty) return;
              await context.read<JobsCubit>().addExpense(jobId, descCtrl.text, double.parse(amtCtrl.text));
              if (ctx.mounted) Navigator.pop(ctx);
              _load();
            },
            child: const Text('إضافة'),
          ),
        ],
      ),
    );
  }

  void _addPayment(AppColors c, int jobId) {
    final amtCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('إضافة دفعة'),
        content: TextField(
          controller: amtCtrl,
          decoration: const InputDecoration(hintText: 'المبلغ'),
          keyboardType: TextInputType.number,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('إلغاء')),
          ElevatedButton(
            onPressed: () async {
              if (amtCtrl.text.isEmpty) return;
              await context.read<JobsCubit>().addPayment(Payment(
                jobId: jobId,
                amount: double.parse(amtCtrl.text),
                date: DateTime.now().toIso8601String(),
              ));
              if (ctx.mounted) Navigator.pop(ctx);
              _load();
            },
            child: const Text('إضافة'),
          ),
        ],
      ),
    );
  }

  void _editJob(BuildContext context) {
    final job = _data!['job'] as Job?;
    if (job == null) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: context.read<JobsCubit>(),
          child: CreateJobScreen(job: job),
        ),
      ),
    ).then((_) => _load());
  }
}
