import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injection_container.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/bottom_nav_bar.dart';
import '../../../../core/widgets/app_top_bar.dart';
import '../../../home/presentation/screens/patient_tab_navigation.dart';
import '../../data/models/doctor_model.dart';
import '../../logic/doctors_cubit.dart';
import '../../logic/doctors_state.dart';
import 'doctor_profile_screen.dart';

class DoctorSearchScreen extends StatelessWidget {
  const DoctorSearchScreen({super.key, this.embedded = false});

  final bool embedded;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<DoctorsCubit>()..fetchDoctors(),
      child: _DoctorSearchView(embedded: embedded),
    );
  }
}

class _DoctorSearchView extends StatefulWidget {
  const _DoctorSearchView({required this.embedded});

  final bool embedded;

  @override
  State<_DoctorSearchView> createState() => _DoctorSearchViewState();
}

class _DoctorSearchViewState extends State<_DoctorSearchView> {
  final _searchController = TextEditingController();
  String? _selectedFilter;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    context.read<DoctorsCubit>().searchDoctors(query);
  }

  void _onFilterSelected(String? specialty) {
    setState(() => _selectedFilter = specialty);
    context.read<DoctorsCubit>().filterBySpecialty(specialty);
  }

  void _navigateToProfile(DoctorModel doctor) {
    Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder: (_) =>
            DoctorProfileScreen(doctorId: doctor.id, doctorName: doctor.name),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final content = Column(
      children: [
        AppTopBar(showBackButton: !widget.embedded),
        Expanded(
          child: RefreshIndicator(
            onRefresh: () => context.read<DoctorsCubit>().refreshDoctors(),
            color: AppColors.primary,
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 24),
                        Text(
                          context.locText(
                            en: 'Find a Specialist',
                            ar: 'ابحث عن طبيب مختص',
                          ),
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textPrimary,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          context.locText(
                            en:
                                'Access the best healthcare providers across Libya with instant booking.',
                            ar:
                                'استعرض أفضل مقدمي الرعاية الصحية في ليبيا واحجز موعدك فورًا.',
                          ),
                          style: TextStyle(
                            fontSize: 15,
                            color: AppColors.textSecondary.withValues(
                              alpha: 0.8,
                            ),
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: 24),
                        _SearchBar(
                          controller: _searchController,
                          onChanged: _onSearchChanged,
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: BlocBuilder<DoctorsCubit, DoctorsState>(
                    builder: (context, state) {
                      if (state is DoctorsLoaded) {
                        return _FilterChips(
                          specialties: state.specialties,
                          selectedFilter: _selectedFilter,
                          onFilterSelected: _onFilterSelected,
                        );
                      }
                      return const SizedBox.shrink();
                    },
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 28)),
                BlocBuilder<DoctorsCubit, DoctorsState>(
                  builder: (context, state) {
                    if (state is DoctorsLoading) {
                      return const SliverFillRemaining(
                        child: Center(
                          child: CircularProgressIndicator(
                            color: AppColors.primary,
                          ),
                        ),
                      );
                    }

                    if (state is DoctorsError) {
                      return SliverFillRemaining(
                        child: _ErrorView(
                          message: state.message,
                          onRetry: () =>
                              context.read<DoctorsCubit>().fetchDoctors(),
                        ),
                      );
                    }

                    if (state is DoctorsLoaded) {
                      final doctors = state.displayDoctors;

                      if (doctors.isEmpty) {
                        return SliverFillRemaining(
                          child: _EmptyView(
                            hasFilters:
                                state.searchQuery.isNotEmpty ||
                                state.selectedSpecialty != null,
                            onClearFilters: () {
                              _searchController.clear();
                              setState(() => _selectedFilter = null);
                              context.read<DoctorsCubit>().clearFilters();
                            },
                          ),
                        );
                      }

                      return SliverPadding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        sliver: SliverList(
                          delegate: SliverChildBuilderDelegate((
                            context,
                            index,
                          ) {
                            if (index == doctors.length) {
                              return const SizedBox(height: 100);
                            }
                            final doctor = doctors[index];
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 20),
                              child: _DoctorCard(
                                doctor: doctor,
                                onViewProfile: () => _navigateToProfile(doctor),
                                onBook: () => _navigateToProfile(doctor),
                              ),
                            );
                          }, childCount: doctors.length + 1),
                        ),
                      );
                    }

                    return const SliverToBoxAdapter(child: SizedBox.shrink());
                  },
                ),
              ],
            ),
          ),
        ),
      ],
    );

    if (widget.embedded) {
      return content;
    }

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: content,
      bottomNavigationBar: AppBottomNavBar(
        currentIndex: 1,
        onTap: (index) {
          if (index == 1) return;
          navigateToPatientRootTab(context, index);
        },
      ),
    );
  }
}

// ============ Search Bar Widget ============

class _SearchBar extends StatelessWidget {
  const _SearchBar({required this.controller, required this.onChanged});

  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 8),
        ],
      ),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        decoration: InputDecoration(
          hintText: context.locText(
            en: 'Search by doctor name or specialty...',
            ar: 'ابحث باسم الطبيب أو التخصص...',
          ),
          prefixIcon: const Icon(Icons.search, color: AppColors.outline),
          suffixIcon: controller.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear, size: 20),
                  onPressed: () {
                    controller.clear();
                    onChanged('');
                  },
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            vertical: 16,
            horizontal: 16,
          ),
        ),
      ),
    );
  }
}

// ============ Filter Chips Widget ============

class _FilterChips extends StatelessWidget {
  const _FilterChips({
    required this.specialties,
    required this.selectedFilter,
    required this.onFilterSelected,
  });

  final List<String> specialties;
  final String? selectedFilter;
  final ValueChanged<String?> onFilterSelected;

  @override
  Widget build(BuildContext context) {
    final allSpecialists = context.locText(
      en: 'All Specialists',
      ar: 'كل التخصصات',
    );
    final filters = [allSpecialists, ...specialties];

    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: filters.length,
        separatorBuilder: (context, index) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final filter = filters[index];
          final isAll = filter == allSpecialists;
          final isSelected = isAll
              ? selectedFilter == null
              : filter == selectedFilter;

          return GestureDetector(
            onTap: () => onFilterSelected(isAll ? null : filter),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.primary
                    : AppColors.surfaceContainerHigh,
                borderRadius: BorderRadius.circular(20),
              ),
              alignment: Alignment.center,
              child: Text(
                filter,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: isSelected ? Colors.white : AppColors.textPrimary,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

// ============ Doctor Card Widget ============

class _DoctorCard extends StatelessWidget {
  const _DoctorCard({
    required this.doctor,
    required this.onViewProfile,
    required this.onBook,
  });

  final DoctorModel doctor;
  final VoidCallback onViewProfile;
  final VoidCallback onBook;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.textPrimary.withValues(alpha: 0.06),
            blurRadius: 32,
            offset: const Offset(0, 16),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Avatar
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: doctor.imageUrl != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Image.network(
                          doctor.imageUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              _buildInitials(),
                        ),
                      )
                    : _buildInitials(),
              ),
              const SizedBox(width: 16),
              // Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            doctor.name,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                        // Rating
                        if (doctor.rating != null)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.surfaceContainerLow,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.star,
                                  size: 14,
                                  color: Colors.amber,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  doctor.rating!.toStringAsFixed(1),
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      doctor.specialty,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.tertiary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Details row
                    Wrap(
                      spacing: 16,
                      runSpacing: 8,
                      children: [
                        _DetailItem(
                          icon: Icons.payments_outlined,
                          text: doctor.formattedFee,
                        ),
                        if (doctor.isActive)
                          _DetailItem(
                            icon: Icons.check_circle,
                            text: context.locText(
                              en: 'Available',
                              ar: 'متاح',
                            ),
                            color: AppColors.tertiaryFixedDim,
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          // Divider
          Container(height: 1, color: AppColors.surfaceContainerHigh),
          const SizedBox(height: 16),
          // Buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: onViewProfile,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.textPrimary,
                    side: const BorderSide(
                      color: AppColors.surfaceContainerHigh,
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: Text(
                    context.locText(en: 'View Profile', ar: 'عرض الملف'),
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: onBook,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    minimumSize: Size.zero,
                  ),
                  child: Text(
                    context.locText(en: 'Book Now', ar: 'احجز الآن'),
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInitials() {
    return Center(
      child: Text(
        doctor.initials,
        style: const TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w700,
          color: AppColors.primary,
        ),
      ),
    );
  }
}

// ============ Detail Item Widget ============

class _DetailItem extends StatelessWidget {
  const _DetailItem({required this.icon, required this.text, this.color});

  final IconData icon;
  final String text;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final itemColor = color ?? AppColors.textSecondary;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: itemColor),
        const SizedBox(width: 4),
        Text(
          text,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: itemColor.withValues(alpha: 0.8),
          ),
        ),
      ],
    );
  }
}

// ============ Error View Widget ============

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: AppColors.error.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15,
                color: AppColors.textSecondary.withValues(alpha: 0.8),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh, size: 18),
              label: Text(context.l10n.tr('retry')),
            ),
          ],
        ),
      ),
    );
  }
}

// ============ Empty View Widget ============

class _EmptyView extends StatelessWidget {
  const _EmptyView({required this.hasFilters, required this.onClearFilters});

  final bool hasFilters;
  final VoidCallback onClearFilters;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              hasFilters ? Icons.search_off : Icons.medical_services_outlined,
              size: 64,
              color: AppColors.outline.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 16),
            Text(
              hasFilters
                  ? context.locText(
                      en: 'No doctors match your search criteria',
                      ar: 'لا يوجد أطباء يطابقون معايير البحث',
                    )
                  : context.locText(
                      en: 'No doctors available at the moment',
                      ar: 'لا يوجد أطباء متاحون حاليًا',
                    ),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15,
                color: AppColors.textSecondary.withValues(alpha: 0.8),
              ),
            ),
            if (hasFilters) ...[
              const SizedBox(height: 24),
              OutlinedButton(
                onPressed: onClearFilters,
                child: Text(
                  context.locText(en: 'Clear Filters', ar: 'مسح الفلاتر'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
