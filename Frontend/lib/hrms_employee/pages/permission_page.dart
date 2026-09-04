import 'package:flutter/material.dart';

import '../shared/employee_ui.dart';

class EmployeePermissionPage extends StatelessWidget {
  const EmployeePermissionPage({super.key});

  @override
  Widget build(BuildContext context) {
    final logOnly = ModalRoute.of(context)?.settings.arguments == 'log';
    return EmployeeScaffold(
      route: '/employee/permission',
      title: 'Permission',
      subtitle: logOnly
          ? 'Review your permission history'
          : 'Request short personal permission and review your history',
      desktop: _PermissionContent(logOnly: logOnly),
      mobile: _PermissionContent(mobile: true, logOnly: logOnly),
    );
  }
}

class _PermissionContent extends StatefulWidget {
  const _PermissionContent({this.mobile = false, this.logOnly = false});
  final bool mobile;
  final bool logOnly;

  @override
  State<_PermissionContent> createState() => _PermissionContentState();
}

class _PermissionContentState extends State<_PermissionContent> {
  final _reason = TextEditingController();
  bool submitted = false;

  @override
  void dispose() {
    _reason.dispose();
    super.dispose();
  }

  void submit() {
    if (_reason.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please enter a reason.')));
      return;
    }
    setState(() => submitted = true);
    _reason.clear();
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Permission request submitted for approval.')));
  }

  @override
  Widget build(BuildContext context) =>
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        if (widget.mobile) ...[
          const MobileEmployeeHeader(showGreeting: false),
          const SizedBox(height: 18),
          const Text('Permission',
              style: TextStyle(
                  color: employeeNavy,
                  fontSize: 28,
                  fontWeight: FontWeight.w800)),
          const SizedBox(height: 18),
        ],
        if (!widget.logOnly)
          EmployeeCard(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                const SectionTitle('Apply Permission',
                    subtitle:
                        'Submit a short absence request for manager approval'),
                const SizedBox(height: 18),
                const TextField(
                    decoration: InputDecoration(
                        labelText: 'Date',
                        prefixIcon: Icon(Icons.calendar_today_outlined),
                        border: OutlineInputBorder())),
                const SizedBox(height: 14),
                const TextField(
                    decoration: InputDecoration(
                        labelText: 'Time required',
                        hintText: 'Example: 02:00 PM – 04:00 PM',
                        prefixIcon: Icon(Icons.schedule_outlined),
                        border: OutlineInputBorder())),
                const SizedBox(height: 14),
                TextField(
                    controller: _reason,
                    minLines: 3,
                    maxLines: 4,
                    decoration: const InputDecoration(
                        labelText: 'Reason',
                        hintText: 'Briefly describe your request',
                        border: OutlineInputBorder())),
                const SizedBox(height: 16),
                Align(
                    alignment: Alignment.centerRight,
                    child: PrimaryButton(
                        label: 'Submit Request',
                        icon: Icons.send_outlined,
                        onPressed: submit)),
              ])),
        if (!widget.logOnly) const SizedBox(height: 18),
        if (widget.logOnly)
          EmployeeCard(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                const SectionTitle('Permission Log'),
                const SizedBox(height: 12),
                _row('20 Aug 2026', 'Doctor appointment', '02:00 PM – 04:00 PM',
                    'APPROVED', employeeGreen),
                if (submitted)
                  _row('Today', 'New permission request',
                      'Pending manager review', 'PENDING', employeeOrange),
              ])),
      ]);

  Widget _row(String date, String reason, String time, String status,
          Color color) =>
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(children: [
          const Icon(Icons.shield_outlined, color: employeePurple),
          const SizedBox(width: 12),
          Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                Text(date,
                    style: const TextStyle(
                        color: employeeNavy, fontWeight: FontWeight.w700)),
                Text('$reason · $time',
                    style: const TextStyle(color: employeeMuted, fontSize: 12))
              ])),
          StatusPill(status, color),
        ]),
      );
}
