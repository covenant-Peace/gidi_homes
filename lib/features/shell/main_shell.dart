import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/responsive.dart';
import '../../theme/app_theme.dart';

/// Responsive navigation chrome shared by the four primary tabs.
/// Desktop/tablet → top nav bar (website feel). Mobile → bottom nav (app feel).
class MainShell extends StatelessWidget {
  const MainShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  static const _tabs = [
    (_Tab(label: 'Explore', icon: Icons.explore_outlined, active: Icons.explore_rounded)),
    (_Tab(label: 'Search', icon: Icons.search_rounded, active: Icons.search_rounded)),
    (_Tab(label: 'Saved', icon: Icons.favorite_border_rounded, active: Icons.favorite_rounded)),
    (_Tab(label: 'Account', icon: Icons.person_outline_rounded, active: Icons.person_rounded)),
  ];

  void _go(int i) => navigationShell.goBranch(i,
      initialLocation: i == navigationShell.currentIndex);

  @override
  Widget build(BuildContext context) {
    final current = navigationShell.currentIndex;

    // Top nav bar only on true desktop; mobile + tablet use the bottom nav so
    // the horizontal nav never overflows on narrow widths.
    if (!context.isDesktop) {
      return Scaffold(
        body: navigationShell,
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: current,
          onTap: _go,
          items: [
            for (final t in _tabs)
              BottomNavigationBarItem(
                icon: Icon(t.icon),
                activeIcon: Icon(t.active),
                label: t.label,
              ),
          ],
        ),
      );
    }

    // Desktop / tablet: top navigation bar.
    return Scaffold(
      body: Column(
        children: [
          _TopBar(current: current, onSelect: _go),
          const Divider(height: 1),
          Expanded(child: navigationShell),
        ],
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar({required this.current, required this.onSelect});
  final int current;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      child: SafeArea(
        bottom: false,
        child: PageContainer(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          child: Row(
            children: [
              InkWell(
                onTap: () => onSelect(0),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(7),
                      decoration: BoxDecoration(
                          color: AppColors.green,
                          borderRadius: BorderRadius.circular(10)),
                      child: const Icon(Icons.location_city_rounded,
                          color: Colors.white, size: 20),
                    ),
                    const SizedBox(width: 10),
                    const Text('GidiHomes',
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.w900)),
                  ],
                ),
              ),
              const SizedBox(width: 40),
              for (int i = 0; i < MainShell._tabs.length; i++)
                _NavLink(
                  label: MainShell._tabs[i].label,
                  selected: current == i,
                  onTap: () => onSelect(i),
                ),
              const Spacer(),
              ElevatedButton.icon(
                onPressed: () => context.push('/agent/post'),
                icon: const Icon(Icons.add_home_work_outlined, size: 18),
                label: const Text('List a property'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavLink extends StatelessWidget {
  const _NavLink(
      {required this.label, required this.selected, required this.onTap});
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6),
      child: TextButton(
        onPressed: onTap,
        style: TextButton.styleFrom(
          foregroundColor: selected ? AppColors.green : AppColors.ink,
        ),
        child: Text(label,
            style: TextStyle(
                fontSize: 15,
                fontWeight: selected ? FontWeight.w800 : FontWeight.w600)),
      ),
    );
  }
}

class _Tab {
  const _Tab({required this.label, required this.icon, required this.active});
  final String label;
  final IconData icon;
  final IconData active;
}
