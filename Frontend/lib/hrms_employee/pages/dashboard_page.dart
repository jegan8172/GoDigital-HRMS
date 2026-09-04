import 'package:flutter/material.dart';

import '../core/employee_session.dart';
import '../shared/employee_ui.dart';

class EmployeeDashboardPage extends StatefulWidget {
  const EmployeeDashboardPage({super.key});
  @override
  State<EmployeeDashboardPage> createState() => _EmployeeDashboardPageState();
}

class _EmployeeDashboardPageState extends State<EmployeeDashboardPage> {
  bool menuOpen = false;
  static const routes = <String>{
    '/employee/dashboard',
    '/employee/attendance',
    '/employee/clock-log',
    '/employee/leave',
    '/employee/permission',
    '/employee/extra-hours',
    '/employee/salary',
    '/employee/tracking',
  };
  void go(String route) {
    setState(() => menuOpen = false);
    if (routes.contains(route))
      Navigator.pushNamed(context, route);
    else
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('This page is not available yet.')));
  }

  @override
  Widget build(BuildContext context) {
    final mobile = MediaQuery.sizeOf(context).width < 600;
    return Scaffold(
        body: SafeArea(
            child: Stack(children: [
      Column(children: [
        _Header(
            mobile: mobile,
            open: menuOpen,
            onMenu: () => setState(() => menuOpen = !menuOpen)),
        Expanded(
            child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(
              mobile ? 18 : 36, mobile ? 24 : 34, mobile ? 18 : 36, 40),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1120),
            child: const _Content(),
          ),
        )),
      ]),
      if (menuOpen)
        _Menu(onClose: () => setState(() => menuOpen = false), onSelect: go),
    ])));
  }
}

class _Header extends StatelessWidget {
  const _Header(
      {required this.mobile, required this.open, required this.onMenu});
  final bool mobile, open;
  final VoidCallback onMenu;
  @override
  Widget build(BuildContext context) => Container(
        height: mobile ? 78 : 88,
        padding: EdgeInsets.symmetric(horizontal: mobile ? 18 : 36),
        decoration: const BoxDecoration(
            color: Colors.white,
            border: Border(bottom: BorderSide(color: Color(0xFFE7EDF7))),
            boxShadow: [
              BoxShadow(
                  color: Color(0x0D102C5A),
                  blurRadius: 14,
                  offset: Offset(0, 4))
            ]),
        child: Row(children: [
          Image.asset('assets/images/go_digital_logo.jpeg',
              height: mobile ? 45 : 53,
              width: mobile ? 136 : 164,
              fit: BoxFit.contain,
              alignment: Alignment.centerLeft),
          const Spacer(),
          if (!mobile) ...[
            const Text('Employee Portal',
                style: TextStyle(color: employeeMuted)),
            const SizedBox(width: 24)
          ],
          const EmployeeNotificationButton(),
          const SizedBox(width: 18),
          const EmployeeProfileMenu(radius: 25),
        ]),
      );
}

class _Content extends StatelessWidget {
  const _Content();
  @override
  Widget build(BuildContext context) =>
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text.rich(
            TextSpan(children: [
              TextSpan(text: 'Hello, '),
              TextSpan(
                  text: 'Arul Kumar', style: TextStyle(color: employeeBlue))
            ]),
            style: TextStyle(
                color: employeeNavy,
                fontSize: 27,
                fontWeight: FontWeight.w800)),
        const SizedBox(height: 6),
        const Text('EMP1001  •  Sunday, 23 Aug 2026',
            style: TextStyle(color: employeeMuted, fontSize: 13)),
        const SizedBox(height: 22),
        const _CheckCard(),
        const SizedBox(height: 18),
        LayoutBuilder(
            builder: (context, c) => c.maxWidth < 520
                ? const Column(
                    children: [_Workday(), SizedBox(height: 14), _Overview()])
                : const Row(children: [
                    Expanded(child: _Workday()),
                    SizedBox(width: 18),
                    Expanded(child: _Overview())
                  ])),
        const SizedBox(height: 18),
        const _Actions(
            'ATTENDANCE', employeeBlue, Icons.calendar_month_outlined, [
          ('Calendar', Icons.calendar_today_outlined, '/employee/attendance'),
          ('Clock Log', Icons.history_rounded, '/employee/clock-log')
        ]),
        const SizedBox(height: 12),
        const _Actions('LEAVE', Color(0xFF6C36E8), Icons.eco_outlined, [
          ('Apply Leave', Icons.note_add_outlined, '/employee/leave'),
          ('My Requests', Icons.assignment_outlined, '/employee/leave')
        ]),
        const SizedBox(height: 12),
        const _Actions(
            'PERMISSION', Color(0xFF5B35D5), Icons.verified_user_outlined, [
          (
            'Apply Permission',
            Icons.verified_user_outlined,
            '/employee/permission'
          ),
          ('View Log', Icons.history_rounded, '/employee/permission')
        ]),
        const SizedBox(height: 12),
        const _Actions('EXTRA HOURS', employeeOrange, Icons.more_time_rounded, [
          ('Log Hours', Icons.more_time_rounded, '/employee/extra-hours'),
          ('38h Total', Icons.timelapse_rounded, '/employee/extra-hours')
        ]),
        const SizedBox(height: 12),
        const _Actions(
            'SALARY', Color(0xFF07368D), Icons.currency_rupee_rounded, [
          ('Net Pay ₹37,846', Icons.currency_rupee_rounded, '/employee/salary'),
          ('View Payslip', Icons.description_outlined, '/employee/salary')
        ]),
        const SizedBox(height: 12),
        const _Actions(
            'TRACKING', Color(0xFF079B9B), Icons.location_on_outlined, [
          ('Live Tracking', Icons.location_on_outlined, '/employee/tracking'),
          ('Route History', Icons.map_outlined, '/employee/tracking')
        ]),
      ]);
}

class _CheckCard extends StatelessWidget {
  const _CheckCard();
  @override
  Widget build(BuildContext context) => AnimatedBuilder(
      animation: EmployeeSession.instance,
      builder: (context, _) {
        final inNow = EmployeeSession.instance.checkedIn;
        final narrow = MediaQuery.sizeOf(context).width < 390;
        final details = Row(children: [
          const DecoratedBox(
              decoration: BoxDecoration(
                  color: Color(0xFF24D479), shape: BoxShape.circle),
              child: SizedBox(width: 11, height: 11)),
          const SizedBox(width: 11),
          Expanded(
              child: Text(inNow ? 'Checked In' : 'Checked Out',
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 17,
                      fontWeight: FontWeight.w800))),
          Text(inNow ? '09:22 AM' : 'Shift complete',
              style: const TextStyle(
                  color: Colors.white, fontWeight: FontWeight.w700))
        ]);
        final action = OutlinedButton.icon(
            onPressed: () {
              inNow
                  ? EmployeeSession.instance.clockOut()
                  : EmployeeSession.instance.clockIn();
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text(inNow
                      ? 'You have been clocked out for today.'
                      : 'You are now checked in.')));
            },
            style: OutlinedButton.styleFrom(
                foregroundColor: Colors.white,
                side: const BorderSide(color: Colors.white, width: 1.2),
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10))),
            icon: const Icon(Icons.logout_rounded, size: 18),
            label: Text(inNow ? 'Clock Out' : 'Clock In',
                style: const TextStyle(fontWeight: FontWeight.w700)));
        return Container(
            padding: const EdgeInsets.fromLTRB(18, 16, 16, 16),
            decoration: BoxDecoration(
                gradient: const LinearGradient(
                    colors: [Color(0xFF0B72F5), Color(0xFF073B9D)]),
                borderRadius: BorderRadius.circular(16),
                boxShadow: const [
                  BoxShadow(
                      color: Color(0x2E0668F5),
                      blurRadius: 20,
                      offset: Offset(0, 9))
                ]),
            child: narrow
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [details, const SizedBox(height: 13), action])
                : Row(children: [
                    Expanded(child: details),
                    const SizedBox(width: 18),
                    action
                  ]));
      });
}

class _Workday extends StatelessWidget {
  const _Workday();
  @override
  Widget build(BuildContext context) => const EmployeeCard(
      padding: EdgeInsets.fromLTRB(19, 18, 19, 20),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text("Today's Workday",
            style: TextStyle(
                color: employeeNavy,
                fontSize: 16,
                fontWeight: FontWeight.w800)),
        SizedBox(height: 18),
        Center(
            child: SizedBox(
                width: 130,
                height: 130,
                child: Stack(alignment: Alignment.center, children: [
                  Positioned.fill(
                      child: CircularProgressIndicator(
                          value: .70,
                          strokeWidth: 10,
                          color: employeeBlue,
                          backgroundColor: Color(0xFFE5EFFD))),
                  Column(mainAxisSize: MainAxisSize.min, children: [
                    Text('8h 20m',
                        style: TextStyle(
                            color: employeeNavy,
                            fontSize: 22,
                            fontWeight: FontWeight.w800)),
                    SizedBox(height: 3),
                    Text('Worked',
                        style: TextStyle(color: employeeMuted, fontSize: 12))
                  ])
                ])))
      ]));
}

class _Overview extends StatelessWidget {
  const _Overview();
  @override
  Widget build(BuildContext context) => const EmployeeCard(
      padding: EdgeInsets.fromLTRB(19, 18, 19, 17),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('August Overview',
            style: TextStyle(
                color: employeeNavy,
                fontSize: 16,
                fontWeight: FontWeight.w800)),
        SizedBox(height: 13),
        _Row('Present', '18', Color(0xFF11A55B)),
        Divider(height: 20, color: employeeLine),
        _Row('Absent', '1', Color(0xFFE34646)),
        Divider(height: 20, color: employeeLine),
        _Row('Late', '2', Color(0xFFFF8B17))
      ]));
}

class _Row extends StatelessWidget {
  const _Row(this.label, this.value, this.color);
  final String label, value;
  final Color color;
  @override
  Widget build(BuildContext context) => Row(children: [
        Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 11),
        Expanded(
            child: Text(label,
                style: const TextStyle(color: employeeNavy, fontSize: 14))),
        Text(value,
            style: TextStyle(
                color: color, fontSize: 22, fontWeight: FontWeight.w800))
      ]);
}

class _Actions extends StatelessWidget {
  const _Actions(this.title, this.color, this.icon, this.actions);
  final String title;
  final Color color;
  final IconData icon;
  final List<(String, IconData, String)> actions;
  @override
  Widget build(BuildContext context) => EmployeeCard(
        padding: EdgeInsets.zero,
        child: Column(children: [
          Container(
            height: 52,
            padding: const EdgeInsets.symmetric(horizontal: 18),
            decoration: BoxDecoration(
                color: color,
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(14))),
            child: Row(children: [
              Icon(icon, color: Colors.white),
              const SizedBox(width: 14),
              Text(title,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w800))
            ]),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(children: [
              for (var i = 0; i < actions.length; i++) ...[
                if (i > 0) const SizedBox(width: 10),
                Expanded(child: _ActionTile(action: actions[i], color: color)),
              ],
            ]),
          ),
        ]),
      );
}

class _ActionTile extends StatelessWidget {
  const _ActionTile({required this.action, required this.color});
  final (String, IconData, String) action;
  final Color color;
  @override
  Widget build(BuildContext context) => InkWell(
        onTap: () => Navigator.pushNamed(context, action.$3,
            arguments: switch (action.$1) {
              'Route History' => 'history',
              'View Log' => 'log',
              _ => null
            }),
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 15),
          decoration: BoxDecoration(
              border: Border.all(color: employeeLine),
              borderRadius: BorderRadius.circular(10)),
          child: Row(children: [
            Icon(action.$2, color: color),
            const SizedBox(width: 10),
            Expanded(
                child: Text(action.$1,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        color: employeeNavy, fontWeight: FontWeight.w600))),
            const Icon(Icons.chevron_right_rounded, color: employeeNavy),
          ]),
        ),
      );
}

class _Menu extends StatelessWidget {
  const _Menu({required this.onClose, required this.onSelect});
  final VoidCallback onClose;
  final ValueChanged<String> onSelect;
  static const items = [
    ('Dashboard', Icons.grid_view_rounded, '/employee/dashboard'),
    ('Attendance', Icons.calendar_month_outlined, '/employee/attendance'),
    ('Clock In / Out', Icons.schedule_rounded, '/employee/clock-log'),
    ('Leave', Icons.description_outlined, '/employee/leave'),
    ('Permission', Icons.verified_user_outlined, '/employee/permission'),
    ('Extra Hours', Icons.more_time_rounded, '/employee/extra-hours'),
    ('Salary', Icons.currency_rupee_rounded, '/employee/salary'),
    ('Tracking', Icons.location_on_outlined, '/employee/tracking')
  ];
  @override
  Widget build(BuildContext context) => Stack(children: [
        GestureDetector(
            onTap: onClose, child: Container(color: const Color(0x4A07143F))),
        Align(
            alignment: Alignment.centerRight,
            child: Material(
                color: Colors.white,
                elevation: 24,
                child: SafeArea(
                    child: SizedBox(
                        width: MediaQuery.sizeOf(context)
                            .width
                            .clamp(280.0, 350.0),
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Padding(
                                  padding:
                                      const EdgeInsets.fromLTRB(22, 19, 12, 15),
                                  child: Row(children: [
                                    const Expanded(
                                        child: Text('Menu',
                                            style: TextStyle(
                                                color: employeeNavy,
                                                fontSize: 20,
                                                fontWeight: FontWeight.w800))),
                                    IconButton(
                                        onPressed: onClose,
                                        icon: const Icon(Icons.close_rounded,
                                            color: employeeNavy))
                                  ])),
                              const Divider(height: 1, color: employeeLine),
                              const SizedBox(height: 8),
                              ...items.map((item) => InkWell(
                                  onTap: () => onSelect(item.$3),
                                  child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 23, vertical: 15),
                                      child: Row(children: [
                                        Icon(item.$2,
                                            color: employeeBlue, size: 22),
                                        const SizedBox(width: 16),
                                        Text(item.$1,
                                            style: const TextStyle(
                                                color: employeeNavy,
                                                fontSize: 15,
                                                fontWeight: FontWeight.w600))
                                      ]))))
                            ])))))
      ]);
}
