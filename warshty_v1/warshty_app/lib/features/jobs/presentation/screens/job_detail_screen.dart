import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

class JobDetailScreen extends StatelessWidget {
  final int jobId;

  const JobDetailScreen({super.key, required this.jobId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_forward, color: AppColors.darkTextSecondary),
          onPressed: () => context.pop(),
        ),
        title: const Text('تفاصيل الشغلانة'),
      ),
      body: Center(
        child: Text('تفاصيل الشغلانة #$jobId', style: AppTextStyles.sectionTitle(context)),
      ),
    );
  }
}
