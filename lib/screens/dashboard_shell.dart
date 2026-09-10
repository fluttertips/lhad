import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tempsupabaseadmintool/providers/auth_provider.dart';
import 'package:tempsupabaseadmintool/providers/dashboard_provider.dart';
import 'package:tempsupabaseadmintool/screens/overview_screen.dart';
import 'package:tempsupabaseadmintool/screens/tasks_screen.dart';
import 'package:tempsupabaseadmintool/screens/login_screen.dart';
import 'package:tempsupabaseadmintool/theme/admin_tokens.dart';

const _wideBreakpoint = 840.0;

class _NavItem {
  final IconData icon;
  final String label;
  const _NavItem(this.icon, this.label);
}

const _navItems = [
  _NavItem(Icons.dashboard_rounded, 'Overview'),
  _NavItem(Icons.list_alt_rounded, 'Activity'),
];

class DashboardShell extends StatefulWidget {
  const DashboardShell({super.key});

  @override
  State<DashboardShell> createState() => _DashboardShellState();
}

class _DashboardShellState extends State<DashboardShell> {
  final DashboardProvider _dashboardProvider = DashboardProvider();
  int _tabIndex = 0;

  @override
  void initState() {
    super.initState();
    _dashboardProvider.load();
  }

  @override
  void dispose() {
    _dashboardProvider.dispose();
    super.dispose();
  }

  void _logout() {
    context.read<AdminAuthProvider>().logout();
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _dashboardProvider,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth >= _wideBreakpoint;
          final body = IndexedStack(
            index: _tabIndex,
            children: const [OverviewScreen(), TasksScreen()],
          );

          if (isWide) {
            return Scaffold(
              backgroundColor: AdminTokens.bg,
              body: Row(
                children: [
                  NavigationRail(
                    selectedIndex: _tabIndex,
                    onDestinationSelected: (i) => setState(() => _tabIndex = i),
                    backgroundColor: Colors.white,
                    labelType: NavigationRailLabelType.all,
                    leading: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      child: Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(color: AdminTokens.brand.withOpacity(0.12), borderRadius: BorderRadius.circular(12)),
                        alignment: Alignment.center,
                        child: const Icon(Icons.admin_panel_settings_rounded, color: AdminTokens.brand),
                      ),
                    ),
                    trailing: Expanded(
                      child: Align(
                        alignment: Alignment.bottomCenter,
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 20),
                          child: IconButton(
                            tooltip: 'Logout',
                            onPressed: _logout,
                            icon: const Icon(Icons.logout_rounded, color: AdminTokens.subtle),
                          ),
                        ),
                      ),
                    ),
                    destinations: _navItems
                        .map((d) => NavigationRailDestination(icon: Icon(d.icon), label: Text(d.label)))
                        .toList(),
                  ),
                  const VerticalDivider(width: 1, thickness: 1, color: AdminTokens.border),
                  Expanded(child: body),
                ],
              ),
            );
          }

          return Scaffold(
            backgroundColor: AdminTokens.bg,
            appBar: AppBar(
              backgroundColor: Colors.white,
              elevation: 0,
              title: Text(_navItems[_tabIndex].label,
                  style: const TextStyle(color: AdminTokens.ink, fontWeight: FontWeight.w800, fontSize: 18)),
              actions: [
                IconButton(
                  tooltip: 'Logout',
                  onPressed: _logout,
                  icon: const Icon(Icons.logout_rounded, color: AdminTokens.subtle),
                ),
              ],
            ),
            body: body,
            bottomNavigationBar: NavigationBar(
              selectedIndex: _tabIndex,
              onDestinationSelected: (i) => setState(() => _tabIndex = i),
              destinations: _navItems
                  .map((d) => NavigationDestination(icon: Icon(d.icon), label: d.label))
                  .toList(),
            ),
          );
        },
      ),
    );
  }
}
