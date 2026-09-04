import 'package:flutter/material.dart';

import 'pages/attendance_page.dart';
import 'pages/clock_page.dart';
import 'pages/dashboard_page.dart';
import 'pages/extra_hours_page.dart';
import 'pages/leave_page.dart';
import 'pages/permission_page.dart';
import 'pages/salary_page.dart';
import 'pages/tracking_page.dart';

void main() => runApp(const EmployeePortal());

class EmployeePortal extends StatelessWidget {
  const EmployeePortal({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Go Digital Employee Portal',
        theme: ThemeData(
          useMaterial3: true,
          fontFamily: 'Arial',
          scaffoldBackgroundColor: const Color(0xFFF8FBFF),
          colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF0668F5)),
          textTheme: const TextTheme(
            headlineLarge: TextStyle(
              color: Color(0xFF07143F),
              fontWeight: FontWeight.w800,
            ),
            titleLarge: TextStyle(
              color: Color(0xFF07143F),
              fontWeight: FontWeight.w700,
            ),
            bodyMedium: TextStyle(color: Color(0xFF263451)),
          ),
        ),
        initialRoute: '/employee/dashboard',
        routes: {
          '/employee/dashboard': (_) => const EmployeeDashboardPage(),
          '/employee/attendance': (_) => const EmployeeAttendancePage(),
          '/employee/clock-log': (_) => const EmployeeClockPage(),
          '/employee/leave': (_) => const EmployeeLeavePage(),
          '/employee/permission': (_) => const EmployeePermissionPage(),
          '/employee/extra-hours': (_) => const EmployeeExtraHoursPage(),
          '/employee/salary': (_) => const EmployeeSalaryPage(),
          '/employee/tracking': (_) => const EmployeeTrackingPage(),
        },
      );
}
