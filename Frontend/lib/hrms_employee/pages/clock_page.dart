import 'package:flutter/material.dart';

import '../core/employee_session.dart';
import '../shared/employee_ui.dart';

class EmployeeClockPage extends StatelessWidget {
  const EmployeeClockPage({super.key});

  @override
  Widget build(BuildContext context) => const EmployeeScaffold(
        route: '/employee/clock-log',
        title: 'Clock In / Clock Out',
        subtitle: 'Track your daily working hours in real time',
        desktop: _DesktopClock(),
        mobile: _MobileClock(),
      );
}

const _clockRows = [
  ('Sat, 22 Aug', '09:00 AM', '05:00 PM', '8h 00m', '00h 00m', '—'),
  ('Fri, 21 Aug', '09:22 AM', '06:10 PM', '8h 48m', '00h 48m', 'Not Paid'),
  ('Thu, 20 Aug', '09:00 AM', '01:00 PM', '4h 00m', '— (Half Leave)', '—'),
  ('Wed, 19 Aug', '09:18 AM', '07:05 PM', '9h 47m', '01h 47m', 'Not Paid'),
  ('Tue, 18 Aug', '09:00 AM', '05:00 PM', '8h 00m', '00h 00m', '—'),
  ('Mon, 17 Aug', '09:08 AM', '05:20 PM', '8h 12m', '00h 12m', 'Not Paid'),
];

class _DesktopClock extends StatelessWidget {
  const _DesktopClock();
  @override
  Widget build(BuildContext context) => Column(children: [
        EmployeeCard(
          child: Column(children: [
            Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Expanded(
                  child: _SessionMetric('TODAY’S SESSION — 24 AUG 2026',
                      '09:00 AM', 'Clock In', employeeNavy)),
              const _MetricDivider(),
              const Expanded(
                  child: _SessionMetric('ELAPSED TODAY', '07h 42m',
                      'Still checked in', employeeBlue)),
              const _MetricDivider(),
              const Expanded(
                  child: _SessionMetric('EXTRA HOURS (BEYOND 8H SHIFT)',
                      '00h 00m', '⚠ Not compensated', employeeOrange)),
              const SizedBox(width: 24),
              AnimatedBuilder(
                animation: EmployeeSession.instance,
                builder: (context, _) {
                  final checkedIn = EmployeeSession.instance.checkedIn;
                  return Column(children: [
                    PrimaryButton(
                      label: checkedIn ? 'Clock Out' : 'Clock In',
                      icon: checkedIn
                          ? Icons.logout_rounded
                          : Icons.login_rounded,
                      onPressed: () {
                        if (checkedIn) {
                          EmployeeSession.instance.clockOut();
                          ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text('Clock out recorded.')));
                        } else {
                          EmployeeSession.instance.clockIn();
                          ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text('Clock in recorded.')));
                        }
                      },
                    ),
                    const SizedBox(height: 12),
                    const Text('Standard shift: 09:00 AM - 05:00 PM',
                        style: TextStyle(color: employeeMuted, fontSize: 12)),
                  ]);
                },
              ),
            ]),
            const SizedBox(height: 18),
            const InfoBanner(
              'Policy: Extra hours beyond the 8-hour shift are recorded on your attendance log for visibility only. They do not add to salary or generate compensation.',
              color: employeeOrange,
            ),
          ]),
        ),
        const SizedBox(height: 20),
        EmployeeCard(
          padding: EdgeInsets.zero,
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Padding(
              padding: EdgeInsets.all(22),
              child: SectionTitle('Recent Clock Log',
                  subtitle: 'Extra hours are logged but excluded from payroll'),
            ),
            SimpleTable(
              minWidth: 1040,
              columns: const [
                'DATE',
                'CLOCK IN',
                'CLOCK OUT',
                'TOTAL HOURS',
                'EXTRA HOURS',
                'COMPENSATION'
              ],
              rows: _clockRows
                  .map((r) => [
                        Text(r.$1),
                        Text(r.$2),
                        Text(r.$3),
                        Text(r.$4),
                        Text(r.$5,
                            style: TextStyle(
                                color: r.$5.contains('Half')
                                    ? employeeBlue
                                    : employeeNavy)),
                        Text(r.$6,
                            style: TextStyle(
                                color: r.$6 == 'Not Paid'
                                    ? const Color(0xFFF12B46)
                                    : employeeNavy,
                                fontWeight: r.$6 == 'Not Paid'
                                    ? FontWeight.w700
                                    : FontWeight.normal)),
                      ])
                  .toList(),
            ),
          ]),
        ),
      ]);
}

class _SessionMetric extends StatelessWidget {
  const _SessionMetric(this.label, this.value, this.caption, this.color);
  final String label;
  final String value;
  final String caption;
  final Color color;
  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: const TextStyle(
                  color: employeeMuted,
                  fontSize: 11,
                  fontWeight: FontWeight.w800)),
          const SizedBox(height: 12),
          Text(value,
              style: TextStyle(
                  color: color, fontSize: 30, fontWeight: FontWeight.w800)),
          const SizedBox(height: 8),
          Text(caption, style: TextStyle(color: color)),
        ],
      );
}

class _MetricDivider extends StatelessWidget {
  const _MetricDivider();
  @override
  Widget build(BuildContext context) => const SizedBox(
        height: 105,
        child: VerticalDivider(width: 32, color: employeeLine),
      );
}

class _MobileClock extends StatelessWidget {
  const _MobileClock();
  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const MobileEmployeeHeader(),
          const SizedBox(height: 14),
          EmployeePageTitle(
            title: 'Clock Log',
            trailing: AnimatedBuilder(
              animation: EmployeeSession.instance,
              builder: (context, _) {
                final checkedIn = EmployeeSession.instance.checkedIn;
                return PrimaryButton(
                  label: checkedIn ? 'Clock Out' : 'Clock In',
                  icon: checkedIn ? Icons.logout_rounded : Icons.login_rounded,
                  onPressed: () {
                    if (checkedIn) {
                      EmployeeSession.instance.clockOut();
                      ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Clock out recorded.')));
                    } else {
                      EmployeeSession.instance.clockIn();
                      ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Clock in recorded.')));
                    }
                  },
                );
              },
            ),
          ),
          const SizedBox(height: 20),
          const EmployeeCard(
            padding: EdgeInsets.all(16),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Expanded(
                  child: Text('Today, 24 Aug 2026',
                      style: TextStyle(
                          color: employeeNavy,
                          fontSize: 19,
                          fontWeight: FontWeight.w800)),
                ),
                StatusPill('Working', Color(0xFF14863C)),
              ]),
              SizedBox(height: 18),
              Row(children: [
                Expanded(
                    child: _MobileClockMetric(
                        Icons.schedule, 'Clock In', '09:18 AM', employeeGreen)),
                SizedBox(
                    height: 70, child: VerticalDivider(color: employeeLine)),
                Expanded(
                    child: _MobileClockMetric(Icons.timer_outlined, 'Clock Out',
                        '--:--', employeeOrange)),
              ]),
              Divider(height: 30, color: employeeLine),
              Row(children: [
                Expanded(
                    child: _MobileClockMetric(Icons.calendar_month_outlined,
                        'Total Hours', '07h 42m', employeeGreen)),
                SizedBox(
                    height: 70, child: VerticalDivider(color: employeeLine)),
                Expanded(
                    child: _MobileClockMetric(Icons.coffee_outlined, 'Break',
                        '00h 30m', employeePurple)),
              ]),
              Divider(height: 30, color: employeeLine),
              Text('Standard shift',
                  style: TextStyle(fontWeight: FontWeight.w700)),
              SizedBox(height: 4),
              Text('09:00 AM – 05:00 PM',
                  style: TextStyle(color: employeeMuted)),
              SizedBox(height: 12),
              LinearProgressIndicator(
                value: .82,
                minHeight: 9,
                borderRadius: BorderRadius.all(Radius.circular(8)),
                color: employeeBlue,
                backgroundColor: Color(0xFFE4EAF3),
              ),
            ]),
          ),
          const SizedBox(height: 16),
          EmployeeCard(
            padding: const EdgeInsets.all(12),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Padding(
                padding: EdgeInsets.all(8),
                child: Text('Recent Logs',
                    style: TextStyle(
                        color: employeeNavy,
                        fontSize: 20,
                        fontWeight: FontWeight.w800)),
              ),
              ..._clockRows
                  .take(5)
                  .map((r) => _MobileLogRow(r.$1, r.$2, r.$3, r.$4)),
            ]),
          ),
          const SizedBox(height: 16),
          const EmployeeCard(
            padding: EdgeInsets.all(16),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('This Month',
                  style: TextStyle(
                      color: employeeNavy,
                      fontSize: 19,
                      fontWeight: FontWeight.w800)),
              SizedBox(height: 18),
              Row(children: [
                Expanded(
                    child: _MonthlyMetric(Icons.calendar_month_outlined,
                        'Working Days', '26', employeeGreen)),
                Expanded(
                    child: _MonthlyMetric(
                        Icons.people_outline, 'Present', '23', employeeBlue)),
                Expanded(
                    child: _MonthlyMetric(
                        Icons.schedule, 'Extra Hours', '11h', employeePurple)),
              ]),
            ]),
          ),
        ],
      );
}

class _MobileClockMetric extends StatelessWidget {
  const _MobileClockMetric(this.icon, this.label, this.value, this.color);
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.all(8),
        child: Row(children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(width: 12),
          Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                Text(label, style: const TextStyle(color: employeeMuted)),
                const SizedBox(height: 5),
                Text(value,
                    style: const TextStyle(
                        color: employeeNavy,
                        fontSize: 20,
                        fontWeight: FontWeight.w800)),
              ])),
        ]),
      );
}

class _MobileLogRow extends StatelessWidget {
  const _MobileLogRow(this.date, this.clockIn, this.clockOut, this.total);
  final String date;
  final String clockIn;
  final String clockOut;
  final String total;
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        decoration: const BoxDecoration(
            border: Border(bottom: BorderSide(color: employeeLine))),
        child: Row(children: [
          Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                Text(date,
                    style: const TextStyle(
                        color: employeeNavy, fontWeight: FontWeight.w700)),
                const SizedBox(height: 3),
                Text('$clockIn – $clockOut',
                    style: const TextStyle(color: employeeMuted)),
              ])),
          Text(total,
              style: const TextStyle(
                  color: employeeBlue, fontWeight: FontWeight.w800)),
          const SizedBox(width: 8),
          const Icon(Icons.chevron_right_rounded, color: employeeMuted),
        ]),
      );
}

class _MonthlyMetric extends StatelessWidget {
  const _MonthlyMetric(this.icon, this.label, this.value, this.color);
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  @override
  Widget build(BuildContext context) => Column(children: [
        Icon(icon, color: color, size: 25),
        const SizedBox(height: 7),
        Text(label,
            textAlign: TextAlign.center,
            style: const TextStyle(color: employeeMuted, fontSize: 11)),
        const SizedBox(height: 4),
        Text(value,
            style: const TextStyle(
                color: employeeNavy,
                fontSize: 20,
                fontWeight: FontWeight.w800)),
      ]);
}
