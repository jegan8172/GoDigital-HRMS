import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../shared/employee_ui.dart';

class EmployeeTrackingPage extends StatelessWidget {
  const EmployeeTrackingPage({super.key});

  @override
  Widget build(BuildContext context) {
    final routeHistory =
        ModalRoute.of(context)?.settings.arguments == 'history';
    return EmployeeScaffold(
      route: '/employee/tracking',
      title: routeHistory ? 'Route History' : 'Live Tracking',
      subtitle: routeHistory
          ? 'Your recent travel routes'
          : 'Live employee location and today’s field activity',
      desktop: _TrackingView(mobile: false, routeHistory: routeHistory),
      mobile: _TrackingView(mobile: true, routeHistory: routeHistory),
    );
  }
}

enum _WorkMode { office, home, field }

class _TrackingView extends StatefulWidget {
  const _TrackingView({required this.mobile, required this.routeHistory});
  final bool mobile;
  final bool routeHistory;

  @override
  State<_TrackingView> createState() => _TrackingViewState();
}

class _TrackingViewState extends State<_TrackingView> {
  _WorkMode mode = _WorkMode.field;
  String updated = 'Updated just now';

  String get modeLabel => switch (mode) {
        _WorkMode.office => 'Office',
        _WorkMode.home => 'Home',
        _WorkMode.field => 'Field',
      };

  String get address => switch (mode) {
        _WorkMode.office =>
          'Go Digital Office, Sector 62\nNoida, Uttar Pradesh',
        _WorkMode.home => 'Registered Home Location\nNoida, Uttar Pradesh',
        _WorkMode.field => 'Sector 62, Noida\nUttar Pradesh 201309',
      };

  Color get activeColor =>
      mode == _WorkMode.field ? employeeGreen : employeeBlue;

  void refreshLocation() {
    setState(() => updated = 'Updated just now');
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Live location refreshed.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.routeHistory) return _RouteHistoryView(mobile: widget.mobile);
    final modes = _ModeTabs(
      selected: mode,
      onChanged: (value) => setState(() => mode = value),
    );
    final status = _CurrentStatusCard(
      mode: modeLabel,
      address: address,
      color: activeColor,
      onRefresh: refreshLocation,
    );
    final map = _RouteMap(mode: mode);
    const metrics = _TripMetrics();
    const timeline = _ActivityTimeline();
    const live = _LiveTrackingStatus();

    if (widget.mobile) {
      return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const MobileEmployeeHeader(),
        const SizedBox(height: 14),
        const EmployeePageTitle(title: 'Live Tracking'),
        const SizedBox(height: 18),
        modes,
        const SizedBox(height: 14),
        status,
        const SizedBox(height: 20),
        Row(children: [
          const Expanded(
            child: Text('Live Location',
                style: TextStyle(
                    color: employeeNavy,
                    fontSize: 20,
                    fontWeight: FontWeight.w800)),
          ),
          Text(updated, style: const TextStyle(color: employeeMuted)),
        ]),
        const SizedBox(height: 12),
        map,
        const SizedBox(height: 14),
        metrics,
        const SizedBox(height: 22),
        const Text('Today’s Activity',
            style: TextStyle(
                color: employeeNavy,
                fontSize: 20,
                fontWeight: FontWeight.w800)),
        const SizedBox(height: 12),
        timeline,
        const SizedBox(height: 18),
        live,
      ]);
    }

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      modes,
      const SizedBox(height: 18),
      status,
      const SizedBox(height: 20),
      Row(children: [
        const Expanded(
          child: Text('Live Location',
              style: TextStyle(
                  color: employeeNavy,
                  fontSize: 22,
                  fontWeight: FontWeight.w800)),
        ),
        Text(updated, style: const TextStyle(color: employeeMuted)),
      ]),
      const SizedBox(height: 12),
      Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Expanded(
          flex: 7,
          child: Column(children: [
            map,
            const SizedBox(height: 14),
            metrics,
          ]),
        ),
        const SizedBox(width: 20),
        const Expanded(
          flex: 4,
          child: Column(children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Text('Today’s Activity',
                  style: TextStyle(
                      color: employeeNavy,
                      fontSize: 20,
                      fontWeight: FontWeight.w800)),
            ),
            SizedBox(height: 12),
            _ActivityTimeline(),
            SizedBox(height: 18),
            _LiveTrackingStatus(),
          ]),
        ),
      ]),
    ]);
  }
}

class _RouteHistoryView extends StatelessWidget {
  const _RouteHistoryView({required this.mobile});
  final bool mobile;
  @override
  Widget build(BuildContext context) {
    final history =
        const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('Recent Routes',
          style: TextStyle(
              color: employeeNavy, fontSize: 20, fontWeight: FontWeight.w800)),
      SizedBox(height: 12),
      _RouteHistoryCard(
          'Today', 'Sector 62 → Sector 63 → Sector 62', '18.6 km', '01h 48m'),
      SizedBox(height: 12),
      _RouteHistoryCard('22 Aug 2026',
          'Noida Office → Sector 18 → Noida Office', '12.4 km', '01h 12m'),
      SizedBox(height: 12),
      _RouteHistoryCard(
          '21 Aug 2026', 'Noida Office → Greater Noida', '24.1 km', '02h 06m'),
    ]);
    return mobile
        ? Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const MobileEmployeeHeader(),
            const SizedBox(height: 14),
            const EmployeePageTitle(title: 'Route History'),
            const SizedBox(height: 20),
            history
          ])
        : history;
  }
}

class _RouteHistoryCard extends StatelessWidget {
  const _RouteHistoryCard(this.date, this.route, this.distance, this.duration);
  final String date, route, distance, duration;
  @override
  Widget build(BuildContext context) => EmployeeCard(
        padding: const EdgeInsets.all(18),
        child: Row(children: [
          Container(
              width: 43,
              height: 43,
              decoration: BoxDecoration(
                  color: const Color(0xFFE9F7F7),
                  borderRadius: BorderRadius.circular(11)),
              child:
                  const Icon(Icons.route_outlined, color: Color(0xFF079B9B))),
          const SizedBox(width: 14),
          Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                Text(date,
                    style: const TextStyle(
                        color: employeeNavy, fontWeight: FontWeight.w800)),
                const SizedBox(height: 5),
                Text(route,
                    style: const TextStyle(color: employeeMuted, fontSize: 13))
              ])),
          Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
            Text(distance,
                style: const TextStyle(
                    color: employeeNavy, fontWeight: FontWeight.w700)),
            const SizedBox(height: 5),
            Text(duration,
                style: const TextStyle(color: employeeMuted, fontSize: 12))
          ]),
        ]),
      );
}

class _ModeTabs extends StatelessWidget {
  const _ModeTabs({required this.selected, required this.onChanged});
  final _WorkMode selected;
  final ValueChanged<_WorkMode> onChanged;

  @override
  Widget build(BuildContext context) => Row(children: [
        _ModeTab(
          icon: Icons.business_outlined,
          label: 'Office',
          active: selected == _WorkMode.office,
          onTap: () => onChanged(_WorkMode.office),
        ),
        const SizedBox(width: 8),
        _ModeTab(
          icon: Icons.home_outlined,
          label: 'Home',
          active: selected == _WorkMode.home,
          onTap: () => onChanged(_WorkMode.home),
        ),
        const SizedBox(width: 8),
        _ModeTab(
          icon: Icons.person_outline_rounded,
          label: 'Field',
          active: selected == _WorkMode.field,
          onTap: () => onChanged(_WorkMode.field),
        ),
      ]);
}

class _ModeTab extends StatelessWidget {
  const _ModeTab({
    required this.icon,
    required this.label,
    required this.active,
    required this.onTap,
  });
  final IconData icon;
  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Expanded(
        child: Material(
          color: active ? employeeGreen : Colors.white,
          borderRadius: BorderRadius.circular(11),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(11),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                border:
                    Border.all(color: active ? employeeGreen : employeeLine),
                borderRadius: BorderRadius.circular(11),
              ),
              child:
                  Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                Icon(icon,
                    color: active ? Colors.white : employeeMuted, size: 25),
                const SizedBox(width: 7),
                Text(label,
                    style: TextStyle(
                        color: active ? Colors.white : employeeNavy,
                        fontSize: 16,
                        fontWeight: FontWeight.w700)),
              ]),
            ),
          ),
        ),
      );
}

class _CurrentStatusCard extends StatelessWidget {
  const _CurrentStatusCard({
    required this.mode,
    required this.address,
    required this.color,
    required this.onRefresh,
  });
  final String mode;
  final String address;
  final Color color;
  final VoidCallback onRefresh;

  @override
  Widget build(BuildContext context) => EmployeeCard(
        padding: const EdgeInsets.all(18),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            const Text('Current Status',
                style: TextStyle(
                    color: employeeNavy,
                    fontSize: 18,
                    fontWeight: FontWeight.w800)),
            const SizedBox(width: 12),
            CircleAvatar(radius: 5, backgroundColor: color),
            const SizedBox(width: 7),
            Text(mode,
                style: TextStyle(
                    color: color, fontSize: 18, fontWeight: FontWeight.w700)),
            const Spacer(),
            const Text('Since 09:20 AM',
                style: TextStyle(color: employeeMuted, fontSize: 13)),
          ]),
          const SizedBox(height: 22),
          Row(children: [
            const Icon(Icons.location_on_outlined,
                color: employeeMuted, size: 30),
            const SizedBox(width: 12),
            Expanded(
              child: Text(address,
                  style: const TextStyle(color: employeeMuted, height: 1.4)),
            ),
            IconButton.outlined(
              tooltip: 'Refresh live location',
              onPressed: onRefresh,
              icon: const Icon(Icons.refresh_rounded,
                  color: employeeBlue, size: 27),
              style: IconButton.styleFrom(
                padding: const EdgeInsets.all(11),
                side: const BorderSide(color: employeeLine),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ]),
        ]),
      );
}

/// Real, pannable/zoomable street map — OpenStreetMap tiles via flutter_map.
/// No API key. Field mode draws today's route as a polyline between mock
/// waypoints; Office/Home modes just pin the registered location. Wired to
/// real GPS + /tracking/live once the backend (Section 6 of the blueprint)
/// exists — these coordinates are local placeholders until then.
class _RouteMap extends StatelessWidget {
  const _RouteMap({required this.mode});
  final _WorkMode mode;

  static const _fieldRoute = <LatLng>[
    LatLng(28.5921, 77.3906),
    LatLng(28.6005, 77.3844),
    LatLng(28.6098, 77.3760),
    LatLng(28.6193, 77.3726),
    LatLng(28.6280, 77.3649),
  ];
  static const _officePoint = LatLng(28.6139, 77.3773);
  static const _homePoint = LatLng(28.6203, 77.3803);

  @override
  Widget build(BuildContext context) {
    final isField = mode == _WorkMode.field;
    final center = isField
        ? _fieldRoute.last
        : mode == _WorkMode.office
            ? _officePoint
            : _homePoint;

    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: AspectRatio(
        aspectRatio: 1.95,
        child: GoogleMap(
          initialCameraPosition: CameraPosition(target: center, zoom: 13.5),
          mapToolbarEnabled: false,
          polylines: isField ? {const Polyline(polylineId: PolylineId('today-route'), points: _fieldRoute, color: employeeGreen, width: 4)} : {},
          markers: isField ? {
            Marker(markerId: const MarkerId('start'), position: _fieldRoute.first, icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure)),
            Marker(markerId: const MarkerId('current'), position: _fieldRoute.last),
          } : {Marker(markerId: const MarkerId('location'), position: center, icon: BitmapDescriptor.defaultMarkerWithHue(mode == _WorkMode.office ? BitmapDescriptor.hueAzure : BitmapDescriptor.hueGreen))},
        ),
      ),
    );
  }
}

class _TripMetrics extends StatelessWidget {
  const _TripMetrics();

  @override
  Widget build(BuildContext context) => const EmployeeCard(
        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 18),
        child: Row(children: [
          Expanded(
            child: _TripMetric(Icons.route_outlined, 'Distance Travelled',
                '18.6 km', employeeGreen),
          ),
          SizedBox(height: 66, child: VerticalDivider(color: employeeLine)),
          Expanded(
            child: _TripMetric(
                Icons.schedule_rounded, 'Duration', '01h 48m', employeeBlue),
          ),
          SizedBox(height: 66, child: VerticalDivider(color: employeeLine)),
          Expanded(
            child: _TripMetric(
                Icons.speed_rounded, 'Avg Speed', '24.3 km/h', employeeGreen),
          ),
        ]),
      );
}

class _TripMetric extends StatelessWidget {
  const _TripMetric(this.icon, this.label, this.value, this.color);
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) => Column(children: [
        Icon(icon, color: color, size: 27),
        const SizedBox(height: 7),
        Text(label,
            textAlign: TextAlign.center,
            style: const TextStyle(color: employeeMuted, fontSize: 10)),
        const SizedBox(height: 4),
        Text(value,
            maxLines: 1,
            textAlign: TextAlign.center,
            style: const TextStyle(
                color: employeeNavy,
                fontSize: 17,
                fontWeight: FontWeight.w800)),
      ]);
}

class _ActivityTimeline extends StatelessWidget {
  const _ActivityTimeline();

  @override
  Widget build(BuildContext context) => const EmployeeCard(
        padding: EdgeInsets.all(18),
        child: Column(children: [
          _TimelineRow('09:20 AM', 'Started field tracking'),
          Divider(indent: 42, color: employeeLine),
          _TimelineRow('10:05 AM', 'Reached Sector 63'),
          Divider(indent: 42, color: employeeLine),
          _TimelineRow('11:08 AM', 'Arrived at Sector 62'),
        ]),
      );
}

class _TimelineRow extends StatelessWidget {
  const _TimelineRow(this.time, this.label);
  final String time;
  final String label;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(children: [
          const CircleAvatar(
            radius: 14,
            backgroundColor: employeeGreen,
            child: Icon(Icons.check, color: Colors.white, size: 16),
          ),
          const SizedBox(width: 14),
          SizedBox(
            width: 78,
            child: Text(time,
                style: const TextStyle(
                    color: employeeNavy, fontWeight: FontWeight.w700)),
          ),
          Expanded(
            child: Text(label, style: const TextStyle(color: employeeMuted)),
          ),
        ]),
      );
}

class _LiveTrackingStatus extends StatelessWidget {
  const _LiveTrackingStatus();

  @override
  Widget build(BuildContext context) => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFFEAF9F4),
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: const Color(0xFFCAEDE1)),
        ),
        child: const Text('●  Live tracking active',
            textAlign: TextAlign.center,
            style:
                TextStyle(color: employeeGreen, fontWeight: FontWeight.w700)),
      );
}
