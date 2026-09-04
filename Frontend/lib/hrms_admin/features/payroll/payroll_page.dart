import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../shared/widgets/admin_top_nav.dart';
import '../dashboard/widgets/manage_calendar_dialog.dart' as calendar;
import 'payroll_download.dart';

abstract final class HrmsColors {
  static const blue = Color(0xFF075EF7);
  static const navy = Color(0xFF061457);
  static const page = Color(0xFFFCFDFF);
}

class PayrollPage extends StatefulWidget {
  const PayrollPage({super.key});

  static Widget builder(BuildContext context) => const PayrollPage();

  @override
  State<PayrollPage> createState() => _PayrollPageState();
}

class _PayrollPageState extends State<PayrollPage> {
  static const _storageKey = 'admin_payroll_statuses_v1';
  static const pageSize = 5;
  String month = 'August 2026';
  int currentPage = 1;
  late List<_PayrollRecord> payroll;

  @override
  void initState() {
    super.initState();
    payroll = _seedPayroll();
    _loadMonthStatuses();
  }

  int get totalPages => (payroll.length / pageSize).ceil();

  List<_PayrollRecord> get pagedPayroll {
    final safePage = currentPage.clamp(1, totalPages).toInt();
    final start = (safePage - 1) * pageSize;
    final end = (start + pageSize).clamp(0, payroll.length).toInt();
    return payroll.sublist(start, end);
  }

  Future<void> _loadMonthStatuses() async {
    final preferences = await SharedPreferences.getInstance();
    final encoded = preferences.getString(_storageKey);
    if (encoded == null) return;
    try {
      final allMonths = Map<String, dynamic>.from(jsonDecode(encoded) as Map);
      final saved = allMonths[month];
      if (saved is Map) {
        final statuses = Map<String, dynamic>.from(saved);
        for (final record in payroll) {
          final stored = statuses[record.id];
          if (stored is String) record.status = stored;
        }
        if (mounted) setState(() {});
      }
    } catch (_) {
      // Keep starter payroll data when stored data cannot be read.
    }
  }

  Future<void> _saveMonthStatuses() async {
    final preferences = await SharedPreferences.getInstance();
    final encoded = preferences.getString(_storageKey);
    final allMonths = encoded == null
        ? <String, dynamic>{}
        : Map<String, dynamic>.from(jsonDecode(encoded) as Map);
    allMonths[month] = {for (final record in payroll) record.id: record.status};
    await preferences.setString(_storageKey, jsonEncode(allMonths));
  }

  Future<void> _changeMonth(String? value) async {
    if (value == null || value == month) return;
    setState(() {
      month = value;
      currentPage = 1;
      payroll = _seedPayroll();
    });
    await _loadMonthStatuses();
  }

  Future<void> _processPayroll() async {
    final pendingRecords =
        payroll.where((record) => record.status == 'Pending').toList();
    if (pendingRecords.isEmpty) {
      _notify('$month payroll is already processed');
      return;
    }
    setState(() {
      for (final record in payroll) {
        record.status = 'Processed';
      }
    });
    await _saveMonthStatuses();
    for (final record in pendingRecords) {
      await calendar.CalendarStore.addNotification({
        'type': 'payroll',
        'employeeId': record.id,
        'employeeName': record.name,
        'title': '$month payroll processed',
        'message': 'Your ${record.net} net payslip is ready to download.',
        'createdAt': DateTime.now().toIso8601String(),
        'read': false,
      });
    }
    if (!mounted) return;
    _notify('${pendingRecords.length} pending payroll records processed');
  }

  void _notify(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _exportPayroll() async {
    String csv(String value) => '"${value.replaceAll('"', '""')}"';
    final content = <String>[
      'Month,Employee,Employee ID,Gross Salary,Deductions,Net Pay,Status',
      ...payroll.map((record) => [
            month,
            record.name,
            record.id,
            record.gross,
            record.deductions,
            record.net,
            record.status,
          ].map(csv).join(',')),
    ].join('\n');
    await downloadTextFile(
      'payroll_${month.toLowerCase().replaceAll(' ', '_')}.csv',
      content,
      'text/csv;charset=utf-8',
    );
    if (mounted) _notify('$month payroll CSV downloaded');
  }

  Future<void> _downloadPayslip(_PayrollRecord record) async {
    final content = '''GO DIGITAL — PAYSLIP
Month: $month
Employee: ${record.name}
Employee ID: ${record.id}

Gross Salary: ${record.gross}
Deductions: ${record.deductions}
Net Pay: ${record.net}
Status: ${record.status}
''';
    await downloadTextFile(
      'payslip_${record.id}_${month.toLowerCase().replaceAll(' ', '_')}.txt',
      content,
      'text/plain;charset=utf-8',
    );
    if (mounted) _notify('${record.name} payslip downloaded');
  }

  @override
  Widget build(BuildContext context) {
    final mobile = MediaQuery.sizeOf(context).width < 600;
    return Scaffold(
      backgroundColor: HrmsColors.page,
      body: Column(
        children: [
          const AdminTopNav(activeRoute: '/admin/payroll'),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(
                  mobile ? 16 : 26, 18, mobile ? 16 : 26, 28),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1580),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const _PayrollHeader(),
                      const SizedBox(height: 14),
                      _PayrollActions(
                        month: month,
                        onMonthChanged: _changeMonth,
                        onProcess: _processPayroll,
                        onExport: _exportPayroll,
                      ),
                      const SizedBox(height: 23),
                      _PayrollKpis(payroll: payroll),
                      const SizedBox(height: 24),
                      _PayrollTable(
                        payroll: pagedPayroll,
                        total: payroll.length,
                        currentPage: currentPage,
                        totalPages: totalPages,
                        mobile: mobile,
                        onPageChanged: (page) => setState(() =>
                            currentPage = page.clamp(1, totalPages).toInt()),
                        onDownload: _downloadPayslip,
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

class _PayrollHeader extends StatelessWidget {
  const _PayrollHeader();

  @override
  Widget build(BuildContext context) => const AdminPageHeader(title: 'Payroll');
}

class _PayrollActions extends StatelessWidget {
  const _PayrollActions(
      {required this.month,
      required this.onMonthChanged,
      required this.onProcess,
      required this.onExport});
  final String month;
  final ValueChanged<String?> onMonthChanged;
  final VoidCallback onProcess, onExport;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 18),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: const Color(0xFFE3E7EF)),
          borderRadius: BorderRadius.circular(13),
          boxShadow: const [
            BoxShadow(
                color: Color(0x08071A72), blurRadius: 12, offset: Offset(0, 5))
          ],
        ),
        child: LayoutBuilder(builder: (_, constraints) {
          final narrow = constraints.maxWidth < 650;
          final monthPicker = SizedBox(
            width: 220,
            child: DropdownButtonFormField<String>(
              initialValue: month,
              onChanged: onMonthChanged,
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.calendar_today_outlined,
                    color: Color(0xFF31394A), size: 20),
                filled: true,
                fillColor: Colors.white,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
                enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Color(0xFFD9DEE8))),
                focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: HrmsColors.blue)),
              ),
              items: const [
                'June 2026',
                'July 2026',
                'August 2026',
                'September 2026'
              ]
                  .map((item) =>
                      DropdownMenuItem(value: item, child: Text(item)))
                  .toList(),
            ),
          );
          final buttons = Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              FilledButton(
                onPressed: onProcess,
                style: FilledButton.styleFrom(
                    backgroundColor: HrmsColors.blue,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 18),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(9))),
                child: const Text('Process Payroll'),
              ),
              const SizedBox(width: 18),
              OutlinedButton.icon(
                onPressed: onExport,
                icon: const Icon(Icons.ios_share_outlined),
                label: const Text('Export'),
                style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF31394A),
                    side: const BorderSide(color: Color(0xFFD9DEE8)),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 22, vertical: 18),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(9))),
              ),
            ],
          );
          return narrow
              ? Wrap(
                  spacing: 18, runSpacing: 14, children: [monthPicker, buttons])
              : Row(children: [monthPicker, const Spacer(), buttons]);
        }),
      );
}

class _PayrollKpis extends StatelessWidget {
  const _PayrollKpis({required this.payroll});

  final List<_PayrollRecord> payroll;

  @override
  Widget build(BuildContext context) {
    final gross =
        payroll.fold<int>(0, (sum, record) => sum + record.grossValue);
    final deductions =
        payroll.fold<int>(0, (sum, record) => sum + record.deductionValue);
    final net = gross - deductions;
    final cards = [
      _PayrollKpi('Employees', '${payroll.length}', 'Total Employees',
          Icons.groups_outlined, HrmsColors.blue),
      _PayrollKpi('Gross Payroll', _formatMoney(gross), 'Total Gross Payroll',
          Icons.currency_rupee_rounded, Color(0xFF168921)),
      _PayrollKpi('Deductions', _formatMoney(deductions), 'Total Deductions',
          Icons.remove_circle_outline_rounded, Color(0xFFF0182A)),
      _PayrollKpi('Net Payroll', _formatMoney(net), 'Total Net Payroll',
          Icons.account_balance_wallet_outlined, Color(0xFFFF6500)),
    ];
    return LayoutBuilder(builder: (_, constraints) {
      final columns = constraints.maxWidth < 650
          ? 2
          : constraints.maxWidth < 1100
              ? 2
              : 4;
      final spacing = constraints.maxWidth < 650 ? 12.0 : 20.0;
      final width = (constraints.maxWidth - (columns - 1) * spacing) / columns;
      return Wrap(
          spacing: spacing,
          runSpacing: constraints.maxWidth < 650 ? 12 : 16,
          children: cards
              .map((card) => SizedBox(width: width, child: card))
              .toList());
    });
  }
}

class _PayrollKpi extends StatelessWidget {
  const _PayrollKpi(
      this.label, this.value, this.caption, this.icon, this.color);
  final String label, value, caption;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) =>
      LayoutBuilder(builder: (_, constraints) {
        final compact = constraints.maxWidth < 220;
        return Container(
          height: 116,
          padding:
              EdgeInsets.fromLTRB(compact ? 12 : 16, 14, compact ? 12 : 16, 9),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: const Color(0xFFE3E7EF)),
            borderRadius: BorderRadius.circular(18),
            boxShadow: const [
              BoxShadow(
                  color: Color(0x08071A72),
                  blurRadius: 13,
                  offset: Offset(0, 5))
            ],
          ),
          child: compact
              ? Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(children: [
                    Container(
                        width: 39,
                        height: 39,
                        decoration: BoxDecoration(
                            color: color.withValues(alpha: .10),
                            borderRadius: BorderRadius.circular(11)),
                        child: Icon(icon, color: color, size: 23)),
                    const Spacer(),
                  ]),
                  const Spacer(),
                  Text(label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          color: Color(0xFF303747),
                          fontSize: 11,
                          fontWeight: FontWeight.w700)),
                  const SizedBox(height: 4),
                  FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Text(value,
                          style: TextStyle(
                              color: color,
                              fontSize: 17,
                              fontWeight: FontWeight.w800))),
                ])
              : Column(
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
                                      color: Color(0xFF303747), fontSize: 13)),
                              const SizedBox(height: 2),
                              FittedBox(
                                  fit: BoxFit.scaleDown,
                                  alignment: Alignment.centerLeft,
                                  child: Text(value,
                                      style: const TextStyle(
                                          color: Color(0xFF10131B),
                                          fontSize: 24,
                                          fontWeight: FontWeight.w700))),
                              const SizedBox(height: 2),
                              Text(caption,
                                  style: const TextStyle(
                                      color: Color(0xFF596176), fontSize: 11)),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    Stack(
                      children: [
                        Container(
                            height: 3,
                            decoration: BoxDecoration(
                                color: const Color(0xFFE5E8EF),
                                borderRadius: BorderRadius.circular(3))),
                        Container(
                            width: 55,
                            height: 3,
                            decoration: BoxDecoration(
                                color: HrmsColors.blue,
                                borderRadius: BorderRadius.circular(3))),
                      ],
                    ),
                  ],
                ),
        );
      });
}

class _PayrollTable extends StatelessWidget {
  const _PayrollTable({
    required this.payroll,
    required this.total,
    required this.currentPage,
    required this.totalPages,
    required this.mobile,
    required this.onPageChanged,
    required this.onDownload,
  });
  final List<_PayrollRecord> payroll;
  final int total, currentPage, totalPages;
  final bool mobile;
  final ValueChanged<int> onPageChanged;
  final ValueChanged<_PayrollRecord> onDownload;

  @override
  Widget build(BuildContext context) => mobile
      ? _MobilePayrollList(
          payroll: payroll,
          total: total,
          currentPage: currentPage,
          totalPages: totalPages,
          onPageChanged: onPageChanged,
          onDownload: onDownload,
        )
      : Container(
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: const Color(0xFFE3E7EF)),
            borderRadius: BorderRadius.circular(14),
            boxShadow: const [
              BoxShadow(
                  color: Color(0x08071A72),
                  blurRadius: 15,
                  offset: Offset(0, 6))
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            children: [
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: SizedBox(
                  width: 1440,
                  child: Column(
                    children: [
                      const _PayrollTableHeader(),
                      ...payroll.map((record) =>
                          _PayrollRow(record: record, onDownload: onDownload)),
                    ],
                  ),
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 23, vertical: 14),
                child: Row(
                  children: [
                    Text(_showingText(),
                        style: const TextStyle(
                            color: Color(0xFF596176), fontSize: 13)),
                    const Spacer(),
                    _PageButton(
                        icon: Icons.chevron_left_rounded,
                        enabled: currentPage > 1,
                        onTap: () => onPageChanged(currentPage - 1)),
                    ..._visiblePages().map((page) => page == 0
                        ? const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 12),
                            child: Text('...'))
                        : _PageButton(
                            text: '$page',
                            active: page == currentPage,
                            onTap: () => onPageChanged(page))),
                    _PageButton(
                        icon: Icons.chevron_right_rounded,
                        enabled: currentPage < totalPages,
                        onTap: () => onPageChanged(currentPage + 1)),
                  ],
                ),
              ),
            ],
          ),
        );

  String _showingText() {
    final first = (currentPage - 1) * _PayrollPageState.pageSize + 1;
    final last = (first + payroll.length - 1).clamp(0, total).toInt();
    return 'Showing $first to $last of $total employees';
  }

  List<int> _visiblePages() {
    if (totalPages <= 5) return List.generate(totalPages, (index) => index + 1);
    if (currentPage <= 3) return [1, 2, 3, 0, totalPages];
    if (currentPage >= totalPages - 2) {
      return [1, 0, totalPages - 2, totalPages - 1, totalPages];
    }
    return [1, 0, currentPage, 0, totalPages];
  }
}

class _MobilePayrollList extends StatelessWidget {
  const _MobilePayrollList({
    required this.payroll,
    required this.total,
    required this.currentPage,
    required this.totalPages,
    required this.onPageChanged,
    required this.onDownload,
  });
  final List<_PayrollRecord> payroll;
  final int total, currentPage, totalPages;
  final ValueChanged<int> onPageChanged;
  final ValueChanged<_PayrollRecord> onDownload;

  @override
  Widget build(BuildContext context) => Column(
        children: [
          ...payroll.map(
            (record) => Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: const Color(0xFFE5EAF3)),
                borderRadius: BorderRadius.circular(15),
                boxShadow: const [
                  BoxShadow(
                      color: Color(0x08071A72),
                      blurRadius: 12,
                      offset: Offset(0, 5))
                ],
              ),
              child: Column(
                children: [
                  Row(children: [
                    CircleAvatar(
                        radius: 22,
                        backgroundColor: const Color(0xFFEAF1FF),
                        child: Text(record.name.substring(0, 1),
                            style: const TextStyle(
                                color: HrmsColors.blue,
                                fontWeight: FontWeight.w800))),
                    const SizedBox(width: 11),
                    Expanded(
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                          Text(record.name,
                              style: const TextStyle(
                                  color: HrmsColors.navy,
                                  fontWeight: FontWeight.w700)),
                          Text(record.id,
                              style: const TextStyle(
                                  color: Color(0xFF657087), fontSize: 10))
                        ])),
                    _PayrollStatus(status: record.status),
                  ]),
                  const SizedBox(height: 14),
                  Row(children: [
                    Expanded(
                        child: _MobilePayMetric(
                            label: 'Gross',
                            value: record.gross,
                            color: HrmsColors.navy)),
                    const SizedBox(width: 8),
                    Expanded(
                        child: _MobilePayMetric(
                            label: 'Deductions',
                            value: record.deductions,
                            color: const Color(0xFFF0182A))),
                    const SizedBox(width: 8),
                    Expanded(
                        child: _MobilePayMetric(
                            label: 'Net pay',
                            value: record.net,
                            color: const Color(0xFF138A20))),
                  ]),
                  const SizedBox(height: 9),
                  SizedBox(
                    width: double.infinity,
                    child: TextButton.icon(
                        onPressed: () => onDownload(record),
                        icon: const Icon(Icons.download_outlined, size: 19),
                        label: const Text('Download Payslip')),
                  ),
                ],
              ),
            ),
          ),
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            IconButton(
                onPressed: currentPage > 1
                    ? () => onPageChanged(currentPage - 1)
                    : null,
                icon: const Icon(Icons.chevron_left_rounded)),
            Text('Page $currentPage of $totalPages · $total employees',
                style: const TextStyle(color: Color(0xFF657087), fontSize: 12)),
            IconButton(
                onPressed: currentPage < totalPages
                    ? () => onPageChanged(currentPage + 1)
                    : null,
                icon: const Icon(Icons.chevron_right_rounded)),
          ]),
        ],
      );
}

class _MobilePayMetric extends StatelessWidget {
  const _MobilePayMetric(
      {required this.label, required this.value, required this.color});
  final String label, value;
  final Color color;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 9),
        decoration: BoxDecoration(
            color: color.withValues(alpha: .07),
            borderRadius: BorderRadius.circular(9)),
        child: Column(children: [
          Text(label,
              style: const TextStyle(color: Color(0xFF657087), fontSize: 8)),
          const SizedBox(height: 4),
          FittedBox(
              child: Text(value,
                  style: TextStyle(
                      color: color,
                      fontWeight: FontWeight.w800,
                      fontSize: 11))),
        ]),
      );
}

class _PayrollTableHeader extends StatelessWidget {
  const _PayrollTableHeader();
  @override
  Widget build(BuildContext context) => const SizedBox(
        height: 53,
        child: Row(children: [
          _PayrollCell(width: 360, child: Text('Employee', style: _headStyle)),
          _PayrollCell(
              width: 220, child: Text('Gross Salary', style: _headStyle)),
          _PayrollCell(
              width: 210, child: Text('Deductions', style: _headStyle)),
          _PayrollCell(width: 200, child: Text('Net Pay', style: _headStyle)),
          _PayrollCell(width: 210, child: Text('Status', style: _headStyle)),
          _PayrollCell(width: 240, child: Text('Payslip', style: _headStyle)),
        ]),
      );
}

class _PayrollRow extends StatelessWidget {
  const _PayrollRow({required this.record, required this.onDownload});
  final _PayrollRecord record;
  final ValueChanged<_PayrollRecord> onDownload;

  @override
  Widget build(BuildContext context) => Container(
        height: 74,
        decoration: const BoxDecoration(
            border: Border(top: BorderSide(color: Color(0xFFE5E8EF)))),
        child: Row(
          children: [
            _PayrollCell(
              width: 360,
              child: Row(children: [
                CircleAvatar(
                    radius: 23,
                    backgroundColor: const Color(0xFFE8EEF8),
                    child: Text(record.name.substring(0, 1),
                        style: const TextStyle(
                            color: HrmsColors.navy,
                            fontWeight: FontWeight.w700))),
                const SizedBox(width: 15),
                Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(record.name,
                          style: const TextStyle(
                              color: Color(0xFF171B25), fontSize: 16)),
                      Text(record.id,
                          style: const TextStyle(
                              color: Color(0xFF596176), fontSize: 13))
                    ]),
              ]),
            ),
            _PayrollCell(
                width: 220, child: Text(record.gross, style: _cellStyle)),
            _PayrollCell(
                width: 210, child: Text(record.deductions, style: _cellStyle)),
            _PayrollCell(
                width: 200, child: Text(record.net, style: _cellStyle)),
            _PayrollCell(
                width: 210, child: _PayrollStatus(status: record.status)),
            _PayrollCell(
              width: 240,
              child: TextButton.icon(
                onPressed: () => onDownload(record),
                icon: const Icon(Icons.download_outlined, size: 21),
                label: const Text('Download Payslip'),
                style: TextButton.styleFrom(foregroundColor: HrmsColors.blue),
              ),
            ),
          ],
        ),
      );
}

class _PayrollCell extends StatelessWidget {
  const _PayrollCell({required this.width, required this.child});
  final double width;
  final Widget child;
  @override
  Widget build(BuildContext context) => SizedBox(
      width: width,
      child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 22), child: child));
}

class _PayrollStatus extends StatelessWidget {
  const _PayrollStatus({required this.status});
  final String status;
  @override
  Widget build(BuildContext context) {
    final processed = status == 'Processed';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 7),
      decoration: BoxDecoration(
          color: processed ? const Color(0xFFEAF6E6) : const Color(0xFFFFF0E4),
          borderRadius: BorderRadius.circular(6)),
      child: Text(status,
          style: TextStyle(
              color:
                  processed ? const Color(0xFF177020) : const Color(0xFFFF6500),
              fontSize: 13)),
    );
  }
}

class _PageButton extends StatelessWidget {
  const _PageButton({
    this.text,
    this.icon,
    this.active = false,
    this.enabled = true,
    this.onTap,
  });
  final String? text;
  final IconData? icon;
  final bool active, enabled;
  final VoidCallback? onTap;
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(left: 7),
        child: InkWell(
          onTap: enabled ? onTap : null,
          borderRadius: BorderRadius.circular(8),
          child: Container(
            width: 39,
            height: 38,
            decoration: BoxDecoration(
                color: active ? HrmsColors.blue : Colors.white,
                border: Border.all(color: const Color(0xFFE1E6F0)),
                borderRadius: BorderRadius.circular(8)),
            alignment: Alignment.center,
            child: icon != null
                ? Icon(icon,
                    size: 19,
                    color: enabled
                        ? const Color(0xFF596176)
                        : const Color(0xFFB5BBC8))
                : Text(text!,
                    style: TextStyle(
                        color:
                            active ? Colors.white : const Color(0xFF202633))),
          ),
        ),
      );
}

class _PayrollRecord {
  _PayrollRecord(
      this.name, this.id, this.grossValue, this.deductionValue, this.status);
  final String name, id;
  final int grossValue, deductionValue;
  String status;

  String get gross => _formatMoney(grossValue);
  String get deductions => _formatMoney(deductionValue);
  String get net => _formatMoney(grossValue - deductionValue);
}

String _formatMoney(int value) {
  final digits = value.toString();
  if (digits.length <= 3) return '₹$digits';
  final lastThree = digits.substring(digits.length - 3);
  var leading = digits.substring(0, digits.length - 3);
  final groups = <String>[];
  while (leading.length > 2) {
    groups.insert(0, leading.substring(leading.length - 2));
    leading = leading.substring(0, leading.length - 2);
  }
  if (leading.isNotEmpty) groups.insert(0, leading);
  return '₹${groups.join(',')},$lastThree';
}

List<_PayrollRecord> _seedPayroll() {
  final records = <_PayrollRecord>[
    _PayrollRecord('Arul Kumar', 'EMP1001', 50000, 5000, 'Processed'),
    _PayrollRecord('Priya Sharma', 'EMP1002', 45000, 4500, 'Processed'),
    _PayrollRecord('Vikram Singh', 'EMP1003', 55000, 5500, 'Processed'),
    _PayrollRecord('Neha Verma', 'EMP1004', 40000, 4000, 'Pending'),
    _PayrollRecord('Rohan Mehta', 'EMP1005', 60000, 6000, 'Pending'),
  ];
  const firstNames = [
    'Kavya',
    'Ajay',
    'Pooja',
    'Rahul',
    'Divya',
    'Sanjay',
    'Meera',
    'Karthik',
    'Ananya',
    'Naveen',
    'Sneha',
    'Vijay'
  ];
  const lastNames = [
    'Nair',
    'Iyer',
    'Das',
    'Rao',
    'Patel',
    'Kapoor',
    'Menon',
    'Gupta'
  ];
  for (var number = 6; number <= 48; number++) {
    final gross = 32000 + ((number * 2500) % 33000);
    final deduction = (gross * .10).round();
    records.add(_PayrollRecord(
      '${firstNames[(number - 6) % firstNames.length]} ${lastNames[(number - 6) % lastNames.length]}',
      'EMP${1000 + number}',
      gross,
      deduction,
      'Pending',
    ));
  }
  return records;
}

const _headStyle = TextStyle(
    color: Color(0xFF171B25), fontSize: 14, fontWeight: FontWeight.w600);
const _cellStyle = TextStyle(color: Color(0xFF222936), fontSize: 15);
