import 'package:flutter/material.dart';

import '../../../../core/localization/app_localizations.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/bottom_nav_bar.dart';
import '../../../../core/widgets/app_top_bar.dart';
import '../../../home/presentation/screens/patient_tab_navigation.dart';

class FacilityListingScreen extends StatefulWidget {
  const FacilityListingScreen({super.key});

  @override
  State<FacilityListingScreen> createState() => _FacilityListingScreenState();
}

class _FacilityListingScreenState extends State<FacilityListingScreen> {
  String _selectedFilter = 'All';
  final List<String> _filters = ['All', 'ICU', 'Private', 'Ward', 'Emergency'];

  final List<Map<String, dynamic>> _facilities = [
    {
      'name': 'Tripoli Medical Center',
      'type': 'Government Hospital',
      'rating': 4.8,
      'reviews': 234,
      'distance': '2.5 km',
      'icuBeds': 12,
      'privateBeds': 45,
      'wardBeds': 120,
      'isOpen': true,
      'waitTime': '~15 min',
    },
    {
      'name': 'Al-Jala Hospital',
      'type': 'Specialized Hospital',
      'rating': 4.6,
      'reviews': 189,
      'distance': '4.2 km',
      'icuBeds': 8,
      'privateBeds': 32,
      'wardBeds': 85,
      'isOpen': true,
      'waitTime': '~25 min',
    },
    {
      'name': 'Benghazi Medical Center',
      'type': 'Government Hospital',
      'rating': 4.5,
      'reviews': 156,
      'distance': '6.8 km',
      'icuBeds': 15,
      'privateBeds': 50,
      'wardBeds': 200,
      'isOpen': false,
      'waitTime': 'Closed',
    },
    {
      'name': 'Libya Heart Center',
      'type': 'Private Clinic',
      'rating': 4.9,
      'reviews': 312,
      'distance': '3.1 km',
      'icuBeds': 6,
      'privateBeds': 28,
      'wardBeds': 0,
      'isOpen': true,
      'waitTime': '~10 min',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final facilitiesFound = context.locText(
      en: '${_facilities.length} Facilities Found',
      ar: '${_facilities.length} مرفقًا متاحًا',
    );

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: Column(
        children: [
          const AppTopBar(showBackButton: true),
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 24),
                    // Hero section
                    _buildHeroSection(),
                    const SizedBox(height: 24),
                    // Search bar
                    _buildSearchBar(),
                    const SizedBox(height: 20),
                    // Filter chips
                    _buildFilterChips(),
                    const SizedBox(height: 24),
                    // Quick stats
                    _buildQuickStats(),
                    const SizedBox(height: 24),
                    // Results header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          facilitiesFound,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        TextButton.icon(
                          onPressed: () {},
                          icon: const Icon(Icons.tune, size: 16),
                          label: Text(
                            context.locText(en: 'Sort', ar: 'ترتيب'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // Facility cards
                    ..._facilities.map(
                      (f) => Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: _buildFacilityCard(f),
                      ),
                    ),
                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: AppBottomNavBar(
        currentIndex: 1,
        onTap: (index) {
          if (index == 1) return;
          navigateToPatientRootTab(context, index);
        },
      ),
    );
  }

  Widget _buildHeroSection() {
    final t = context;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary, AppColors.primaryContainer],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.tertiaryFixedDim,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        t.locText(
                          en: 'REAL-TIME AVAILABILITY',
                          ar: 'التوفر المباشر',
                        ),
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  t.locText(
                    en: 'Hospital Rooms\n& Facilities',
                    ar: 'غرف المستشفى\nوالمرافق',
                  ),
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  t.locText(
                    en:
                        'Find and book available hospital beds, ICU rooms, and specialized care facilities.',
                    ar:
                        'ابحث عن أسرّة المستشفيات وغرف العناية والمرافق الطبية المتاحة واحجزها.',
                  ),
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withValues(alpha: 0.8),
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 20),
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(
              Icons.local_hospital,
              size: 40,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.textPrimary.withValues(alpha: 0.04),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: TextField(
        decoration: InputDecoration(
          hintText: context.locText(
            en: 'Search hospitals, clinics...',
            ar: 'ابحث عن مستشفيات أو عيادات...',
          ),
          prefixIcon: const Icon(Icons.search, color: AppColors.outlineVariant),
          suffixIcon: Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.my_location, color: Colors.white, size: 20),
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 16,
          ),
        ),
      ),
    );
  }

  Widget _buildFilterChips() {
    final labels = {
      'All': context.locText(en: 'All', ar: 'الكل'),
      'ICU': context.locText(en: 'ICU', ar: 'عناية'),
      'Private': context.locText(en: 'Private', ar: 'خاص'),
      'Ward': context.locText(en: 'Ward', ar: 'عنابر'),
      'Emergency': context.locText(en: 'Emergency', ar: 'طوارئ'),
    };

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: _filters.map((filter) {
          final isSelected = _selectedFilter == filter;
          return Padding(
            padding: const EdgeInsets.only(right: 10),
            child: GestureDetector(
              onTap: () => setState(() => _selectedFilter = filter),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primary : Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: isSelected
                        ? AppColors.primary
                        : AppColors.surfaceContainerHigh,
                  ),
                ),
                child: Text(
                  labels[filter] ?? filter,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: isSelected ? Colors.white : AppColors.textSecondary,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildQuickStats() {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            Icons.bed,
            '287',
            context.locText(en: 'Available Beds', ar: 'الأسرّة المتاحة'),
            AppColors.tertiary,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            Icons.medical_services,
            '23',
            context.locText(en: 'ICU Units', ar: 'وحدات العناية'),
            AppColors.warning,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            Icons.local_hospital,
            '12',
            context.locText(en: 'Hospitals', ar: 'مستشفيات'),
            AppColors.primary,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(
    IconData icon,
    String value,
    String label,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: AppColors.textSecondary.withValues(alpha: 0.8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFacilityCard(Map<String, dynamic> facility) {
    return Container(
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
          // Header
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.surfaceContainerLow, Colors.white],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(20),
              ),
            ),
            child: Row(
              children: [
                // Icon
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(
                    Icons.local_hospital,
                    color: AppColors.primary,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                // Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              _localizedFacilityName(facility['name'] as String),
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: (facility['isOpen'] as bool)
                                  ? AppColors.success.withValues(alpha: 0.15)
                                  : AppColors.error.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 6,
                                  height: 6,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: (facility['isOpen'] as bool)
                                        ? AppColors.tertiary
                                        : AppColors.error,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  (facility['isOpen'] as bool)
                                      ? context.locText(
                                          en: 'OPEN',
                                          ar: 'مفتوح',
                                        )
                                      : context.locText(
                                          en: 'CLOSED',
                                          ar: 'مغلق',
                                        ),
                                  style: TextStyle(
                                    fontSize: 9,
                                    fontWeight: FontWeight.w700,
                                    color: (facility['isOpen'] as bool)
                                        ? AppColors.tertiary
                                        : AppColors.error,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        _localizedFacilityType(facility['type'] as String),
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary.withValues(alpha: 0.7),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(Icons.star, size: 14, color: Colors.amber),
                          const SizedBox(width: 4),
                          Text(
                            context.locText(
                              en:
                                  '${facility['rating']} (${facility['reviews']} reviews)',
                              ar:
                                  '${facility['rating']} (${facility['reviews']} تقييم)',
                            ),
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary.withValues(
                                alpha: 0.8,
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          const Icon(
                            Icons.location_on_outlined,
                            size: 14,
                            color: AppColors.textSecondary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            _localizedDistance(facility['distance'] as String),
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary.withValues(
                                alpha: 0.8,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Bed availability
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _buildBedInfo(
                        context.locText(en: 'ICU Beds', ar: 'أسرة العناية'),
                        facility['icuBeds'] as int,
                        AppColors.error,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildBedInfo(
                        context.locText(en: 'Private', ar: 'خاص'),
                        facility['privateBeds'] as int,
                        AppColors.primary,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildBedInfo(
                        context.locText(en: 'Ward', ar: 'عنابر'),
                        facility['wardBeds'] as int,
                        AppColors.tertiary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceContainerLow,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.timer_outlined,
                              size: 18,
                              color: AppColors.textSecondary,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              context.locText(
                                en: 'Wait: ${facility['waitTime']}',
                                ar:
                                    'الانتظار: ${_localizedWaitTime(facility['waitTime'] as String)}',
                              ),
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textSecondary.withValues(
                                  alpha: 0.8,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: (facility['isOpen'] as bool) ? () {} : null,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: Text(
                          context.locText(en: 'Book Room', ar: 'احجز غرفة'),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBedInfo(String label, int count, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(
            '$count',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w500,
              color: AppColors.textSecondary.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }

  String _localizedFacilityType(String type) {
    if (!context.l10n.isArabic) return type;

    switch (type) {
      case 'Government Hospital':
        return 'مستشفى حكومي';
      case 'Specialized Hospital':
        return 'مستشفى تخصصي';
      case 'Private Clinic':
        return 'عيادة خاصة';
      default:
        return type;
    }
  }

  String _localizedFacilityName(String name) {
    if (!context.l10n.isArabic) return name;

    switch (name) {
      case 'Tripoli Medical Center':
        return 'مركز طرابلس الطبي';
      case 'Al-Jala Hospital':
        return 'مستشفى الجلاء';
      case 'Benghazi Medical Center':
        return 'مركز بنغازي الطبي';
      case 'Libya Heart Center':
        return 'مركز ليبيا للقلب';
      default:
        return name;
    }
  }

  String _localizedDistance(String distance) {
    if (!context.l10n.isArabic) return distance;
    return distance.replaceAll(' km', ' كم');
  }

  String _localizedWaitTime(String waitTime) {
    if (!context.l10n.isArabic) return waitTime;

    switch (waitTime) {
      case '~15 min':
        return '~15 دقيقة';
      case '~25 min':
        return '~25 دقيقة';
      case '~10 min':
        return '~10 دقائق';
      case 'Closed':
        return 'مغلق';
      default:
        return waitTime;
    }
  }
}
