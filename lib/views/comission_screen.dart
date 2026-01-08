import 'package:flutter/material.dart';
import 'package:policy_dukaan/api_service.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:policy_dukaan/widgets/custom_appbar.dart';
import '../utils/app_colors.dart';

class CommissionsScreen extends StatefulWidget {
  const CommissionsScreen({Key? key}) : super(key: key);

  @override
  State<CommissionsScreen> createState() => _CommissionsScreenState();
}

class _CommissionsScreenState extends State<CommissionsScreen> {
  final ApiService _apiService = ApiService();

  bool isLoading = false;
  Map<String, dynamic> stats = {};
  List<dynamic> commissions = [];

  @override
  void initState() {
    super.initState();
    loadCommissions();
  }

  Future<void> loadCommissions() async {
    setState(() => isLoading = true);

    final response = await _apiService.getCommissions();

    if (response['success'] == true) {
      setState(() {
        stats = response['stats'] ?? {};
        commissions = response['items'] ?? [];
      });
    } else {
      Fluttertoast.showToast(
        msg: response['message'] ?? 'Failed to load commissions',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
    }

    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: "Commission Management",
        centerTitle: false,
        showBackButton: true,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // -------- STATS --------
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    icon: Icons.attach_money,
                    title: 'Total Earned',
                    value: '₹${stats['totalCommission']?.toStringAsFixed(2) ?? '0'}',
                    subtitle: 'All time earnings',
                    gradient: const LinearGradient(
                      colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    icon: Icons.calendar_today,
                    title: 'This Month',
                    value: '₹${stats['monthCommission']?.toStringAsFixed(2) ?? '0'}',
                    subtitle: 'Current month earnings',
                    gradient: const LinearGradient(
                      colors: [Color(0xFF00BFA5), Color(0xFF00D4AA)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    icon: Icons.account_balance_wallet,
                    title: 'Total Premium',
                    value: '₹${stats['totalPremium'] ?? 0}',
                    subtitle: 'Business Generated',
                    gradient: const LinearGradient(
                      colors: [Color(0xFFFFA726), Color(0xFFFFB74D)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    icon: Icons.description,
                    title: 'Policies',
                    value: '${stats['totalPolicies'] ?? 0}',
                    subtitle: 'Total Sold',
                    gradient: const LinearGradient(
                      colors: [Color(0xFFEC407A), Color(0xFFF06292)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 32),

            // -------- COMMISSION LIST --------
            const Text(
              'Commission Details',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: AppColors.textColor1,
              ),
            ),
            const SizedBox(height: 16),

            commissions.isEmpty
                ? const Center(child: Text("No commissions found"))
                : ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: commissions.length,
              itemBuilder: (context, index) {
                final item = commissions[index];

                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _buildCommissionDetailCard(
                    name: item['customerName'] ?? '',
                    policyNumber: 'Policy: ${item['policyNumber']}',
                    company: item['companyName'] ?? '',
                    premium: '₹${item['premium']}',
                    commissionRate: '${item['rate']}%',
                    date: DateTime.parse(item['policyDate'])
                        .toLocal()
                        .toString()
                        .split(' ')[0],
                    commission: '₹${item['commissionAmount']}',
                    status: item['status'] ?? '',
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  // ================= UI COMPONENTS =================

  Widget _buildStatCard({
    required IconData icon,
    required String title,
    required String value,
    required String subtitle,
    required Gradient gradient,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: Colors.white, size: 20),
        ),
        const SizedBox(height: 12),
        Text(title,
            style: const TextStyle(fontSize: 12, color: Colors.white)),
        const SizedBox(height: 4),
        Text(value,
            style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Colors.white)),
        const SizedBox(height: 2),
        Text(subtitle,
            style: TextStyle(
                fontSize: 11, color: Colors.white.withOpacity(0.9))),
      ]),
    );
  }

  Widget _buildCommissionDetailCard({
    required String name,
    required String policyNumber,
    required String company,
    required String premium,
    required String commissionRate,
    required String date,
    required String commission,
    required String status,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(name,
                  style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textColor1)),
              const SizedBox(height: 4),
              Text(policyNumber,
                  style: const TextStyle(
                      fontSize: 13, color: AppColors.textColor2)),
            ]),
          ),
          Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
            Text(commission,
                style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textColor1)),
            const SizedBox(height: 4),
            Container(
              padding:
              const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFFFE5D0),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                status,
                style: const TextStyle(
                    color: Color(0xFFFF8A3D),
                    fontSize: 11,
                    fontWeight: FontWeight.w600),
              ),
            ),
          ]),
        ]),
        const SizedBox(height: 4),
        _buildDetailItem('Company:', company),
        const SizedBox(height: 4),
        _buildDetailItem('Premium:', premium),
        const SizedBox(height: 4),
        _buildDetailItem('Commission Rate:', commissionRate),
        const SizedBox(height: 4),
        _buildDetailItem('Date:', date)

      ]),
    );
  }

  Widget _buildDetailItem(String label, String value) {
    return Row(children: [
      Text(label,
          style: const TextStyle(fontSize: 13, color: AppColors.textColor2)),
      const SizedBox(width: 4),
      Text(value,
          style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.textColor1)),
    ]);
  }
}
