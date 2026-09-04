import 'package:flutter/material.dart';

const employeeBlue = Color(0xFF0767F2);
const employeeNavy = Color(0xFF07143F);
const employeeMuted = Color(0xFF66738F);
const employeeLine = Color(0xFFDCE4F0);
const employeePurple = Color(0xFF772AE4);
const employeeOrange = Color(0xFFFF7100);
const employeeGreen = Color(0xFF08A978);

class EmployeeScaffold extends StatelessWidget {
  const EmployeeScaffold({
    super.key,
    required this.route,
    required this.title,
    required this.subtitle,
    required this.desktop,
    required this.mobile,
  });

  final String route;
  final String title;
  final String subtitle;
  final Widget desktop;
  final Widget mobile;

  @override
  Widget build(BuildContext context) {
    if (MediaQuery.sizeOf(context).width < 600) {
      return Scaffold(
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(18, 18, 18, 28),
            child: mobile,
          ),
        ),
      );
    }
    return Scaffold(
      body: Column(
        children: [
          EmployeeTopNavigation(route: route),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(30, 26, 30, 44),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: employeeNavy,
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: employeeMuted,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 24),
                  desktop,
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class EmployeeSidebar extends StatelessWidget {
  const EmployeeSidebar({super.key, required this.route});
  final String route;

  static const items = <_NavItem>[
    _NavItem('/employee/dashboard', 'Dashboard', Icons.grid_view_rounded),
    _NavItem(
        '/employee/attendance', 'Attendance', Icons.calendar_month_outlined),
    _NavItem('/employee/clock-log', 'Clock In / Out', Icons.schedule_rounded),
    _NavItem('/employee/leave', 'Leave', Icons.description_outlined,
        badge: '2'),
    _NavItem('/employee/extra-hours', 'Extra Hours', Icons.more_time_rounded),
    _NavItem('/employee/salary', 'Salary', Icons.currency_rupee_rounded),
    _NavItem('/employee/tracking', 'Tracking', Icons.my_location_rounded),
  ];

  @override
  Widget build(BuildContext context) => Container(
        width: 264,
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(right: BorderSide(color: employeeLine)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 12),
              child: Image.asset(
                'assets/images/go_digital_logo.jpeg',
                height: 67,
                alignment: Alignment.centerLeft,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                padding: const EdgeInsets.all(11),
                decoration: BoxDecoration(
                  color: const Color(0xFFEEF4FF),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Row(children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: employeeBlue,
                    child: Text('AK', style: TextStyle(color: Colors.white)),
                  ),
                  SizedBox(width: 10),
                  Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Arul Kumar',
                            style: TextStyle(fontWeight: FontWeight.w700)),
                        Text('EMP1001',
                            style:
                                TextStyle(color: employeeBlue, fontSize: 12)),
                      ]),
                ]),
              ),
            ),
            const SizedBox(height: 20),
            const _SectionLabel('MAIN'),
            ...items
                .take(5)
                .map((item) => _SidebarTile(item: item, route: route)),
            const SizedBox(height: 8),
            const _SectionLabel('FINANCE'),
            _SidebarTile(item: items[5], route: route),
            const SizedBox(height: 8),
            const _SectionLabel('TOOLS'),
            _SidebarTile(item: items[6], route: route),
            const Spacer(),
            const Padding(
              padding: EdgeInsets.all(24),
              child: Row(children: [
                Icon(Icons.logout_rounded, size: 17, color: employeeMuted),
                SizedBox(width: 8),
                Text('Logout', style: TextStyle(color: employeeMuted)),
              ]),
            ),
          ],
        ),
      );
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);
  final String text;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.fromLTRB(22, 4, 22, 6),
        child: Text(text,
            style: const TextStyle(
                color: Color(0xFF8390AA),
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: .5)),
      );
}

class _SidebarTile extends StatelessWidget {
  const _SidebarTile({required this.item, required this.route});
  final _NavItem item;
  final String route;

  @override
  Widget build(BuildContext context) {
    final active = route == item.route;
    return InkWell(
      onTap: active ? null : () => Navigator.pushNamed(context, item.route),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
        padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 11),
        decoration: BoxDecoration(
          color: active ? const Color(0xFFEAF2FF) : null,
          border: Border(
            left: BorderSide(
              color: active ? employeeBlue : Colors.transparent,
              width: 4,
            ),
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(children: [
          Icon(item.icon,
              size: 19, color: active ? employeeBlue : const Color(0xFF50617F)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(item.label,
                style: TextStyle(
                    color: active ? employeeBlue : const Color(0xFF34435E),
                    fontWeight: active ? FontWeight.w700 : FontWeight.w500)),
          ),
          if (item.badge != null)
            CircleAvatar(
              radius: 11,
              backgroundColor: const Color(0xFFFFA000),
              child: Text(item.badge!,
                  style: const TextStyle(color: Colors.white, fontSize: 11)),
            ),
        ]),
      ),
    );
  }
}

class _NavItem {
  const _NavItem(this.route, this.label, this.icon, {this.badge});
  final String route;
  final String label;
  final IconData icon;
  final String? badge;
}

class EmployeeProfileMenu extends StatelessWidget {
  const EmployeeProfileMenu({super.key, required this.radius});
  final double radius;

  void _openSettings(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => const _EmployeeSettingsSheet(),
    );
  }

  Future<void> _logout(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Logout?'),
        content: const Text('Are you sure you want to logout of your account?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute<void>(builder: (_) => const EmployeeSignedOutPage()),
      (_) => false,
    );
  }

  @override
  Widget build(BuildContext context) => PopupMenuButton<String>(
        tooltip: 'Open profile menu',
        offset: const Offset(0, 56),
        elevation: 10,
        color: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        onSelected: (value) {
          if (value == 'settings') {
            _openSettings(context);
          } else if (value == 'logout') {
            _logout(context);
          }
        },
        itemBuilder: (_) => const [
          PopupMenuItem<String>(
            value: 'settings',
            child: Row(children: [
              Icon(Icons.settings_outlined, size: 19, color: employeeNavy),
              SizedBox(width: 12),
              Text('Settings', style: TextStyle(color: employeeNavy)),
            ]),
          ),
          PopupMenuDivider(),
          PopupMenuItem<String>(
            value: 'logout',
            child: Row(children: [
              Icon(Icons.logout_rounded, size: 19, color: Color(0xFFD92D20)),
              SizedBox(width: 12),
              Text('Logout', style: TextStyle(color: Color(0xFFD92D20))),
            ]),
          ),
        ],
        child: CircleAvatar(
          radius: radius,
          backgroundColor: const Color(0xFFE8F0FF),
          child: Text('AK',
              style: TextStyle(
                  color: employeeBlue,
                  fontSize: radius * .72,
                  fontWeight: FontWeight.w800)),
        ),
      );
}

class EmployeeNotificationButton extends StatelessWidget {
  const EmployeeNotificationButton({super.key, this.compact = false});

  final bool compact;

  @override
  Widget build(BuildContext context) => Badge(
        smallSize: 9,
        backgroundColor: employeeBlue,
        child: IconButton(
          tooltip: 'Notifications',
          onPressed: () => showModalBottomSheet<void>(
            context: context,
            showDragHandle: true,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            builder: (_) => const _EmployeeNotificationsSheet(),
          ),
          style: IconButton.styleFrom(
            backgroundColor: const Color(0xFFF3F6FB),
            fixedSize: Size.square(compact ? 44 : 46),
            shape: const CircleBorder(),
          ),
          icon: const Icon(
            Icons.notifications_none_rounded,
            color: employeeNavy,
          ),
        ),
      );
}

class _EmployeeNotificationsSheet extends StatelessWidget {
  const _EmployeeNotificationsSheet();

  @override
  Widget build(BuildContext context) => const SafeArea(
        child: Padding(
          padding: EdgeInsets.fromLTRB(22, 4, 22, 28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Notifications',
                style: TextStyle(
                  color: employeeNavy,
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                ),
              ),
              SizedBox(height: 18),
              _NotificationRow(
                icon: Icons.login_rounded,
                title: 'Checked in successfully',
                subtitle: 'Today at 09:22 AM',
              ),
              Divider(height: 28, color: employeeLine),
              _NotificationRow(
                icon: Icons.verified_rounded,
                title: 'Leave request approved',
                subtitle: '20 Aug 2026',
              ),
            ],
          ),
        ),
      );
}

class _NotificationRow extends StatelessWidget {
  const _NotificationRow({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) => Row(children: [
        CircleAvatar(
          backgroundColor: const Color(0xFFEAF2FF),
          child: Icon(icon, color: employeeBlue, size: 20),
        ),
        const SizedBox(width: 13),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: const TextStyle(
                      color: employeeNavy, fontWeight: FontWeight.w700)),
              const SizedBox(height: 3),
              Text(subtitle,
                  style: const TextStyle(color: employeeMuted, fontSize: 12)),
            ],
          ),
        ),
      ]);
}

class _EmployeeSettingsSheet extends StatefulWidget {
  const _EmployeeSettingsSheet();

  @override
  State<_EmployeeSettingsSheet> createState() => _EmployeeSettingsSheetState();
}

class _EmployeeSettingsSheetState extends State<_EmployeeSettingsSheet> {
  bool notifications = true;

  @override
  Widget build(BuildContext context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(22, 4, 22, 28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Settings',
                  style: TextStyle(
                      color: employeeNavy,
                      fontSize: 20,
                      fontWeight: FontWeight.w800)),
              const SizedBox(height: 18),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const CircleAvatar(
                  backgroundColor: Color(0xFFEAF2FF),
                  child:
                      Icon(Icons.notifications_outlined, color: employeeBlue),
                ),
                title: const Text('Notifications'),
                subtitle: const Text('Attendance and request updates'),
                trailing: Switch(
                  value: notifications,
                  onChanged: (value) => setState(() => notifications = value),
                ),
              ),
            ],
          ),
        ),
      );
}

class EmployeeSignedOutPage extends StatelessWidget {
  const EmployeeSignedOutPage({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
        body: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 380),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Image.asset('assets/images/go_digital_logo.jpeg',
                        height: 74),
                    const SizedBox(height: 28),
                    const Icon(Icons.check_circle_rounded,
                        color: employeeGreen, size: 48),
                    const SizedBox(height: 14),
                    const Text('You have been logged out',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: employeeNavy,
                            fontSize: 22,
                            fontWeight: FontWeight.w800)),
                    const SizedBox(height: 8),
                    const Text('Your employee session has ended safely.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: employeeMuted)),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: () => Navigator.pushNamedAndRemoveUntil(
                          context,
                          '/employee/dashboard',
                          (_) => false,
                        ),
                        child: const Text('Return to employee portal'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
}

class EmployeeTopNavigation extends StatelessWidget {
  const EmployeeTopNavigation({super.key, required this.route});

  final String route;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
        builder: (context, constraints) {
          final compact = constraints.maxWidth < 1120;
          return Container(
            height: 88,
            padding: EdgeInsets.symmetric(horizontal: compact ? 18 : 28),
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(bottom: BorderSide(color: employeeLine)),
              boxShadow: [
                BoxShadow(
                  color: Color(0x0A07143F),
                  blurRadius: 16,
                  offset: Offset(0, 5),
                ),
              ],
            ),
            child: Row(children: [
              Image.asset(
                'assets/images/go_digital_logo.jpeg',
                height: compact ? 50 : 60,
                width: compact ? 145 : 185,
                fit: BoxFit.contain,
                alignment: Alignment.centerLeft,
              ),
              SizedBox(width: compact ? 12 : 28),
              Expanded(
                child: Center(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Container(
                      padding: const EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF5F7FB),
                        borderRadius: BorderRadius.circular(32),
                        border: Border.all(color: const Color(0xFFE7ECF4)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: EmployeeSidebar.items
                            .map((item) => _TopNavigationItem(
                                  item: item,
                                  active: route == item.route,
                                  compact: compact,
                                ))
                            .toList(),
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(width: compact ? 12 : 24),
              if (!compact) ...[
                const HeaderPill('08:46 AM'),
                const SizedBox(width: 8),
                const HeaderPill('●  Checked In'),
                const SizedBox(width: 14),
              ],
              const EmployeeNotificationButton(),
              const SizedBox(width: 10),
              const EmployeeProfileMenu(radius: 21),
            ]),
          );
        },
      );
}

class _TopNavigationItem extends StatelessWidget {
  const _TopNavigationItem({
    required this.item,
    required this.active,
    required this.compact,
  });

  final _NavItem item;
  final bool active;
  final bool compact;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 2),
        child: Material(
          color: active ? employeeBlue : Colors.transparent,
          borderRadius: BorderRadius.circular(26),
          child: InkWell(
            borderRadius: BorderRadius.circular(26),
            onTap:
                active ? null : () => Navigator.pushNamed(context, item.route),
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: compact ? 13 : 18,
                vertical: 12,
              ),
              child: Text(
                item.label,
                style: TextStyle(
                  color: active ? Colors.white : employeeMuted,
                  fontSize: compact ? 12 : 13,
                  fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
            ),
          ),
        ),
      );
}

class EmployeeTopHeader extends StatelessWidget {
  const EmployeeTopHeader(
      {super.key, required this.title, required this.subtitle});
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) => Container(
        height: 74,
        padding: const EdgeInsets.symmetric(horizontal: 30),
        decoration: const BoxDecoration(
          color: Color(0xFFFBFDFF),
          border: Border(bottom: BorderSide(color: employeeLine)),
        ),
        child: Row(children: [
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        fontSize: 20,
                        color: employeeNavy,
                        fontWeight: FontWeight.w800)),
                const SizedBox(height: 2),
                Text(subtitle,
                    style: const TextStyle(color: employeeMuted, fontSize: 13)),
              ],
            ),
          ),
          const HeaderPill('08:46 AM'),
          const SizedBox(width: 10),
          const HeaderPill('●  Checked In'),
          const SizedBox(width: 14),
          const EmployeeNotificationButton(compact: true),
          const SizedBox(width: 16),
          const EmployeeProfileMenu(radius: 20),
        ]),
      );
}

class HeaderPill extends StatelessWidget {
  const HeaderPill(this.text, {super.key});
  final String text;
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 17, vertical: 9),
        decoration: BoxDecoration(
          color: const Color(0xFFEAF2FF),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(text,
            style: const TextStyle(
                color: employeeBlue, fontWeight: FontWeight.w700)),
      );
}

class MobileEmployeeHeader extends StatelessWidget {
  const MobileEmployeeHeader({super.key, this.showGreeting = true});
  final bool showGreeting;

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Image.asset('assets/images/go_digital_logo.jpeg', height: 68),
            const Spacer(),
            const EmployeeNotificationButton(compact: true),
            const SizedBox(width: 12),
            const EmployeeProfileMenu(radius: 25),
          ]),
          if (showGreeting) ...[
            const SizedBox(height: 22),
            const Text('Hello, Arul 👋',
                style: TextStyle(color: Color(0xFF495572), fontSize: 19)),
          ],
        ],
      );
}

class EmployeeCard extends StatelessWidget {
  const EmployeeCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(22),
    this.color = Colors.white,
    this.borderColor = employeeLine,
  });
  final Widget child;
  final EdgeInsets padding;
  final Color color;
  final Color borderColor;

  @override
  Widget build(BuildContext context) => Container(
        padding: padding,
        decoration: BoxDecoration(
          color: color,
          border: Border.all(color: borderColor),
          borderRadius: BorderRadius.circular(14),
          boxShadow: const [
            BoxShadow(
              color: Color(0x0D193B75),
              blurRadius: 22,
              offset: Offset(0, 9),
            ),
          ],
        ),
        child: child,
      );
}

class SectionTitle extends StatelessWidget {
  const SectionTitle(this.title, {super.key, this.subtitle, this.trailing});
  final String title;
  final String? subtitle;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) => Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        color: employeeNavy,
                        fontSize: 19,
                        fontWeight: FontWeight.w800)),
                if (subtitle != null) ...[
                  const SizedBox(height: 3),
                  Text(subtitle!,
                      style:
                          const TextStyle(color: employeeMuted, fontSize: 13)),
                ],
              ],
            ),
          ),
          if (trailing != null) trailing!,
        ],
      );
}

class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    super.key,
    required this.label,
    required this.icon,
    this.color = employeeBlue,
    this.onPressed,
  });
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) => FilledButton.icon(
        style: FilledButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 17),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
        onPressed: onPressed ?? () {},
        icon: Icon(icon, size: 20),
        label: Text(label, style: const TextStyle(fontWeight: FontWeight.w700)),
      );
}

class StatusPill extends StatelessWidget {
  const StatusPill(this.label, this.color, {super.key});
  final String label;
  final Color color;
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: color.withValues(alpha: .11),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(label,
            style: TextStyle(
                color: color, fontSize: 11, fontWeight: FontWeight.w800)),
      );
}

class MetricCard extends StatelessWidget {
  const MetricCard({
    super.key,
    required this.label,
    required this.value,
    required this.color,
    required this.icon,
    this.caption,
  });
  final String label;
  final String value;
  final String? caption;
  final Color color;
  final IconData icon;

  @override
  Widget build(BuildContext context) => EmployeeCard(
        padding: const EdgeInsets.all(20),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: color.withValues(alpha: .1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color),
          ),
          const SizedBox(width: 14),
          Expanded(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(label,
                  style: const TextStyle(color: employeeMuted, fontSize: 12)),
              const SizedBox(height: 5),
              Text(value,
                  style: const TextStyle(
                      color: employeeNavy,
                      fontSize: 27,
                      fontWeight: FontWeight.w800)),
              if (caption != null) ...[
                const SizedBox(height: 4),
                Text(caption!,
                    style: const TextStyle(color: employeeMuted, fontSize: 12)),
              ],
            ]),
          ),
        ]),
      );
}

class LabeledValue extends StatelessWidget {
  const LabeledValue(this.label, this.value,
      {super.key, this.valueColor = employeeNavy});
  final String label;
  final String value;
  final Color valueColor;
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 11),
        child: Row(children: [
          Expanded(
              child: Text(label, style: const TextStyle(color: employeeMuted))),
          Text(value,
              style: TextStyle(color: valueColor, fontWeight: FontWeight.w700)),
        ]),
      );
}

class ResponsiveGrid extends StatelessWidget {
  const ResponsiveGrid({
    super.key,
    required this.children,
    this.desktopColumns = 2,
    this.tabletColumns = 2,
    this.mobileColumns = 1,
    this.spacing = 18,
    this.childAspectRatio = 2.2,
  });
  final List<Widget> children;
  final int desktopColumns;
  final int tabletColumns;
  final int mobileColumns;
  final double spacing;
  final double childAspectRatio;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final columns = width < 600
        ? mobileColumns
        : width < 1024
            ? tabletColumns
            : desktopColumns;
    return GridView.count(
      crossAxisCount: columns,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: spacing,
      crossAxisSpacing: spacing,
      childAspectRatio: childAspectRatio,
      children: children,
    );
  }
}

class SimpleTable extends StatelessWidget {
  const SimpleTable({
    super.key,
    required this.columns,
    required this.rows,
    this.minWidth = 760,
  });
  final List<String> columns;
  final List<List<Widget>> rows;
  final double minWidth;

  @override
  Widget build(BuildContext context) => SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: SizedBox(
          width: minWidth,
          child: Table(
            defaultVerticalAlignment: TableCellVerticalAlignment.middle,
            border: const TableBorder(
              horizontalInside: BorderSide(color: employeeLine),
            ),
            children: [
              TableRow(
                decoration: const BoxDecoration(color: Color(0xFFF8FAFD)),
                children: columns
                    .map((c) => Padding(
                          padding: const EdgeInsets.all(13),
                          child: Text(c,
                              style: const TextStyle(
                                  color: employeeMuted,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w800)),
                        ))
                    .toList(),
              ),
              ...rows.map(
                (row) => TableRow(
                  children: row
                      .map((cell) => Padding(
                            padding: const EdgeInsets.all(13),
                            child: cell,
                          ))
                      .toList(),
                ),
              ),
            ],
          ),
        ),
      );
}

class EmployeePageTitle extends StatelessWidget {
  const EmployeePageTitle({
    super.key,
    required this.title,
    this.trailing,
  });
  final String title;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) => Row(children: [
        Expanded(
          child: Text(title,
              style: const TextStyle(
                  color: employeeNavy,
                  fontSize: 34,
                  height: 1,
                  fontWeight: FontWeight.w800)),
        ),
        if (trailing != null) trailing!,
      ]);
}

class InfoBanner extends StatelessWidget {
  const InfoBanner(this.text, {super.key, this.color = employeeBlue});
  final String text;
  final Color color;
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: color.withValues(alpha: .08),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(children: [
          Icon(Icons.info_outline_rounded, color: color, size: 20),
          const SizedBox(width: 10),
          Expanded(
              child: Text(text, style: TextStyle(color: color, height: 1.4))),
        ]),
      );
}
