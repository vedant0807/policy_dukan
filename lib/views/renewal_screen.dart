import 'package:flutter/material.dart';
import 'package:policy_dukaan/widgets/custom_appbar.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../api_service.dart';
import '../utils/app_colors.dart';

class RenewalsScreen extends StatefulWidget {
  const RenewalsScreen({Key? key}) : super(key: key);

  @override
  State<RenewalsScreen> createState() => _RenewalsScreenState();
}

class _RenewalsScreenState extends State<RenewalsScreen> {
  final ApiService _apiService = ApiService();
  bool _isLoading = true;
  String? _errorMessage;

  int _dueThisWeek = 0;
  int _completed = 0;
  List<dynamic> _renewals = [];

  @override
  void initState() {
    super.initState();
    _fetchRenewals();
  }

  Future<void> _fetchRenewals() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await _apiService.getRenewals(daysAhead: 30);

      if (response['success'] == true && response['data'] != null) {
        final data = response['data'];

        setState(() {
          _dueThisWeek = data['dueThisWeek'] ?? 0;
          _completed = data['completed'] ?? 0;
          _renewals = data['renewals'] ?? [];
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = response['message'] ?? 'Failed to load renewals';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppBar(
        title: 'Renewals',
        showBackButton: true,
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _errorMessage!,
                        style: const TextStyle(color: Colors.red),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _fetchRenewals,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _fetchRenewals,
                  child: Column(
                    children: [
                      Expanded(
                        child: ListView(
                          padding: const EdgeInsets.all(16),
                          children: [
// Stats Row
                            Row(
                              children: [
                                Expanded(
                                  child: Container(
                                    padding: const EdgeInsets.all(20),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFFFF8E5),
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          '$_dueThisWeek',
                                          style: const TextStyle(
                                            fontSize: 22,
                                            fontWeight: FontWeight.w600,
                                            color: Color(0xFFFFA500),
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        const Text(
                                          'Due This Week',
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: Colors.grey,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Container(
                                    padding: const EdgeInsets.all(20),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFE8F8F5),
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          '$_completed',
                                          style: const TextStyle(
                                            fontSize: 22,
                                            fontWeight: FontWeight.w600,
                                            color: Color(0xFF00BFA5),
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        const Text(
                                          'Completed',
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: Colors.grey,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),

// Renewals List
                            if (_renewals.isEmpty)
                              const Center(
                                child: Padding(
                                  padding: EdgeInsets.all(32.0),
                                  child: Text(
                                    'No renewals due',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ),
                              )
                            else
                              ..._renewals.map((renewal) {
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 12),
                                  child: _buildRenewalCard(renewal),
                                );
                              }).toList(),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }

  Widget _buildRenewalCard(Map<String, dynamic> renewal) {
    final String customerName =
        '${renewal['customer_first_name'] ?? ''} ${renewal['customer_last_name'] ?? ''}'
            .trim();
    final String policyNumber = renewal['policy_number'] ?? 'N/A';
    final String policyType = renewal['policy_type'] ?? 'Unknown';
    final int daysLeft = renewal['days_until_expiry'] ?? 0;
    final double premium = (renewal['premium_with_gst'] ?? 0).toDouble();

// Determine status based on days left
    String status;
    Color statusColor;
    Color statusTextColor;

    if (daysLeft <= 7) {
      status = 'Urgent';
      statusColor = const Color(0xFFFFEBEE);
      statusTextColor = const Color(0xFFD32F2F);
    } else if (daysLeft <= 14) {
      status = 'Pending';
      statusColor = const Color(0xFFFFF8E5);
      statusTextColor = const Color(0xFFFFA500);
    } else {
      status = 'Review';
      statusColor = const Color(0xFFE5F0FF);
      statusTextColor = const Color(0xFF4A90E2);
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border(
          left: const BorderSide(color: Color(0xFFFFA500), width: 4),
          top: const BorderSide(color: Color(0xFFFFA500), width: 1),
          right: const BorderSide(color: Color(0xFFFFA500), width: 1),
          bottom: const BorderSide(color: Color(0xFFFFA500), width: 1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  customerName.isEmpty ? 'Unknown Customer' : customerName,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textColor1,
                  ),
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: statusColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  status,
                  style: TextStyle(
                    color: statusTextColor,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            '$policyNumber • $policyType',
            style: const TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.access_time,
                    size: 16,
                    color: Color(0xFFFFA500),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '$daysLeft ${daysLeft == 1 ? 'day' : 'days'} left',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFFFFA500),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              Text(
                '₹${premium.toStringAsFixed(0)}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
// TODO: Navigate to renewal processing
                Fluttertoast.showToast(
                  msg: 'Process renewal for $customerName',
                  toastLength: Toast.LENGTH_SHORT,
                  gravity: ToastGravity.BOTTOM,
                  backgroundColor: Colors.black,
                  textColor: Colors.white,
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00BFA5),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: const Text(
                'Process Renewal',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
