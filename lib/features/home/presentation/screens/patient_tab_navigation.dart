import 'package:flutter/material.dart';

import 'patient_dashboard_screen.dart';

void navigateToPatientRootTab(BuildContext context, int index) {
  Navigator.of(context).pushAndRemoveUntil(
    MaterialPageRoute<void>(
      builder: (_) => PatientDashboardScreen(initialTabIndex: index),
    ),
    (route) => false,
  );
}
