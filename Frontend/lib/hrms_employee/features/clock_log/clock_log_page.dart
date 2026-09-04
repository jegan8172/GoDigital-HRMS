import 'package:flutter/material.dart';
import '../../core/employee_shell.dart';
import '../../core/employee_nav.dart';

/// See HRMS_PROJECT_BLUEPRINT.md, Section 1 for this page's purpose.
class ClockLogPage extends StatelessWidget {
  const ClockLogPage({super.key});

  static Widget builder(BuildContext context) => const ClockLogPage();

  @override
  Widget build(BuildContext context) {
    return EmployeeShell(
      current: EmployeeNavItem.clockLog,
      body:
          const Center(child: Text('ClockLogPage — pending design reference')),
    );
  }
}
