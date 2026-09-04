import 'package:flutter/material.dart';
import '../../core/employee_shell.dart';
import '../../core/employee_nav.dart';

/// See HRMS_PROJECT_BLUEPRINT.md, Section 1 for this page's purpose.
class AttendancePage extends StatelessWidget {
  const AttendancePage({super.key});

  static Widget builder(BuildContext context) => const AttendancePage();

  @override
  Widget build(BuildContext context) {
    return EmployeeShell(
      current: EmployeeNavItem.attendance,
      body: const Center(
          child: Text('AttendancePage — pending design reference')),
    );
  }
}
