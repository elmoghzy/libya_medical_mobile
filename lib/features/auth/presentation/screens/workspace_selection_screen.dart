import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/localization/app_localizations.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_top_bar.dart';
import '../../data/auth_models.dart';
import '../../logic/auth_cubit.dart';
import '../../../doctors/presentation/screens/doctor_dashboard_screen.dart';

class WorkspaceSelectionScreen extends StatefulWidget {
  const WorkspaceSelectionScreen({
    super.key,
    required this.institutions,
    this.isSwitching = false,
  });

  final List<InstitutionModel> institutions;
  final bool isSwitching;

  @override
  State<WorkspaceSelectionScreen> createState() =>
      _WorkspaceSelectionScreenState();
}

class _WorkspaceSelectionScreenState extends State<WorkspaceSelectionScreen> {
  bool _isSubmitting = false;

  Future<void> _selectInstitution(InstitutionModel institution) async {
    if (_isSubmitting) {
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      await context.read<AuthCubit>().selectInstitution(institution);
      unawaited(_syncActiveWorkspace(institution.id));
    } catch (e) {
      if (!mounted) {
        return;
      }

      setState(() => _isSubmitting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            context.locText(
              en: 'Unable to select workspace right now.',
              ar: 'تعذر اختيار مساحة العمل الآن.',
            ),
          ),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    if (!mounted) {
      return;
    }

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute<void>(builder: (_) => const DoctorDashboardScreen()),
      (route) => false,
    );
  }

  Future<void> _syncActiveWorkspace(int institutionId) async {
    try {
      await context.read<AuthCubit>().syncActiveWorkspace(institutionId);
    } catch (e) {
      debugPrint('Failed to sync active workspace: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentInstitutionId = context.read<AuthCubit>().currentInstitutionId;

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: Column(
        children: [
          AppTopBar(
            title: context.locText(
              en: 'Choose Workspace',
              ar: 'اختر مساحة العمل',
            ),
            showBackButton: widget.isSwitching,
            showNotification: false,
          ),
          Expanded(
            child: SafeArea(
              top: false,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
                children: [
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 52,
                          height: 52,
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(18),
                          ),
                          child: const Icon(
                            Icons.apartment_rounded,
                            color: AppColors.primary,
                            size: 28,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          context.locText(
                            en: widget.isSwitching
                                ? 'Switch your active clinic'
                                : 'Select the clinic you want to work in today',
                            ar: widget.isSwitching
                                ? 'غيّر العيادة النشطة'
                                : 'اختر العيادة التي تريد العمل داخلها الآن',
                          ),
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textPrimary,
                            height: 1.2,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          context.locText(
                            en: 'Every request after login will use the selected workspace automatically.',
                            ar: 'كل الطلبات بعد تسجيل الدخول ستستخدم مساحة العمل المختارة تلقائيًا.',
                          ),
                          style: TextStyle(
                            fontSize: 14,
                            height: 1.5,
                            color: AppColors.textSecondary.withValues(
                              alpha: 0.85,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    context.locText(
                      en: 'Available Clinics',
                      ar: 'العيادات المتاحة',
                    ),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ...widget.institutions.map((institution) {
                    final isSelected = currentInstitutionId == institution.id;

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(20),
                          onTap: _isSubmitting
                              ? null
                              : () => _selectInstitution(institution),
                          child: Ink(
                            padding: const EdgeInsets.all(18),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: isSelected
                                    ? AppColors.primary
                                    : AppColors.outlineVariant.withValues(
                                        alpha: 0.45,
                                      ),
                                width: isSelected ? 1.4 : 1,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.04),
                                  blurRadius: 18,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 52,
                                  height: 52,
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? AppColors.primary.withValues(
                                            alpha: 0.12,
                                          )
                                        : AppColors.surfaceContainerLow,
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Icon(
                                    Icons.local_hospital_rounded,
                                    color: isSelected
                                        ? AppColors.primary
                                        : AppColors.textSecondary,
                                  ),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        institution.name,
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w700,
                                          color: AppColors.textPrimary,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        context.locText(
                                          en: 'Workspace ID: ${institution.id}',
                                          ar: 'معرّف مساحة العمل: ${institution.id}',
                                        ),
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: AppColors.textSecondary
                                              .withValues(alpha: 0.8),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 12),
                                if (_isSubmitting)
                                  const SizedBox(
                                    width: 22,
                                    height: 22,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2.2,
                                      color: AppColors.primary,
                                    ),
                                  )
                                else
                                  Icon(
                                    isSelected
                                        ? Icons.check_circle_rounded
                                        : Icons.arrow_forward_ios_rounded,
                                    size: isSelected ? 24 : 18,
                                    color: isSelected
                                        ? AppColors.primary
                                        : AppColors.textSecondary,
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
