import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/enums/category_type.dart';
import '../../../../core/presentation/widgets/app_modal.dart';
import '../../../../core/presentation/widgets/empty_state.dart';
import '../../../../core/presentation/widgets/app_filter_chip.dart';
import '../../../../core/presentation/widgets/loading_state.dart';
import '../../../../core/theme/app_colors.dart';
import '../../data/models/category_model.dart';
import '../cubits/category_cubit.dart';
import '../cubits/category_state.dart';
import '../widgets/add_category_form.dart';
import '../widgets/category_card.dart';

class CategoriesScreen extends StatefulWidget {
  const CategoriesScreen({super.key});

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<CategoryCubit>()..load(),
      child: Builder(
        builder: (context) => Scaffold(
          appBar: AppBar(title: const Text('التصنيفات')),
          body: BlocConsumer<CategoryCubit, CategoryState>(
            listener: (ctx, state) {
              if (state is CategoryError) {
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
              if (state is CategoryLoading) return const LoadingState();
              if (state is CategoryError) return Center(child: Text(state.message));
              if (state is CategoryLoaded) {
                final cubit = ctx.read<CategoryCubit>();
                final currentFilter = cubit.typeFilter;

                return Column(
                  children: [
                    SizedBox(
                      height: 40,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        padding: EdgeInsets.symmetric(
                          horizontal: AppConstants.spacing16,
                          vertical: AppConstants.spacing6,
                        ),
                        children: [
                          AppFilterChip(label: 'الكل', isActive: currentFilter == null, onTap: () => cubit.setTypeFilter(null)),
                          ...CategoryType.values.map((t) => AppFilterChip(
                            label: t.displayName,
                            isActive: currentFilter == t,
                            onTap: () => cubit.setTypeFilter(t),
                          )),
                        ],
                      ),
                    ),
                    if (state.categories.isEmpty)
                      Expanded(
                        child: EmptyState(
                          icon: Icons.category_outlined,
                          title: 'لا توجد تصنيفات',
                          subtitle: currentFilter != null
                              ? 'لا توجد تصنيفات من نوع "${currentFilter.displayName}"'
                              : 'أضف أول تصنيف بالضغط على زر +',
                        ),
                      )
                    else
                      Expanded(
                        child: ListView.separated(
                          padding: EdgeInsets.all(AppConstants.spacing16),
                          itemCount: state.categories.length,
                          separatorBuilder: (_, __) => SizedBox(height: AppConstants.spacing10),
                          itemBuilder: (_, i) {
                            final cat = state.categories[i];
                            return CategoryCard(
                              category: cat,
                              onTap: () => _showEditModal(context, cat),
                              onDelete: () => _confirmDelete(context, cat),
                            );
                          },
                        ),
                      ),
                  ],
                );
              }
              return const SizedBox.shrink();
            },
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () {
              if (!context.read<CategoryCubit>().isProcessing) {
                _showAddModal(context);
              }
            },
            backgroundColor: AppColors.darkAccent,
            child: const Icon(Icons.add, color: Colors.black),
          ),
        ),
      ),
    );
  }

  Future<void> _submitWithFeedback(BuildContext context, Future<void> Function() action) async {
    try {
      await action();
      if (context.mounted) Navigator.pop(context);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تمت العملية بنجاح'),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('خطأ: $e'),
            backgroundColor: AppColors.danger,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  void _showAddModal(BuildContext context) {
    AppModal.show(
      context,
      AppModal(
        title: 'إضافة تصنيف جديد',
        child: AddCategoryForm(
          onSubmit: (cat) => _submitWithFeedback(context, () async {
            await context.read<CategoryCubit>().add(cat);
          }),
        ),
      ),
    );
  }

  void _showEditModal(BuildContext context, CategoryModel cat) {
    AppModal.show(
      context,
      AppModal(
        title: 'تعديل التصنيف',
        child: AddCategoryForm(
          existingCategory: cat,
          onSubmit: (updated) => _submitWithFeedback(context, () async {
            await context.read<CategoryCubit>().update(updated);
          }),
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context, CategoryModel cat) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.darkBgSecondary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusLg),
        ),
        title: const Text('حذف التصنيف'),
        content: Text('هل أنت متأكد من حذف "${cat.name}"؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              try {
                await context.read<CategoryCubit>().softDelete(cat.id!);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('تم الحذف بنجاح'),
                      backgroundColor: AppColors.success,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('خطأ: $e'),
                      backgroundColor: AppColors.danger,
                      behavior: SnackBarBehavior.floating,
                    ),
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
