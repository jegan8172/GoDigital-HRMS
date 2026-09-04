import 'package:flutter/material.dart';

const _blue = Color(0xFF075EF7);
const _navy = Color(0xFF061457);

class AdminTopNav extends StatelessWidget {
  const AdminTopNav({super.key, required this.activeRoute});

  final String activeRoute;

  static const items = <(String, String)>[
    ('Dashboard', '/admin/dashboard'),
    ('Employees', '/admin/employees'),
    ('Approvals', '/admin/approvals'),
    ('Payroll', '/admin/payroll'),
    ('Tracking', '/admin/tracking'),
  ];

  void _open(BuildContext context, String route) {
    if (route == activeRoute) return;
    Navigator.pushReplacementNamed(context, route);
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final mobile = screenWidth < 600;
    final compact = screenWidth < 880;
    return Container(
      height: mobile ? 68 : 90,
      padding: EdgeInsets.symmetric(
          horizontal: mobile
              ? 14
              : compact
                  ? 16
                  : 32),
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
              color: Color(0x12071A72), blurRadius: 16, offset: Offset(0, 5))
        ],
      ),
      child: Row(
        children: [
          Image.asset(
            'assets/images/go_digital_logo.jpeg',
            width: mobile
                ? 116
                : compact
                    ? 142
                    : 174,
            fit: BoxFit.contain,
          ),
          const Spacer(),
          if (!compact)
            _DesktopNav(
                activeRoute: activeRoute,
                onOpen: (route) => _open(context, route)),
          if (!mobile) const Spacer(),
          _NotificationButton(mobile: mobile),
          SizedBox(width: mobile ? 3 : 18),
          if (!mobile)
            const CircleAvatar(
              radius: 26,
              backgroundColor: Color(0xFFE7F0FF),
              child: Icon(Icons.account_circle_rounded, color: _navy, size: 48),
            ),
          if (!compact) ...[
            const SizedBox(width: 10),
            const Icon(Icons.keyboard_arrow_down_rounded, color: _navy),
          ],
          if (compact)
            PopupMenuButton<String>(
              tooltip: 'Navigation',
              icon: const Icon(Icons.menu_rounded, color: _navy, size: 28),
              onSelected: (route) => _open(context, route),
              itemBuilder: (_) => items
                  .map(
                    (item) => PopupMenuItem(
                      value: item.$2,
                      child: Row(
                        children: [
                          if (item.$2 == activeRoute) ...[
                            const Icon(Icons.circle, size: 8, color: _blue),
                            const SizedBox(width: 10),
                          ],
                          Text(item.$1,
                              style: TextStyle(
                                  fontWeight: item.$2 == activeRoute
                                      ? FontWeight.w700
                                      : FontWeight.w500)),
                        ],
                      ),
                    ),
                  )
                  .toList(),
            ),
        ],
      ),
    );
  }
}

class AdminPageHeader extends StatelessWidget {
  const AdminPageHeader({
    super.key,
    required this.title,
    this.breadcrumb,
    this.trailing,
  });

  final String title;
  final String? breadcrumb;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
        builder: (context, constraints) {
          final narrow = constraints.maxWidth < 760;
          final heading = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Color(0xFF11131A),
                  fontSize: 28,
                  height: 1.15,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Home',
                      style: TextStyle(color: _blue, fontSize: 15)),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    child: Icon(Icons.chevron_right, color: _blue, size: 18),
                  ),
                  Text(breadcrumb ?? title,
                      style: const TextStyle(color: _blue, fontSize: 15)),
                ],
              ),
            ],
          );
          if (trailing == null) return heading;
          if (narrow) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [heading, const SizedBox(height: 14), trailing!],
            );
          }
          return Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [Expanded(child: heading), trailing!],
          );
        },
      );
}

class _DesktopNav extends StatelessWidget {
  const _DesktopNav({required this.activeRoute, required this.onOpen});
  final String activeRoute;
  final ValueChanged<String> onOpen;

  @override
  Widget build(BuildContext context) => Container(
        height: 60,
        padding: const EdgeInsets.all(7),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: const Color(0xFFE2E7F1)),
          borderRadius: BorderRadius.circular(22),
          boxShadow: const [
            BoxShadow(
                color: Color(0x0C071A72), blurRadius: 8, offset: Offset(0, 3))
          ],
        ),
        child: Row(
          children: AdminTopNav.items.map((item) {
            final active = item.$2 == activeRoute;
            return InkWell(
              onTap: () => onOpen(item.$2),
              borderRadius: BorderRadius.circular(13),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding:
                    const EdgeInsets.symmetric(horizontal: 19, vertical: 12),
                decoration: BoxDecoration(
                    color: active ? _blue : Colors.transparent,
                    borderRadius: BorderRadius.circular(13)),
                child: Text(item.$1,
                    style: TextStyle(
                        color: active ? Colors.white : _navy,
                        fontWeight: FontWeight.w600,
                        fontSize: 15)),
              ),
            );
          }).toList(),
        ),
      );
}

class _NotificationButton extends StatelessWidget {
  const _NotificationButton({required this.mobile});
  final bool mobile;

  @override
  Widget build(BuildContext context) => Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: mobile ? 38 : 45,
            height: mobile ? 38 : 45,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: mobile ? const Color(0xFFF3F6FC) : Colors.white,
              border: Border.all(color: const Color(0xFFE2E7F1)),
            ),
            child: Icon(Icons.notifications_none_rounded,
                color: _navy, size: mobile ? 22 : 24),
          ),
          Positioned(
            right: 3,
            top: 2,
            child: Container(
                width: 9,
                height: 9,
                decoration:
                    const BoxDecoration(color: _blue, shape: BoxShape.circle)),
          ),
        ],
      );
}
