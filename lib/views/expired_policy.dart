import 'package:flutter/material.dart';
import 'package:policy_dukaan/widgets/custom_appbar.dart';

import '../utils/app_colors.dart';



class ExpiredPoliciesScreen extends StatelessWidget {
  const ExpiredPoliciesScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: "Expired Policies",centerTitle: true,showBackButton: true,),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
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
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '78',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
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
                _buildPolicyCard(
                  name: 'David Wilson',
                  policyNumber: 'POL045',
                  type: 'Health',
                  daysExpired: 35,
                  amount: '₹12K',
                  priority: 'High',
                  priorityColor: const Color(0xFFFFE5E5),
                  priorityTextColor: const Color(0xFFE63946),
                ),
                const SizedBox(height: 12),
                _buildPolicyCard(
                  name: 'Emma Johnson',
                  policyNumber: 'POL032',
                  type: 'Car',
                  daysExpired: 50,
                  amount: '₹9.5K',
                  priority: 'Medium',
                  priorityColor: const Color(0xFFFFF8E5),
                  priorityTextColor: const Color(0xFFFFA500),
                ),
                const SizedBox(height: 12),
                _buildPolicyCard(
                  name: 'Frank Miller',
                  policyNumber: 'POL028',
                  type: 'Life',
                  daysExpired: 91,
                  amount: '₹22K',
                  priority: 'Low',
                  priorityColor: const Color(0xFFE5F0FF),
                  priorityTextColor: const Color(0xFF4A90E2),
                ),
              ],
            ),
          ),
        ],
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
                Text(
                  name,
                  style:  TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textColor1
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
            Container(
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
          ],
        ),
      ),
    );
  }

}