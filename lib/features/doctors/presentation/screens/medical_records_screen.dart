import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/localization/app_localizations.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_top_bar.dart';
import '../../../queue/logic/clinic_queue_cubit.dart';

class MedicalRecordsScreen extends StatelessWidget {
  const MedicalRecordsScreen({super.key, this.patientId});

  final int? patientId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: Column(
        children: [
          AppTopBar(
            title: context.locText(en: 'Medical Records', ar: 'السجل الطبي'),
            showBackButton: true,
          ),
          Expanded(
            child: BlocBuilder<ClinicQueueCubit, ClinicQueueState>(
              builder: (context, state) {
                final patient = _resolvePatient(state);
                if (patient == null) {
                  return _buildEmptyState(context);
                }

                return LayoutBuilder(
                  builder: (context, constraints) {
                    final isWide = constraints.maxWidth >= 980;
                    final cardWidth = isWide
                        ? (constraints.maxWidth - 56) / 2
                        : constraints.maxWidth - 40;
                    final history = _historyFor(patient);
                    final medications = _medicationsFor(patient);
                    final visits = _visitsFor(patient);

                    return SingleChildScrollView(
                      padding: const EdgeInsets.all(20),
                      child: Wrap(
                        spacing: 16,
                        runSpacing: 16,
                        children: [
                          SizedBox(
                            width: cardWidth,
                            child: _buildPatientOverviewCard(context, patient),
                          ),
                          SizedBox(
                            width: cardWidth,
                            child: _buildCaseSummaryCard(
                              context,
                              patient,
                              history.length,
                              medications.length,
                            ),
                          ),
                          SizedBox(
                            width: cardWidth,
                            child: _buildAllergiesCard(context, patient),
                          ),
                          SizedBox(
                            width: cardWidth,
                            child: _buildMedicationsCard(context, medications),
                          ),
                          SizedBox(
                            width: cardWidth,
                            child: _buildHistoryCard(context, history),
                          ),
                          SizedBox(
                            width: cardWidth,
                            child: _buildVisitsCard(context, visits),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  ClinicQueuePatient? _resolvePatient(ClinicQueueState state) {
    if (patientId != null) {
      return state.patientById(patientId!);
    }
    if (state.activePatient != null) {
      return state.activePatient;
    }
    if (state.trackedPatient != null) {
      return state.trackedPatient;
    }
    if (state.orderedPatients.isEmpty) {
      return null;
    }
    return state.orderedPatients.first;
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 420),
        margin: const EdgeInsets.all(24),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: AppColors.textPrimary.withValues(alpha: 0.05),
              blurRadius: 24,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLow,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(
                Icons.folder_open_outlined,
                size: 32,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              context.locText(
                en: 'No medical record available',
                ar: 'لا يوجد سجل طبي متاح',
              ),
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              context.locText(
                en: 'Select a patient from the queue to review their details.',
                ar: 'اختر مريضًا من الطابور لمراجعة تفاصيله.',
              ),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                height: 1.5,
                color: AppColors.textSecondary.withValues(alpha: 0.8),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPatientOverviewCard(
    BuildContext context,
    ClinicQueuePatient patient,
  ) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, AppColors.secondary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.18),
            blurRadius: 28,
            offset: const Offset(0, 16),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(Icons.person, color: Colors.white, size: 30),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      context.l10n.isArabic ? patient.nameAr : patient.nameEn,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      context.locText(
                        en: '${patient.genderEn}, ${patient.age} years',
                        ar: '${patient.genderAr}، ${patient.age} سنة',
                      ),
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.white.withValues(alpha: 0.82),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _buildInfoBadge(
                context.locText(
                  en: 'Queue #${patient.queueNumber}',
                  ar: 'رقم الدور ${patient.queueNumber}',
                ),
              ),
              _buildInfoBadge(
                context.locText(
                  en: 'Visit: ${patient.visitTypeEn}',
                  ar: 'الزيارة: ${patient.visitTypeAr}',
                ),
              ),
              _buildInfoBadge(
                context.locText(
                  en: 'Scheduled ${patient.scheduledTime}',
                  ar: 'الموعد ${patient.scheduledTime}',
                ),
              ),
              _buildInfoBadge(_statusLabel(context, patient.status)),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _buildMetricTile(
                  context,
                  context.locText(en: 'Blood Type', ar: 'فصيلة الدم'),
                  _bloodTypeFor(patient),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildMetricTile(
                  context,
                  context.locText(en: 'Last Visit', ar: 'آخر زيارة'),
                  _lastVisitFor(context, patient),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCaseSummaryCard(
    BuildContext context,
    ClinicQueuePatient patient,
    int historyCount,
    int medicationCount,
  ) {
    final allergies = _allergiesFor(context, patient);
    return _buildSectionCard(
      context,
      title: context.locText(en: 'Case Summary', ar: 'ملخص الحالة'),
      icon: Icons.summarize_outlined,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _summaryFor(context, patient),
            style: TextStyle(
              fontSize: 13,
              height: 1.6,
              color: AppColors.textSecondary.withValues(alpha: 0.88),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildStatPill(
                  context,
                  context.locText(
                    en: '$historyCount active conditions',
                    ar: '$historyCount حالات نشطة',
                  ),
                  AppColors.primary,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildStatPill(
                  context,
                  context.locText(
                    en: '$medicationCount current medications',
                    ar: '$medicationCount أدوية حالية',
                  ),
                  AppColors.tertiary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          _buildStatPill(
            context,
            context.locText(
              en: '${allergies.length} allergy alerts',
              ar: '${allergies.length} تنبيهات حساسية',
            ),
            AppColors.warning,
          ),
        ],
      ),
    );
  }

  Widget _buildAllergiesCard(BuildContext context, ClinicQueuePatient patient) {
    final allergies = _allergiesFor(context, patient);
    final hasKnownAllergies = !_hasNoKnownAllergies(context, allergies);

    return _buildSectionCard(
      context,
      title: context.locText(en: 'Allergies', ar: 'الحساسية'),
      icon: Icons.warning_amber_rounded,
      child: Wrap(
        spacing: 10,
        runSpacing: 10,
        children: allergies.map((allergy) {
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: (hasKnownAllergies ? AppColors.warning : AppColors.success)
                  .withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color:
                    (hasKnownAllergies ? AppColors.warning : AppColors.success)
                        .withValues(alpha: 0.22),
              ),
            ),
            child: Text(
              allergy,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: hasKnownAllergies
                    ? AppColors.warning
                    : AppColors.success,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildMedicationsCard(
    BuildContext context,
    List<_MedicationEntry> medications,
  ) {
    return _buildSectionCard(
      context,
      title: context.locText(en: 'Current Medications', ar: 'الأدوية الحالية'),
      icon: Icons.medication_outlined,
      child: Column(
        children: medications.map((medication) {
          return Padding(
            padding: EdgeInsets.only(
              bottom: medication == medications.last ? 0 : 12,
            ),
            child: _buildDetailTile(
              context,
              title: medication.name(context),
              subtitle: medication.schedule(context),
              trailing: medication.dose,
              accent: AppColors.primary,
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildHistoryCard(BuildContext context, List<_HistoryEntry> history) {
    return _buildSectionCard(
      context,
      title: context.locText(en: 'Medical History', ar: 'التاريخ المرضي'),
      icon: Icons.history_edu_outlined,
      child: Column(
        children: history.map((entry) {
          return Padding(
            padding: EdgeInsets.only(bottom: entry == history.last ? 0 : 12),
            child: _buildDetailTile(
              context,
              title: entry.title(context),
              subtitle: entry.note(context),
              trailing: entry.year,
              accent: AppColors.tertiary,
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildVisitsCard(BuildContext context, List<_VisitEntry> visits) {
    return _buildSectionCard(
      context,
      title: context.locText(en: 'Recent Visits', ar: 'الزيارات الأخيرة'),
      icon: Icons.event_note_outlined,
      child: Column(
        children: visits.map((visit) {
          return Padding(
            padding: EdgeInsets.only(bottom: visit == visits.last ? 0 : 12),
            child: _buildDetailTile(
              context,
              title: visit.title(context),
              subtitle: visit.note(context),
              trailing: visit.date(context),
              accent: AppColors.secondary,
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildSectionCard(
    BuildContext context, {
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.textPrimary.withValues(alpha: 0.05),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: AppColors.primary, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          child,
        ],
      ),
    );
  }

  Widget _buildMetricTile(BuildContext context, String label, String value) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.14)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: Colors.white.withValues(alpha: 0.72),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoBadge(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildStatPill(BuildContext context, String label, Color color) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }

  Widget _buildDetailTile(
    BuildContext context, {
    required String title,
    required String subtitle,
    required String trailing,
    required Color accent,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(color: accent, shape: BoxShape.circle),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 11,
                    height: 1.4,
                    color: AppColors.textSecondary.withValues(alpha: 0.78),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Text(
            trailing,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: accent,
            ),
          ),
        ],
      ),
    );
  }

  bool _hasNoKnownAllergies(BuildContext context, List<String> allergies) {
    final noKnownAllergies = context.locText(
      en: 'No known allergies',
      ar: 'لا توجد حساسية معروفة',
    );
    return allergies.length == 1 && allergies.first == noKnownAllergies;
  }

  String _statusLabel(BuildContext context, ClinicQueuePatientStatus status) {
    switch (status) {
      case ClinicQueuePatientStatus.waiting:
        return context.locText(en: 'Waiting', ar: 'بانتظار الموعد');
      case ClinicQueuePatientStatus.inProgress:
        return context.locText(en: 'In Consultation', ar: 'داخل الاستشارة');
      case ClinicQueuePatientStatus.completed:
        return context.locText(en: 'Completed', ar: 'مكتمل');
    }
  }

  String _bloodTypeFor(ClinicQueuePatient patient) {
    switch (patient.id) {
      case 3:
        return 'B+';
      case 4:
        return 'A+';
      case 5:
        return 'O-';
      case 6:
        return 'AB+';
      default:
        return 'O+';
    }
  }

  String _lastVisitFor(BuildContext context, ClinicQueuePatient patient) {
    switch (patient.id) {
      case 3:
        return context.locText(en: '02 Mar 2026', ar: '02 مارس 2026');
      case 4:
        return context.locText(en: '18 Feb 2026', ar: '18 فبراير 2026');
      case 5:
        return context.locText(en: '28 Jan 2026', ar: '28 يناير 2026');
      case 6:
        return context.locText(en: '11 Mar 2026', ar: '11 مارس 2026');
      default:
        return context.locText(en: '04 Apr 2026', ar: '04 أبريل 2026');
    }
  }

  String _summaryFor(BuildContext context, ClinicQueuePatient patient) {
    switch (patient.id) {
      case 3:
        return context.locText(
          en: 'Follow-up case with recurring dizziness and elevated blood pressure readings over the past two weeks.',
          ar: 'حالة متابعة مع دوار متكرر وارتفاع في قراءات ضغط الدم خلال الأسبوعين الماضيين.',
        );
      case 4:
        return context.locText(
          en: 'Reports chest discomfort during exertion with shortness of breath. History indicates hypertension and diabetes requiring regular monitoring.',
          ar: 'تشتكي من انزعاج في الصدر مع المجهود وضيق في التنفس. السجل يشير إلى ضغط مرتفع وسكري ويحتاجان إلى متابعة دورية.',
        );
      case 5:
        return context.locText(
          en: 'Senior patient under consultation for palpitations and fatigue, with prior cardiac screening and medication adjustment.',
          ar: 'مريض مسن قيد المتابعة بسبب خفقان وإرهاق، مع فحوصات قلب سابقة وتعديل في العلاج الدوائي.',
        );
      case 6:
        return context.locText(
          en: 'Routine follow-up showing stable vitals after previous treatment plan, with mild headache episodes noted.',
          ar: 'متابعة دورية تُظهر استقرار العلامات الحيوية بعد الخطة العلاجية السابقة مع ملاحظة نوبات صداع خفيفة.',
        );
      default:
        return context.locText(
          en: 'General consultation record with prior notes, medication adherence tracking, and recent visit summaries.',
          ar: 'سجل استشارة عام يحتوي على ملاحظات سابقة ومتابعة للالتزام بالعلاج وملخصات الزيارات الأخيرة.',
        );
    }
  }

  List<String> _allergiesFor(BuildContext context, ClinicQueuePatient patient) {
    switch (patient.id) {
      case 3:
        return [context.locText(en: 'Sulfa drugs', ar: 'أدوية السلفا')];
      case 4:
        return [
          context.locText(en: 'Penicillin', ar: 'البنسلين'),
          context.locText(en: 'Aspirin', ar: 'الأسبرين'),
        ];
      case 5:
        return [context.locText(en: 'Shellfish', ar: 'المأكولات البحرية')];
      default:
        return [
          context.locText(
            en: 'No known allergies',
            ar: 'لا توجد حساسية معروفة',
          ),
        ];
    }
  }

  List<_MedicationEntry> _medicationsFor(ClinicQueuePatient patient) {
    switch (patient.id) {
      case 3:
        return const [
          _MedicationEntry(
            nameEn: 'Amlodipine',
            nameAr: 'أملوديبين',
            dose: '5mg',
            scheduleEn: 'Once daily after breakfast',
            scheduleAr: 'مرة يوميًا بعد الإفطار',
          ),
          _MedicationEntry(
            nameEn: 'Atorvastatin',
            nameAr: 'أتورفاستاتين',
            dose: '20mg',
            scheduleEn: 'Every evening',
            scheduleAr: 'كل مساء',
          ),
        ];
      case 4:
        return const [
          _MedicationEntry(
            nameEn: 'Lisinopril',
            nameAr: 'ليسينوبريل',
            dose: '10mg',
            scheduleEn: 'Once daily',
            scheduleAr: 'مرة يوميًا',
          ),
          _MedicationEntry(
            nameEn: 'Metformin',
            nameAr: 'ميتفورمين',
            dose: '500mg',
            scheduleEn: 'Twice daily with meals',
            scheduleAr: 'مرتين يوميًا مع الطعام',
          ),
        ];
      case 5:
        return const [
          _MedicationEntry(
            nameEn: 'Bisoprolol',
            nameAr: 'بيسوبرولول',
            dose: '2.5mg',
            scheduleEn: 'Once daily in the morning',
            scheduleAr: 'مرة يوميًا صباحًا',
          ),
          _MedicationEntry(
            nameEn: 'Clopidogrel',
            nameAr: 'كلوبيدوغريل',
            dose: '75mg',
            scheduleEn: 'Once daily after lunch',
            scheduleAr: 'مرة يوميًا بعد الغداء',
          ),
        ];
      default:
        return const [
          _MedicationEntry(
            nameEn: 'Paracetamol',
            nameAr: 'باراسيتامول',
            dose: '500mg',
            scheduleEn: 'As needed',
            scheduleAr: 'عند الحاجة',
          ),
        ];
    }
  }

  List<_HistoryEntry> _historyFor(ClinicQueuePatient patient) {
    switch (patient.id) {
      case 3:
        return const [
          _HistoryEntry(
            titleEn: 'Hypertension',
            titleAr: 'ارتفاع ضغط الدم',
            year: '2021',
            noteEn: 'Managed with medication and lifestyle changes',
            noteAr: 'تتم السيطرة عليه بالأدوية وتعديل نمط الحياة',
          ),
          _HistoryEntry(
            titleEn: 'Vertigo episodes',
            titleAr: 'نوبات دوار',
            year: '2024',
            noteEn: 'Observed during exertion, improved with rest',
            noteAr: 'ظهرت أثناء المجهود وتحسنت مع الراحة',
          ),
        ];
      case 4:
        return const [
          _HistoryEntry(
            titleEn: 'Hypertension',
            titleAr: 'ارتفاع ضغط الدم',
            year: '2019',
            noteEn: 'Requires regular monitoring',
            noteAr: 'يحتاج إلى متابعة منتظمة',
          ),
          _HistoryEntry(
            titleEn: 'Type 2 Diabetes',
            titleAr: 'السكري من النوع الثاني',
            year: '2020',
            noteEn: 'Stable on oral medication',
            noteAr: 'مستقر على العلاج الفموي',
          ),
        ];
      case 5:
        return const [
          _HistoryEntry(
            titleEn: 'Arrhythmia',
            titleAr: 'اضطراب نظم القلب',
            year: '2023',
            noteEn: 'Symptoms controlled after medication adjustment',
            noteAr: 'تمت السيطرة على الأعراض بعد تعديل العلاج',
          ),
          _HistoryEntry(
            titleEn: 'Hyperlipidemia',
            titleAr: 'ارتفاع الدهون',
            year: '2022',
            noteEn: 'On long-term lipid management plan',
            noteAr: 'ضمن خطة علاج طويلة المدى للدهون',
          ),
        ];
      default:
        return const [
          _HistoryEntry(
            titleEn: 'Migraine',
            titleAr: 'الشقيقة',
            year: '2024',
            noteEn: 'Occasional mild headaches',
            noteAr: 'نوبات صداع خفيفة متقطعة',
          ),
        ];
    }
  }

  List<_VisitEntry> _visitsFor(ClinicQueuePatient patient) {
    switch (patient.id) {
      case 3:
        return const [
          _VisitEntry(
            titleEn: 'Blood pressure review',
            titleAr: 'مراجعة ضغط الدم',
            dateEn: '02 Mar 2026',
            dateAr: '02 مارس 2026',
            noteEn: 'Medication dose maintained after stable readings',
            noteAr: 'تم تثبيت الجرعة بعد استقرار القراءات',
          ),
          _VisitEntry(
            titleEn: 'ECG assessment',
            titleAr: 'تقييم تخطيط القلب',
            dateEn: '16 Feb 2026',
            dateAr: '16 فبراير 2026',
            noteEn: 'Normal rhythm with no acute findings',
            noteAr: 'نظم طبيعي دون مؤشرات حادة',
          ),
        ];
      case 4:
        return const [
          _VisitEntry(
            titleEn: 'Cardiac follow-up',
            titleAr: 'متابعة قلبية',
            dateEn: '18 Feb 2026',
            dateAr: '18 فبراير 2026',
            noteEn: 'Shortness of breath improved with treatment plan',
            noteAr: 'تحسن ضيق التنفس مع الخطة العلاجية',
          ),
          _VisitEntry(
            titleEn: 'Lab review',
            titleAr: 'مراجعة التحاليل',
            dateEn: '07 Jan 2026',
            dateAr: '07 يناير 2026',
            noteEn: 'HbA1c elevated, advised stricter follow-up',
            noteAr: 'ارتفاع السكر التراكمي مع التوصية بمتابعة أدق',
          ),
        ];
      case 5:
        return const [
          _VisitEntry(
            titleEn: 'Medication adjustment',
            titleAr: 'تعديل العلاج',
            dateEn: '28 Jan 2026',
            dateAr: '28 يناير 2026',
            noteEn: 'Reduced palpitations after introducing beta blocker',
            noteAr: 'انخفاض الخفقان بعد إضافة حاصر بيتا',
          ),
          _VisitEntry(
            titleEn: 'Cardiology screening',
            titleAr: 'فحص أمراض القلب',
            dateEn: '14 Dec 2025',
            dateAr: '14 ديسمبر 2025',
            noteEn: 'Recommended continued observation',
            noteAr: 'تمت التوصية بالاستمرار في المراقبة',
          ),
        ];
      default:
        return const [
          _VisitEntry(
            titleEn: 'Routine follow-up',
            titleAr: 'متابعة روتينية',
            dateEn: '11 Mar 2026',
            dateAr: '11 مارس 2026',
            noteEn: 'Symptoms mild and controlled',
            noteAr: 'الأعراض خفيفة وتحت السيطرة',
          ),
          _VisitEntry(
            titleEn: 'Initial consultation',
            titleAr: 'الاستشارة الأولى',
            dateEn: '03 Feb 2026',
            dateAr: '03 فبراير 2026',
            noteEn: 'Baseline treatment plan started',
            noteAr: 'تم بدء الخطة العلاجية الأساسية',
          ),
        ];
    }
  }
}

class _MedicationEntry {
  const _MedicationEntry({
    required this.nameEn,
    required this.nameAr,
    required this.dose,
    required this.scheduleEn,
    required this.scheduleAr,
  });

  final String nameEn;
  final String nameAr;
  final String dose;
  final String scheduleEn;
  final String scheduleAr;

  String name(BuildContext context) => context.locText(en: nameEn, ar: nameAr);

  String schedule(BuildContext context) =>
      context.locText(en: scheduleEn, ar: scheduleAr);
}

class _HistoryEntry {
  const _HistoryEntry({
    required this.titleEn,
    required this.titleAr,
    required this.year,
    required this.noteEn,
    required this.noteAr,
  });

  final String titleEn;
  final String titleAr;
  final String year;
  final String noteEn;
  final String noteAr;

  String title(BuildContext context) =>
      context.locText(en: titleEn, ar: titleAr);

  String note(BuildContext context) => context.locText(en: noteEn, ar: noteAr);
}

class _VisitEntry {
  const _VisitEntry({
    required this.titleEn,
    required this.titleAr,
    required this.dateEn,
    required this.dateAr,
    required this.noteEn,
    required this.noteAr,
  });

  final String titleEn;
  final String titleAr;
  final String dateEn;
  final String dateAr;
  final String noteEn;
  final String noteAr;

  String title(BuildContext context) =>
      context.locText(en: titleEn, ar: titleAr);

  String date(BuildContext context) => context.locText(en: dateEn, ar: dateAr);

  String note(BuildContext context) => context.locText(en: noteEn, ar: noteAr);
}
