import 'package:flutter/material.dart';

import '../shared/employee_ui.dart';

class EmployeeLeavePage extends StatelessWidget {
  const EmployeeLeavePage({super.key});

  @override
  Widget build(BuildContext context) {
    final mode =
        ModalRoute.of(context)?.settings.arguments as String? ?? 'apply';

    return EmployeeScaffold(
      route: '/employee/leave',
      title: 'Leave',
      subtitle: 'Apply and track your leave requests',
      desktop: _DesktopLeave(mode: mode),
      mobile: _MobileLeave(mode: mode),
    );
  }
}

const _leaveRequests = [
  (
    '20',
    'AUG',
    'Medical Leave · Half Day',
    'Afternoon session · Doctor visit',
    'APPROVED',
    Color(0xFF14863C)
  ),
  (
    '02',
    'SEP',
    'Casual Leave · Full Day',
    'Personal work',
    'PENDING',
    employeeOrange
  ),
  (
    '15',
    'SEP',
    'Earned Leave · 3 Days',
    'Family function · 15–17 Sep',
    'PENDING',
    employeeOrange
  ),
  ('10', 'JUL', 'Sick Leave · Full Day', 'Fever', 'DENIED', Color(0xFFF12B46)),
];

class _DesktopLeave extends StatelessWidget {
  const _DesktopLeave({required this.mode});

  final String mode;

  @override
  Widget build(BuildContext context) {
    if (mode == 'requests') {
      return const _RequestList();
    }

    return const Column(
      children: [
        _LeaveBalance(),
        SizedBox(height: 20),
        _LeaveForm(desktop: true),
      ],
    );
  }
}

class _LeaveBalance extends StatelessWidget {
  const _LeaveBalance();
  @override
  Widget build(BuildContext context) => const EmployeeCard(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          SectionTitle('Leave Balance', subtitle: 'Remaining days for 2026'),
          SizedBox(height: 12),
          _BalanceLine('Casual Leave', '8 / 12', employeeGreen),
          _BalanceLine('Sick Leave', '5 / 8', employeePurple),
          _BalanceLine('Earned Leave', '14 / 18', employeeBlue),
          _BalanceLine('Optional Holiday', '2 / 3', employeeOrange),
          SizedBox(height: 108),
        ]),
      );
}

class _BalanceLine extends StatelessWidget {
  const _BalanceLine(this.label, this.value, this.color);
  final String label;
  final String value;
  final Color color;
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 7),
        child: Row(children: [
          Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                  color: color, borderRadius: BorderRadius.circular(2))),
          const SizedBox(width: 12),
          Expanded(
              child: Text(label, style: const TextStyle(color: employeeMuted))),
          Text(value,
              style: const TextStyle(
                  color: employeeNavy, fontWeight: FontWeight.w800)),
        ]),
      );
}

class _RequestList extends StatelessWidget {
  const _RequestList();
  @override
  Widget build(BuildContext context) => EmployeeCard(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const SectionTitle('My Requests',
              subtitle: 'Recent and pending leave requests'),
          const SizedBox(height: 14),
          ..._leaveRequests.map((r) => _DesktopRequestRow(r)),
        ]),
      );
}

class _DesktopRequestRow extends StatelessWidget {
  const _DesktopRequestRow(this.row);
  final (String, String, String, String, String, Color) row;
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: const BoxDecoration(
            border: Border(bottom: BorderSide(color: employeeLine))),
        child: Row(children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
                color: const Color(0xFFF3F6FB),
                borderRadius: BorderRadius.circular(8)),
            child:
                Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              Text(row.$1,
                  style: const TextStyle(
                      color: employeeNavy, fontWeight: FontWeight.w800)),
              Text(row.$2,
                  style: const TextStyle(color: employeeMuted, fontSize: 10)),
            ]),
          ),
          const SizedBox(width: 12),
          Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                Text(row.$3,
                    style: const TextStyle(
                        color: employeeNavy, fontWeight: FontWeight.w700)),
                Text(row.$4,
                    style: const TextStyle(color: employeeMuted, fontSize: 12)),
              ])),
          StatusPill(row.$5, row.$6),
          if (row.$5 == 'PENDING') ...[
            const SizedBox(width: 8),
            const Icon(Icons.close_rounded, color: Color(0xFFF12B46)),
          ],
        ]),
      );
}

class _LeaveForm extends StatefulWidget {
  const _LeaveForm({required this.desktop});
  final bool desktop;
  @override
  State<_LeaveForm> createState() => _LeaveFormState();
}

class _LeaveFormState extends State<_LeaveForm> {
  String type = 'Casual Leave';
  String duration = 'Full Day';
  bool halfDay = false;

  @override
  Widget build(BuildContext context) => EmployeeCard(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const SectionTitle('Apply for Leave',
              subtitle: 'Submit a new leave request for manager approval'),
          const SizedBox(height: 18),
          if (widget.desktop)
            Row(children: [
              Expanded(
                  child: _DropdownField(
                      'LEAVE TYPE',
                      type,
                      const ['Casual Leave', 'Sick Leave', 'Earned Leave'],
                      (v) => setState(() => type = v!))),
              const SizedBox(width: 18),
              Expanded(
                  child: _DropdownField(
                      'DURATION',
                      duration,
                      const ['Full Day', 'Half Day'],
                      (v) => setState(() => duration = v!))),
            ])
          else
            _DropdownField(
                'Leave Type',
                type,
                const ['Casual Leave', 'Sick Leave', 'Earned Leave'],
                (v) => setState(() => type = v!)),
          const SizedBox(height: 14),
          if (widget.desktop)
            Row(children: const [
              Expanded(
                  child: _TextFieldShell('FROM DATE', '09/02/2026',
                      icon: Icons.calendar_today_outlined)),
              SizedBox(width: 18),
              Expanded(
                  child: _TextFieldShell('TO DATE', '09/02/2026',
                      icon: Icons.calendar_today_outlined)),
            ])
          else ...[
            const _TextFieldShell('From Date', 'Select Date',
                icon: Icons.calendar_today_outlined),
            const SizedBox(height: 14),
            const _TextFieldShell('To Date', 'Select Date',
                icon: Icons.calendar_today_outlined),
          ],
          const SizedBox(height: 14),
          const _TextFieldShell(
              'REASON', 'Briefly describe the reason for leave...',
              lines: 3),
          if (!widget.desktop) ...[
            const SizedBox(height: 14),
            Row(children: [
              const Text('Half Day',
                  style: TextStyle(fontWeight: FontWeight.w700)),
              const SizedBox(width: 15),
              Checkbox(
                  value: halfDay,
                  onChanged: (v) => setState(() => halfDay = v ?? false)),
              const Expanded(child: Text('Yes, I want to apply for Half Day')),
            ]),
          ],
          const SizedBox(height: 16),
          Align(
            alignment: Alignment.centerRight,
            child: widget.desktop
                ? Row(mainAxisSize: MainAxisSize.min, children: [
                    OutlinedButton(
                        onPressed: () => ScaffoldMessenger.of(context)
                            .showSnackBar(const SnackBar(
                                content: Text('Leave form cleared.'))),
                        child: const Text('Clear')),
                    const SizedBox(width: 10),
                    PrimaryButton(
                        label: 'Submit Request',
                        icon: Icons.send_outlined,
                        onPressed: () => _submitted(context)),
                  ])
                : SizedBox(
                    width: double.infinity,
                    child: PrimaryButton(
                      label: 'Submit Leave Application',
                      icon: Icons.send_outlined,
                      color: employeePurple,
                      onPressed: () => _submitted(context),
                    ),
                  ),
          ),
        ]),
      );

  void _submitted(BuildContext context) =>
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Leave request submitted for approval.')),
      );
}

class _DropdownField extends StatelessWidget {
  const _DropdownField(this.label, this.value, this.items, this.onChanged);
  final String label;
  final String value;
  final List<String> items;
  final ValueChanged<String?> onChanged;
  @override
  Widget build(BuildContext context) =>
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label,
            style: const TextStyle(
                color: employeeNavy,
                fontSize: 11,
                fontWeight: FontWeight.w700)),
        const SizedBox(height: 6),
        DropdownButtonFormField<String>(
          initialValue: value,
          decoration: InputDecoration(
            filled: true,
            fillColor: const Color(0xFFFBFCFE),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
            border: OutlineInputBorder(
                borderSide: const BorderSide(color: employeeLine),
                borderRadius: BorderRadius.circular(8)),
            enabledBorder: OutlineInputBorder(
                borderSide: const BorderSide(color: employeeLine),
                borderRadius: BorderRadius.circular(8)),
          ),
          items: items
              .map((item) => DropdownMenuItem(value: item, child: Text(item)))
              .toList(),
          onChanged: onChanged,
        ),
      ]);
}

class _TextFieldShell extends StatelessWidget {
  const _TextFieldShell(this.label, this.hint, {this.icon, this.lines = 1});
  final String label;
  final String hint;
  final IconData? icon;
  final int lines;
  @override
  Widget build(BuildContext context) =>
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label,
            style: const TextStyle(
                color: employeeNavy,
                fontSize: 11,
                fontWeight: FontWeight.w700)),
        const SizedBox(height: 6),
        TextField(
          maxLines: lines,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: icon == null ? null : Icon(icon, size: 20),
            filled: true,
            fillColor: const Color(0xFFFBFCFE),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            border: OutlineInputBorder(
                borderSide: const BorderSide(color: employeeLine),
                borderRadius: BorderRadius.circular(8)),
            enabledBorder: OutlineInputBorder(
                borderSide: const BorderSide(color: employeeLine),
                borderRadius: BorderRadius.circular(8)),
          ),
        ),
      ]);
}

class _MobileLeave extends StatelessWidget {
  const _MobileLeave({required this.mode});

  final String mode;

  @override
  Widget build(BuildContext context) {
    if (mode == 'requests') {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const MobileEmployeeHeader(),
          const SizedBox(height: 14),
          const EmployeePageTitle(title: 'My Requests'),
          const SizedBox(height: 20),
          EmployeeCard(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'My Requests',
                  style: TextStyle(
                    color: employeeNavy,
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 12),
                ..._leaveRequests.map((r) => _MobileRequest(r)),
              ],
            ),
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const MobileEmployeeHeader(),
        const SizedBox(height: 14),
        const EmployeePageTitle(title: 'Leave'),
        const SizedBox(height: 20),
        EmployeeCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Leave Balance',
                style: TextStyle(
                  color: employeeNavy,
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 16),
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                childAspectRatio: 1.25,
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                children: const [
                  _MobileBalanceTile(
                    'Casual Leave',
                    '12',
                    employeePurple,
                    Icons.calendar_month_outlined,
                  ),
                  _MobileBalanceTile(
                    'Sick Leave',
                    '8',
                    employeeGreen,
                    Icons.medical_services_outlined,
                  ),
                  _MobileBalanceTile(
                    'Earned Leave',
                    '15',
                    employeeBlue,
                    Icons.work_outline_rounded,
                  ),
                  _MobileBalanceTile(
                    'Comp Off',
                    '6',
                    employeeOrange,
                    Icons.schedule_rounded,
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        const _LeaveForm(desktop: false),
      ],
    );
  }
}

class _MobileBalanceTile extends StatelessWidget {
  const _MobileBalanceTile(this.label, this.value, this.color, this.icon);
  final String label;
  final String value;
  final Color color;
  final IconData icon;
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
            border: Border.all(color: employeeLine),
            borderRadius: BorderRadius.circular(10)),
        child: Row(children: [
          CircleAvatar(
              radius: 22,
              backgroundColor: color.withValues(alpha: .11),
              child: Icon(icon, color: color)),
          const SizedBox(width: 10),
          Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                Text(label,
                    style: TextStyle(
                        color: color,
                        fontSize: 12,
                        fontWeight: FontWeight.w700)),
                Text(value,
                    style: TextStyle(
                        color: color,
                        fontSize: 24,
                        fontWeight: FontWeight.w800)),
                const Text('Days',
                    style: TextStyle(color: employeeMuted, fontSize: 11)),
              ])),
        ]),
      );
}

class _MobileRequest extends StatelessWidget {
  const _MobileRequest(this.row);
  final (String, String, String, String, String, Color) row;
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(vertical: 13),
        decoration: const BoxDecoration(
            border: Border(bottom: BorderSide(color: employeeLine))),
        child: Row(children: [
          CircleAvatar(
              radius: 21,
              backgroundColor: row.$6.withValues(alpha: .1),
              child: Icon(Icons.description_outlined, color: row.$6)),
          const SizedBox(width: 11),
          Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                Text(row.$3,
                    style: const TextStyle(
                        color: employeeNavy, fontWeight: FontWeight.w700)),
                Text('${row.$1} ${row.$2} 2026',
                    style: const TextStyle(color: employeeMuted, fontSize: 12)),
              ])),
          StatusPill(row.$5, row.$6),
        ]),
      );
}
