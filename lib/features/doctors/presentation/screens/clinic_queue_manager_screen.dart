import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/services.dart';

import '../../../../core/localization/app_localizations.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_top_bar.dart';
import '../../../queue/logic/clinic_queue_cubit.dart';
import 'consultation_view_screen.dart';

class ClinicQueueManagerScreen extends StatefulWidget {
  const ClinicQueueManagerScreen({super.key, this.embedded = false});

  final bool embedded;

  @override
  State<ClinicQueueManagerScreen> createState() =>
      _ClinicQueueManagerScreenState();
}

class _ClinicQueueManagerScreenState extends State<ClinicQueueManagerScreen> {
  bool _isQueueActive = true;
  String _selectedFilter = 'All';
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _showAddPatientDialog(ClinicQueueCubit queueCubit) async {
    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController();
    final ageController = TextEditingController();
    var isFemale = false;
    var selectedVisitType = 'consultation';
    var selectedPriority = ClinicQueuePatientPriority.normal;

    try {
      await showDialog<void>(
        context: context,
        builder: (dialogContext) {
          return StatefulBuilder(
            builder: (dialogContext, setDialogState) {
              final estimatedSlot = queueCubit.nextAvailableStartMinutes();

              return AlertDialog(
                title: Text(
                  context.locText(en: 'Add Patient', ar: 'إضافة مريض'),
                ),
                content: SizedBox(
                  width: 420,
                  child: Form(
                    key: formKey,
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          TextFormField(
                            controller: nameController,
                            textInputAction: TextInputAction.next,
                            decoration: InputDecoration(
                              labelText: context.locText(
                                en: 'Patient name',
                                ar: 'اسم المريض',
                              ),
                              hintText: context.locText(
                                en: 'Enter patient name',
                                ar: 'اكتب اسم المريض',
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return context.locText(
                                  en: 'Patient name is required',
                                  ar: 'اسم المريض مطلوب',
                                );
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 14),
                          TextFormField(
                            controller: ageController,
                            keyboardType: TextInputType.number,
                            textInputAction: TextInputAction.done,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                            ],
                            decoration: InputDecoration(
                              labelText: context.locText(
                                en: 'Age',
                                ar: 'العمر',
                              ),
                              hintText: context.locText(
                                en: 'Enter age',
                                ar: 'اكتب العمر',
                              ),
                            ),
                            validator: (value) {
                              final age = int.tryParse(value ?? '');
                              if (age == null || age <= 0 || age > 120) {
                                return context.locText(
                                  en: 'Enter a valid age',
                                  ar: 'اكتب عمرًا صحيحًا',
                                );
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 14),
                          DropdownButtonFormField<bool>(
                            initialValue: isFemale,
                            decoration: InputDecoration(
                              labelText: context.locText(
                                en: 'Gender',
                                ar: 'النوع',
                              ),
                            ),
                            items: [
                              DropdownMenuItem<bool>(
                                value: false,
                                child: Text(
                                  context.locText(en: 'Male', ar: 'ذكر'),
                                ),
                              ),
                              DropdownMenuItem<bool>(
                                value: true,
                                child: Text(
                                  context.locText(en: 'Female', ar: 'أنثى'),
                                ),
                              ),
                            ],
                            onChanged: (value) {
                              setDialogState(() {
                                isFemale = value ?? false;
                              });
                            },
                          ),
                          const SizedBox(height: 14),
                          DropdownButtonFormField<String>(
                            initialValue: selectedVisitType,
                            decoration: InputDecoration(
                              labelText: context.locText(
                                en: 'Visit type',
                                ar: 'نوع الزيارة',
                              ),
                            ),
                            items: [
                              DropdownMenuItem<String>(
                                value: 'consultation',
                                child: Text(
                                  context.locText(
                                    en: 'Consultation',
                                    ar: 'استشارة',
                                  ),
                                ),
                              ),
                              DropdownMenuItem<String>(
                                value: 'follow_up',
                                child: Text(
                                  context.locText(
                                    en: 'Follow-up',
                                    ar: 'متابعة',
                                  ),
                                ),
                              ),
                              DropdownMenuItem<String>(
                                value: 'checkup',
                                child: Text(
                                  context.locText(
                                    en: 'Heart Checkup',
                                    ar: 'فحص قلب',
                                  ),
                                ),
                              ),
                              DropdownMenuItem<String>(
                                value: 'ecg',
                                child: Text(
                                  context.locText(
                                    en: 'ECG Test',
                                    ar: 'تخطيط قلب',
                                  ),
                                ),
                              ),
                            ],
                            onChanged: (value) {
                              setDialogState(() {
                                selectedVisitType = value ?? 'consultation';
                              });
                            },
                          ),
                          const SizedBox(height: 14),
                          DropdownButtonFormField<ClinicQueuePatientPriority>(
                            initialValue: selectedPriority,
                            decoration: InputDecoration(
                              labelText: context.locText(
                                en: 'Priority',
                                ar: 'الأولوية',
                              ),
                            ),
                            items: ClinicQueuePatientPriority.values
                                .map(
                                  (priority) =>
                                      DropdownMenuItem<
                                        ClinicQueuePatientPriority
                                      >(
                                        value: priority,
                                        child: Text(_priorityLabel(priority)),
                                      ),
                                )
                                .toList(growable: false),
                            onChanged: (value) {
                              setDialogState(() {
                                selectedPriority =
                                    value ?? ClinicQueuePatientPriority.normal;
                              });
                            },
                          ),
                          const SizedBox(height: 16),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.06),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  context.locText(
                                    en: 'Queue preview',
                                    ar: 'معاينة الدور',
                                  ),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.primary,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  context.locText(
                                    en: 'Queue #${queueCubit.totalPatients + 1} • Expected ${queueCubit.formatClock(estimatedSlot)}',
                                    ar: 'الدور #${queueCubit.totalPatients + 1} • المتوقع ${queueCubit.formatClock(estimatedSlot, useArabicPeriod: true)}',
                                  ),
                                  style: TextStyle(
                                    color: AppColors.textSecondary,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(dialogContext).pop(),
                    child: Text(context.l10n.tr('cancel')),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      if (!(formKey.currentState?.validate() ?? false)) {
                        return;
                      }

                      queueCubit.addPatient(
                        name: nameController.text.trim(),
                        age: int.parse(ageController.text.trim()),
                        isFemale: isFemale,
                        visitTypeEn: _visitTypeEn(selectedVisitType),
                        visitTypeAr: _visitTypeAr(selectedVisitType),
                        priority: selectedPriority,
                      );

                      Navigator.of(dialogContext).pop();

                      if (!mounted) {
                        return;
                      }

                      setState(() {
                        _selectedFilter = 'Waiting';
                      });

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            context.locText(
                              en: 'Patient added to the queue',
                              ar: 'تمت إضافة المريض إلى الطابور',
                            ),
                          ),
                        ),
                      );
                    },
                    child: Text(
                      context.locText(en: 'Add Patient', ar: 'إضافة مريض'),
                    ),
                  ),
                ],
              );
            },
          );
        },
      );
    } finally {
      nameController.dispose();
      ageController.dispose();
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ClinicQueueCubit, ClinicQueueState>(
      builder: (context, queueState) {
        final queueCubit = context.read<ClinicQueueCubit>();
        final visiblePatients = queueState.orderedPatients
            .where((patient) {
              switch (_selectedFilter) {
                case 'Waiting':
                  return patient.status == ClinicQueuePatientStatus.waiting;
                case 'In Progress':
                  return patient.status == ClinicQueuePatientStatus.inProgress;
                case 'Completed':
                  return patient.status == ClinicQueuePatientStatus.completed;
                default:
                  return true;
              }
            })
            .where(_matchesSearch)
            .toList(growable: false);

        return Scaffold(
          backgroundColor: AppColors.surface,
          body: Column(
            children: [
              AppTopBar(
                title: context.locText(en: 'Clinic Queue', ar: 'طابور العيادة'),
                showBackButton: !widget.embedded,
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 24),
                      _buildHeader(),
                      const SizedBox(height: 24),
                      _buildQueueStats(queueCubit),
                      const SizedBox(height: 24),
                      _buildSearchBar(),
                      const SizedBox(height: 16),
                      _buildFilterTabs(),
                      const SizedBox(height: 20),
                      if (visiblePatients.isEmpty)
                        _buildEmptyResultsState()
                      else
                        ...visiblePatients.map(
                          (patient) => Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: _buildPatientCard(
                              patient: patient,
                              queueCubit: queueCubit,
                            ),
                          ),
                        ),
                      const SizedBox(height: 100),
                    ],
                  ),
                ),
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () => _showAddPatientDialog(queueCubit),
            backgroundColor: AppColors.primary,
            icon: const Icon(Icons.person_add, color: Colors.white),
            label: Text(
              context.locText(en: 'Add Patient', ar: 'إضافة مريض'),
              style: const TextStyle(color: Colors.white),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: AppColors.textPrimary.withValues(alpha: 0.04),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        onChanged: (value) {
          setState(() {
            _searchQuery = value;
          });
        },
        decoration: InputDecoration(
          border: InputBorder.none,
          prefixIcon: const Icon(Icons.search, color: AppColors.textSecondary),
          hintText: context.locText(
            en: 'Search by patient name, queue number, or visit type',
            ar: 'ابحث باسم المريض أو رقم الدور أو نوع الزيارة',
          ),
          hintStyle: TextStyle(
            color: AppColors.textSecondary.withValues(alpha: 0.7),
            fontSize: 14,
          ),
          suffixIcon: _searchQuery.trim().isEmpty
              ? null
              : IconButton(
                  onPressed: () {
                    _searchController.clear();
                    setState(() {
                      _searchQuery = '';
                    });
                  },
                  icon: const Icon(Icons.close, color: AppColors.textSecondary),
                  tooltip: context.locText(en: 'Clear search', ar: 'مسح البحث'),
                ),
        ),
      ),
    );
  }

  Widget _buildEmptyResultsState() {
    final hasSearch = _searchQuery.trim().isNotEmpty;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: AppColors.textPrimary.withValues(alpha: 0.04),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(
            hasSearch ? Icons.search_off_rounded : Icons.groups_2_outlined,
            size: 40,
            color: AppColors.textSecondary.withValues(alpha: 0.6),
          ),
          const SizedBox(height: 12),
          Text(
            hasSearch
                ? context.locText(
                    en: 'No patient matches this search',
                    ar: 'لا يوجد مريض مطابق لهذا البحث',
                  )
                : context.locText(
                    en: 'No patients in this section',
                    ar: 'لا يوجد مرضى في هذا القسم',
                  ),
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            hasSearch
                ? context.locText(
                    en: 'Try another name, queue number, or visit type.',
                    ar: 'جرّب اسمًا آخر أو رقم دور أو نوع زيارة مختلف.',
                  )
                : context.locText(
                    en: 'Change the filter or add a new patient.',
                    ar: 'غيّر الفلتر أو أضف مريضًا جديدًا.',
                  ),
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary.withValues(alpha: 0.8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              context.locText(en: 'Clinic Queue', ar: 'طابور العيادة'),
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              context.locText(
                en: 'Manage your patient queue in real time',
                ar: 'أدر قائمة المرضى وتحديث الوقت بشكل مباشر',
              ),
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary.withValues(alpha: 0.7),
              ),
            ),
          ],
        ),
        GestureDetector(
          onTap: () => setState(() => _isQueueActive = !_isQueueActive),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: _isQueueActive
                  ? AppColors.success.withValues(alpha: 0.15)
                  : AppColors.surfaceContainerLow,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: _isQueueActive
                    ? AppColors.tertiary.withValues(alpha: 0.3)
                    : AppColors.outlineVariant,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _isQueueActive
                        ? AppColors.tertiary
                        : AppColors.outlineVariant,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  _isQueueActive
                      ? context.locText(en: 'Queue Active', ar: 'الطابور نشط')
                      : context.locText(
                          en: 'Queue Paused',
                          ar: 'الطابور متوقف',
                        ),
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: _isQueueActive
                        ? AppColors.tertiary
                        : AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildQueueStats(ClinicQueueCubit queueCubit) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary, AppColors.primaryContainer],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildStatItem(
              context.locText(en: 'Waiting', ar: 'انتظار'),
              '${queueCubit.waitingCount}',
              Icons.hourglass_empty,
              Colors.white,
            ),
          ),
          Container(
            width: 1,
            height: 50,
            color: Colors.white.withValues(alpha: 0.2),
          ),
          Expanded(
            child: _buildStatItem(
              context.locText(en: 'In Progress', ar: 'قيد المعالجة'),
              '${queueCubit.activeCount}',
              Icons.person,
              AppColors.tertiaryFixedDim,
            ),
          ),
          Container(
            width: 1,
            height: 50,
            color: Colors.white.withValues(alpha: 0.2),
          ),
          Expanded(
            child: _buildStatItem(
              context.locText(en: 'Completed', ar: 'مكتمل'),
              '${queueCubit.completedCount}',
              Icons.check_circle_outline,
              Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(
    String label,
    String value,
    IconData icon,
    Color iconColor,
  ) {
    return Column(
      children: [
        Icon(icon, color: iconColor, size: 24),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w800,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: Colors.white.withValues(alpha: 0.8),
          ),
        ),
      ],
    );
  }

  Widget _buildFilterTabs() {
    final filters = ['All', 'Waiting', 'In Progress', 'Completed'];
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: filters.map((filter) {
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
                  _localizedFilterLabel(filter),
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

  Widget _buildPatientCard({
    required ClinicQueuePatient patient,
    required ClinicQueueCubit queueCubit,
  }) {
    final statusColor = _statusColor(patient.status);
    final priorityColor = _priorityColor(patient.priority);
    final estimatedStart = queueCubit.estimatedStartMinutesFor(patient.id);
    final delayMinutes = queueCubit.delayMinutesFor(patient.id);
    final canCallPatient = queueCubit.canCallPatient(patient.id);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: patient.status == ClinicQueuePatientStatus.inProgress
            ? Border.all(
                color: AppColors.warning.withValues(alpha: 0.4),
                width: 2,
              )
            : null,
        boxShadow: [
          BoxShadow(
            color: AppColors.textPrimary.withValues(alpha: 0.04),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    '#${patient.queueNumber}',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: statusColor,
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              context.l10n.isArabic
                                  ? patient.nameAr
                                  : patient.nameEn,
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ),
                          if (patient.priority !=
                              ClinicQueuePatientPriority.normal)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: priorityColor.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                _priorityLabel(patient.priority),
                                style: TextStyle(
                                  fontSize: 8,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.5,
                                  color: priorityColor,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${context.l10n.isArabic ? patient.genderAr : patient.genderEn}، ${patient.age} ${context.locText(en: 'years', ar: 'سنة')} • ${context.l10n.isArabic ? patient.visitTypeAr : patient.visitTypeEn}',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary.withValues(alpha: 0.7),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          _buildMetaPill(
                            icon: Icons.login_rounded,
                            text: context.locText(
                              en: 'Check-in ${patient.checkInTime}',
                              ar: 'الحضور ${patient.checkInTime}',
                            ),
                          ),
                          _buildMetaPill(
                            icon: Icons.event_available_outlined,
                            text: context.locText(
                              en: 'Booked ${patient.scheduledTime}',
                              ar: 'الحجز ${patient.scheduledTime}',
                            ),
                          ),
                          _buildMetaPill(
                            icon: Icons.schedule,
                            text: context.locText(
                              en: 'Expected ${queueCubit.formatClock(estimatedStart)}',
                              ar: 'المتوقع ${queueCubit.formatClock(estimatedStart, useArabicPeriod: true)}',
                            ),
                            color: delayMinutes > 0
                                ? AppColors.warning
                                : AppColors.primary,
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(
                            _statusIcon(patient.status),
                            size: 14,
                            color: statusColor,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            _statusLabel(patient.status),
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: statusColor,
                            ),
                          ),
                          if (delayMinutes > 0) ...[
                            const SizedBox(width: 10),
                            Text(
                              context.locText(
                                en: '+$delayMinutes min delay',
                                ar: 'تأخير +$delayMinutes دقيقة',
                              ),
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: AppColors.warning,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (patient.status != ClinicQueuePatientStatus.completed)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLow.withValues(alpha: 0.55),
                borderRadius: const BorderRadius.vertical(
                  bottom: Radius.circular(16),
                ),
              ),
              child: patient.status == ClinicQueuePatientStatus.waiting
                  ? Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: null,
                            child: Text(
                              context.locText(
                                en: 'ETA ${queueCubit.formatClock(estimatedStart)}',
                                ar: 'الوقت ${queueCubit.formatClock(estimatedStart, useArabicPeriod: true)}',
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          flex: 2,
                          child: ElevatedButton.icon(
                            onPressed: canCallPatient
                                ? () {
                                    queueCubit.callPatient(patient.id);
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute<void>(
                                        builder: (_) => ConsultationViewScreen(
                                          patientId: patient.id,
                                        ),
                                      ),
                                    );
                                  }
                                : null,
                            icon: const Icon(
                              Icons.notifications_active_outlined,
                              size: 18,
                              color: Colors.white,
                            ),
                            label: Text(
                              canCallPatient
                                  ? context.locText(
                                      en: 'Call Patient',
                                      ar: 'استدعاء المريض',
                                    )
                                  : context.locText(
                                      en: 'Waiting for current case',
                                      ar: 'بانتظار انتهاء الحالة الحالية',
                                    ),
                            ),
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 10),
                            ),
                          ),
                        ),
                      ],
                    )
                  : Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () {
                              queueCubit.addDelayToActivePatient(minutes: 10);
                            },
                            icon: const Icon(Icons.schedule, size: 16),
                            label: Text(
                              context.locText(
                                en: '+10 min delay',
                                ar: 'تأخير +10 د',
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          flex: 2,
                          child: ElevatedButton.icon(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute<void>(
                                  builder: (_) => ConsultationViewScreen(
                                    patientId: patient.id,
                                  ),
                                ),
                              );
                            },
                            icon: const Icon(
                              Icons.play_arrow,
                              size: 18,
                              color: Colors.white,
                            ),
                            label: Text(
                              context.locText(
                                en: 'Continue Consultation',
                                ar: 'متابعة الكشف',
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 10),
                            ),
                          ),
                        ),
                      ],
                    ),
            ),
        ],
      ),
    );
  }

  Widget _buildMetaPill({
    required IconData icon,
    required String text,
    Color? color,
  }) {
    final pillColor = color ?? AppColors.textSecondary;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: pillColor.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: pillColor),
          const SizedBox(width: 6),
          Text(
            text,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: pillColor,
            ),
          ),
        ],
      ),
    );
  }

  String _localizedFilterLabel(String filter) {
    switch (filter) {
      case 'Waiting':
        return context.locText(en: filter, ar: 'انتظار');
      case 'In Progress':
        return context.locText(en: filter, ar: 'قيد المعالجة');
      case 'Completed':
        return context.locText(en: filter, ar: 'مكتمل');
      default:
        return context.locText(en: 'All', ar: 'الكل');
    }
  }

  Color _statusColor(ClinicQueuePatientStatus status) {
    switch (status) {
      case ClinicQueuePatientStatus.inProgress:
        return AppColors.warning;
      case ClinicQueuePatientStatus.completed:
        return AppColors.tertiary;
      case ClinicQueuePatientStatus.waiting:
        return AppColors.textSecondary;
    }
  }

  IconData _statusIcon(ClinicQueuePatientStatus status) {
    switch (status) {
      case ClinicQueuePatientStatus.inProgress:
        return Icons.person;
      case ClinicQueuePatientStatus.completed:
        return Icons.check_circle;
      case ClinicQueuePatientStatus.waiting:
        return Icons.hourglass_empty;
    }
  }

  String _statusLabel(ClinicQueuePatientStatus status) {
    switch (status) {
      case ClinicQueuePatientStatus.inProgress:
        return context.locText(en: 'In Progress', ar: 'قيد المعالجة');
      case ClinicQueuePatientStatus.completed:
        return context.locText(en: 'Completed', ar: 'مكتمل');
      case ClinicQueuePatientStatus.waiting:
        return context.locText(en: 'Waiting', ar: 'انتظار');
    }
  }

  Color _priorityColor(ClinicQueuePatientPriority priority) {
    switch (priority) {
      case ClinicQueuePatientPriority.urgent:
        return AppColors.error;
      case ClinicQueuePatientPriority.high:
        return AppColors.warning;
      case ClinicQueuePatientPriority.normal:
        return AppColors.textSecondary;
    }
  }

  String _priorityLabel(ClinicQueuePatientPriority priority) {
    switch (priority) {
      case ClinicQueuePatientPriority.urgent:
        return context.locText(en: 'URGENT', ar: 'عاجل');
      case ClinicQueuePatientPriority.high:
        return context.locText(en: 'HIGH', ar: 'مرتفع');
      case ClinicQueuePatientPriority.normal:
        return context.locText(en: 'NORMAL', ar: 'عادي');
    }
  }

  String _visitTypeEn(String visitType) {
    switch (visitType) {
      case 'follow_up':
        return 'Follow-up';
      case 'checkup':
        return 'Heart Checkup';
      case 'ecg':
        return 'ECG Test';
      default:
        return 'Consultation';
    }
  }

  String _visitTypeAr(String visitType) {
    switch (visitType) {
      case 'follow_up':
        return 'متابعة';
      case 'checkup':
        return 'فحص قلب';
      case 'ecg':
        return 'تخطيط قلب';
      default:
        return 'استشارة';
    }
  }

  bool _matchesSearch(ClinicQueuePatient patient) {
    final normalizedQuery = _normalizeSearchText(_searchQuery);
    if (normalizedQuery.isEmpty) {
      return true;
    }

    final searchableFields = [
      patient.nameEn,
      patient.nameAr,
      patient.visitTypeEn,
      patient.visitTypeAr,
      patient.queueNumber.toString(),
      '#${patient.queueNumber}',
      patient.scheduledTime,
      patient.checkInTime,
    ];

    return searchableFields.any(
      (field) => _normalizeSearchText(field).contains(normalizedQuery),
    );
  }

  String _normalizeSearchText(String input) {
    final easternArabicDigits = {
      '٠': '0',
      '١': '1',
      '٢': '2',
      '٣': '3',
      '٤': '4',
      '٥': '5',
      '٦': '6',
      '٧': '7',
      '٨': '8',
      '٩': '9',
    };

    var normalized = input.trim().toLowerCase();
    easternArabicDigits.forEach((key, value) {
      normalized = normalized.replaceAll(key, value);
    });

    return normalized.replaceAll(RegExp(r'\s+'), ' ');
  }
}
