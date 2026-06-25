import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/database/database_helper.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/theme_cubit.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('الإعدادات')),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(AppConstants.spacing16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle(context, 'المظهر'),
            SizedBox(height: AppConstants.spacing10),
            _buildThemeRow(context),
            SizedBox(height: AppConstants.spacing24),
            _buildSectionTitle(context, 'النسخ الاحتياطي'),
            SizedBox(height: AppConstants.spacing10),
            _buildBackupRow(context),
            SizedBox(height: AppConstants.spacing10),
            _buildRestoreRow(context),
            SizedBox(height: AppConstants.spacing24),
            _buildSectionTitle(context, 'معلومات'),
            SizedBox(height: AppConstants.spacing10),
            _buildAboutRow(context),
            SizedBox(height: AppConstants.spacing20),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Text(title, style: AppTextStyles.sectionTitle(context));
  }

  // ── Theme Row ──────────────────────────────────────────────
  Widget _buildThemeRow(BuildContext context) {
    return BlocBuilder<ThemeCubit, ThemeMode>(
      builder: (context, themeMode) {
        final isDark = themeMode == ThemeMode.dark;
        return _settingsCard(
          context,
          leading: Icon(isDark ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
              color: context.accentColor, size: AppConstants.iconXl),
          title: isDark ? 'الوضع الداكن' : 'الوضع الفاتح',
          trailing: Switch(
            value: isDark,
            activeColor: context.accentColor,
            onChanged: (_) => context.read<ThemeCubit>().toggleTheme(),
          ),
        );
      },
    );
  }

  // ── Backup Row ─────────────────────────────────────────────
  Widget _buildBackupRow(BuildContext context) {
    return _settingsCard(
      context,
      leading: Icon(Icons.backup_rounded, color: context.accentColor, size: AppConstants.iconXl),
      title: 'إنشاء نسخة احتياطية',
      subtitle: 'مشاركة قاعدة البيانات كملف',
      trailing: Icon(Icons.chevron_left_rounded, color: context.textMuted, size: AppConstants.iconLg),
      onTap: () => _doBackup(context),
    );
  }

  // ── Restore Row ────────────────────────────────────────────
  Widget _buildRestoreRow(BuildContext context) {
    return _settingsCard(
      context,
      leading: Icon(Icons.restore_page_rounded, color: AppColors.warning, size: AppConstants.iconXl),
      title: 'استعادة نسخة احتياطية',
      subtitle: 'استبدال البيانات بملف قديم',
      trailing: Icon(Icons.chevron_left_rounded, color: context.textMuted, size: AppConstants.iconLg),
      onTap: () => _confirmRestore(context),
    );
  }

  // ── About Row ──────────────────────────────────────────────
  Widget _buildAboutRow(BuildContext context) {
    return _settingsCard(
      context,
      leading: Icon(Icons.info_outline_rounded, color: AppColors.info, size: AppConstants.iconXl),
      title: 'ورشتي',
      subtitle: 'الإصدار 1.0.0 — إدارة الورش والورش',
    );
  }

  // ── Shared Card ────────────────────────────────────────────
  Widget _settingsCard(
    BuildContext context, {
    required Widget leading,
    required String title,
    String? subtitle,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: context.bgCard,
        borderRadius: BorderRadius.circular(AppConstants.radiusXl),
        border: Border.all(color: context.borderColor),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppConstants.radiusXl),
          child: Padding(
            padding: EdgeInsets.all(AppConstants.spacing16),
            child: Row(
              children: [
                leading,
                SizedBox(width: AppConstants.spacing12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: AppTextStyles.cardTitle(context)),
                      if (subtitle != null) ...[
                        SizedBox(height: AppConstants.spacing2),
                        Text(subtitle, style: AppTextStyles.cardSub(context)),
                      ],
                    ],
                  ),
                ),
                if (trailing != null) trailing,
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── Backup Logic ───────────────────────────────────────────
  Future<void> _doBackup(BuildContext context) async {
    try {
      final helper = DatabaseHelper.instance;
      await helper.close();

      final src = await helper.getDbPath();
      final tempDir = await getTemporaryDirectory();
      final backupPath = '${tempDir.path}/warshty_backup.db';
      await File(src).copy(backupPath);

      await helper.database;

      if (!context.mounted) return;
      await Share.shareXFiles(
        [XFile(backupPath)],
        subject: 'ورشتي - نسخة احتياطية',
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('فشل النسخ الاحتياطي: $e'), backgroundColor: AppColors.danger),
      );
    }
  }

  // ── Restore Logic ─────────────────────────────────────────
  Future<void> _confirmRestore(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('استعادة نسخة احتياطية'),
        content: const Text(
          'هل أنت متأكد؟ كل البيانات الحالية ستُستبدل بالكامل بالبيانات القديمة ولا يمكن التراجع عن هذا الإجراء.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('إلغاء', style: TextStyle(color: context.textSecondary)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text('تأكيد', style: TextStyle(color: AppColors.danger)),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    if (!context.mounted) return;

    try {
      final result = await FilePicker.platform.pickFiles(
        allowedExtensions: ['db'],
      );
      if (result == null || result.files.single.path == null) return;

      final pickedPath = result.files.single.path!;
      final helper = DatabaseHelper.instance;
      await helper.close();

      final dbPath = await helper.getDbPath();
      await File(pickedPath).copy(dbPath);

      await helper.ensureSeedData();
      await helper.database;

      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تمت الاستعادة بنجاح'), backgroundColor: AppColors.success),
      );
      Navigator.of(context).popUntil((route) => route.isFirst);
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('فشل الاستعادة: $e'), backgroundColor: AppColors.danger),
      );
    }
  }
}
