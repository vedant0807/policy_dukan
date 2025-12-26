import 'package:flutter/material.dart';
import 'package:policy_dukaan/widgets/custom_appbar.dart';
import 'package:policy_dukaan/utils/app_colors.dart';
import 'package:policy_dukaan/widgets/primary_button.dart';

import '../session_manager.dart';
import '../widgets/primary_text_field.dart';


class MyProfile extends StatefulWidget {
  const MyProfile({super.key});

  @override
  State<MyProfile> createState() => _MyProfileState();
}

class _MyProfileState extends State<MyProfile> {
  final SessionManager _sessionManager = SessionManager();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _mobileController = TextEditingController();

  bool _loading = true;
  String _initials = '';

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final user = await _sessionManager.getUserData();

    if (user != null) {
      final name = user['name'] ?? '';
      setState(() {
        _nameController.text = name;
        _emailController.text = user['email'] ?? '';
        _mobileController.text = user['mobileNumber'] ?? '';
        _initials = _getInitials(name);
        _loading = false;
      });
    } else {
      setState(() => _loading = false);
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
        title: "My Profile",
        showBackButton: true,centerTitle: true,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _profileHeader(),
            const SizedBox(height: 24),
            _profileForm(),
          ],
        ),
      ),
    );
  }

  // ---------------- HEADER ----------------

  Widget _profileHeader() {
    return Column(
      children: [
        Container(
          width: 90,
          height: 90,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.primary.withOpacity(0.15),
          ),
          alignment: Alignment.center,
          child: Text(
            _initials,
            style: const TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.w700,
              color: AppColors.primary,
            ),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          _nameController.text,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          _emailController.text,
          style: const TextStyle(
            fontSize: 14,
            color: Colors.grey,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  // ---------------- FORM ----------------

  Widget _profileForm() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Contact information",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 20),

          // Full name
          _label("Full Name"),
          PrimaryTextField(
            hintText: "Enter full name",
            controller: _nameController,
            prefixIcon: const Icon(Icons.person_outline),
          ),

          const SizedBox(height: 16),

          _label("Email Address"),
          PrimaryTextField(
            hintText: "Email",
            controller: _emailController,
            prefixIcon: const Icon(Icons.email_outlined),
            keyboardType: TextInputType.emailAddress,
          ),

          const SizedBox(height: 16),

          _label("Mobile Number"),
          PrimaryTextField(
            hintText: "Mobile",
            controller: _mobileController,
            prefixIcon: const Icon(Icons.phone_outlined),
            keyboardType: TextInputType.phone,
          ),

          const SizedBox(height: 24),

          PrimaryButton(label: "Save Changes", onPressed: () {

          },)

        ],
      ),
    );
  }

  Widget _label(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: Color(0xFF64748B),
        ),
      ),
    );
  }
}
