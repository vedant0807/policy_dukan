import 'package:flutter/material.dart';
import 'package:policy_dukaan/utils/app_colors.dart';
import 'package:policy_dukaan/views/lead_screen.dart';
import '../session_manager.dart';
import 'add_policy_screen.dart';
import 'dashboard_screen.dart';
import 'menu_screen.dart';
import 'my_policies.dart';

class TabScreen extends StatefulWidget {
  final int initialIndex;

  const TabScreen({Key? key, this.initialIndex = 0}) : super(key: key);

  @override
  State<TabScreen> createState() => _TabScreenState();
}

class _TabScreenState extends State<TabScreen> {
  late int _currentIndex;
  final SessionManager _sessionManager = SessionManager();

  List<String> _userPermissions = [];
  String _userRole = '';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _loadUserPermissions();
  }

  Future<void> _loadUserPermissions() async {
    final permissions = await _sessionManager.getUserPermissions();
    final role = await _sessionManager.getUserRole();

    print('📋 User Permissions: $permissions');
    print('👤 User Role: $role');

    setState(() {
      _userPermissions = permissions;
      _userRole = role ?? '';
      _isLoading = false;
    });
  }

  // ✅ Check if user has permission or is admin
  bool _hasAccess(String permission) {
    // Admin/Owner has access to everything
    if (_userRole == 'admin' || _userRole == 'owner') {
      return true;
    }

    // Staff can only access what's in their permissions
    return _userPermissions.contains(permission);
  }

  // ✅ Build filtered screens based on permissions
  List<Widget> get _availableScreens {
    List<Widget> screens = [];

    // Home is always visible
    screens.add(const DashboardScreen());

    // Policies - check 'policies' permission
    if (_hasAccess('policies')) {
      screens.add(PoliciesScreen());
    }

    // Leads - check 'leads' permission
    if (_hasAccess('leads')) {
      screens.add(LeadsScreen());
    }

    // Add Policy/Customers - check 'customers' permission
    if (_hasAccess('customers')) {
      screens.add(AddPolicyScreen());
    }

    // More is always visible
    screens.add(const MenuScreen());

    return screens;
  }

  // ✅ Build filtered nav items based on permissions
  List<Map<String, dynamic>> get _availableNavItems {
    List<Map<String, dynamic>> items = [];

    // Home is always visible
    items.add({
      'icon': Icons.dashboard,
      'label': 'Home',
    });

    // Policies - check 'policies' permission
    if (_hasAccess('policies')) {
      items.add({
        'icon': Icons.folder,
        'label': 'Policies',
      });
    }

    // Leads - check 'leads' permission
    if (_hasAccess('leads')) {
      items.add({
        'icon': Icons.people,
        'label': 'Leads',
      });
    }

    // Add Policy - check 'customers' permission
    if (_hasAccess('customers')) {
      items.add({
        'icon': Icons.description,
        'label': 'Add Policy',
      });
    }

    // More is always visible
    items.add({
      'icon': Icons.more_horiz,
      'label': 'More',
    });

    return items;
  }

  void _onItemTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    final screens = _availableScreens;
    final navItems = _availableNavItems;

    return Scaffold(
      body: screens[_currentIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(navItems.length, (index) {
                final item = navItems[index];
                final bool isActive = _currentIndex == index;

                return Expanded(
                  child: NavBarItem(
                    icon: item['icon'],
                    label: item['label'],
                    isActive: isActive,
                    onTap: () => _onItemTapped(index),
                  ),
                );
              }),
            ),
          ),
        ),
      ),
    );
  }
}

class NavBarItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const NavBarItem({
    Key? key,
    required this.icon,
    required this.label,
    required this.isActive,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isActive ? AppColors.navActive : Colors.grey[600],
              size: 26,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                color: isActive ? AppColors.navActive : Colors.grey[600],
                fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}