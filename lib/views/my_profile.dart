import 'package:flutter/material.dart';
import 'package:policy_dukaan/api_service.dart';
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

  final ApiService _apiService = ApiService();
  final SessionManager _sessionManager = SessionManager();
  bool _isSaving = false;

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

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _mobileController.dispose();
    super.dispose();
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

  Future<void> _saveProfile() async {
    // Validation
    if (_nameController.text.trim().isEmpty) {
      _showSnackBar('Please enter your name', Colors.red);
      return;
    }

    if (_emailController.text.trim().isEmpty) {
      _showSnackBar('Please enter your email', Colors.red);
      return;
    }

    if (_mobileController.text.trim().isEmpty) {
      _showSnackBar('Please enter your mobile number', Colors.red);
      return;
    }

    setState(() => _isSaving = true);

    try {
      final response = await _apiService.updateProfile(
        name: _nameController.text,
        email: _emailController.text,
        mobileNumber: _mobileController.text,
      );

      if (response['success'] == true) {
        // Update session data
        await _sessionManager.saveUserData({
          "name": _nameController.text.trim(),
          "email": _emailController.text.trim(),
          "mobileNumber": _mobileController.text.trim(),
        });

        setState(() {
          _initials = _getInitials(_nameController.text);
        });

        _showSnackBar('Profile updated successfully', Colors.green);
      } else {
        _showSnackBar(
          response['message'] ?? 'Failed to update profile',
          Colors.red,
        );
      }
    } catch (e) {
      _showSnackBar('Error: $e', Colors.red);
    } finally {
      setState(() => _isSaving = false);
    }
  }

  void _showSnackBar(String message, Color backgroundColor) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: backgroundColor,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  String _getInitials(String name) {
    final parts = name.trim().split(' ');
    if (parts.isEmpty || parts[0].isEmpty) return '';
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return (parts[0][0] + parts[parts.length - 1][0]).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const CustomAppBar(
        title: "My Profile",
        showBackButton: true,
        centerTitle: true,
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
            _initials.isNotEmpty ? _initials : '?',
            style: const TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.w700,
              color: AppColors.primary,
            ),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          _nameController.text.isNotEmpty
              ? _nameController.text
              : 'User Name',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          _emailController.text.isNotEmpty
              ? _emailController.text
              : 'email@example.com',
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

          PrimaryButton(
            label: _isSaving ? "Saving..." : "Save Changes",
            onPressed: _isSaving ? null : _saveProfile,
          ),
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