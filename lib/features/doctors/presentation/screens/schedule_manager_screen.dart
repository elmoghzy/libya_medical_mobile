import 'package:flutter/material.dart';

import '../../../../core/localization/app_localizations.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_top_bar.dart';

class ScheduleManagerScreen extends StatefulWidget {
  const ScheduleManagerScreen({super.key, this.embedded = false});

  final bool embedded;

  @override
  State<ScheduleManagerScreen> createState() => _ScheduleManagerScreenState();
}

class _ScheduleManagerScreenState extends State<ScheduleManagerScreen> {
  int _selectedDay = 3; // Thursday
  final List<int> _dates = [21, 22, 23, 24, 25, 26, 27];
  final DateTime _weekStart = DateTime(2024, 10, 21);

  final Map<int, List<Map<String, dynamic>>> _schedule = {
    0: [], // Monday
    1: [
      {'start': '09:00', 'end': '12:00', 'type': 'clinic'},
      {'start': '14:00', 'end': '17:00', 'type': 'clinic'},
    ],
    2: [
      {'start': '09:00', 'end': '13:00', 'type': 'clinic'},
    ],
    3: [
      {'start': '08:00', 'end': '12:00', 'type': 'clinic'},
      {'start': '13:00', 'end': '15:00', 'type': 'surgery'},
      {'start': '16:00', 'end': '18:00', 'type': 'clinic'},
    ],
    4: [
      {'start': '09:00', 'end': '14:00', 'type': 'clinic'},
    ],
    5: [
      {'start': '10:00', 'end': '13:00', 'type': 'clinic'},
    ],
    6: [], // Sunday
  };

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: Column(
        children: [
          AppTopBar(
            title: l10n.tr('schedule'),
            showBackButton: !widget.embedded,
          ),
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
                  // Week selector
                  _buildWeekSelector(),
                  const SizedBox(height: 24),
                  // Day picker
                  _buildDayPicker(),
                  const SizedBox(height: 24),
                  // Schedule display
                  _buildScheduleDisplay(),
                  const SizedBox(height: 24),
                  // Quick stats
                  _buildQuickStats(),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddSlotDialog,
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add, color: Colors.white),
        label: Text(
          l10n.tr('addTimeSlot'),
          style: const TextStyle(color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final l10n = context.l10n;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.tr('scheduleManagerTitle'),
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                l10n.tr('scheduleManagerSubtitle'),
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary.withValues(alpha: 0.7),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: AppColors.tertiary.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.check_circle,
                color: AppColors.tertiary,
                size: 18,
              ),
              const SizedBox(width: 8),
              Text(
                l10n.tr('published'),
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.tertiary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildWeekSelector() {
    final l10n = context.l10n;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.textPrimary.withValues(alpha: 0.04),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.chevron_left),
            color: AppColors.textSecondary,
          ),
          Column(
            children: [
              Text(
                _getMonthYearLabel(l10n),
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                _getWeekRangeLabel(l10n),
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary.withValues(alpha: 0.7),
                ),
              ),
            ],
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.chevron_right),
            color: AppColors.textSecondary,
          ),
        ],
      ),
    );
  }

  Widget _buildDayPicker() {
    final weekDays = _getWeekdayShortLabels(context.l10n);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.textPrimary.withValues(alpha: 0.04),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: List.generate(7, (index) {
          final isSelected = _selectedDay == index;
          final hasSlots = (_schedule[index] ?? []).isNotEmpty;

          return Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _selectedDay = index),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primary : Colors.transparent,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Column(
                  children: [
                    Text(
                      weekDays[index],
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: isSelected
                            ? Colors.white.withValues(alpha: 0.8)
                            : AppColors.textSecondary.withValues(alpha: 0.6),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '${_dates[index]}',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: isSelected
                            ? Colors.white
                            : AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: hasSlots
                            ? (isSelected ? Colors.white : AppColors.tertiary)
                            : Colors.transparent,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildScheduleDisplay() {
    final l10n = context.l10n;
    final daySlots = _schedule[_selectedDay] ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              _getSelectedDateLabel(l10n),
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            if (daySlots.isNotEmpty)
              TextButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.edit, size: 16),
                label: Text(l10n.tr('editAll')),
              ),
          ],
        ),
        const SizedBox(height: 16),
        if (daySlots.isEmpty)
          _buildEmptyState()
        else
          ...daySlots.map(
            (slot) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _buildTimeSlot(slot),
            ),
          ),
      ],
    );
  }

  Widget _buildEmptyState() {
    final l10n = context.l10n;

    return Container(
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.outlineVariant.withValues(alpha: 0.5),
          style: BorderStyle.solid,
        ),
      ),
      child: Column(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerHigh,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              Icons.event_busy,
              size: 32,
              color: AppColors.textSecondary.withValues(alpha: 0.4),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            l10n.tr('noAvailabilityTitle'),
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.tr('noAvailabilityMessage'),
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary.withValues(alpha: 0.7),
              height: 1.5,
            ),
          ),
          const SizedBox(height: 20),
          OutlinedButton.icon(
            onPressed: _showAddSlotDialog,
            icon: const Icon(Icons.add),
            label: Text(l10n.tr('addTimeSlot')),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeSlot(Map<String, dynamic> slot) {
    final l10n = context.l10n;
    final type = slot['type'] as String;
    Color typeColor;
    String typeLabel;
    IconData typeIcon;

    switch (type) {
      case 'surgery':
        typeColor = AppColors.error;
        typeLabel = l10n.tr('surgery');
        typeIcon = Icons.medical_services;
        break;
      case 'teleconsult':
        typeColor = AppColors.tertiary;
        typeLabel = l10n.tr('teleconsult');
        typeIcon = Icons.video_call;
        break;
      default:
        typeColor = AppColors.primary;
        typeLabel = l10n.tr('clinicHours');
        typeIcon = Icons.local_hospital;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border(left: BorderSide(color: typeColor, width: 4)),
        boxShadow: [
          BoxShadow(
            color: AppColors.textPrimary.withValues(alpha: 0.04),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          // Time
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                slot['start'] as String,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                slot['end'] as String,
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary.withValues(alpha: 0.7),
                ),
              ),
            ],
          ),
          const SizedBox(width: 20),
          // Divider
          Container(
            width: 1,
            height: 40,
            color: AppColors.surfaceContainerHigh,
          ),
          const SizedBox(width: 20),
          // Type info
          Expanded(
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: typeColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(typeIcon, color: typeColor, size: 22),
                ),
                const SizedBox(width: 14),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      typeLabel,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: typeColor,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _calculateDuration(
                        slot['start'] as String,
                        slot['end'] as String,
                      ),
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary.withValues(alpha: 0.6),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Actions
          PopupMenuButton(
            icon: Icon(
              Icons.more_vert,
              color: AppColors.textSecondary.withValues(alpha: 0.6),
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'edit',
                child: Row(
                  children: [
                    const Icon(Icons.edit, size: 18),
                    const SizedBox(width: 10),
                    Text(l10n.tr('edit')),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'duplicate',
                child: Row(
                  children: [
                    const Icon(Icons.copy, size: 18),
                    const SizedBox(width: 10),
                    Text(l10n.tr('duplicate')),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(
                      Icons.delete_outline,
                      size: 18,
                      color: AppColors.error,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      l10n.tr('delete'),
                      style: TextStyle(color: AppColors.error),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStats() {
    final l10n = context.l10n;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary.withValues(alpha: 0.1),
            AppColors.tertiary.withValues(alpha: 0.1),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.tr('thisWeeksSummary'),
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  l10n.tr('totalHours'),
                  _formatHourValue(28),
                  Icons.schedule,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatItem(
                  l10n.tr('workingDays'),
                  '5',
                  Icons.calendar_today,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatItem(
                  l10n.tr('slots'),
                  '8',
                  Icons.event_available,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, color: AppColors.primary, size: 22),
          const SizedBox(height: 10),
          Text(
            value,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: AppColors.textSecondary.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }

  String _calculateDuration(String start, String end) {
    final l10n = context.l10n;
    final startParts = start.split(':');
    final endParts = end.split(':');

    final startMinutes =
        int.parse(startParts[0]) * 60 + int.parse(startParts[1]);
    final endMinutes = int.parse(endParts[0]) * 60 + int.parse(endParts[1]);

    final durationMinutes = endMinutes - startMinutes;
    final hours = durationMinutes ~/ 60;
    final minutes = durationMinutes % 60;

    if (minutes == 0) {
      return l10n.trWithArgs('hoursShort', {'hours': '$hours'});
    }
    return l10n.trWithArgs('hoursMinutesShort', {
      'hours': '$hours',
      'minutes': '$minutes',
    });
  }

  String _formatHourValue(int hours) {
    return context.l10n.trWithArgs('hoursShort', {'hours': '$hours'});
  }

  void _showAddSlotDialog() {
    final l10n = context.l10n;
    String selectedType = 'clinic';
    TimeOfDay startTime = const TimeOfDay(hour: 9, minute: 0);
    TimeOfDay endTime = const TimeOfDay(hour: 12, minute: 0);

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Text(l10n.tr('addTimeSlot')),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Type selector
                Text(
                  l10n.tr('slotType'),
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
                  children: [
                    _buildTypeOption(
                      l10n.tr('clinic'),
                      'clinic',
                      selectedType,
                      (value) {
                        setDialogState(() => selectedType = value);
                      },
                    ),
                    _buildTypeOption(
                      l10n.tr('surgery'),
                      'surgery',
                      selectedType,
                      (value) {
                        setDialogState(() => selectedType = value);
                      },
                    ),
                    _buildTypeOption(
                      l10n.tr('teleconsult'),
                      'teleconsult',
                      selectedType,
                      (value) {
                        setDialogState(() => selectedType = value);
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                // Time pickers
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.tr('startTime'),
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 8),
                          GestureDetector(
                            onTap: () async {
                              final picked = await showTimePicker(
                                context: context,
                                initialTime: startTime,
                              );
                              if (picked != null) {
                                setDialogState(() => startTime = picked);
                              }
                            },
                            child: Container(
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: AppColors.surfaceContainerLow,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(
                                    Icons.access_time,
                                    size: 18,
                                    color: AppColors.primary,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    startTime.format(context),
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.tr('endTime'),
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 8),
                          GestureDetector(
                            onTap: () async {
                              final picked = await showTimePicker(
                                context: context,
                                initialTime: endTime,
                              );
                              if (picked != null) {
                                setDialogState(() => endTime = picked);
                              }
                            },
                            child: Container(
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: AppColors.surfaceContainerLow,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(
                                    Icons.access_time,
                                    size: 18,
                                    color: AppColors.primary,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    endTime.format(context),
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
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
                const SizedBox(height: 24),
                // Repeat options
                Text(
                  l10n.tr('repeat'),
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            l10n.tr('thisDayOnly'),
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          alignment: Alignment.center,
                          child: Text(
                            l10n.tr('everyWeek'),
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textSecondary.withValues(
                                alpha: 0.7,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(l10n.tr('cancel')),
            ),
            ElevatedButton(
              onPressed: () {
                // Add slot logic
                Navigator.pop(context);
              },
              child: Text(l10n.tr('addTimeSlot')),
            ),
          ],
        ),
      ),
    );
  }

  List<String> _getWeekdayShortLabels(AppLocalizations l10n) => l10n.isArabic
      ? ['اثن', 'ثلا', 'أرب', 'خمي', 'جمع', 'سبت', 'أحد']
      : ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

  List<String> _getWeekdayLongLabels(AppLocalizations l10n) => l10n.isArabic
      ? [
          'الاثنين',
          'الثلاثاء',
          'الأربعاء',
          'الخميس',
          'الجمعة',
          'السبت',
          'الأحد',
        ]
      : [
          'Monday',
          'Tuesday',
          'Wednesday',
          'Thursday',
          'Friday',
          'Saturday',
          'Sunday',
        ];

  List<String> _getMonthShortLabels(AppLocalizations l10n) => l10n.isArabic
      ? [
          'يناير',
          'فبراير',
          'مارس',
          'أبريل',
          'مايو',
          'يونيو',
          'يوليو',
          'أغسطس',
          'سبتمبر',
          'أكتوبر',
          'نوفمبر',
          'ديسمبر',
        ]
      : [
          'Jan',
          'Feb',
          'Mar',
          'Apr',
          'May',
          'Jun',
          'Jul',
          'Aug',
          'Sep',
          'Oct',
          'Nov',
          'Dec',
        ];

  List<String> _getMonthLongLabels(AppLocalizations l10n) => l10n.isArabic
      ? [
          'يناير',
          'فبراير',
          'مارس',
          'أبريل',
          'مايو',
          'يونيو',
          'يوليو',
          'أغسطس',
          'سبتمبر',
          'أكتوبر',
          'نوفمبر',
          'ديسمبر',
        ]
      : [
          'January',
          'February',
          'March',
          'April',
          'May',
          'June',
          'July',
          'August',
          'September',
          'October',
          'November',
          'December',
        ];

  String _getMonthYearLabel(AppLocalizations l10n) {
    final month = _getMonthLongLabels(l10n)[_weekStart.month - 1];
    return '$month ${_weekStart.year}';
  }

  String _getWeekRangeLabel(AppLocalizations l10n) {
    final startMonth = _getMonthShortLabels(l10n)[_weekStart.month - 1];
    final weekEnd = _weekStart.add(const Duration(days: 6));

    if (l10n.isArabic) {
      return '${l10n.tr('week')} 43 • ${_weekStart.day} $startMonth - ${weekEnd.day} $startMonth';
    }

    return '${l10n.tr('week')} 43 • $startMonth ${_weekStart.day} - $startMonth ${weekEnd.day}';
  }

  String _getSelectedDateLabel(AppLocalizations l10n) {
    final weekday = _getWeekdayLongLabels(l10n)[_selectedDay];
    final month = _getMonthShortLabels(l10n)[_weekStart.month - 1];
    final date = _dates[_selectedDay];

    if (l10n.isArabic) {
      return '$weekday، $date $month';
    }

    return '$weekday, $month $date';
  }

  Widget _buildTypeOption(
    String label,
    String value,
    String selected,
    Function(String) onSelect,
  ) {
    final isSelected = selected == value;
    return GestureDetector(
      onTap: () => onSelect(value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.surfaceContainerLow,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: isSelected ? Colors.white : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}
