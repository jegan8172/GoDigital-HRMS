import 'package:flutter/material.dart';

import '../shared/employee_ui.dart';

class EmployeeExtraHoursPage extends StatelessWidget {
  const EmployeeExtraHoursPage({super.key});

  @override
  Widget build(BuildContext context) => const EmployeeScaffold(
        route: '/employee/extra-hours',
        title: 'Extra Hours',
        subtitle: 'Overtime hours tracked for records only',
        desktop: _DesktopExtraHours(),
        mobile: _MobileExtraHours(),
      );
}

const _extraRows = [
  ('19 Aug', 'Wed', '06:00 PM', '08:34 PM', '+2h 34m', 'APPROVED'),
  ('14 Aug', 'Fri', '06:00 PM', '07:10 PM', '+1h 10m', 'APPROVED'),
  ('07 Aug', 'Fri', '06:00 PM', '08:00 PM', '+2h 00m', 'APPROVED'),
  ('02 Aug', 'Sun', '—', '10:00 AM - 04:00 PM', '+6h 00m', 'PENDING'),
  ('28 Jul', 'Mon', '06:00 PM', '07:45 PM', '+1h 45m', 'APPROVED'),
];

class _DesktopExtraHours extends StatelessWidget {
  const _DesktopExtraHours();
  @override
  Widget build(BuildContext context) =>
      Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
        PrimaryButton(
          label: 'Log Hours',
          icon: Icons.add_rounded,
          onPressed: () => _showLogDialog(context),
        ),
        const SizedBox(height: 18),
        Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Expanded(
            flex: 7,
            child: EmployeeCard(
              padding: EdgeInsets.zero,
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.all(22),
                      child: SectionTitle('Extra Hours Log',
                          subtitle: 'August 2026',
                          trailing: HeaderPill('This Month ▼')),
                    ),
                    SimpleTable(
                      minWidth: 790,
                      columns: const [
                        'DATE',
                        'DAY',
                        'REGULAR OUT',
                        'ACTUAL OUT',
                        'EXTRA HRS',
                        'STATUS'
                      ],
                      rows: _extraRows
                          .map((r) => [
                                Text(r.$1,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w700)),
                                Text(r.$2),
                                Text(r.$3),
                                Text(r.$4),
                                Text(r.$5,
                                    style: const TextStyle(
                                        color: employeeBlue,
                                        fontWeight: FontWeight.w800)),
                                StatusPill(
                                    r.$6,
                                    r.$6 == 'APPROVED'
                                        ? employeeBlue
                                        : employeeOrange),
                              ])
                          .toList(),
                    ),
                    const Padding(
                      padding: EdgeInsets.all(22),
                      child: InfoBanner(
                        'Extra hours are recorded for attendance history only. They do not generate additional pay.',
                      ),
                    ),
                  ]),
            ),
          ),
          const SizedBox(width: 20),
          const Expanded(
            flex: 3,
            child: Column(children: [
              MetricCard(
                  label: 'TOTAL EXTRA HOURS',
                  value: '38h',
                  caption: 'Logged this year · 2026',
                  color: employeeBlue,
                  icon: Icons.schedule),
              SizedBox(height: 18),
              MetricCard(
                  label: 'APPROVED SESSIONS',
                  value: '9 / 11',
                  caption: 'Approved by manager',
                  color: employeeBlue,
                  icon: Icons.check_circle_outline),
              SizedBox(height: 18),
              MetricCard(
                  label: 'PENDING APPROVAL',
                  value: '6h 00m',
                  caption: '1 session awaiting review',
                  color: employeeOrange,
                  icon: Icons.hourglass_bottom_rounded),
              SizedBox(height: 18),
              MetricCard(
                  label: 'THIS MONTH',
                  value: '11h',
                  caption: '3 sessions · 2 approved',
                  color: employeeBlue,
                  icon: Icons.bar_chart_rounded),
            ]),
          ),
        ]),
      ]);
}

class _MobileExtraHours extends StatelessWidget {
  const _MobileExtraHours();
  @override
  Widget build(BuildContext context) =>
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const MobileEmployeeHeader(),
        const SizedBox(height: 14),
        EmployeePageTitle(
          title: 'Extra Hours',
          trailing: PrimaryButton(
            label: 'Log Extra Hours',
            icon: Icons.add_circle_outline,
            color: employeeOrange,
            onPressed: () => _showLogDialog(context),
          ),
        ),
        const SizedBox(height: 20),
        const EmployeeCard(
          padding: EdgeInsets.all(18),
          child: Column(children: [
            Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Expanded(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                    Text('This Month',
                        style: TextStyle(
                            color: employeeNavy,
                            fontSize: 20,
                            fontWeight: FontWeight.w800)),
                    SizedBox(height: 6),
                    Text('August 2026', style: TextStyle(color: employeeMuted)),
                  ])),
              Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                Text('Total Extra Hours',
                    style: TextStyle(color: employeeMuted)),
                SizedBox(height: 4),
                Text('12h 45m',
                    style: TextStyle(
                        color: employeeOrange,
                        fontSize: 28,
                        fontWeight: FontWeight.w800)),
              ]),
            ]),
            Divider(height: 28, color: Color(0xFFFFCAA2)),
            Row(children: [
              Expanded(
                  child: _ExtraSummary(
                      Icons.check_circle_outline, 'Approved', '9h 45m')),
              Expanded(
                  child: _ExtraSummary(Icons.schedule, 'Pending', '3h 00m')),
              Expanded(
                  child: _ExtraSummary(
                      Icons.description_outlined, 'Sessions', '5')),
            ]),
          ]),
        ),
        const SizedBox(height: 16),
        EmployeeCard(
          padding: const EdgeInsets.all(12),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Padding(
              padding: EdgeInsets.all(8),
              child: Text('Extra Hours Log',
                  style: TextStyle(
                      color: employeeNavy,
                      fontSize: 20,
                      fontWeight: FontWeight.w800)),
            ),
            ..._extraRows.map((r) => _MobileExtraRow(r)),
          ]),
        ),
        const SizedBox(height: 16),
        const InfoBanner(
          'Extra hours are recorded for attendance history only. They do not generate additional pay.',
          color: employeeOrange,
        ),
      ]);
}

class _ExtraSummary extends StatelessWidget {
  const _ExtraSummary(this.icon, this.label, this.value);
  final IconData icon;
  final String label;
  final String value;
  @override
  Widget build(BuildContext context) => Column(children: [
        Icon(icon, color: employeeOrange, size: 27),
        const SizedBox(height: 8),
        Text(label, style: const TextStyle(color: employeeMuted)),
        const SizedBox(height: 4),
        Text(value,
            style: const TextStyle(
                color: employeeOrange,
                fontSize: 20,
                fontWeight: FontWeight.w800)),
      ]);
}

class _MobileExtraRow extends StatelessWidget {
  const _MobileExtraRow(this.row);
  final (String, String, String, String, String, String) row;
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 14),
        decoration: const BoxDecoration(
            border: Border(bottom: BorderSide(color: employeeLine))),
        child: Row(children: [
          const CircleAvatar(
            radius: 21,
            backgroundColor: Color(0xFFEAF2FF),
            child: Icon(Icons.calendar_today_outlined,
                color: employeeBlue, size: 21),
          ),
          const SizedBox(width: 12),
          Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                Text('${row.$1} 2026 · ${row.$2}',
                    style: const TextStyle(
                        color: employeeNavy, fontWeight: FontWeight.w800)),
                const SizedBox(height: 4),
                Text('${row.$3} – ${row.$4}',
                    style: const TextStyle(color: employeeMuted, fontSize: 12)),
              ])),
          Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
            Text(row.$5,
                style: const TextStyle(
                    color: employeeOrange, fontWeight: FontWeight.w800)),
            const SizedBox(height: 4),
            Text(row.$6,
                style: TextStyle(
                    color: row.$6 == 'APPROVED'
                        ? const Color(0xFF14863C)
                        : employeeOrange,
                    fontSize: 11,
                    fontWeight: FontWeight.w700)),
          ]),
          const SizedBox(width: 7),
          const Icon(Icons.chevron_right_rounded, color: employeeMuted),
        ]),
      );
}

void _showLogDialog(BuildContext context) {
  showDialog<void>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Log Extra Hours'),
      content: const SizedBox(
        width: 360,
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          TextField(
              decoration: InputDecoration(
                  labelText: 'Date',
                  prefixIcon: Icon(Icons.calendar_today_outlined))),
          SizedBox(height: 12),
          TextField(
              decoration: InputDecoration(
                  labelText: 'Hours worked', prefixIcon: Icon(Icons.schedule))),
          SizedBox(height: 12),
          TextField(
              maxLines: 3, decoration: InputDecoration(labelText: 'Reason')),
        ]),
      ),
      actions: [
        TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel')),
        FilledButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content:
                        Text('Extra-hours request submitted for approval.')),
              );
            },
            child: const Text('Submit')),
      ],
    ),
  );
}
