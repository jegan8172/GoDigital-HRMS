import 'package:flutter/material.dart';

import '../shared/employee_ui.dart';

class EmployeeAttendancePage extends StatelessWidget {
  const EmployeeAttendancePage({super.key});

  @override
  Widget build(BuildContext context) => const EmployeeScaffold(
        route: '/employee/attendance',
        title: 'Attendance Calendar',
        subtitle: 'Your attendance for August 2026',
        desktop: _AttendanceView(mobile: false),
        mobile: _AttendanceView(mobile: true),
      );
}

class _AttendanceView extends StatefulWidget {
  const _AttendanceView({required this.mobile});
  final bool mobile;

  @override
  State<_AttendanceView> createState() => _AttendanceViewState();
}

class _AttendanceViewState extends State<_AttendanceView> {
  int year = 2026;
  int month = 8;

  static const monthNames = [
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

  static const augustStatuses = <int, String>{
    1: 'P',
    2: 'OFF',
    3: 'P',
    4: 'P',
    5: 'P',
    6: 'P',
    7: 'P',
    8: 'P',
    9: 'OFF',
    10: 'P',
    11: 'P',
    12: 'P',
    13: 'P',
    14: 'A',
    15: 'P',
    16: 'OFF',
    17: 'P',
    18: 'L',
    19: 'P',
    20: 'P',
    21: 'P',
    22: 'P',
    23: 'OFF',
    24: 'P',
    25: 'HL',
    26: 'P',
    27: 'P',
    28: 'P',
    29: 'P',
    30: 'OFF',
    31: 'P',
  };

  String get monthLabel => '${monthNames[month - 1]} $year';

  void changeMonth(int offset) {
    setState(() {
      month += offset;
      if (month == 0) {
        month = 12;
        year--;
      } else if (month == 13) {
        month = 1;
        year++;
      }
    });
  }

  String statusFor(int day) {
    if (year == 2026 && month == 8) return augustStatuses[day] ?? 'P';
    return DateTime(year, month, day).weekday == DateTime.sunday ? 'OFF' : 'P';
  }

  @override
  Widget build(BuildContext context) {
    final calendar = _CalendarCard(
      year: year,
      month: month,
      label: monthLabel,
      mobile: widget.mobile,
      statusFor: statusFor,
      onPrevious: () => changeMonth(-1),
      onNext: () => changeMonth(1),
    );
    final details = Column(children: [
      _SummaryCard(monthLabel: monthLabel, august: year == 2026 && month == 8),
      const SizedBox(height: 16),
      _RecentAttendanceCard(month: monthNames[month - 1]),
    ]);

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      if (widget.mobile) ...[
        const MobileEmployeeHeader(showGreeting: false),
        const SizedBox(height: 24),
        const Text('Attendance Calendar',
            style: TextStyle(
                color: employeeNavy,
                fontSize: 28,
                fontWeight: FontWeight.w800)),
        const SizedBox(height: 5),
        Text('Your attendance for $monthLabel',
            style: const TextStyle(color: employeeMuted, fontSize: 16)),
        const SizedBox(height: 18),
        calendar,
        const SizedBox(height: 16),
        details,
      ] else
        LayoutBuilder(builder: (context, constraints) {
          if (constraints.maxWidth < 980) {
            return Column(
                children: [calendar, const SizedBox(height: 18), details]);
          }
          return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Expanded(flex: 7, child: calendar),
            const SizedBox(width: 20),
            Expanded(flex: 4, child: details),
          ]);
        }),
    ]);
  }
}

class _CalendarCard extends StatelessWidget {
  const _CalendarCard({
    required this.year,
    required this.month,
    required this.label,
    required this.mobile,
    required this.statusFor,
    required this.onPrevious,
    required this.onNext,
  });

  final int year;
  final int month;
  final String label;
  final bool mobile;
  final String Function(int day) statusFor;
  final VoidCallback onPrevious;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) => EmployeeCard(
        padding: EdgeInsets.all(mobile ? 14 : 22),
        child: Column(children: [
          Row(children: [
            _CalendarArrow(
                icon: Icons.chevron_left_rounded, onPressed: onPrevious),
            Expanded(
              child: Text(label,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: employeeBlue,
                      fontSize: mobile ? 22 : 25,
                      fontWeight: FontWeight.w800)),
            ),
            _CalendarArrow(
                icon: Icons.chevron_right_rounded, onPressed: onNext),
          ]),
          const SizedBox(height: 12),
          const Divider(height: 1, color: employeeLine),
          const SizedBox(height: 8),
          _AttendanceCalendar(
              year: year, month: month, mobile: mobile, statusFor: statusFor),
          const SizedBox(height: 14),
          const Wrap(
              alignment: WrapAlignment.center,
              spacing: 15,
              runSpacing: 9,
              children: [
                _LegendStatus('P', 'Present', employeeBlue),
                _LegendStatus('A', 'Absent', Color(0xFFF2212F)),
                _LegendStatus('L', 'Late', employeeOrange),
                _LegendStatus('HL', 'Half Leave', employeePurple),
                _LegendStatus('OFF', 'Weekly Off', Color(0xFF7D8FAA)),
              ]),
        ]),
      );
}

class _AttendanceCalendar extends StatelessWidget {
  const _AttendanceCalendar({
    required this.year,
    required this.month,
    required this.mobile,
    required this.statusFor,
  });

  final int year;
  final int month;
  final bool mobile;
  final String Function(int day) statusFor;

  @override
  Widget build(BuildContext context) {
    const weekdays = ['MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT', 'SUN'];
    final days = DateTime(year, month + 1, 0).day;
    final leading = DateTime(year, month, 1).weekday - 1;
    final used = leading + days;
    final trailing = (7 - used % 7) % 7;
    final cells = <Widget>[
      ...List.generate(leading, (_) => const _EmptyCalendarDay()),
      ...List.generate(days, (index) {
        final day = index + 1;
        return _CalendarDay(day: day, status: statusFor(day));
      }),
      ...List.generate(trailing, (_) => const _EmptyCalendarDay()),
    ];

    return Column(children: [
      Row(
        children: weekdays
            .map((day) => Expanded(
                  child: SizedBox(
                    height: 34,
                    child: Center(
                      child: Text(day,
                          style: TextStyle(
                              color: employeeMuted,
                              fontSize: mobile ? 9 : 11,
                              fontWeight: FontWeight.w800)),
                    ),
                  ),
                ))
            .toList(),
      ),
      GridView.count(
        crossAxisCount: 7,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        childAspectRatio: mobile ? .72 : 1.18,
        children: cells,
      ),
    ]);
  }
}

class _EmptyCalendarDay extends StatelessWidget {
  const _EmptyCalendarDay();

  @override
  Widget build(BuildContext context) => Container(
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: employeeLine, width: .7),
        ),
      );
}

class _CalendarDay extends StatelessWidget {
  const _CalendarDay({required this.day, required this.status});
  final int day;
  final String status;

  Color get color => switch (status) {
        'A' => const Color(0xFFF2212F),
        'L' => employeeOrange,
        'HL' => employeePurple,
        'OFF' => const Color(0xFF7D8FAA),
        _ => employeeBlue,
      };

  @override
  Widget build(BuildContext context) => Container(
        decoration: BoxDecoration(
          color: status == 'OFF' ? const Color(0xFFF6F9FD) : Colors.white,
          border: Border.all(color: employeeLine, width: .7),
        ),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Text('$day',
              style: const TextStyle(
                  color: employeeNavy,
                  fontSize: 13,
                  fontWeight: FontWeight.w700)),
          const SizedBox(height: 7),
          if (status == 'OFF')
            Text('OFF',
                style: TextStyle(
                    color: color, fontSize: 10, fontWeight: FontWeight.w600))
          else
            Container(
              width: status == 'HL' ? 31 : 27,
              height: 27,
              alignment: Alignment.center,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              child: Text(status,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w800)),
            ),
        ]),
      );
}

class _CalendarArrow extends StatelessWidget {
  const _CalendarArrow({required this.icon, required this.onPressed});
  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) => SizedBox(
        width: 42,
        height: 42,
        child: IconButton.outlined(
          onPressed: onPressed,
          padding: EdgeInsets.zero,
          icon: Icon(icon, color: employeeBlue, size: 27),
          style: IconButton.styleFrom(
              side: const BorderSide(color: employeeLine),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8))),
        ),
      );
}

class _LegendStatus extends StatelessWidget {
  const _LegendStatus(this.code, this.label, this.color);
  final String code;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: code == 'OFF' ? 34 : 27,
            height: 27,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: code == 'OFF' ? const Color(0xFFEAF0F8) : color,
              shape: code == 'OFF' ? BoxShape.rectangle : BoxShape.circle,
              borderRadius: code == 'OFF' ? BorderRadius.circular(14) : null,
            ),
            child: Text(code,
                style: TextStyle(
                    color: code == 'OFF' ? employeeMuted : Colors.white,
                    fontSize: 9,
                    fontWeight: FontWeight.w800)),
          ),
          const SizedBox(width: 7),
          Text(label,
              style: const TextStyle(color: employeeNavy, fontSize: 11)),
        ],
      );
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({required this.monthLabel, required this.august});
  final String monthLabel;
  final bool august;

  @override
  Widget build(BuildContext context) => EmployeeCard(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('${monthLabel.split(' ').first} Summary',
              style: const TextStyle(
                  color: employeeBlue,
                  fontSize: 20,
                  fontWeight: FontWeight.w800)),
          const SizedBox(height: 14),
          Row(children: [
            Expanded(
                child: _SummaryCell(
                    'Working Days', august ? '26' : '—', employeeBlue)),
            Expanded(
                child:
                    _SummaryCell('Present', august ? '23' : '—', employeeBlue)),
            Expanded(
                child: _SummaryCell(
                    'Absent', august ? '2' : '—', const Color(0xFFF04438))),
            Expanded(
                child: _SummaryCell('Late', august ? '1' : '—', employeeOrange,
                    last: true)),
          ]),
        ]),
      );
}

class _SummaryCell extends StatelessWidget {
  const _SummaryCell(this.label, this.value, this.color, {this.last = false});
  final String label;
  final String value;
  final Color color;
  final bool last;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 3),
        decoration: BoxDecoration(
          border: last
              ? null
              : const Border(right: BorderSide(color: employeeLine)),
        ),
        child: Column(children: [
          Text(label,
              maxLines: 2,
              textAlign: TextAlign.center,
              style: const TextStyle(color: employeeMuted, fontSize: 10)),
          const SizedBox(height: 5),
          Text(value,
              style: TextStyle(
                  color: color, fontSize: 25, fontWeight: FontWeight.w800)),
        ]),
      );
}

class _RecentAttendanceCard extends StatelessWidget {
  const _RecentAttendanceCard({required this.month});
  final String month;

  @override
  Widget build(BuildContext context) => EmployeeCard(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Recent Attendance',
              style: TextStyle(
                  color: employeeBlue,
                  fontSize: 20,
                  fontWeight: FontWeight.w800)),
          const SizedBox(height: 10),
          _RecentAttendanceRow('23 ${month.substring(0, 3)}', 'Present',
              '09:22 AM', employeeBlue),
          const Divider(color: employeeLine),
          _RecentAttendanceRow('22 ${month.substring(0, 3)}', 'Present',
              '09:05 AM', employeeBlue),
          const Divider(color: employeeLine),
          _RecentAttendanceRow('21 ${month.substring(0, 3)}', 'Late',
              '09:22 AM', employeeOrange),
        ]),
      );
}

class _RecentAttendanceRow extends StatelessWidget {
  const _RecentAttendanceRow(this.date, this.status, this.time, this.color);
  final String date;
  final String status;
  final String time;
  final Color color;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(children: [
          Container(
            padding: const EdgeInsets.all(9),
            decoration: BoxDecoration(
              color: const Color(0xFFEAF2FF),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.calendar_today_outlined,
                color: employeeBlue, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
              child: Text(date,
                  style: const TextStyle(
                      color: employeeNavy, fontWeight: FontWeight.w700))),
          CircleAvatar(radius: 4, backgroundColor: color),
          const SizedBox(width: 6),
          Text(status, style: TextStyle(color: color)),
          const SizedBox(width: 14),
          Text(time, style: const TextStyle(color: employeeMuted)),
        ]),
      );
}
