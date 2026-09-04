import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../shared/widgets/admin_top_nav.dart';
import '../dashboard/widgets/manage_calendar_dialog.dart' as calendar;

abstract final class _ApprovalsColors {
  static const blue = Color(0xFF075EF7);
  static const navy = Color(0xFF061457);
  static const page = Color(0xFFF7F9FD);
}

class ApprovalsPage extends StatefulWidget {
  const ApprovalsPage({super.key});

  static Widget builder(BuildContext context) => const ApprovalsPage();

  @override
  State<ApprovalsPage> createState() => _ApprovalsPageState();
}

class _ApprovalsPageState extends State<ApprovalsPage> {
  static const _storageKey = 'admin_approval_statuses_v1';
  bool leaveRequests = true;
  String employee = 'All Employees';
  String status = 'All Status';
  String dateRange = '17 Aug 2026 – 23 Aug 2026';

  final leaveRequestItems = <_ApprovalRequest>[
    _ApprovalRequest(
        'Arul Kumar',
        'EMP1001',
        'Annual Leave',
        '21 Aug 2026 – 24 Aug 2026',
        '(Thu – Sun)',
        '4 Days',
        'Family vacation',
        'Pending',
        Icons.beach_access_outlined,
        0xFF7137E8),
    _ApprovalRequest(
        'Priya Sharma',
        'EMP1002',
        'Sick Leave',
        '20 Aug 2026 – 20 Aug 2026',
        '(Thu)',
        '1 Day',
        'Not feeling well',
        'Pending',
        Icons.medical_services_outlined,
        0xFFFF4F62),
    _ApprovalRequest(
        'Vikram Singh',
        'EMP1003',
        'Personal Leave',
        '19 Aug 2026 – 19 Aug 2026',
        '(Wed)',
        '1 Day',
        'Personal work',
        'Approved',
        Icons.event_busy_outlined,
        0xFFFF6D3A),
    _ApprovalRequest(
        'Neha Verma',
        'EMP1004',
        'Annual Leave',
        '17 Aug 2026 – 18 Aug 2026',
        '(Mon – Tue)',
        '2 Days',
        'Short trip',
        'Approved',
        Icons.beach_access_outlined,
        0xFF7137E8),
    _ApprovalRequest(
        'Rohan Mehta',
        'EMP1005',
        'Sick Leave',
        '18 Aug 2026 – 18 Aug 2026',
        '(Tue)',
        '1 Day',
        'Fever and rest',
        'Approved',
        Icons.medical_services_outlined,
        0xFFFF4F62),
  ];

  final extraHourItems = <_ApprovalRequest>[
    _ApprovalRequest(
        'Arul Kumar',
        'EMP1001',
        'Extra Hours',
        '22 Aug 2026',
        '(Sat)',
        '2h 30m',
        'Client deployment',
        'Pending',
        Icons.more_time_rounded,
        0xFFFF6500),
    _ApprovalRequest(
        'Priya Sharma',
        'EMP1002',
        'Extra Hours',
        '20 Aug 2026',
        '(Thu)',
        '1h 45m',
        'Campaign launch',
        'Pending',
        Icons.more_time_rounded,
        0xFFFF6500),
    _ApprovalRequest(
        'Rohan Mehta',
        'EMP1005',
        'Extra Hours',
        '18 Aug 2026',
        '(Tue)',
        '2h 00m',
        'Payroll closing',
        'Approved',
        Icons.more_time_rounded,
        0xFFFF6500),
  ];

  @override
  void initState() {
    super.initState();
    _loadStatuses();
  }

  List<_ApprovalRequest> get allRequests =>
      [...leaveRequestItems, ...extraHourItems];

  Future<void> _loadStatuses() async {
    final preferences = await SharedPreferences.getInstance();
    final encoded = preferences.getString(_storageKey);
    if (encoded == null) return;
    try {
      final saved = Map<String, dynamic>.from(jsonDecode(encoded) as Map);
      for (final request in allRequests) {
        final stored = saved[request.storageId];
        if (stored is String) request.status = stored;
      }
      if (mounted) setState(() {});
    } catch (_) {
      // Keep the starter approval data when saved data is invalid.
    }
  }

  Future<void> _saveStatuses() async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(
      _storageKey,
      jsonEncode({
        for (final request in allRequests) request.storageId: request.status
      }),
    );
  }

  List<_ApprovalRequest> get visibleRequests {
    final source = leaveRequests ? leaveRequestItems : extraHourItems;
    return source.where((request) {
      final employeeMatch =
          employee == 'All Employees' || request.name == employee;
      final statusMatch = status == 'All Status' || request.status == status;
      final dateMatch = dateRange == 'All Dates' ||
          request.dates.contains(RegExp(r'1[7-9]|2[0-3] Aug 2026'));
      return employeeMatch && statusMatch && dateMatch;
    }).toList();
  }

  Future<void> _updateStatus(
      _ApprovalRequest request, String nextStatus) async {
    setState(() => request.status = nextStatus);
    await _saveStatuses();
    await calendar.CalendarStore.addNotification({
      'type': 'approval',
      'employeeId': request.id,
      'employeeName': request.name,
      'title': '${request.type} $nextStatus',
      'message':
          'Your ${request.type.toLowerCase()} request for ${request.dates} was ${nextStatus.toLowerCase()}.',
      'createdAt': DateTime.now().toIso8601String(),
      'read': false,
    });
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content: Text(
              '${request.name} was notified: request ${nextStatus.toLowerCase()}')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final mobile = MediaQuery.sizeOf(context).width < 600;
    return Scaffold(
      backgroundColor: _ApprovalsColors.page,
      body: Column(
        children: [
          const AdminTopNav(activeRoute: '/admin/approvals'),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(
                  mobile ? 16 : 28, 18, mobile ? 16 : 28, 28),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1580),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const _ApprovalsHeader(),
                      const SizedBox(height: 17),
                      _ApprovalKpis(requests: allRequests),
                      const SizedBox(height: 16),
                      _RequestsPanel(
                        leaveRequests: leaveRequests,
                        employee: employee,
                        status: status,
                        dateRange: dateRange,
                        leaveCount: leaveRequestItems.length,
                        extraCount: extraHourItems.length,
                        requests: visibleRequests,
                        onTabChanged: (value) =>
                            setState(() => leaveRequests = value),
                        onEmployeeChanged: (value) =>
                            setState(() => employee = value!),
                        onStatusChanged: (value) =>
                            setState(() => status = value!),
                        onDateChanged: (value) =>
                            setState(() => dateRange = value!),
                        onReset: () => setState(() {
                          employee = 'All Employees';
                          status = 'All Status';
                          dateRange = '17 Aug 2026 – 23 Aug 2026';
                        }),
                        onApprove: (request) =>
                            _updateStatus(request, 'Approved'),
                        onReject: (request) =>
                            _updateStatus(request, 'Rejected'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ApprovalsHeader extends StatelessWidget {
  const _ApprovalsHeader();

  @override
  Widget build(BuildContext context) =>
      const AdminPageHeader(title: 'Approvals');
}

class _ApprovalKpis extends StatelessWidget {
  const _ApprovalKpis({required this.requests});

  final List<_ApprovalRequest> requests;

  @override
  Widget build(BuildContext context) {
    final pending =
        requests.where((request) => request.status == 'Pending').length;
    final approved =
        requests.where((request) => request.status == 'Approved').length;
    final rejected =
        requests.where((request) => request.status == 'Rejected').length;
    final cards = [
      _ApprovalKpi('Pending', '$pending', 'Requests awaiting approval',
          Icons.pending_actions_outlined, _ApprovalsColors.blue),
      _ApprovalKpi('Approved This Month', '$approved', 'Requests approved',
          Icons.check_circle_outline_rounded, Color(0xFF158C20)),
      _ApprovalKpi('Rejected', '$rejected', 'Requests rejected',
          Icons.highlight_off_rounded, Color(0xFFF0182A)),
    ];
    return LayoutBuilder(builder: (_, constraints) {
      final columns = constraints.maxWidth < 700
          ? 1
          : constraints.maxWidth < 1050
              ? 2
              : 3;
      final width = (constraints.maxWidth - (columns - 1) * 20) / columns;
      return Wrap(
          spacing: 20,
          runSpacing: 16,
          children: cards
              .map((card) => SizedBox(width: width, child: card))
              .toList());
    });
  }
}

class _ApprovalKpi extends StatelessWidget {
  const _ApprovalKpi(
      this.label, this.value, this.caption, this.icon, this.color);
  final String label, value, caption;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) => Container(
        height: 116,
        padding: const EdgeInsets.fromLTRB(18, 15, 18, 9),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: const Color(0xFFE5E8EF)),
          borderRadius: BorderRadius.circular(13),
          boxShadow: const [
            BoxShadow(
                color: Color(0x0C071A72), blurRadius: 16, offset: Offset(0, 6))
          ],
        ),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  width: 54,
                  height: 54,
                  decoration: BoxDecoration(
                      color: color.withValues(alpha: .09),
                      shape: BoxShape.circle),
                  child: Icon(icon, color: color, size: 29),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(label,
                          style: const TextStyle(
                              color: Color(0xFF596176), fontSize: 15)),
                      Text(value,
                          style: const TextStyle(
                              color: Color(0xFF090B12),
                              fontSize: 29,
                              height: 1.15,
                              fontWeight: FontWeight.w700)),
                      const SizedBox(height: 3),
                      Text(caption,
                          style: const TextStyle(
                              color: Color(0xFF596176), fontSize: 13)),
                    ],
                  ),
                ),
              ],
            ),
            const Spacer(),
            Align(
              alignment: Alignment.centerLeft,
              child: Container(
                  width: 55,
                  height: 3,
                  decoration: BoxDecoration(
                      color: _ApprovalsColors.blue,
                      borderRadius: BorderRadius.circular(4))),
            ),
          ],
        ),
      );
}

class _RequestsPanel extends StatelessWidget {
  const _RequestsPanel({
    required this.leaveRequests,
    required this.employee,
    required this.status,
    required this.dateRange,
    required this.leaveCount,
    required this.extraCount,
    required this.requests,
    required this.onTabChanged,
    required this.onEmployeeChanged,
    required this.onStatusChanged,
    required this.onDateChanged,
    required this.onReset,
    required this.onApprove,
    required this.onReject,
  });

  final bool leaveRequests;
  final String employee, status, dateRange;
  final int leaveCount, extraCount;
  final List<_ApprovalRequest> requests;
  final ValueChanged<bool> onTabChanged;
  final ValueChanged<String?> onEmployeeChanged, onStatusChanged, onDateChanged;
  final VoidCallback onReset;
  final ValueChanged<_ApprovalRequest> onApprove, onReject;

  @override
  Widget build(BuildContext context) => Container(
        padding: EdgeInsets.fromLTRB(
          MediaQuery.sizeOf(context).width < 600 ? 14 : 28,
          20,
          MediaQuery.sizeOf(context).width < 600 ? 14 : 28,
          18,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: const Color(0xFFE4E7EE)),
          borderRadius: BorderRadius.circular(14),
          boxShadow: const [
            BoxShadow(
                color: Color(0x0A071A72), blurRadius: 16, offset: Offset(0, 6))
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _ApprovalTabs(
                leaveRequests: leaveRequests,
                leaveCount: leaveCount,
                extraCount: extraCount,
                onChanged: onTabChanged),
            const SizedBox(height: 16),
            _ApprovalFilters(
              employee: employee,
              status: status,
              dateRange: dateRange,
              onEmployeeChanged: onEmployeeChanged,
              onStatusChanged: onStatusChanged,
              onDateChanged: onDateChanged,
              onReset: onReset,
            ),
            const SizedBox(height: 16),
            if (MediaQuery.sizeOf(context).width < 600)
              _MobileApprovalList(
                  requests: requests, onApprove: onApprove, onReject: onReject)
            else
              _ApprovalTable(
                  requests: requests, onApprove: onApprove, onReject: onReject),
            const SizedBox(height: 18),
            if (MediaQuery.sizeOf(context).width < 600)
              Center(
                  child: Text('${requests.length} requests',
                      style: const TextStyle(
                          color: Color(0xFF596176), fontSize: 12)))
            else
              Row(
                children: [
                  Text(
                      'Showing 1 to ${requests.length} of ${requests.length} requests',
                      style: const TextStyle(
                          color: Color(0xFF596176), fontSize: 13)),
                  const Spacer(),
                  const _PaginationButton(icon: Icons.chevron_left_rounded),
                  const _PaginationButton(text: '1', active: true),
                  const _PaginationButton(icon: Icons.chevron_right_rounded),
                ],
              ),
          ],
        ),
      );
}

class _MobileApprovalList extends StatelessWidget {
  const _MobileApprovalList(
      {required this.requests,
      required this.onApprove,
      required this.onReject});
  final List<_ApprovalRequest> requests;
  final ValueChanged<_ApprovalRequest> onApprove, onReject;

  @override
  Widget build(BuildContext context) {
    if (requests.isEmpty) {
      return const SizedBox(
          height: 150,
          child:
              Center(child: Text('No approval requests match these filters.')));
    }
    return Column(
      children: requests
          .map(
            (request) => Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: const Color(0xFFE5EAF3)),
                  borderRadius: BorderRadius.circular(14)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    CircleAvatar(
                        radius: 21,
                        backgroundColor: const Color(0xFFEAF1FF),
                        child: Text(request.name.substring(0, 1),
                            style: const TextStyle(
                                color: _ApprovalsColors.blue,
                                fontWeight: FontWeight.w800))),
                    const SizedBox(width: 11),
                    Expanded(
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                          Text(request.name,
                              style: const TextStyle(
                                  color: _ApprovalsColors.navy,
                                  fontWeight: FontWeight.w700)),
                          Text('${request.id} • ${request.type}',
                              style: const TextStyle(
                                  color: Color(0xFF657087), fontSize: 10))
                        ])),
                    _RequestStatus(status: request.status),
                  ]),
                  const SizedBox(height: 13),
                  Container(
                    padding: const EdgeInsets.all(11),
                    decoration: BoxDecoration(
                        color: const Color(0xFFF5F8FE),
                        borderRadius: BorderRadius.circular(10)),
                    child: Column(children: [
                      Row(children: [
                        const Icon(Icons.calendar_today_outlined,
                            size: 15, color: _ApprovalsColors.blue),
                        const SizedBox(width: 8),
                        Expanded(
                            child: Text(request.dates,
                                style: const TextStyle(
                                    color: _ApprovalsColors.navy,
                                    fontSize: 11))),
                        Text(request.duration,
                            style: const TextStyle(
                                color: _ApprovalsColors.navy,
                                fontWeight: FontWeight.w700,
                                fontSize: 11))
                      ]),
                      const SizedBox(height: 8),
                      Row(children: [
                        const Icon(Icons.notes_rounded,
                            size: 15, color: Color(0xFF657087)),
                        const SizedBox(width: 8),
                        Expanded(
                            child: Text(request.reason,
                                style: const TextStyle(
                                    color: Color(0xFF657087), fontSize: 11)))
                      ]),
                    ]),
                  ),
                  if (request.status == 'Pending') ...[
                    const SizedBox(height: 12),
                    Row(children: [
                      Expanded(
                          child: FilledButton(
                              onPressed: () => onApprove(request),
                              style: FilledButton.styleFrom(
                                  backgroundColor: _ApprovalsColors.blue),
                              child: const Text('Approve'))),
                      const SizedBox(width: 10),
                      Expanded(
                          child: OutlinedButton(
                              onPressed: () => onReject(request),
                              style: OutlinedButton.styleFrom(
                                  foregroundColor: const Color(0xFFF0182A),
                                  side: const BorderSide(
                                      color: Color(0xFFF0182A))),
                              child: const Text('Reject'))),
                    ]),
                  ],
                ],
              ),
            ),
          )
          .toList(),
    );
  }
}

class _ApprovalTabs extends StatelessWidget {
  const _ApprovalTabs({
    required this.leaveRequests,
    required this.leaveCount,
    required this.extraCount,
    required this.onChanged,
  });
  final bool leaveRequests;
  final int leaveCount, extraCount;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) =>
      LayoutBuilder(builder: (_, constraints) {
        return SizedBox(
          width: constraints.maxWidth < 600 ? constraints.maxWidth : 426,
          child: Row(children: [
            Expanded(
                child: _TabButton(
                    label: 'Leave Requests',
                    count: leaveCount,
                    active: leaveRequests,
                    onTap: () => onChanged(true))),
            const SizedBox(width: 6),
            Expanded(
                child: _TabButton(
                    label: 'Extra Hours',
                    count: extraCount,
                    active: !leaveRequests,
                    onTap: () => onChanged(false))),
          ]),
        );
      });
}

class _TabButton extends StatelessWidget {
  const _TabButton(
      {required this.label,
      required this.count,
      required this.active,
      required this.onTap});
  final String label;
  final int count;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Container(
          width: double.infinity,
          height: 38,
          decoration: BoxDecoration(
              color: active ? _ApprovalsColors.blue : Colors.white,
              border: Border.all(
                  color:
                      active ? _ApprovalsColors.blue : const Color(0xFFDCE1EB)),
              borderRadius: BorderRadius.circular(24)),
          alignment: Alignment.center,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(label,
                  style: TextStyle(
                      color: active ? Colors.white : const Color(0xFF596176),
                      fontWeight: FontWeight.w600)),
              const SizedBox(width: 12),
              Container(
                width: 21,
                height: 21,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                    color: active ? Colors.white : const Color(0xFFE7E9ED),
                    shape: BoxShape.circle),
                child: Text('$count',
                    style: TextStyle(
                        color: active
                            ? _ApprovalsColors.blue
                            : const Color(0xFF596176),
                        fontSize: 12)),
              ),
            ],
          ),
        ),
      );
}

class _ApprovalFilters extends StatelessWidget {
  const _ApprovalFilters(
      {required this.employee,
      required this.status,
      required this.dateRange,
      required this.onEmployeeChanged,
      required this.onStatusChanged,
      required this.onDateChanged,
      required this.onReset});
  final String employee, status, dateRange;
  final ValueChanged<String?> onEmployeeChanged, onStatusChanged, onDateChanged;
  final VoidCallback onReset;

  @override
  Widget build(BuildContext context) =>
      LayoutBuilder(builder: (_, constraints) {
        final width = constraints.maxWidth < 900 ? constraints.maxWidth : 350.0;
        return Wrap(
          spacing: 44,
          runSpacing: 14,
          crossAxisAlignment: WrapCrossAlignment.end,
          children: [
            _FilterField(
                label: 'Employee',
                width: width,
                child: DropdownButtonFormField<String>(
                    initialValue: employee,
                    onChanged: onEmployeeChanged,
                    decoration: _fieldDecoration(),
                    items: const [
                      'All Employees',
                      'Arul Kumar',
                      'Priya Sharma',
                      'Vikram Singh',
                      'Neha Verma',
                      'Rohan Mehta'
                    ]
                        .map((item) =>
                            DropdownMenuItem(value: item, child: Text(item)))
                        .toList())),
            _FilterField(
                label: 'Date',
                width: width,
                child: DropdownButtonFormField<String>(
                    initialValue: dateRange,
                    onChanged: onDateChanged,
                    decoration:
                        _fieldDecoration(prefix: Icons.calendar_today_outlined),
                    items: const [
                      DropdownMenuItem(
                          value: 'All Dates', child: Text('All Dates')),
                      DropdownMenuItem(
                          value: '17 Aug 2026 – 23 Aug 2026',
                          child: Text('17 Aug 2026 – 23 Aug 2026'))
                    ])),
            _FilterField(
                label: 'Status',
                width: width,
                child: DropdownButtonFormField<String>(
                    initialValue: status,
                    onChanged: onStatusChanged,
                    decoration: _fieldDecoration(),
                    items: const [
                      'All Status',
                      'Pending',
                      'Approved',
                      'Rejected'
                    ]
                        .map((item) =>
                            DropdownMenuItem(value: item, child: Text(item)))
                        .toList())),
            OutlinedButton.icon(
              onPressed: onReset,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Reset Filters'),
              style: OutlinedButton.styleFrom(
                  foregroundColor: _ApprovalsColors.blue,
                  side: const BorderSide(color: Color(0xFFD6DDEA)),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 17, vertical: 17),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8))),
            ),
          ],
        );
      });
}

class _FilterField extends StatelessWidget {
  const _FilterField(
      {required this.label, required this.width, required this.child});
  final String label;
  final double width;
  final Widget child;
  @override
  Widget build(BuildContext context) => SizedBox(
        width: width,
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(label,
              style: const TextStyle(color: Color(0xFF596176), fontSize: 13)),
          const SizedBox(height: 8),
          child
        ]),
      );
}

InputDecoration _fieldDecoration({IconData? prefix}) => InputDecoration(
      prefixIcon: prefix == null
          ? null
          : Icon(prefix, color: const Color(0xFF596176), size: 19),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
      enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(7),
          borderSide: const BorderSide(color: Color(0xFFD8DEE9))),
      focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(7),
          borderSide: const BorderSide(color: _ApprovalsColors.blue)),
    );

class _ApprovalTable extends StatelessWidget {
  const _ApprovalTable(
      {required this.requests,
      required this.onApprove,
      required this.onReject});
  final List<_ApprovalRequest> requests;
  final ValueChanged<_ApprovalRequest> onApprove, onReject;

  @override
  Widget build(BuildContext context) => Container(
        decoration: BoxDecoration(
            border: Border.all(color: const Color(0xFFE3E7EF)),
            borderRadius: BorderRadius.circular(10)),
        clipBehavior: Clip.antiAlias,
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: SizedBox(
            width: 1400,
            child: Column(
              children: [
                const _ApprovalTableHeader(),
                if (requests.isEmpty)
                  const SizedBox(
                      height: 180,
                      child: Center(
                          child: Text(
                              'No approval requests match these filters.')))
                else
                  ...requests.map((request) => _ApprovalRow(
                      request: request,
                      onApprove: onApprove,
                      onReject: onReject)),
              ],
            ),
          ),
        ),
      );
}

class _ApprovalTableHeader extends StatelessWidget {
  const _ApprovalTableHeader();
  @override
  Widget build(BuildContext context) => Container(
        height: 44,
        color: const Color(0xFFFCFCFD),
        child: const Row(children: [
          _ApprovalCell(width: 270, child: Text('Employee', style: _headStyle)),
          _ApprovalCell(
              width: 200, child: Text('Leave Type', style: _headStyle)),
          _ApprovalCell(width: 270, child: Text('Dates', style: _headStyle)),
          _ApprovalCell(width: 115, child: Text('Duration', style: _headStyle)),
          _ApprovalCell(width: 200, child: Text('Reason', style: _headStyle)),
          _ApprovalCell(width: 140, child: Text('Status', style: _headStyle)),
          _ApprovalCell(width: 205, child: Text('Action', style: _headStyle)),
        ]),
      );
}

class _ApprovalRow extends StatelessWidget {
  const _ApprovalRow(
      {required this.request, required this.onApprove, required this.onReject});
  final _ApprovalRequest request;
  final ValueChanged<_ApprovalRequest> onApprove, onReject;

  @override
  Widget build(BuildContext context) => Container(
        height: 64,
        decoration: const BoxDecoration(
            border: Border(top: BorderSide(color: Color(0xFFE6E9EF)))),
        child: Row(
          children: [
            _ApprovalCell(
              width: 270,
              child: Row(children: [
                CircleAvatar(
                    radius: 21,
                    backgroundColor: const Color(0xFFE8EEF8),
                    child: Text(request.name.substring(0, 1),
                        style: const TextStyle(
                            color: _ApprovalsColors.navy,
                            fontWeight: FontWeight.w700))),
                const SizedBox(width: 14),
                Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(request.name,
                          style: const TextStyle(
                              color: Color(0xFF11131A),
                              fontWeight: FontWeight.w600)),
                      Text(request.id,
                          style: const TextStyle(
                              color: Color(0xFF596176), fontSize: 12))
                    ]),
              ]),
            ),
            _ApprovalCell(
              width: 200,
              child: Row(children: [
                Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                        color: Color(request.color).withValues(alpha: .10),
                        shape: BoxShape.circle),
                    child: Icon(request.icon,
                        color: Color(request.color), size: 19)),
                const SizedBox(width: 11),
                Text(request.type,
                    style: const TextStyle(
                        color: Color(0xFF272B35), fontSize: 13)),
              ]),
            ),
            _ApprovalCell(
                width: 270,
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(request.dates,
                          style: const TextStyle(
                              color: Color(0xFF272B35), fontSize: 13)),
                      Text(request.dayRange,
                          style: const TextStyle(
                              color: Color(0xFF596176), fontSize: 12))
                    ])),
            _ApprovalCell(
                width: 115, child: Text(request.duration, style: _cellStyle)),
            _ApprovalCell(
                width: 200, child: Text(request.reason, style: _cellStyle)),
            _ApprovalCell(
                width: 140, child: _RequestStatus(status: request.status)),
            _ApprovalCell(
              width: 205,
              child: request.status == 'Pending'
                  ? Row(children: [
                      FilledButton(
                          onPressed: () => onApprove(request),
                          style: FilledButton.styleFrom(
                              backgroundColor: _ApprovalsColors.blue,
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 20),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(6))),
                          child: const Text('Approve')),
                      const SizedBox(width: 12),
                      OutlinedButton(
                          onPressed: () => onReject(request),
                          style: OutlinedButton.styleFrom(
                              foregroundColor: const Color(0xFFF0182A),
                              side: const BorderSide(color: Color(0xFFF0182A)),
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 18),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(6))),
                          child: const Text('Reject')),
                    ])
                  : const Center(
                      child: Text('–',
                          style: TextStyle(color: Color(0xFF596176)))),
            ),
          ],
        ),
      );
}

class _ApprovalCell extends StatelessWidget {
  const _ApprovalCell({required this.width, required this.child});
  final double width;
  final Widget child;
  @override
  Widget build(BuildContext context) => SizedBox(
      width: width,
      child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18), child: child));
}

class _RequestStatus extends StatelessWidget {
  const _RequestStatus({required this.status});
  final String status;
  @override
  Widget build(BuildContext context) {
    final color = status == 'Approved'
        ? const Color(0xFF188226)
        : status == 'Rejected'
            ? const Color(0xFFF0182A)
            : const Color(0xFFFF6500);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
          color: color.withValues(alpha: .10),
          borderRadius: BorderRadius.circular(5)),
      child: Text(status, style: TextStyle(color: color, fontSize: 12)),
    );
  }
}

class _PaginationButton extends StatelessWidget {
  const _PaginationButton({this.text, this.icon, this.active = false});
  final String? text;
  final IconData? icon;
  final bool active;
  @override
  Widget build(BuildContext context) => Container(
        width: 34,
        height: 34,
        margin: const EdgeInsets.only(left: 10),
        decoration: BoxDecoration(
            color: active ? _ApprovalsColors.blue : Colors.white,
            border: Border.all(
                color:
                    active ? _ApprovalsColors.blue : const Color(0xFFDCE1EB)),
            borderRadius: BorderRadius.circular(6)),
        alignment: Alignment.center,
        child: icon != null
            ? Icon(icon, color: const Color(0xFF596176), size: 19)
            : Text(text!,
                style: TextStyle(
                    color: active ? Colors.white : _ApprovalsColors.navy)),
      );
}

class _ApprovalRequest {
  _ApprovalRequest(this.name, this.id, this.type, this.dates, this.dayRange,
      this.duration, this.reason, this.status, this.icon, this.color);
  final String name, id, type, dates, dayRange, duration, reason;
  String status;
  final IconData icon;
  final int color;

  String get storageId => '$id|$type|$dates';
}

const _headStyle = TextStyle(
    color: Color(0xFF11131A), fontSize: 13, fontWeight: FontWeight.w600);
const _cellStyle = TextStyle(color: Color(0xFF272B35), fontSize: 13);
