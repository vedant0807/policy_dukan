import 'package:flutter/material.dart';
import 'package:policy_dukaan/widgets/custom_appbar.dart';

import '../utils/app_colors.dart';


class RenewalsScreen extends StatelessWidget {
  const RenewalsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(backgroundColor: Colors.white,
      appBar: CustomAppBar(title: 'Renewals',showBackButton: true,centerTitle: true,),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFF8E5),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '15',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFFFFA500),
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
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
                        child: const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '32',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF00BFA5),
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
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
                _buildRenewalCard(
                  name: 'Grace Taylor',
                  policyNumber: 'POL056',
                  type: 'Health',
                  daysLeft: '6 days left',
                  amount: '₹16.5K',
                  status: 'Pending',
                  statusColor: const Color(0xFFFFF8E5),
                  statusTextColor: const Color(0xFFFFA500),
                  borderColor: const Color(0xFFFFA500),
                ),
                const SizedBox(height: 12),
                _buildRenewalCard(
                  name: 'Henry Brown',
                  policyNumber: 'POL043',
                  type: 'Car',
                  daysLeft: '8 days left',
                  amount: '₹9.2K',
                  status: 'Review',
                  statusColor: const Color(0xFFE5F0FF),
                  statusTextColor: const Color(0xFF4A90E2),
                  borderColor: const Color(0xFFFFA500),
                ),
                const SizedBox(height: 12),
                _buildRenewalCard(
                  name: 'Isabel Davis',
                  policyNumber: 'POL029',
                  type: 'Life',
                  daysLeft: '11 days left',
                  amount: '₹26K',
                  status: 'Ready',
                  statusColor: const Color(0xFFE8F8F5),
                  statusTextColor: const Color(0xFF00BFA5),
                  borderColor: const Color(0xFFFFA500),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRenewalCard({
    required String name,
    required String policyNumber,
    required String type,
    required String daysLeft,
    required String amount,
    required String status,
    required Color statusColor,
    required Color statusTextColor,
    required Color borderColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),border: Border(
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
              Text(
                name,
                style:  TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textColor1,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
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
            '$policyNumber • $type',
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
                    daysLeft,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFFFFA500),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
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
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {},
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