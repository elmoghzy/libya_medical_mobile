import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_top_bar.dart';
import 'consultation_view_screen.dart';

class ClinicQueueManagerScreen extends StatefulWidget {
  const ClinicQueueManagerScreen({super.key});

  @override
  State<ClinicQueueManagerScreen> createState() =>
      _ClinicQueueManagerScreenState();
}

class _ClinicQueueManagerScreenState extends State<ClinicQueueManagerScreen> {
  bool _isQueueActive = true;
  String _selectedFilter = 'All';

  final List<Map<String, dynamic>> _patients = [
    {
      'id': 1,
      'name': 'Mohammed Ali',
      'age': 45,
      'gender': 'Male',
      'queueNumber': 1,
      'checkInTime': '09:00',
      'type': 'Follow-up',
      'status': 'completed',
      'priority': 'normal',
    },
    {
      'id': 2,
      'name': 'Sara Ahmed',
      'age': 28,
      'gender': 'Female',
      'queueNumber': 2,
      'checkInTime': '09:15',
      'type': 'Consultation',
      'status': 'completed',
      'priority': 'normal',
    },
    {
      'id': 3,
      'name': 'Khalid Omar',
      'age': 52,
      'gender': 'Male',
      'queueNumber': 3,
      'checkInTime': '09:30',
      'type': 'ECG Test',
      'status': 'in_progress',
      'priority': 'high',
    },
    {
      'id': 4,
      'name': 'Fatima Al-Farsi',
      'age': 34,
      'gender': 'Female',
      'queueNumber': 4,
      'checkInTime': '09:45',
      'type': 'Heart Checkup',
      'status': 'waiting',
      'priority': 'urgent',
    },
    {
      'id': 5,
      'name': 'Ali Hassan',
      'age': 67,
      'gender': 'Male',
      'queueNumber': 5,
      'checkInTime': '10:00',
      'type': 'Consultation',
      'status': 'waiting',
      'priority': 'high',
    },
    {
      'id': 6,
      'name': 'Maryam Salem',
      'age': 41,
      'gender': 'Female',
      'queueNumber': 6,
      'checkInTime': '10:15',
      'type': 'Follow-up',
      'status': 'waiting',
      'priority': 'normal',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: Column(
        children: [
          const AppTopBar(title: 'Clinic Queue'),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 24),
                  // Header
                  _buildHeader(),
                  const SizedBox(height: 24),
                  // Queue stats
                  _buildQueueStats(),
                  const SizedBox(height: 24),
                  // Filter tabs
                  _buildFilterTabs(),
                  const SizedBox(height: 20),
                  // Patient list
                  ..._patients
                      .where((p) {
                        if (_selectedFilter == 'All') return true;
                        if (_selectedFilter == 'Waiting')
                          return p['status'] == 'waiting';
                        if (_selectedFilter == 'In Progress')
                          return p['status'] == 'in_progress';
                        if (_selectedFilter == 'Completed')
                          return p['status'] == 'completed';
                        return true;
                      })
                      .map(
                        (p) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: _buildPatientCard(p),
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
        onPressed: () {
          // Add patient to queue
        },
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.person_add, color: Colors.white),
        label: const Text('Add Patient', style: TextStyle(color: Colors.white)),
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
            const Text(
              'Clinic Queue',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Manage your patient queue',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary.withValues(alpha: 0.7),
              ),
            ),
          ],
        ),
        // Queue toggle
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
                  _isQueueActive ? 'Queue Active' : 'Queue Paused',
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

  Widget _buildQueueStats() {
    final waiting = _patients.where((p) => p['status'] == 'waiting').length;
    final inProgress = _patients
        .where((p) => p['status'] == 'in_progress')
        .length;
    final completed = _patients.where((p) => p['status'] == 'completed').length;

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
              'Waiting',
              waiting.toString(),
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
              'In Progress',
              inProgress.toString(),
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
              'Completed',
              completed.toString(),
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
                  filter,
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

  Widget _buildPatientCard(Map<String, dynamic> patient) {
    final status = patient['status'] as String;
    final priority = patient['priority'] as String;

    Color statusColor;
    String statusText;
    IconData statusIcon;

    switch (status) {
      case 'completed':
        statusColor = AppColors.tertiary;
        statusText = 'Completed';
        statusIcon = Icons.check_circle;
        break;
      case 'in_progress':
        statusColor = AppColors.warning;
        statusText = 'In Progress';
        statusIcon = Icons.person;
        break;
      default:
        statusColor = AppColors.textSecondary;
        statusText = 'Waiting';
        statusIcon = Icons.hourglass_empty;
    }

    Color priorityColor;
    switch (priority) {
      case 'urgent':
        priorityColor = AppColors.error;
        break;
      case 'high':
        priorityColor = AppColors.warning;
        break;
      default:
        priorityColor = AppColors.textSecondary;
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: status == 'in_progress'
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
                // Queue number
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    '#${patient['queueNumber']}',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: statusColor,
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                // Patient info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              patient['name'] as String,
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: status == 'completed'
                                    ? AppColors.textSecondary.withValues(
                                        alpha: 0.6,
                                      )
                                    : AppColors.textPrimary,
                              ),
                            ),
                          ),
                          if (priority != 'normal')
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
                                priority.toUpperCase(),
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
                        '${patient['gender']}, ${patient['age']} years • ${patient['type']}',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary.withValues(alpha: 0.7),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Icon(
                            Icons.schedule,
                            size: 12,
                            color: AppColors.textSecondary.withValues(
                              alpha: 0.5,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Check-in: ${patient['checkInTime']}',
                            style: TextStyle(
                              fontSize: 11,
                              color: AppColors.textSecondary.withValues(
                                alpha: 0.6,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Icon(statusIcon, size: 12, color: statusColor),
                          const SizedBox(width: 4),
                          Text(
                            statusText,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: statusColor,
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
          // Action buttons
          if (status != 'completed')
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLow.withValues(alpha: 0.5),
                borderRadius: const BorderRadius.vertical(
                  bottom: Radius.circular(16),
                ),
              ),
              child: Row(
                children: [
                  if (status == 'waiting') ...[
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.skip_next, size: 16),
                        label: const Text('Skip'),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 8),
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
                              builder: (_) => const ConsultationViewScreen(),
                            ),
                          );
                        },
                        icon: const Icon(
                          Icons.play_arrow,
                          size: 18,
                          color: Colors.white,
                        ),
                        label: const Text('Call Patient'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                        ),
                      ),
                    ),
                  ] else if (status == 'in_progress') ...[
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.pause, size: 16),
                        label: const Text('Pause'),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      flex: 2,
                      child: ElevatedButton.icon(
                        onPressed: () {},
                        icon: const Icon(
                          Icons.check,
                          size: 18,
                          color: Colors.white,
                        ),
                        label: const Text('Complete'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.tertiary,
                          padding: const EdgeInsets.symmetric(vertical: 8),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
        ],
      ),
    );
  }
}
