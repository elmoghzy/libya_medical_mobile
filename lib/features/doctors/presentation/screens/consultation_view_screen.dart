import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/localization/app_localizations.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_top_bar.dart';
import '../../../queue/logic/clinic_queue_cubit.dart';

class ConsultationViewScreen extends StatefulWidget {
  const ConsultationViewScreen({super.key, this.patientId});

  final int? patientId;

  @override
  State<ConsultationViewScreen> createState() => _ConsultationViewScreenState();
}

class _ConsultationViewScreenState extends State<ConsultationViewScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _notesController = TextEditingController();
  final _diagnosisController = TextEditingController();
  final _prescriptionController = TextEditingController();

  final List<String> _selectedSymptoms = ['Chest Pain', 'Shortness of Breath'];
  final List<String> _availableSymptoms = [
    'Chest Pain',
    'Shortness of Breath',
    'Fatigue',
    'Dizziness',
    'Palpitations',
    'Swelling',
    'Nausea',
    'Headache',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _notesController.dispose();
    _diagnosisController.dispose();
    _prescriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: Column(
        children: [
          const AppTopBar(showBackButton: true),
          Expanded(
            child: Row(
              children: [
                // Left panel - Patient info
                SizedBox(width: 320, child: _buildPatientPanel()),
                // Right panel - Consultation form
                Expanded(child: _buildConsultationPanel()),
              ],
            ),
          ),
        ],
      ),
    );
  }

  ClinicQueuePatient? get _currentPatient {
    final queueState = context.read<ClinicQueueCubit>().state;
    if (widget.patientId != null) {
      return queueState.patientById(widget.patientId!);
    }
    return queueState.activePatient;
  }

  Widget _buildPatientPanel() {
    final patient = _currentPatient;
    final patientName = patient == null
        ? context.locText(en: 'Fatima Al-Farsi', ar: 'فاطمة الفارسي')
        : (context.l10n.isArabic ? patient.nameAr : patient.nameEn);
    final patientMeta = patient == null
        ? context.locText(
            en: 'Female, 34 years • Patient ID: P-2024-0847',
            ar: 'أنثى، 34 سنة • رقم المريض: P-2024-0847',
          )
        : '${context.l10n.isArabic ? patient.genderAr : patient.genderEn}، ${patient.age} ${context.locText(en: 'years', ar: 'سنة')} • ${context.locText(en: 'Queue #${patient.queueNumber}', ar: 'رقم الدور ${patient.queueNumber}')}';

    return Container(
      margin: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
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
          // Patient header
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.primary, AppColors.primaryContainer],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(24),
              ),
            ),
            child: Column(
              children: [
                // Active badge
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                            context.locText(
                              en: 'CONSULTATION ACTIVE',
                              ar: 'الاستشارة نشطة',
                            ),
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.5,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.more_vert,
                        color: Colors.white,
                        size: 18,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                // Avatar
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Icon(
                    Icons.person,
                    size: 40,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  patientName,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  patientMeta,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white.withValues(alpha: 0.8),
                  ),
                ),
                const SizedBox(height: 16),
                // Timer
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.timer_outlined,
                        color: Colors.white,
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        '00:12:34',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          fontFamily: 'monospace',
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Patient details
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildInfoSection(
                    context.locText(en: 'Vitals', ar: 'العلامات الحيوية'),
                    [
                      _buildVitalItem(
                        context.locText(en: 'Blood Pressure', ar: 'ضغط الدم'),
                        '120/80',
                        'mmHg',
                        AppColors.tertiary,
                      ),
                      _buildVitalItem(
                        context.locText(en: 'Heart Rate', ar: 'معدل النبض'),
                        '72',
                        'bpm',
                        AppColors.primary,
                      ),
                      _buildVitalItem(
                        context.locText(en: 'Temperature', ar: 'الحرارة'),
                        '36.8',
                        '°C',
                        AppColors.warning,
                      ),
                      _buildVitalItem(
                        context.locText(en: 'SpO2', ar: 'الأكسجين'),
                        '98',
                        '%',
                        AppColors.success,
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  _buildInfoSection(
                    context.locText(en: 'Allergies', ar: 'الحساسية'),
                    [
                      _buildChip('Penicillin', AppColors.error),
                      _buildChip('Aspirin', AppColors.warning),
                    ],
                  ),
                  const SizedBox(height: 24),
                  _buildInfoSection(
                    context.locText(
                      en: 'Current Medications',
                      ar: 'الأدوية الحالية',
                    ),
                    [
                      _buildMedicationItem('Lisinopril', '10mg', 'Daily'),
                      _buildMedicationItem('Metformin', '500mg', 'Twice daily'),
                    ],
                  ),
                  const SizedBox(height: 24),
                  _buildInfoSection(
                    context.locText(
                      en: 'Medical History',
                      ar: 'التاريخ المرضي',
                    ),
                    [
                      _buildHistoryItem('Hypertension', '2019'),
                      _buildHistoryItem('Type 2 Diabetes', '2020'),
                    ],
                  ),
                ],
              ),
            ),
          ),
          // Quick actions
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.folder_open, size: 18),
                    label: Text(context.locText(en: 'Records', ar: 'السجل')),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.history, size: 18),
                    label: Text(context.locText(en: 'History', ar: 'السوابق')),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConsultationPanel() {
    return Container(
      margin: const EdgeInsets.fromLTRB(0, 20, 20, 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
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
          // Tab bar
          Container(
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLow,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(24),
              ),
            ),
            child: TabBar(
              controller: _tabController,
              indicatorColor: AppColors.primary,
              indicatorWeight: 3,
              labelColor: AppColors.primary,
              unselectedLabelColor: AppColors.textSecondary,
              labelStyle: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
              tabs: [
                Tab(
                  text: context.locText(
                    en: 'Notes & Diagnosis',
                    ar: 'الملاحظات والتشخيص',
                  ),
                ),
                Tab(
                  text: context.locText(
                    en: 'Prescription',
                    ar: 'الوصفة الطبية',
                  ),
                ),
                Tab(
                  text: context.locText(en: 'Lab Tests', ar: 'التحاليل'),
                ),
              ],
            ),
          ),
          // Tab content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildNotesTab(),
                _buildPrescriptionTab(),
                _buildLabTestsTab(),
              ],
            ),
          ),
          // Bottom actions
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLow.withValues(alpha: 0.5),
              borderRadius: const BorderRadius.vertical(
                bottom: Radius.circular(24),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {},
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: Text(
                      context.locText(en: 'Save Draft', ar: 'حفظ كمسودة'),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    onPressed: _completeConsultation,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.tertiary,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.check_circle, size: 20, color: Colors.white),
                        SizedBox(width: 8),
                        Text(
                          context.locText(
                            en: 'Complete Consultation',
                            ar: 'إنهاء الاستشارة',
                          ),
                          style: TextStyle(color: Colors.white),
                        ),
                      ],
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

  Widget _buildNotesTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Symptoms selection
          Text(
            context.locText(en: 'SYMPTOMS', ar: 'الأعراض'),
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 1,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _availableSymptoms.map((symptom) {
              final isSelected = _selectedSymptoms.contains(symptom);
              return GestureDetector(
                onTap: () {
                  setState(() {
                    if (isSelected) {
                      _selectedSymptoms.remove(symptom);
                    } else {
                      _selectedSymptoms.add(symptom);
                    }
                  });
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.primary
                        : AppColors.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isSelected
                          ? AppColors.primary
                          : AppColors.surfaceContainerHigh,
                    ),
                  ),
                  child: Text(
                    _localizedClinicalText(symptom),
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: isSelected
                          ? Colors.white
                          : AppColors.textSecondary,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 28),
          // Clinical notes
          Text(
            context.locText(en: 'CLINICAL NOTES', ar: 'الملاحظات السريرية'),
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 1,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _notesController,
            maxLines: 6,
            decoration: InputDecoration(
              hintText: context.locText(
                en: 'Enter clinical observations, patient complaints, and examination findings...',
                ar: 'أدخل الملاحظات السريرية وشكوى المريض ونتائج الفحص...',
              ),
              hintStyle: TextStyle(
                color: AppColors.outlineVariant,
                fontSize: 14,
              ),
            ),
          ),
          const SizedBox(height: 28),
          // Diagnosis
          Text(
            context.locText(en: 'DIAGNOSIS', ar: 'التشخيص'),
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 1,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _diagnosisController,
            maxLines: 4,
            decoration: InputDecoration(
              hintText: context.locText(
                en: 'Enter primary and secondary diagnosis (ICD-10 codes will be auto-suggested)...',
                ar: 'أدخل التشخيص الأساسي والثانوي وسيتم اقتراح رموز ICD-10 تلقائيًا...',
              ),
              hintStyle: TextStyle(
                color: AppColors.outlineVariant,
                fontSize: 14,
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Quick diagnosis suggestions
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildSuggestionChip('Angina Pectoris (I20.9)'),
              _buildSuggestionChip('Hypertensive Heart Disease (I11.9)'),
              _buildSuggestionChip('Atrial Fibrillation (I48.91)'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPrescriptionTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Add medication button
          OutlinedButton.icon(
            onPressed: _showAddMedicationDialog,
            icon: const Icon(Icons.add),
            label: Text(
              context.locText(en: 'Add Medication', ar: 'إضافة دواء'),
            ),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            ),
          ),
          const SizedBox(height: 24),
          // Prescription list
          _buildPrescriptionItem(
            'Atorvastatin',
            '20mg',
            'Once daily at night',
            '30 tablets',
            'For cholesterol management',
          ),
          const SizedBox(height: 12),
          _buildPrescriptionItem(
            'Aspirin',
            '81mg',
            'Once daily',
            '30 tablets',
            'Blood thinner',
          ),
          const SizedBox(height: 12),
          _buildPrescriptionItem(
            'Metoprolol',
            '25mg',
            'Twice daily',
            '60 tablets',
            'For heart rate control',
          ),
          const SizedBox(height: 28),
          // Instructions
          Text(
            context.locText(en: 'SPECIAL INSTRUCTIONS', ar: 'تعليمات خاصة'),
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 1,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _prescriptionController,
            maxLines: 4,
            decoration: InputDecoration(
              hintText: context.locText(
                en: 'Enter any special instructions for the patient regarding the prescription...',
                ar: 'أدخل أي تعليمات خاصة للمريض بخصوص الوصفة الطبية...',
              ),
              hintStyle: TextStyle(
                color: AppColors.outlineVariant,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLabTestsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Order tests button
          OutlinedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.add),
            label: Text(context.locText(en: 'Order Lab Test', ar: 'طلب تحليل')),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            ),
          ),
          const SizedBox(height: 24),
          // Ordered tests
          _buildLabTestItem('Complete Blood Count (CBC)', 'Ordered', false),
          const SizedBox(height: 12),
          _buildLabTestItem('Lipid Panel', 'Ordered', false),
          const SizedBox(height: 12),
          _buildLabTestItem('ECG (Electrocardiogram)', 'In Progress', true),
          const SizedBox(height: 12),
          _buildLabTestItem('Chest X-Ray', 'Completed', true, hasResult: true),
          const SizedBox(height: 28),
          // Quick order suggestions
          Text(
            context.locText(en: 'SUGGESTED TESTS', ar: 'تحاليل مقترحة'),
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 1,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildSuggestionChip('Cardiac Enzymes'),
              _buildSuggestionChip('Echocardiogram'),
              _buildSuggestionChip('Stress Test'),
              _buildSuggestionChip('BNP'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          context.l10n.isArabic ? title : title.toUpperCase(),
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w700,
            letterSpacing: 1,
            color: AppColors.textSecondary.withValues(alpha: 0.6),
          ),
        ),
        const SizedBox(height: 12),
        ...children,
      ],
    );
  }

  Widget _buildVitalItem(String label, String value, String unit, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary.withValues(alpha: 0.8),
            ),
          ),
          Row(
            children: [
              Text(
                value,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: color,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                unit,
                style: TextStyle(
                  fontSize: 11,
                  color: AppColors.textSecondary.withValues(alpha: 0.6),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildChip(String label, Color color) {
    return Container(
      margin: const EdgeInsets.only(right: 8, bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        _localizedClinicalText(label),
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }

  Widget _buildMedicationItem(String name, String dose, String frequency) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          const Icon(Icons.medication, size: 16, color: AppColors.primary),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${_localizedClinicalText(name)} - $dose',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  _localizedClinicalText(frequency),
                  style: TextStyle(
                    fontSize: 11,
                    color: AppColors.textSecondary.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryItem(String condition, String year) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            _localizedClinicalText(condition),
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary,
            ),
          ),
          Text(
            context.locText(en: 'Since $year', ar: 'منذ $year'),
            style: TextStyle(
              fontSize: 11,
              color: AppColors.textSecondary.withValues(alpha: 0.6),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuggestionChip(String label) {
    return GestureDetector(
      onTap: () {},
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.tertiary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.tertiary.withValues(alpha: 0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.add, size: 14, color: AppColors.tertiary),
            const SizedBox(width: 6),
            Text(
              _localizedClinicalText(label),
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: AppColors.tertiary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPrescriptionItem(
    String name,
    String dosage,
    String frequency,
    String quantity,
    String notes,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.medication,
              color: AppColors.primary,
              size: 22,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      _localizedClinicalText(name),
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        dosage,
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  '${_localizedClinicalText(frequency)} • $quantity',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary.withValues(alpha: 0.7),
                  ),
                ),
                if (notes.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    _localizedClinicalText(notes),
                    style: TextStyle(
                      fontSize: 11,
                      fontStyle: FontStyle.italic,
                      color: AppColors.textSecondary.withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ],
            ),
          ),
          IconButton(
            onPressed: () {},
            icon: Icon(
              Icons.delete_outline,
              color: AppColors.error.withValues(alpha: 0.7),
              size: 20,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLabTestItem(
    String name,
    String status,
    bool isActive, {
    bool hasResult = false,
  }) {
    Color statusColor;
    switch (status) {
      case 'Completed':
        statusColor = AppColors.tertiary;
        break;
      case 'In Progress':
        statusColor = AppColors.warning;
        break;
      default:
        statusColor = AppColors.textSecondary;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isActive
            ? statusColor.withValues(alpha: 0.08)
            : AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(14),
        border: isActive
            ? Border.all(color: statusColor.withValues(alpha: 0.3))
            : null,
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(Icons.science, color: statusColor, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: statusColor,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      _localizedClinicalText(status),
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: statusColor,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          if (hasResult)
            TextButton(
              onPressed: () {},
              child: Text(
                context.locText(en: 'View Result', ar: 'عرض النتيجة'),
              ),
            ),
        ],
      ),
    );
  }

  void _showAddMedicationDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(context.locText(en: 'Add Medication', ar: 'إضافة دواء')),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              decoration: InputDecoration(
                labelText: context.locText(
                  en: 'Medication Name',
                  ar: 'اسم الدواء',
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      labelText: context.locText(en: 'Dosage', ar: 'الجرعة'),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      labelText: context.locText(en: 'Quantity', ar: 'الكمية'),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextField(
              decoration: InputDecoration(
                labelText: context.locText(en: 'Frequency', ar: 'التكرار'),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(context.locText(en: 'Cancel', ar: 'إلغاء')),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: Text(context.locText(en: 'Add', ar: 'إضافة')),
          ),
        ],
      ),
    );
  }

  void _completeConsultation() {
    final patientId = _currentPatient?.id;
    if (patientId != null) {
      context.read<ClinicQueueCubit>().completePatient(patientId);
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.success.withValues(alpha: 0.2),
              ),
              child: const Icon(
                Icons.check,
                size: 32,
                color: AppColors.tertiary,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              context.locText(
                en: 'Consultation Completed',
                ar: 'اكتملت الاستشارة',
              ),
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              context.locText(
                en: 'All records have been saved successfully.',
                ar: 'تم حفظ جميع السجلات بنجاح.',
              ),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary.withValues(alpha: 0.8),
              ),
            ),
          ],
        ),
        actions: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context);
              },
              child: Text(
                context.locText(en: 'Back to Queue', ar: 'العودة للطابور'),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _localizedClinicalText(String value) {
    switch (value) {
      case 'Chest Pain':
        return context.locText(en: value, ar: 'ألم في الصدر');
      case 'Shortness of Breath':
        return context.locText(en: value, ar: 'ضيق في التنفس');
      case 'Fatigue':
        return context.locText(en: value, ar: 'إرهاق');
      case 'Dizziness':
        return context.locText(en: value, ar: 'دوخة');
      case 'Palpitations':
        return context.locText(en: value, ar: 'خفقان');
      case 'Swelling':
        return context.locText(en: value, ar: 'تورم');
      case 'Nausea':
        return context.locText(en: value, ar: 'غثيان');
      case 'Headache':
        return context.locText(en: value, ar: 'صداع');
      case 'Penicillin':
        return context.locText(en: value, ar: 'بنسلين');
      case 'Aspirin':
        return context.locText(en: value, ar: 'أسبرين');
      case 'Lisinopril':
        return context.locText(en: value, ar: 'ليزينوبريل');
      case 'Metformin':
        return context.locText(en: value, ar: 'ميتفورمين');
      case 'Atorvastatin':
        return context.locText(en: value, ar: 'أتورفاستاتين');
      case 'Metoprolol':
        return context.locText(en: value, ar: 'ميتوبرولول');
      case 'Daily':
        return context.locText(en: value, ar: 'يوميًا');
      case 'Twice daily':
        return context.locText(en: value, ar: 'مرتين يوميًا');
      case 'Once daily':
        return context.locText(en: value, ar: 'مرة يوميًا');
      case 'Once daily at night':
        return context.locText(en: value, ar: 'مرة يوميًا ليلًا');
      case 'For cholesterol management':
        return context.locText(en: value, ar: 'للسيطرة على الكوليسترول');
      case 'Blood thinner':
        return context.locText(en: value, ar: 'مميع للدم');
      case 'For heart rate control':
        return context.locText(en: value, ar: 'للتحكم في معدل النبض');
      case 'Hypertension':
        return context.locText(en: value, ar: 'ارتفاع ضغط الدم');
      case 'Type 2 Diabetes':
        return context.locText(en: value, ar: 'السكري من النوع الثاني');
      case 'Angina Pectoris (I20.9)':
        return context.locText(en: value, ar: 'الذبحة الصدرية (I20.9)');
      case 'Hypertensive Heart Disease (I11.9)':
        return context.locText(
          en: value,
          ar: 'مرض القلب الناتج عن الضغط (I11.9)',
        );
      case 'Atrial Fibrillation (I48.91)':
        return context.locText(en: value, ar: 'الرجفان الأذيني (I48.91)');
      case 'Complete Blood Count (CBC)':
        return context.locText(en: value, ar: 'صورة دم كاملة (CBC)');
      case 'Lipid Panel':
        return context.locText(en: value, ar: 'تحليل الدهون');
      case 'ECG (Electrocardiogram)':
        return context.locText(en: value, ar: 'تخطيط القلب (ECG)');
      case 'Chest X-Ray':
        return context.locText(en: value, ar: 'أشعة سينية للصدر');
      case 'Cardiac Enzymes':
        return context.locText(en: value, ar: 'إنزيمات القلب');
      case 'Echocardiogram':
        return context.locText(en: value, ar: 'موجات صوتية على القلب');
      case 'Stress Test':
        return context.locText(en: value, ar: 'اختبار الجهد');
      case 'Ordered':
        return context.locText(en: value, ar: 'تم الطلب');
      case 'In Progress':
        return context.locText(en: value, ar: 'قيد التنفيذ');
      case 'Completed':
        return context.locText(en: value, ar: 'مكتمل');
      default:
        return value;
    }
  }
}
