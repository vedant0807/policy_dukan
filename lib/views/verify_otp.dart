import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:policy_dukaan/views/tab_screen.dart';
import '../api_service.dart';
import '../session_manager.dart';
import '../utils/app_colors.dart';
import '../widgets/primary_button.dart';

class VerifyOtp extends StatefulWidget {
  final String email;
  const VerifyOtp({Key? key, required this.email}) : super(key: key);

  @override
  State<VerifyOtp> createState() => _VerifyOtpState();
}

class _VerifyOtpState extends State<VerifyOtp> {
  static const int otpLength = 6;
  late final List<TextEditingController> controllers;
  late final List<FocusNode> focusNodes;

  final ApiService _apiService = ApiService();
  final SessionManager _sessionManager = SessionManager();
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    controllers = List.generate(otpLength, (_) => TextEditingController());
    focusNodes = List.generate(otpLength, (_) => FocusNode());
  }

  @override
  void dispose() {
    for (final c in controllers) c.dispose();
    for (final f in focusNodes) f.dispose();
    super.dispose();
  }

  void onOtpChanged(String value, int index) {
    if (value.isNotEmpty && index < otpLength - 1) {
      focusNodes[index + 1].requestFocus();
    }
    if (value.isEmpty && index > 0) {
      focusNodes[index - 1].requestFocus();
    }
  }

  String get otp => controllers.map((e) => e.text).join();

  Future<void> verifyOtp() async {
    final enteredOtp = otp;

    if (enteredOtp.length != otpLength) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter the complete 6-digit OTP')),
      );
      return;
    }

    setState(() => isLoading = true);

    final result = await _apiService.verifyOtp(
      email: widget.email,
      otp: enteredOtp,
    );

    setState(() => isLoading = false);

    if (result['success']) {
      print('🎉 OTP Verification Successful!');

      // Extract token and user data
      final token = result['token'];
      final user = result['user'];

      if (token != null && user != null) {
        // Save session using SessionManager
        final sessionSaved = await _sessionManager.saveLoginSession(
          token: token,
          user: user,
        );

        if (sessionSaved) {
          print('✅ Session saved successfully!');

          // Show success message
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(result['message'] ?? 'Login successful'),
                backgroundColor: Colors.green,
              ),
            );
          }

          // Navigate to main app (TabScreen)
          if (mounted) {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                builder: (context) => const TabScreen(initialIndex: 0),
              ),
                  (route) => false, // Removes all previous routes
            );
          }
        } else {
          print('❌ Failed to save session');
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Failed to save login session'),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      } else {
        print('❌ Token or user data is missing in response');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Invalid response from server'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } else {
      print('❌ OTP Verification Failed: ${result['message']}');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message'] ?? 'OTP verification failed'),
            backgroundColor: Colors.red.shade600,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.primary, AppColors.primaryVariant],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Container(
                constraints: const BoxConstraints(maxWidth: 420),
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppColors.textWhite,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildLogo(),
                    const SizedBox(height: 20),
                    _buildTitle(),
                    const SizedBox(height: 8),
                    const Text(
                      'Verify your OTP',
                      style: TextStyle(color: Color(0xFF64748B)),
                    ),
                    const SizedBox(height: 16),
                    _buildEmail(widget.email),
                    const SizedBox(height: 24),
                    _buildOtpFields(),
                    const SizedBox(height: 12),
                    const Text(
                      'Enter the 6-digit code sent to your email',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
                    ),
                    const SizedBox(height: 24),
                    PrimaryButton(
                      label: isLoading ? 'Verifying...' : 'Verify OTP',
                      icon: const Icon(Icons.check_circle_outline, color: Colors.white),
                      onPressed: isLoading ? null : verifyOtp,
                    ),
                    const SizedBox(height: 12),
                    PrimaryButton(
                      label: 'Change Email',
                      isOutlined: true,
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ---------------- UI WIDGETS ----------------
  Widget _buildLogo() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Image.asset('assets/images/PDlogo.png', height: 40, width: 40),
    );
  }

  Widget _buildTitle() {
    return RichText(
      text: const TextSpan(
        children: [
          TextSpan(
            text: 'Policy',
            style: TextStyle(
              fontSize: 34,
              fontWeight: FontWeight.w600,
              color: AppColors.primary,
            ),
          ),
          TextSpan(
            text: 'Dukan',
            style: TextStyle(
              fontSize: 34,
              fontWeight: FontWeight.w600,
              color: AppColors.primaryVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmail(String email) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.email_outlined, size: 16, color: Color(0xFF7C3AED)),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              email,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Color(0xFF7C3AED),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOtpFields() {
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 8,
      runSpacing: 8,
      children: List.generate(otpLength, (index) {
        return SizedBox(
          width: 48,
          height: 56,
          child: TextField(
            controller: controllers[index],
            focusNode: focusNodes[index],
            maxLength: 1,
            textAlign: TextAlign.center,
            keyboardType: TextInputType.number,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            decoration: InputDecoration(
              contentPadding: EdgeInsets.all(1),
              counterText: '',
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFF7C3AED), width: 2),
              ),
            ),
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            onChanged: (v) => onOtpChanged(v, index),
          ),
        );
      }),
    );
  }
}