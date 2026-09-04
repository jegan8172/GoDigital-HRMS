import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../shared/widgets/admin_top_nav.dart';

abstract final class HrmsColors {
  static const blue = Color(0xFF075EF7);
  static const navy = Color(0xFF061457);
  static const page = Color(0xFFFCFDFF);
}

class TrackingPage extends StatefulWidget {
  const TrackingPage({super.key});

  static Widget builder(BuildContext context) => const TrackingPage();

  @override
  State<TrackingPage> createState() => _TrackingPageState();
}

class _TrackingPageState extends State<TrackingPage> {
  String mode = 'Field';

  static const _modeStorageKey = 'admin_tracking_last_mode';

  static const employees = <_TrackedEmployee>[
    _TrackedEmployee(
        'Arul Kumar', 'EMP1001', 'Connaught Place', 'Field', 28.6315, 77.2167, [
      _RoutePoint('09:02 AM', 'Go Digital Office, Connaught Place'),
      _RoutePoint('11:20 AM', 'Client Site, Connaught Place'),
      _RoutePoint('02:45 PM', 'Connaught Place'),
    ]),
    _TrackedEmployee(
        'Priya Sharma', 'EMP1002', 'Lajpat Nagar', 'Office', 28.5677, 77.2431, [
      _RoutePoint('09:10 AM', 'Go Digital Office, Lajpat Nagar'),
      _RoutePoint('01:00 PM', 'Go Digital Office, Lajpat Nagar'),
    ]),
    _TrackedEmployee(
        'Vikram Singh', 'EMP1003', 'Karol Bagh', 'Home', 28.6519, 77.1909, [
      _RoutePoint('09:05 AM', 'Home — Karol Bagh'),
      _RoutePoint('01:30 PM', 'Home — Karol Bagh'),
    ]),
    _TrackedEmployee(
        'Neha Verma', 'EMP1004', 'Hauz Khas', 'Office', 28.5494, 77.2001, [
      _RoutePoint('09:08 AM', 'Go Digital Office, Hauz Khas'),
      _RoutePoint('12:40 PM', 'Go Digital Office, Hauz Khas'),
    ]),
    _TrackedEmployee(
        'Rohan Mehta', 'EMP1005', 'Punjabi Bagh', 'Field', 28.6692, 77.1312, [
      _RoutePoint('09:15 AM', 'Go Digital Office, Punjabi Bagh'),
      _RoutePoint('11:50 AM', 'Client Site, Punjabi Bagh'),
      _RoutePoint('03:10 PM', 'Punjabi Bagh'),
    ]),
    _TrackedEmployee(
        'Ajay Nair', 'EMP1006', 'Mayapuri', 'Field', 28.6323, 77.1225, [
      _RoutePoint('09:00 AM', 'Go Digital Office, Mayapuri'),
      _RoutePoint('12:05 PM', 'Client Site, Mayapuri'),
    ]),
    _TrackedEmployee(
        'Pooja Iyer', 'EMP1007', 'Saket', 'Office', 28.5245, 77.2066, [
      _RoutePoint('09:12 AM', 'Go Digital Office, Saket'),
      _RoutePoint('01:20 PM', 'Go Digital Office, Saket'),
    ]),
    _TrackedEmployee(
        'Rahul Das', 'EMP1008', 'Shastri Nagar', 'Home', 28.6742, 77.1822, [
      _RoutePoint('09:07 AM', 'Home — Shastri Nagar'),
      _RoutePoint('02:00 PM', 'Home — Shastri Nagar'),
    ]),
  ];

  @override
  void initState() {
    super.initState();
    _loadMode();
  }

  Future<void> _loadMode() async {
    final preferences = await SharedPreferences.getInstance();
    final saved = preferences.getString(_modeStorageKey);
    if (!mounted || saved == null) return;
    if (saved == 'Office' || saved == 'Home' || saved == 'Field') {
      setState(() => mode = saved);
    }
  }

  Future<void> _setMode(String value) async {
    setState(() => mode = value);
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(_modeStorageKey, value);
  }

  List<_TrackedEmployee> get _visibleEmployees =>
      employees.where((employee) => employee.mode == mode).toList();

  void _viewRoute(_TrackedEmployee employee) {
    showDialog<void>(
      context: context,
      builder: (context) => _RouteDialog(employee: employee),
    );
  }

  @override
  Widget build(BuildContext context) {
    final mobile = MediaQuery.sizeOf(context).width < 600;
    return Scaffold(
      backgroundColor: HrmsColors.page,
      body: Column(
        children: [
          const AdminTopNav(activeRoute: '/admin/tracking'),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(
                  mobile ? 16 : 29, 18, mobile ? 16 : 29, 28),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1580),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const _TrackingHeader(),
                      const SizedBox(height: 14),
                      _TrackingKpis(employees: employees),
                      const SizedBox(height: 20),
                      _TrackingWorkspace(
                        mode: mode,
                        employees: _visibleEmployees,
                        onModeChanged: (value) => _setMode(value),
                        onViewRoute: _viewRoute,
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

class _TrackingHeader extends StatelessWidget {
  const _TrackingHeader();

  @override
  Widget build(BuildContext context) => const AdminPageHeader(
        title: 'Employee Tracking',
        breadcrumb: 'Tracking',
      );
}

class _TrackingKpis extends StatelessWidget {
  const _TrackingKpis({required this.employees});
  final List<_TrackedEmployee> employees;

  @override
  Widget build(BuildContext context) {
    final officeCount =
        employees.where((employee) => employee.mode == 'Office').length;
    final homeCount =
        employees.where((employee) => employee.mode == 'Home').length;
    final fieldCount =
        employees.where((employee) => employee.mode == 'Field').length;
    final activeCount = employees.length;
    final cards = [
      _TrackingKpi('Office', '$officeCount', 'Tracked employees',
          Icons.apartment_outlined, HrmsColors.blue),
      _TrackingKpi('Home', '$homeCount', 'Tracked employees',
          Icons.home_outlined, const Color(0xFF138A20)),
      _TrackingKpi('Field', '$fieldCount', 'Tracked employees',
          Icons.hiking_outlined, const Color(0xFFFF6500)),
      _TrackingKpi('Active Now', '$activeCount', 'Employees active',
          Icons.wifi_rounded, const Color(0xFF138A20)),
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

class _TrackingKpi extends StatelessWidget {
  const _TrackingKpi(
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
            borderRadius: BorderRadius.circular(14),
            boxShadow: const [
              BoxShadow(
                  color: Color(0x08071A72),
                  blurRadius: 14,
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
                    Text(value,
                        style: const TextStyle(
                            color: HrmsColors.navy,
                            fontSize: 25,
                            fontWeight: FontWeight.w800))
                  ]),
                  const Spacer(),
                  Text(label,
                      style: const TextStyle(
                          color: Color(0xFF303747),
                          fontWeight: FontWeight.w700,
                          fontSize: 11)),
                  const SizedBox(height: 3),
                  Text(caption,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          color: Color(0xFF657087), fontSize: 9)),
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
                              Text(value,
                                  style: const TextStyle(
                                      color: Color(0xFF10131B),
                                      fontSize: 27,
                                      fontWeight: FontWeight.w700)),
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
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Container(
                          width: 55,
                          height: 3,
                          decoration: BoxDecoration(
                              color: HrmsColors.blue,
                              borderRadius: BorderRadius.circular(4))),
                    ),
                  ],
                ),
        );
      });
}

class _TrackingWorkspace extends StatelessWidget {
  const _TrackingWorkspace(
      {required this.mode,
      required this.employees,
      required this.onModeChanged,
      required this.onViewRoute});
  final String mode;
  final List<_TrackedEmployee> employees;
  final ValueChanged<String> onModeChanged;
  final ValueChanged<_TrackedEmployee> onViewRoute;

  @override
  Widget build(BuildContext context) => Container(
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: const Color(0xFFE3E7EF)),
          borderRadius: BorderRadius.circular(14),
          boxShadow: const [
            BoxShadow(
                color: Color(0x08071A72), blurRadius: 15, offset: Offset(0, 6))
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: LayoutBuilder(builder: (_, constraints) {
          final stacked = constraints.maxWidth < 1050;
          final map = _MapPanel(
            mode: mode,
            employees: employees,
            onModeChanged: onModeChanged,
            onViewRoute: onViewRoute,
          );
          final table = _TrackedEmployeesPanel(
              mode: mode, employees: employees, onViewRoute: onViewRoute);
          if (stacked) {
            return Column(children: [
              map,
              const Divider(height: 1, color: Color(0xFFE3E7EF)),
              table
            ]);
          }
          return SizedBox(
            height: 615,
            child: Row(children: [
              Expanded(flex: 11, child: map),
              const VerticalDivider(width: 1, color: Color(0xFFE3E7EF)),
              Expanded(flex: 10, child: table)
            ]),
          );
        }),
      );
}

class _MapPanel extends StatelessWidget {
  const _MapPanel({
    required this.mode,
    required this.employees,
    required this.onModeChanged,
    required this.onViewRoute,
  });
  final String mode;
  final List<_TrackedEmployee> employees;
  final ValueChanged<String> onModeChanged;
  final ValueChanged<_TrackedEmployee> onViewRoute;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.fromLTRB(17, 16, 17, 18),
        child: Column(
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 340),
                child: Row(
                  children: [
                    for (final item in ['Office', 'Home', 'Field']) ...[
                      if (item != 'Office') const SizedBox(width: 10),
                      Expanded(
                        child: _ModeButton(
                          label: item,
                          active: mode == item,
                          onTap: () => onModeChanged(item),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 15),
            AspectRatio(
              aspectRatio: 1.44,
              child: _LiveMap(employees: employees, onViewRoute: onViewRoute),
            ),
          ],
        ),
      );
}

/// Google Maps display for the live employee markers. The positions remain
/// mock data until the employee location backend is connected.
class _LiveMap extends StatelessWidget {
  const _LiveMap({required this.employees, required this.onViewRoute});
  final List<_TrackedEmployee> employees;
  final ValueChanged<_TrackedEmployee> onViewRoute;

  static const _delhiCenter = LatLng(28.6139, 77.2090);

  Color _pinColor(String mode) => switch (mode) {
        'Office' => HrmsColors.blue,
        'Home' => const Color(0xFF138A20),
        _ => const Color(0xFFFF6500),
      };

  @override
  Widget build(BuildContext context) => ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: GoogleMap(
          initialCameraPosition:
              const CameraPosition(target: _delhiCenter, zoom: 11),
          mapToolbarEnabled: false,
          markers: employees
              .map((employee) => Marker(
                    markerId: MarkerId(employee.id),
                    position: LatLng(employee.lat, employee.lng),
                    infoWindow: InfoWindow(
                        title: employee.name, snippet: employee.location),
                    icon: BitmapDescriptor.defaultMarkerWithHue(
                        _markerHue(employee.mode)),
                    onTap: () => onViewRoute(employee),
                  ))
              .toSet(),
        ),
      );

  double _markerHue(String mode) => switch (mode) {
        'Office' => BitmapDescriptor.hueAzure,
        'Home' => BitmapDescriptor.hueGreen,
        _ => BitmapDescriptor.hueOrange,
      };
}

class _ModeButton extends StatelessWidget {
  const _ModeButton(
      {required this.label, required this.active, required this.onTap});
  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(22),
        child: Container(
          width: double.infinity,
          height: 38,
          alignment: Alignment.center,
          decoration: BoxDecoration(
              color: active ? HrmsColors.blue : Colors.white,
              border: Border.all(
                  color: active ? HrmsColors.blue : const Color(0xFFDCE1EB)),
              borderRadius: BorderRadius.circular(22)),
          child: Text(label,
              style: TextStyle(
                  color: active ? Colors.white : const Color(0xFF303747),
                  fontWeight: FontWeight.w600)),
        ),
      );
}

class _TrackedEmployeesPanel extends StatelessWidget {
  const _TrackedEmployeesPanel(
      {required this.mode, required this.employees, required this.onViewRoute});
  final String mode;
  final List<_TrackedEmployee> employees;
  final ValueChanged<_TrackedEmployee> onViewRoute;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.fromLTRB(18, 20, 18, 18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text('$mode Employees',
                    style: const TextStyle(
                        color: Color(0xFF11131A),
                        fontSize: 18,
                        fontWeight: FontWeight.w700)),
                const Spacer(),
                Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                        color: Color(0xFF138A20), shape: BoxShape.circle)),
                const SizedBox(width: 10),
                const Text('Updated just now',
                    style: TextStyle(color: Color(0xFF596176), fontSize: 12)),
              ],
            ),
            const SizedBox(height: 18),
            if (MediaQuery.sizeOf(context).width < 600)
              _MobileTrackedList(employees: employees, onViewRoute: onViewRoute)
            else
              Container(
                decoration: BoxDecoration(
                    border: Border.all(color: const Color(0xFFE2E6ED)),
                    borderRadius: BorderRadius.circular(10)),
                clipBehavior: Clip.antiAlias,
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: SizedBox(
                    width: 630,
                    child: Column(
                      children: [
                        const _TrackingTableHeader(),
                        ...employees.map((employee) => _TrackingRow(
                            employee: employee, onViewRoute: onViewRoute)),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      );
}

class _MobileTrackedList extends StatelessWidget {
  const _MobileTrackedList(
      {required this.employees, required this.onViewRoute});
  final List<_TrackedEmployee> employees;
  final ValueChanged<_TrackedEmployee> onViewRoute;

  @override
  Widget build(BuildContext context) => Column(
        children: employees
            .map(
              (employee) => Container(
                margin: const EdgeInsets.only(bottom: 9),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                    color: const Color(0xFFFBFCFF),
                    border: Border.all(color: const Color(0xFFE5EAF3)),
                    borderRadius: BorderRadius.circular(12)),
                child: Row(children: [
                  CircleAvatar(
                      radius: 20,
                      backgroundColor: const Color(0xFFEAF1FF),
                      child: Text(employee.name.substring(0, 1),
                          style: const TextStyle(
                              color: HrmsColors.blue,
                              fontWeight: FontWeight.w800))),
                  const SizedBox(width: 10),
                  Expanded(
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                        Row(children: [
                          Expanded(
                              child: Text(employee.name,
                                  style: const TextStyle(
                                      color: HrmsColors.navy,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 12))),
                          const _ActiveBadge()
                        ]),
                        const SizedBox(height: 5),
                        Row(children: [
                          const Icon(Icons.location_on,
                              color: HrmsColors.blue, size: 14),
                          const SizedBox(width: 5),
                          Expanded(
                              child: Text('${employee.location}, New Delhi',
                                  style: const TextStyle(
                                      color: Color(0xFF657087), fontSize: 10)))
                        ]),
                      ])),
                  IconButton(
                      onPressed: () => onViewRoute(employee),
                      icon: const Icon(Icons.map_outlined,
                          color: HrmsColors.blue, size: 23)),
                ]),
              ),
            )
            .toList(),
      );
}

class _TrackingTableHeader extends StatelessWidget {
  const _TrackingTableHeader();
  @override
  Widget build(BuildContext context) => Container(
        height: 42,
        color: const Color(0xFFFCFCFD),
        child: const Row(children: [
          _TrackingCell(width: 220, child: Text('Employee', style: _headStyle)),
          _TrackingCell(
              width: 220, child: Text('Current Location', style: _headStyle)),
          _TrackingCell(width: 110, child: Text('Status', style: _headStyle)),
          _TrackingCell(
              width: 80, child: Text('View Route', style: _headStyle)),
        ]),
      );
}

class _TrackingRow extends StatelessWidget {
  const _TrackingRow({required this.employee, required this.onViewRoute});
  final _TrackedEmployee employee;
  final ValueChanged<_TrackedEmployee> onViewRoute;

  @override
  Widget build(BuildContext context) => Container(
        height: 59,
        decoration: const BoxDecoration(
            border: Border(top: BorderSide(color: Color(0xFFE5E8EF)))),
        child: Row(
          children: [
            _TrackingCell(
              width: 220,
              child: Row(children: [
                CircleAvatar(
                    radius: 19,
                    backgroundColor: const Color(0xFFE8EEF8),
                    child: Text(employee.name.substring(0, 1),
                        style: const TextStyle(
                            color: HrmsColors.navy,
                            fontWeight: FontWeight.w700))),
                const SizedBox(width: 12),
                Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(employee.name,
                          style: const TextStyle(
                              color: Color(0xFF303747), fontSize: 13)),
                      Text(employee.id,
                          style: const TextStyle(
                              color: Color(0xFF657087), fontSize: 11))
                    ]),
              ]),
            ),
            _TrackingCell(
              width: 220,
              child:
                  Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Padding(
                    padding: EdgeInsets.only(top: 2),
                    child: Icon(Icons.location_on,
                        color: HrmsColors.blue, size: 15)),
                const SizedBox(width: 8),
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(employee.location,
                      style: const TextStyle(
                          color: Color(0xFF303747), fontSize: 12)),
                  const Text('New Delhi, Delhi',
                      style: TextStyle(color: Color(0xFF657087), fontSize: 11))
                ]),
              ]),
            ),
            const _TrackingCell(width: 110, child: _ActiveBadge()),
            _TrackingCell(
                width: 80,
                child: IconButton(
                    tooltip: 'View Route',
                    onPressed: () => onViewRoute(employee),
                    icon: const Icon(Icons.map_outlined,
                        color: HrmsColors.blue, size: 24))),
          ],
        ),
      );
}

class _TrackingCell extends StatelessWidget {
  const _TrackingCell({required this.width, required this.child});
  final double width;
  final Widget child;
  @override
  Widget build(BuildContext context) => SizedBox(
      width: width,
      child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12), child: child));
}

class _ActiveBadge extends StatelessWidget {
  const _ActiveBadge();
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 6),
        decoration: BoxDecoration(
            color: const Color(0xFFEAF6E6),
            borderRadius: BorderRadius.circular(5)),
        child: const Text('Active',
            style: TextStyle(color: Color(0xFF177020), fontSize: 11)),
      );
}

class _TrackedEmployee {
  const _TrackedEmployee(this.name, this.id, this.location, this.mode, this.lat,
      this.lng, this.route);
  final String name, id, location, mode;
  final double lat, lng;
  final List<_RoutePoint> route;
}

class _RoutePoint {
  const _RoutePoint(this.time, this.location);
  final String time, location;
}

class _RouteDialog extends StatelessWidget {
  const _RouteDialog({required this.employee});
  final _TrackedEmployee employee;

  @override
  Widget build(BuildContext context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Padding(
            padding: const EdgeInsets.all(22),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text('${employee.name} — Today\'s Route',
                          style: const TextStyle(
                              color: HrmsColors.navy,
                              fontSize: 16,
                              fontWeight: FontWeight.w700)),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close, size: 20),
                    ),
                  ],
                ),
                Text('${employee.id} · ${employee.mode} mode',
                    style: const TextStyle(
                        color: Color(0xFF657087), fontSize: 12)),
                const SizedBox(height: 16),
                for (final point in employee.route)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 14),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 10,
                          height: 10,
                          margin: const EdgeInsets.only(top: 4),
                          decoration: const BoxDecoration(
                              color: HrmsColors.blue, shape: BoxShape.circle),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(point.time,
                                  style: const TextStyle(
                                      color: HrmsColors.navy,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700)),
                              const SizedBox(height: 2),
                              Text(point.location,
                                  style: const TextStyle(
                                      color: Color(0xFF596176), fontSize: 12)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
      );
}

const _headStyle = TextStyle(
    color: Color(0xFF171B25), fontSize: 12, fontWeight: FontWeight.w600);
