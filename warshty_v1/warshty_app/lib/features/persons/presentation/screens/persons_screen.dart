import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/injection_container.dart';
import '../../../../core/presentation/widgets/empty_state.dart';
import '../../../../core/presentation/widgets/loading_state.dart';
import '../../../../core/presentation/widgets/app_modal.dart';
import '../../../../core/presentation/widgets/search_bar.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../cubits/person_cubit.dart';
import '../cubits/person_state.dart';
import '../../data/models/person_model.dart';
import '../widgets/person_card.dart';
import '../widgets/add_person_form.dart';

class PersonsScreen extends StatefulWidget {
  const PersonsScreen({super.key});

  @override
  State<PersonsScreen> createState() => _PersonsScreenState();
}

class _PersonsScreenState extends State<PersonsScreen> {
  final _searchCtrl = TextEditingController();
  String _searchQuery = '';
  String? _typeFilter;

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  List<PersonModel> _filter(List<PersonModel> persons) {
    var result = persons;
    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.trim().toLowerCase();
      result = result.where((p) =>
        p.name.toLowerCase().contains(q) ||
        (p.phone?.toLowerCase().contains(q) ?? false)
      ).toList();
    }
    if (_typeFilter != null) {
      result = result.where((p) => p.type == _typeFilter).toList();
    }
    return result;
  }

  Set<String> _getTypes(List<PersonModel> persons) {
    return persons.map((p) => p.type).toSet();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<PersonCubit>()..load(),
      child: Builder(
        builder: (context) => Scaffold(
          appBar: AppBar(title: const Text('الأشخاص')),
          body: BlocConsumer<PersonCubit, PersonState>(
            listener: (ctx, state) {
              if (state is PersonError) {
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
              if (state is PersonLoading) return const LoadingState();
              if (state is PersonError) return Center(child: Text(state.message));
              if (state is PersonLoaded) {
                final filtered = _filter(state.persons);
                final types = _getTypes(state.persons);

                return Column(
                  children: [
                    Padding(
                      padding: EdgeInsets.fromLTRB(
                        AppConstants.spacing16,
                        AppConstants.spacing16,
                        AppConstants.spacing16,
                        0,
                      ),
                      child: AppSearchBar(
                        controller: _searchCtrl,
                        hintText: 'ابحث بالاسم أو رقم الهاتف...',
                        onChanged: (v) => setState(() => _searchQuery = v),
                      ),
                    ),
                    if (types.length > 1)
                      SizedBox(
                        height: 40,
                        child: ListView(
                          scrollDirection: Axis.horizontal,
                          padding: EdgeInsets.symmetric(
                            horizontal: AppConstants.spacing16,
                            vertical: AppConstants.spacing6,
                          ),
                          children: [
                            _filterChip(context, 'الكل', _typeFilter == null, () {
                              setState(() => _typeFilter = null);
                            }),
                            ...types.map((type) => _filterChip(
                              context, type, _typeFilter == type,
                              () => setState(() => _typeFilter = type),
                            )),
                          ],
                        ),
                      ),
                    if (filtered.isEmpty)
                      Expanded(
                        child: EmptyState(
                          icon: Icons.people_outline,
                          title: 'لا يوجد أشخاص',
                          subtitle: _searchQuery.isNotEmpty || _typeFilter != null
                              ? 'لا توجد نتائج للبحث'
                              : 'أضف أول شخص بالضغط على زر +',
                        ),
                      )
                    else
                      Expanded(
                        child: ListView.separated(
                          padding: EdgeInsets.all(AppConstants.spacing16),
                          itemCount: filtered.length,
                          separatorBuilder: (_, __) => SizedBox(height: AppConstants.spacing10),
                          itemBuilder: (_, i) {
                            final p = filtered[i];
                            return PersonCard(
                              person: p,
                              onTap: p.id != null
                                  ? () => _openDetail(context, p.id!)
                                  : null,
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
              if (!context.read<PersonCubit>().isProcessing) {
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

  Widget _filterChip(BuildContext context, String label, bool isActive, VoidCallback onTap) {
    return Padding(
      padding: EdgeInsets.only(left: AppConstants.spacing6),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: BoxDecoration(
            color: isActive ? AppColors.darkAccent.withValues(alpha: 0.15) : AppColors.darkBgCard,
            borderRadius: BorderRadius.circular(AppConstants.radiusChip),
            border: Border.all(color: isActive ? AppColors.darkAccent : AppColors.darkBorder),
          ),
          child: Text(
            label,
            style: AppTextStyles.categoryChip(context).copyWith(
              color: isActive ? AppColors.darkAccent : AppColors.darkTextSecondary,
            ),
          ),
        ),
      ),
    );
  }

  void _showAddModal(BuildContext context) {
    AppModal.show(
      context,
      AppModal(
        title: 'إضافة شخص جديد',
        child: AddPersonForm(
          onSubmit: (person) async {
            try {
              await context.read<PersonCubit>().add(person);
              if (context.mounted) Navigator.pop(context);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('تمت الإضافة بنجاح'),
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
        ),
      ),
    );
  }

  void _openDetail(BuildContext context, int id) {
    context.push('/person/$id');
  }
}
