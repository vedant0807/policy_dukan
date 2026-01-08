import 'package:flutter/material.dart';
import 'package:policy_dukaan/widgets/custom_appbar.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:policy_dukaan/utils/app_colors.dart';
import 'package:policy_dukaan/api_service.dart';
import 'package:url_launcher/url_launcher.dart';

import '../widgets/custom_searchbar.dart';

class ExpiredPoliciesScreen extends StatefulWidget {
  const ExpiredPoliciesScreen({Key? key}) : super(key: key);

  @override
  State<ExpiredPoliciesScreen> createState() => _ExpiredPoliciesScreenState();
}

class _ExpiredPoliciesScreenState extends State<ExpiredPoliciesScreen> {
  final ApiService _apiService = ApiService();
  List<dynamic> _expiredPolicies = [];
  bool _isLoading = true;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadExpiredPolicies();
  }

  Future<void> _loadExpiredPolicies() async {
    setState(() {
      _isLoading = true;
    });

    final result = await _apiService.getExpiredPolicies();

    if (result['success']) {
      setState(() {
        _expiredPolicies = result['data'] as List<dynamic>;
        _isLoading = false;
      });
    } else {
      setState(() {
        _isLoading = false;
      });
    }
  }

  int _calculateDaysExpired(String? endDate) {
    if (endDate == null || endDate.isEmpty) return 0;

    try {
      final policyEndDate = DateTime.parse(endDate);
      final now = DateTime.now();
      final difference = now.difference(policyEndDate);
      return difference.inDays > 0 ? difference.inDays : 0;
    } catch (e) {
      return 0;
    }
  }

  String _getPriorityLevel(int daysExpired) {
    if (daysExpired <= 30) return 'High';
    if (daysExpired <= 60) return 'Medium';
    return 'Low';
  }

  Color _getPriorityColor(String priority) {
    switch (priority) {
      case 'High':
        return const Color(0xFFFFE5E5);
      case 'Medium':
        return const Color(0xFFFFF8E5);
      case 'Low':
        return const Color(0xFFE5F0FF);
      default:
        return const Color(0xFFE5F0FF);
    }
  }

  Color _getPriorityTextColor(String priority) {
    switch (priority) {
      case 'High':
        return const Color(0xFFE63946);
      case 'Medium':
        return const Color(0xFFFFA500);
      case 'Low':
        return const Color(0xFF4A90E2);
      default:
        return const Color(0xFF4A90E2);
    }
  }

  String _formatAmount(dynamic amount) {
    if (amount == null) return '₹0';
    if (amount is String) {
      final num = double.tryParse(amount) ?? 0;
      return '₹${(num / 1000).toStringAsFixed(1)}K';
    }
    if (amount is num) {
      return '₹${(amount / 1000).toStringAsFixed(1)}K';
    }
    return '₹0';
  }

  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri launchUri = Uri(
      scheme: 'tel',
      path: phoneNumber,
    );

    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    } else {
      if (mounted) {
        Fluttertoast.showToast(
          msg: 'Could not launch phone dialer',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.black,
          textColor: Colors.white,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CustomAppBar(
        title: "Expired Policies",
        centerTitle: true,
        showBackButton: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
        onRefresh: _loadExpiredPolicies,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Summary Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFE63946), Color(0xFFE91E8C)],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.warning_rounded,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${_expiredPolicies.length}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Text(
                        'Expired Policies',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            CustomSearchBar(
              controller: _searchController,
              hintText: 'Search Policies',
              onChanged: (value) {
                debugPrint('Searching: $value');
                // TODO: filter your list here
              },
              onClear: () {
                debugPrint('Search cleared');
              },
            ),


            // Policy Cards
            ..._expiredPolicies.map((policy) {
              final daysExpired = _calculateDaysExpired(policy['policy_end_date']);
              final priority = _getPriorityLevel(daysExpired);

              return Column(
                children: [
                  _buildPolicyCard(
                    name: '${policy['customer_first_name'] ?? ''} ${policy['customer_last_name'] ?? ''}'.trim(),
                    policyNumber: policy['policy_number'] ?? 'N/A',
                    type: policy['policy_type'] ?? 'General',
                    daysExpired: daysExpired,
                    amount: _formatAmount(policy['premium_with_gst']),
                    priority: priority,
                    priorityColor: _getPriorityColor(priority),
                    priorityTextColor: _getPriorityTextColor(priority),
                    phoneNumber: policy['mobile'] ?? '',
                  ),
                  const SizedBox(height: 12),
                ],
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildPolicyCard({
    required String name,
    required String policyNumber,
    required String type,
    required int daysExpired,
    required String amount,
    required String priority,
    required Color priorityColor,
    required Color priorityTextColor,
    required String phoneNumber,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border(
          left: const BorderSide(color: Color(0xFFE63946), width: 4),
          top: const BorderSide(color: Color(0xFFE63946), width: 1),
          right: const BorderSide(color: Color(0xFFE63946), width: 1),
          bottom: const BorderSide(color: Color(0xFFE63946), width: 1),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    name.isEmpty ? 'Unknown Customer' : name,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textColor1,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: priorityColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    priority,
                    style: TextStyle(
                      color: priorityTextColor,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              '$policyNumber • $type',
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textColor2,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '$daysExpired days expired',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFFE63946),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  amount,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            InkWell(
              onTap: phoneNumber.isNotEmpty ? () => _makePhoneCall(phoneNumber) : null,
              borderRadius: BorderRadius.circular(8),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F8F5),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.phone_outlined,
                      color: Color(0xFF00BFA5),
                      size: 20,
                    ),
                    SizedBox(width: 8),
                    Text(
                      'Contact',
                      style: TextStyle(
                        color: Color(0xFF00BFA5),
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}