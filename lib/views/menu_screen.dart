import 'package:flutter/material.dart';
import 'package:policy_dukaan/views/comission_screen.dart';
import 'package:policy_dukaan/views/customer_screen.dart';
import 'package:policy_dukaan/views/login_screen.dart';
import 'package:policy_dukaan/views/plans_page.dart';
import 'package:policy_dukaan/views/renewal_screen.dart';
import 'package:policy_dukaan/views/report_screen.dart';
import 'package:policy_dukaan/views/staff_management.dart';
import 'package:policy_dukaan/views/tab_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../session_manager.dart';
import '../utils/app_colors.dart';
import '../widgets/custom_appbar.dart';
import 'expired_policy.dart';
import 'my_company.dart';
import 'my_profile.dart';

class MenuScreen extends StatefulWidget {
  const MenuScreen({Key? key}) : super(key: key);

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {

  final SessionManager _sessionManager = SessionManager();

  String _userName = '';
  String _userEmail = '';
  String _initials = '';

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final user = await _sessionManager.getUserData();

    if (user != null) {
      final name = user['name'] ?? '';
      setState(() {
        _userName = name;
        _userEmail = user['email'] ?? '';
        _initials = _getInitials(name);
      });
    }
  }

  String _getInitials(String name) {
    final parts = name.trim().split(' ');
    if (parts.isEmpty) return '';
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return (parts[0][0] + parts[1][0]).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const CustomAppBar(
        title: "More",
        centerTitle: true,
        showNotificationIcon: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildProfileCard(),
            const SizedBox(height: 20),
            _Section(
              title: "Policy Management",
              children:  [
                _OptionTile(
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => CustomersScreen(),));
                  },
                  icon: Icons.people_alt_outlined,
                  title: "Customers",
                  color: AppColors.primary,
                  background: AppColors.card1,
                ),
                _OptionTile(
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => ExpiredPoliciesScreen(),));
                  },
                  icon: Icons.event_busy_outlined,
                  title: "Expired Policies",
                  color: AppColors.error,
                  background: AppColors.card3,
                ),
                _OptionTile(
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => RenewalsScreen(),));
                  },
                  icon: Icons.autorenew_outlined,
                  title: "Renewals",
                  color: AppColors.orange,
                  background: AppColors.card2,
                ),
                _OptionTile(
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => AddCompanyScreen(),));
                  },
                  icon: Icons.work,
                  title: "Company",
                  color: AppColors.primary,
                  background: AppColors.card1,
                ),
              ],
            ),
            const SizedBox(height: 16),
            _Section(
              title: "Finance",
              children:  [
                _OptionTile(
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => CommissionsScreen(),));
                  },
                  icon: Icons.payments_outlined,
                  title: "Commissions",
                  color: AppColors.primary,
                ),
                _OptionTile(onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => PlansScreen(),));
                },
                  icon: Icons.unsubscribe_outlined,
                  title: "Plans",
                  color: AppColors.secondary,
                ),
                _OptionTile(onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => StaffManagement(),));
                },
                  icon: Icons.people_alt_rounded,
                  title: "Staff Management",
                  color: AppColors.error,
                ),
              ],
            ),
            const SizedBox(height: 16),
            _Section(
              title: "Settings",
              children: const [
                _OptionTile(
                  icon: Icons.security_outlined,
                  title: "Security",
                  color: AppColors.teal,
                ),
                _OptionTile(
                  icon: Icons.tune_outlined,
                  title: "Preferences",
                  color: AppColors.secondary,
                ),
                _OptionTile(
                  icon: Icons.support_agent_outlined,
                  title: "Help & Support",
                  color: AppColors.teal,
                ),
              ],
            ),
            const SizedBox(height: 16),
            const _LogoutTile(),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileCard() {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const MyProfile()),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 22,
              backgroundColor: AppColors.primary.withOpacity(0.15),
              child: Text(
                _initials.isNotEmpty ? _initials : '--',
                style: const TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _userName.isNotEmpty ? _userName : 'User',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Colors.black87,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _userEmail.isNotEmpty ? _userEmail : '',
                    style: const TextStyle(
                      fontSize: 13,
                      color: Colors.grey,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Section extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _Section({
    Key? key,
    required this.title,
    required this.children,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title.toUpperCase(),
          style: const TextStyle(
            fontSize: 12,
            color: Colors.grey,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 10),
        ...children.map((child) => Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: child,
        )),
      ],
    );
  }
}

class _OptionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color color;
  final Color? background;
  final VoidCallback? onTap;

  const _OptionTile({
    Key? key,
    required this.icon,
    required this.title,
    required this.color,
    this.background,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: background ?? Colors.white,
            borderRadius: BorderRadius.circular(14),
            boxShadow: background == null
                ? [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ]
                : null,
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Icon(icon, color: color),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
              ),
              const Icon(Icons.chevron_right, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }
}

class _LogoutTile extends StatelessWidget {
  const _LogoutTile();

  Future<void> _logout(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const LoginScreen()),
          (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        showDialog(
          context: context,
          builder: (_) => AlertDialog(backgroundColor: Colors.white,
            title: const Text("Logout"),
            content: const Text("Are you sure you want to logout?"),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Cancel"),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  _logout(context);
                },
                child: const Text(
                  "Logout",
                  style: TextStyle(color: AppColors.error),
                ),
              ),
            ],
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.error.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.logout, color: AppColors.error),
            ),
            const SizedBox(width: 14),
            const Expanded(
              child: Text(
                "Log Out",
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppColors.error,
                ),
              ),
            ),
            const Icon(Icons.chevron_right, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}
