import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/theme/app_theme.dart';
import '../../../domain/entities/job.dart';
import '../../cubits/jobs/jobs_cubit.dart';

class CreateJobScreen extends StatefulWidget {
  final Job? job;
  const CreateJobScreen({super.key, this.job});

  @override
  State<CreateJobScreen> createState() => _CreateJobScreenState();
}

class _CreateJobScreenState extends State<CreateJobScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameCtrl;
  late final TextEditingController _clientCtrl;
  late final TextEditingController _phoneCtrl;
  late final TextEditingController _amountCtrl;
  late final TextEditingController _notesCtrl;
  String _workshopId = 'sila';
  String _productType = 'مطبخ';

  bool get _isEditing => widget.job != null;

  @override
  void initState() {
    super.initState();
    final j = widget.job;
    _nameCtrl = TextEditingController(text: j?.name ?? '');
    _clientCtrl = TextEditingController(text: j?.clientName ?? '');
    _phoneCtrl = TextEditingController(text: j?.clientPhone ?? '');
    _amountCtrl = TextEditingController(text: j != null ? j.agreedAmount.toString() : '');
    _notesCtrl = TextEditingController(text: j?.notes ?? '');
    if (j != null) _workshopId = j.workshopId;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _clientCtrl.dispose();
    _phoneCtrl.dispose();
    _amountCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'تعديل الشغلانة' : 'إضافة شغلانة جديدة'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('اسم الشغلانة', style: TextStyle(color: c.textSecondary, fontSize: 13)),
              const SizedBox(height: 6),
              TextFormField(
                controller: _nameCtrl,
                validator: (v) => v == null || v.trim().isEmpty ? 'مطلوب' : null,
                decoration: const InputDecoration(hintText: 'مثال: مطبخ أحمد علي'),
              ),
              const SizedBox(height: 16),
              Text('نوع المنتج', style: TextStyle(color: c.textSecondary, fontSize: 13)),
              const SizedBox(height: 6),
              DropdownButtonFormField<String>(
                value: _productType,
                items: const [
                  DropdownMenuItem(value: 'مطبخ', child: Text('مطبخ')),
                  DropdownMenuItem(value: 'غرفة نوم', child: Text('غرفة نوم')),
                  DropdownMenuItem(value: 'غرفة سفرة', child: Text('غرفة سفرة')),
                  DropdownMenuItem(value: 'دولاب', child: Text('دولاب')),
                  DropdownMenuItem(value: 'أخرى', child: Text('أخرى')),
                ],
                onChanged: (v) => setState(() => _productType = v ?? 'مطبخ'),
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: c.border),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text('الورشة', style: TextStyle(color: c.textSecondary, fontSize: 13)),
              const SizedBox(height: 6),
              DropdownButtonFormField<String>(
                value: _workshopId,
                items: const [
                  DropdownMenuItem(value: 'sila', child: Text('ورشة سيلا')),
                  DropdownMenuItem(value: 'fayoum', child: Text('ورشة الفيوم')),
                ],
                onChanged: (v) => setState(() => _workshopId = v ?? 'sila'),
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: c.border),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text('اسم العميل', style: TextStyle(color: c.textSecondary, fontSize: 13)),
              const SizedBox(height: 6),
              TextFormField(
                controller: _clientCtrl,
                validator: (v) => v == null || v.trim().isEmpty ? 'مطلوب' : null,
                decoration: const InputDecoration(hintText: 'مثال: أحمد علي'),
              ),
              const SizedBox(height: 16),
              Text('رقم الهاتف', style: TextStyle(color: c.textSecondary, fontSize: 13)),
              const SizedBox(height: 6),
              TextFormField(
                controller: _phoneCtrl,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(hintText: 'مثال: 01234567890'),
              ),
              const SizedBox(height: 16),
              Text('المبلغ المتفق عليه', style: TextStyle(color: c.textSecondary, fontSize: 13)),
              const SizedBox(height: 6),
              TextFormField(
                controller: _amountCtrl,
                keyboardType: TextInputType.number,
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'مطلوب';
                  if (double.tryParse(v) == null) return 'رقم غير صحيح';
                  return null;
                },
                decoration: const InputDecoration(hintText: 'مثال: 15000'),
              ),
              const SizedBox(height: 16),
              Text('ملاحظات', style: TextStyle(color: c.textSecondary, fontSize: 13)),
              const SizedBox(height: 6),
              TextFormField(
                controller: _notesCtrl,
                maxLines: 3,
                decoration: const InputDecoration(hintText: 'ملاحظات إضافية...'),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: c.accent,
                    foregroundColor: c.bgPrimary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: Text(
                    _isEditing ? 'حفظ التعديلات' : 'إضافة الشغلانة',
                    style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final amount = double.parse(_amountCtrl.text.trim());
    final now = DateTime.now().toIso8601String();

    if (_isEditing) {
      final updated = widget.job!.copyWith(
        name: _nameCtrl.text.trim(),
        workshopId: _workshopId,
        productType: _productType,
        clientName: _clientCtrl.text.trim(),
        clientPhone: _phoneCtrl.text.trim(),
        agreedAmount: amount,
        updatedAt: now,
        notes: _notesCtrl.text.trim().isEmpty ? null : _notesCtrl.text.trim(),
      );
      await context.read<JobsCubit>().updateJob(updated);
    } else {
      final job = Job(
        name: _nameCtrl.text.trim(),
        workshopId: _workshopId,
        productType: _productType,
        clientName: _clientCtrl.text.trim(),
        clientPhone: _phoneCtrl.text.trim(),
        agreedAmount: amount,
        createdAt: now,
        notes: _notesCtrl.text.trim().isEmpty ? null : _notesCtrl.text.trim(),
      );
      await context.read<JobsCubit>().createJob(job);
    }

    if (mounted) Navigator.pop(context);
  }
}
