import 'package:flutter/material.dart';
import 'package:policy_dukaan/views/tab_screen.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:policy_dukaan/views/verify_otp.dart';
import '../api_service.dart';
import '../utils/app_colors.dart';
import '../widgets/primary_button.dart';
import '../widgets/primary_text_field.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final ApiService _apiService = ApiService();

  bool isLoading = false;

  // Testing credentials
  static const String testEmail = 'test.techgigs@gmail.com';
  static const String testOtp = '123456';

  @override
  void initState() {
    super.initState();
    // Pre-fill test email for testing
    emailController.text = testEmail;
  }

  Future<void> sendOtp() async {
    final email = emailController.text.trim();

    if (email.isEmpty) {
      Fluttertoast.showToast(
        msg: 'Please enter your email address',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.black,
        textColor: Colors.white,
      );
      return;
    }

    setState(() => isLoading = true);

    final result = await _apiService.sendOtp(email: email);

    setState(() => isLoading = false);

    if (result['success']) {
      Fluttertoast.showToast(
        msg: 'OTP sent successfully!',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.green,
        textColor: Colors.white,
      );

      // Navigate to Verify OTP screen, passing the email
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => VerifyOtp(email: email), // Use actual email now
        ),
      );
    } else {
      Fluttertoast.showToast(
        msg: result['message'] ?? 'Failed to send OTP',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
    }
  }

  @override
  void dispose() {
    emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isSmall = width < 360;

    final horizontalPadding = width < 400 ? 20.0 : 48.0;
    final titleSize = isSmall ? 30.0 : 40.0;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.primary, AppColors.primaryVariant],
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Container(
              constraints: const BoxConstraints(maxWidth: 540),
              padding: EdgeInsets.symmetric(
                horizontal: horizontalPadding,
                vertical: horizontalPadding,
              ),
              decoration: BoxDecoration(
                color: AppColors.textWhite,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _logo(),
                  const SizedBox(height: 28),

                  RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: 'Policy',
                          style: TextStyle(
                            fontSize: titleSize,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary,
                          ),
                        ),
                        TextSpan(
                          text: 'Dukan',
                          style: TextStyle(
                            fontSize: titleSize,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primaryVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),

                  const Text(
                    'Welcome back! Login to your account',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Color(0xFF64748B)),
                  ),
                  const SizedBox(height: 32),


                  // Replace the const _LabeledField with this:
                  _LabeledField(
                    icon: Icons.email_outlined,
                    label: 'Email Address',
                    child: PrimaryTextField(
                      controller: emailController, // Important!
                      hintText: 'Enter your email address',
                      keyboardType: TextInputType.emailAddress,
                      prefixIcon: const Icon(Icons.email_outlined, color: Color(0xFF7C3AED)),
                    ),
                  ),

                  const SizedBox(height: 24),

                  /// Send OTP Button - now calls real API
                  PrimaryButton(
                    // onPressed: () {
                    //   Navigator.push(context, MaterialPageRoute(builder: (context) => TabScreen(initialIndex: 0,),));
                    // },
                    label: isLoading ? 'Sending...' : 'Send OTP',
                    icon: const Icon(Icons.email_outlined, size: 20, color: Colors.white),
                    onPressed: isLoading ? null : sendOtp,
                  ),

                  const SizedBox(height: 24),
                  _divider(),
                  const SizedBox(height: 20),

                  _bottomText(
                    context,
                    text: "Don't have an account? ",
                    action: 'Sign up here',
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const SignUpScreen()),
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
}

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({Key? key}) : super(key: key);

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {

  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController mobileController = TextEditingController();
  final ApiService _apiService = ApiService();

  bool isLoading = false;

  Future<void> signUp() async {
    if (isLoading) return;

    setState(() => isLoading = true);

    final result = await _apiService.signUp(
      name: nameController.text,
      email: emailController.text,
      mobileNumber: mobileController.text,
    );

    setState(() => isLoading = false);

    if (result['success']) {
      Fluttertoast.showToast(
        msg: 'Signup successful',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.green,
        textColor: Colors.white,
      );
      Navigator.pop(context); // Go back to login
    } else {
      Fluttertoast.showToast(
        msg: result['message'] ?? 'Signup failed',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final titleSize = width < 360 ? 32.0 : 42.0;
    final padding = width < 400 ? 20.0 : 48.0;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF9D4EDD), Color(0xFF5A67D8)],
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Container(
              constraints: const BoxConstraints(maxWidth: 480),
              padding: EdgeInsets.all(padding),
              decoration: BoxDecoration(
                color: const Color(0xFFE8E4F3),
                borderRadius: BorderRadius.circular(28),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _logo(),
                  const SizedBox(height: 24),

                  RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: 'Policy',
                          style: TextStyle(
                            fontSize: titleSize,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF7C3AED),
                          ),
                        ),
                        TextSpan(
                          text: 'Dukan',
                          style: TextStyle(
                            fontSize: titleSize,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF5A67D8),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),

                  const Text(
                    'Create your account and get started',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Color(0xFF64748B)),
                  ),
                  const SizedBox(height: 28),

                  _LabeledField(
                    icon: Icons.person_outline,
                    label: 'Full Name',
                    child: PrimaryTextField(
                      controller: nameController,
                      hintText: 'Enter your full name',
                      prefixIcon: const Icon(Icons.person_outline, color: Color(0xFF7C3AED)),
                    ),
                  ),                  const SizedBox(height: 20),

                  _LabeledField(
                    icon: Icons.email_outlined,
                    label: 'Email Address',
                    child: PrimaryTextField(
                      controller: emailController,
                      hintText: 'Enter your email',
                      keyboardType: TextInputType.emailAddress,
                      prefixIcon: const Icon(Icons.email_outlined, color: Color(0xFF7C3AED)),
                    ),
                  ),
                  const SizedBox(height: 20),

                  _LabeledField(
                    icon: Icons.phone_outlined,
                    label: 'Mobile Number',
                    child: PrimaryTextField(
                      controller: mobileController,
                      hintText: 'Enter 10-digit mobile number',
                      keyboardType: TextInputType.phone,
                      prefixIcon: const Icon(Icons.phone_outlined, color: Color(0xFF7C3AED)),
                    ),
                  ),
                  const SizedBox(height: 24),

                  PrimaryButton(
                    label: isLoading ? 'Please wait...' : 'Sign Up',
                    icon: const Icon(Icons.check_circle_outline, color: Colors.white),
                    onPressed: isLoading ? null : signUp,
                  ),

                  const SizedBox(height: 24),

                  _bottomText(
                    context,
                    text: 'Already have an account? ',
                    action: 'Login here',
                    onTap: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}


Widget _logo() {
  return Container(
    padding: const EdgeInsets.all(18),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.08),
          blurRadius: 18,
          offset: const Offset(0, 8),
        ),
      ],
    ),
    child: Image.asset(
      'assets/images/PDlogo.png',
      height: 40,
      width: 40,
    ),
  );
}

Widget _divider() {
  return Container(
    height: 3,
    width: 80,
    decoration: BoxDecoration(
      gradient: const LinearGradient(
        colors: [Color(0xFF7C3AED), Color(0xFF5A67D8)],
      ),
      borderRadius: BorderRadius.circular(2),
    ),
  );
}

Widget _bottomText(
    BuildContext context, {
      required String text,
      required String action,
      required VoidCallback onTap,
    }) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      Text(text, style: const TextStyle(color: Color(0xFF64748B))),
      GestureDetector(
        onTap: onTap,
        child: Text(
          action,
          style: const TextStyle(
            color: Color(0xFF5A67D8),
            fontWeight: FontWeight.w600,
            decoration: TextDecoration.underline,
          ),
        ),
      ),
    ],
  );
}

class _LabeledField extends StatelessWidget {
  final IconData icon;
  final String label;
  final Widget child;

  const _LabeledField({
    required this.icon,
    required this.label,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 18, color: const Color(0xFF7C3AED)),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1E293B),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        child,
      ],
    );
  }
}
