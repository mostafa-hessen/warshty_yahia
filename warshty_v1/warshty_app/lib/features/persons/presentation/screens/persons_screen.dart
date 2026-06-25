import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/injection_container.dart';
import '../../../../core/presentation/widgets/empty_state.dart';
import '../../../../core/presentation/widgets/app_filter_chip.dart';
import '../../../../core/presentation/widgets/loading_state.dart';
import '../../../../core/presentation/widgets/app_modal.dart';
import '../../../../core/presentation/widgets/search_bar.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/presentation/widgets/theme_toggle_button.dart';
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

  static const _presetTypes = ['عميل', 'مورد', 'شركة', 'صنايعي', 'مقاول'];

  Set<String> _getAllTypes(List<PersonModel> persons) {
    final custom = persons.map((p) => p.type).toSet();
    return {..._presetTypes, ...custom};
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<PersonCubit>()..load(),
      child: Builder(
        builder: (context) => Scaffold(
          appBar: AppBar(
            title: const Text('الأشخاص'),
            actions: [const ThemeToggleButton()],
          ),
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
                final types = _getAllTypes(state.persons);

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
                    SizedBox(
                      height: 40,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        padding: EdgeInsets.symmetric(
                          horizontal: AppConstants.spacing16,
                          vertical: AppConstants.spacing6,
                        ),
                        children: [
                          AppFilterChip(label: 'الكل', isActive: _typeFilter == null, onTap: () => setState(() => _typeFilter = null)),
                          ...types.map((type) => AppFilterChip(
                            label: type,
                            isActive: _typeFilter == type,
                            onTap: () => setState(() => _typeFilter = type),
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
                        child: RefreshIndicator(
                          onRefresh: () => context.read<PersonCubit>().load(),
                          child: ListView.separated(
                            physics: const AlwaysScrollableScrollPhysics(),
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
        title: 'إضافة شخص جديد',
        child: AddPersonForm(
          onSubmit: (person) => _submitWithFeedback(context, () async {
            await context.read<PersonCubit>().add(person);
          }),
        ),
      ),
    );
  }

  Future<void> _openDetail(BuildContext context, int id) async {
    await context.push('/person/$id');
    if (context.mounted) {
      context.read<PersonCubit>().load();
    }
  }
}
