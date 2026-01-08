import 'package:flutter/material.dart';
import 'package:policy_dukaan/api_service.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:policy_dukaan/session_manager.dart';
import 'package:policy_dukaan/widgets/custom_appbar.dart';
import '../utils/app_colors.dart';
import 'dart:math' as math;
import 'package:razorpay_flutter/razorpay_flutter.dart';

class PlansScreen extends StatefulWidget {
  const PlansScreen({Key? key}) : super(key: key);

  @override
  State<PlansScreen> createState() => _PlansScreenState();
}

class _PlansScreenState extends State<PlansScreen>
    with TickerProviderStateMixin {
  late AnimationController _waveController1;
  late AnimationController _waveController2;
  late AnimationController _waveController3;
  late AnimationController _colorController;
  late Animation<Color?> _colorAnimation1;
  late Animation<Color?> _colorAnimation2;
  late Razorpay _razorpay;

  final SessionManager _sessionManager = SessionManager();
  final ApiService _apiService = ApiService();
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _mobileController = TextEditingController();
  final _addressController = TextEditingController();
  final _gstController = TextEditingController();
  String? _selectedState;

  // Plan state variables
  bool _isLoadingPlan = true;
  bool _hasActivePlan = false;
  Map<String, dynamic>? _currentPlan;

  final List<String> _indianStates = [
    'Andhra Pradesh', 'Arunachal Pradesh', 'Assam', 'Bihar', 'Chhattisgarh',
    'Goa', 'Gujarat', 'Haryana', 'Himachal Pradesh', 'Jharkhand', 'Karnataka',
    'Kerala', 'Madhya Pradesh', 'Maharashtra', 'Manipur', 'Meghalaya',
    'Mizoram', 'Nagaland', 'Odisha', 'Punjab', 'Rajasthan', 'Sikkim',
    'Tamil Nadu', 'Telangana', 'Tripura', 'Uttar Pradesh', 'Uttarakhand',
    'West Bengal',
  ];

  @override
  void initState() {
    super.initState();
    _fetchCurrentPlan();
    _initializeRazorpay();
    _initializeAnimations();
  }

  void _initializeRazorpay() {
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  void _initializeAnimations() {
    _waveController1 = AnimationController(
        duration: const Duration(seconds: 8),
        vsync: this
    )..repeat();

    _waveController2 = AnimationController(
        duration: const Duration(seconds: 6),
        vsync: this
    )..repeat();

    _waveController3 = AnimationController(
        duration: const Duration(seconds: 10),
        vsync: this
    )..repeat();

    _colorController = AnimationController(
        duration: const Duration(seconds: 8),
        vsync: this
    )..repeat();

    _colorAnimation1 = TweenSequence<Color?>([
      TweenSequenceItem(
          tween: ColorTween(
              begin: const Color(0xFF7C4DFF),
              end: const Color(0xFF5E92F3)
          ),
          weight: 1
      ),
      TweenSequenceItem(
          tween: ColorTween(
              begin: const Color(0xFF5E92F3),
              end: const Color(0xFFAA5CC3)
          ),
          weight: 1
      ),
      TweenSequenceItem(
          tween: ColorTween(
              begin: const Color(0xFFAA5CC3),
              end: const Color(0xFF7C4DFF)
          ),
          weight: 1
      ),
    ]).animate(_colorController);

    _colorAnimation2 = TweenSequence<Color?>([
      TweenSequenceItem(
          tween: ColorTween(
              begin: const Color(0xFF9575CD),
              end: const Color(0xFFAA5CC3)
          ),
          weight: 1
      ),
      TweenSequenceItem(
          tween: ColorTween(
              begin: const Color(0xFFAA5CC3),
              end: const Color(0xFF7BB3FF)
          ),
          weight: 1
      ),
      TweenSequenceItem(
          tween: ColorTween(
              begin: const Color(0xFF7BB3FF),
              end: const Color(0xFF9575CD)
          ),
          weight: 1
      ),
    ]).animate(_colorController);
  }

  Future<void> _fetchCurrentPlan() async {
    try {
      final token = await _sessionManager.getToken();
      debugPrint('Fetching current plan...');

      final data = await _apiService.fetchCurrentPlan(token!);

      setState(() {
        _isLoadingPlan = false;
        if (data != null && data['planId'] != null) {
          _hasActivePlan = true;
          _currentPlan = data;
        } else {
          _hasActivePlan = false;
        }
      });
    } catch (e) {
      debugPrint('Error fetching plan: $e');
      setState(() {
        _isLoadingPlan = false;
        _hasActivePlan = false;
      });
    }
  }

  @override
  void dispose() {
    _waveController1.dispose();
    _waveController2.dispose();
    _waveController3.dispose();
    _colorController.dispose();
    _razorpay.clear();
    _nameController.dispose();
    _emailController.dispose();
    _mobileController.dispose();
    _addressController.dispose();
    _gstController.dispose();
    super.dispose();
  }

  Future<String?> _createRazorpayOrder() async {
    try {
      final token = await _sessionManager.getToken();
      return await _apiService.createRazorpayOrder(token!, 10000);
    } catch (e) {
      if (mounted) {
        Fluttertoast.showToast(
          msg: 'Error: ${e.toString()}',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: AppColors.error,
          textColor: Colors.white,
        );
      }
      return null;
    }
  }

  Future<void> _createInvoice() async {
    try {
      final token = await _sessionManager.getToken();
      await _apiService.createInvoice(
          token!,
        planId: 'yearly',
        name: _nameController.text,
        email: _emailController.text,
        mobileNumber: _mobileController.text,
        address: _addressController.text,
        gstNumber: _gstController.text,
        state: _selectedState ?? '',
      );
    } catch (e) {
      if (mounted) {
        Fluttertoast.showToast(
          msg: 'Invoice Error: ${e.toString()}',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.orange,
          textColor: Colors.white,
        );
      }
    }
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    Fluttertoast.showToast(
      msg: 'Payment Successful! ID: ${response.paymentId}',
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: AppColors.success,
      textColor: Colors.white,
    );
    _fetchCurrentPlan();
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    Fluttertoast.showToast(
      msg: 'Payment Failed: ${response.message}',
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: AppColors.error,
      textColor: Colors.white,
    );
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    Fluttertoast.showToast(
      msg: 'External Wallet: ${response.walletName}',
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: Colors.black,
      textColor: Colors.white,
    );
  }

  Future<void> _openCheckout({bool skipInvoice = false}) async {
    final orderId = await _createRazorpayOrder();
    if (orderId == null) return;

    if (!skipInvoice) await _createInvoice();

    var options = {
      'key': 'rzp_test_xmoTkQyHp0cExq',
      'amount': 1000000,
      'order_id': orderId,
      'name': 'Policy Dukaan',
      'description': 'Annual Plan Subscription',
      'prefill': {
        'contact': _mobileController.text.isNotEmpty
            ? _mobileController.text
            : '9999999999',
        'email': _emailController.text.isNotEmpty
            ? _emailController.text
            : 'test@example.com'
      },
      'theme': {'color': '#7C4DFF'}
    };

    try {
      _razorpay.open(options);
    } catch (e) {
      debugPrint('Error: $e');
    }
  }

  void _showInvoiceDialog() {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 500),
          padding: const EdgeInsets.all(24),
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                          'Invoice Details (Optional)',
                          style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textColor1
                          )
                      ),
                      IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => Navigator.pop(context),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints()
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  _buildTextField('Name', _nameController, 'Enter name'),
                  const SizedBox(height: 16),
                  _buildTextField('Email', _emailController, 'Enter email'),
                  const SizedBox(height: 16),
                  _buildTextField(
                      'Mobile Number',
                      _mobileController,
                      'Enter mobile number',
                      keyboardType: TextInputType.phone
                  ),
                  const SizedBox(height: 16),
                  _buildTextField('Address', _addressController, 'Enter billing address'),
                  const SizedBox(height: 16),
                  _buildTextField(
                      'GST Number',
                      _gstController,
                      'Enter GST number (if applicable)'
                  ),
                  const SizedBox(height: 16),
                  const Text(
                      'State',
                      style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textColor1
                      )
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    value: _selectedState,
                    decoration: InputDecoration(
                      hintText: 'Select State',
                      filled: true,
                      fillColor: AppColors.background,
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide.none
                      ),
                    ),
                    items: _indianStates
                        .map((state) => DropdownMenuItem(
                        value: state,
                        child: Text(state)
                    ))
                        .toList(),
                    onChanged: (val) => setState(() => _selectedState = val),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            Navigator.pop(context);
                            _openCheckout(skipInvoice: true);
                          },
                          style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              side: const BorderSide(color: AppColors.primary)
                          ),
                          child: const Text(
                              'Skip',
                              style: TextStyle(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w600
                              )
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context);
                            _openCheckout();
                          },
                          style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              padding: const EdgeInsets.symmetric(vertical: 14)
                          ),
                          child: const Text(
                              'Continue',
                              style: TextStyle(fontWeight: FontWeight.w600)
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
      String label,
      TextEditingController controller,
      String hint,
      {TextInputType? keyboardType}
      ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
            label,
            style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.textColor1
            )
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            hintText: hint,
            filled: true,
            fillColor: AppColors.background,
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide.none
            ),
          ),
        ),
      ],
    );
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null) return 'N/A';
    try {
      final date = DateTime.parse(dateStr);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return dateStr;
    }
  }

  Widget _buildCurrentPlanCard() {
    return Container(
      constraints: const BoxConstraints(maxWidth: 400),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 10)
          )
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.green.shade200)
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.check_circle, color: Colors.green.shade600, size: 20),
                const SizedBox(width: 8),
                Text(
                    'ACTIVE PLAN',
                    style: TextStyle(
                        color: Colors.green.shade700,
                        fontSize: 12,
                        fontWeight: FontWeight.w700
                    )
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Text(
              _currentPlan?['planId'] == 'yearly' ? 'Annual Plan' : 'Current Plan',
              style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary
              )
          ),
          const SizedBox(height: 32),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.05),
                borderRadius: BorderRadius.circular(16)
            ),
            child: Column(
              children: [
                _buildPlanRow('Started On', _formatDate(_currentPlan?['startDate'])),
                const SizedBox(height: 16),
                _buildPlanRow('Expires On', _formatDate(_currentPlan?['endDate'])),
              ],
            ),
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: _showInvoiceDialog,
              style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  side: const BorderSide(color: AppColors.primary, width: 2)
              ),
              child: const Text(
                  'RENEW PLAN',
                  style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary
                  )
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlanRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
            label,
            style: const TextStyle(fontSize: 14, color: AppColors.textColor2)
        ),
        Text(
            value,
            style: const TextStyle(
                fontSize: 14,
                color: AppColors.textColor1,
                fontWeight: FontWeight.w600
            )
        ),
      ],
    );
  }

  Widget _buildPurchasePlanCard() {
    return Container(
      constraints: const BoxConstraints(maxWidth: 400),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 10)
          )
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                  'Annual Plan',
                  style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary
                  )
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(20)
                ),
                child: const Text(
                    'POPULAR',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w700
                    )
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
          const Text(
              '₹10000',
              style: TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary
              )
          ),
          const Text(
              'PER YEAR (INCLUDING GST)',
              style: TextStyle(fontSize: 12, color: AppColors.textColor2)
          ),
          const SizedBox(height: 32),
          Container(
            padding: const EdgeInsets.only(left: 16),
            decoration: const BoxDecoration(
                border: Border(left: BorderSide(color: AppColors.primary, width: 3))
            ),
            child: Column(
              children: [
                _buildFeatureItem('Full access to all features'),
                const SizedBox(height: 16),
                _buildFeatureItem('Unlimited policy renewals'),
                const SizedBox(height: 16),
                _buildFeatureItem('Premium support'),
                const SizedBox(height: 16),
                _buildFeatureItem('Annual billing'),
              ],
            ),
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _showInvoiceDialog,
              style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 14)
              ),
              child: const Text(
                  'PURCHASE PLAN',
                  style: TextStyle(fontWeight: FontWeight.w700)
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
          title: "Plans",
          centerTitle: true,
          showBackButton: true
      ),
      body: AnimatedBuilder(
        animation: _colorController,
        builder: (context, child) {
          return Stack(
            children: [
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      _colorAnimation1.value ?? AppColors.primary,
                      _colorAnimation2.value ?? AppColors.primaryVariant
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
              ),
              ...List.generate(3, (i) {
                final controllers = [
                  _waveController1,
                  _waveController2,
                  _waveController3
                ];
                final opacities = [0.05, 0.08, 0.06];
                final heights = [40.0, 60.0, 50.0];
                final offsets = [0.0, 100.0, 200.0];
                return AnimatedBuilder(
                  animation: controllers[i],
                  builder: (context, child) => CustomPaint(
                    painter: WavePainter(
                      animationValue: controllers[i].value,
                      color: Colors.white.withOpacity(opacities[i]),
                      waveHeight: heights[i],
                      offset: offsets[i],
                    ),
                    child: Container(),
                  ),
                );
              }),
              Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: _isLoadingPlan
                      ? const CircularProgressIndicator(color: Colors.white)
                      : _hasActivePlan
                      ? _buildCurrentPlanCard()
                      : _buildPurchasePlanCard(),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildFeatureItem(String text) {
    return Row(
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.15),
              shape: BoxShape.circle
          ),
          child: const Icon(Icons.check, color: AppColors.primary, size: 16),
        ),
        const SizedBox(width: 12),
        Expanded(
            child: Text(
                text,
                style: const TextStyle(
                    fontSize: 15,
                    color: AppColors.textColor1,
                    fontWeight: FontWeight.w500
                )
            )
        ),
      ],
    );
  }
}

class WavePainter extends CustomPainter {
  final double animationValue;
  final Color color;
  final double waveHeight;
  final double offset;

  WavePainter({
    required this.animationValue,
    required this.color,
    required this.waveHeight,
    required this.offset
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    final path = Path();
    final waveWidth = size.width;
    final waveOffset = animationValue * waveWidth;

    path.moveTo(0, size.height / 2 + offset);
    for (double i = 0; i <= size.width; i++) {
      path.lineTo(
          i,
          size.height / 2 + offset +
              math.sin((i / waveWidth * 2 * math.pi) +
                  (waveOffset / waveWidth * 2 * math.pi)) * waveHeight
      );
    }
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(WavePainter oldDelegate) =>
      oldDelegate.animationValue != animationValue;
}