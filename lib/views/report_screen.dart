import 'package:flutter/material.dart';
import 'package:policy_dukaan/utils/app_colors.dart';
import 'package:policy_dukaan/widgets/custom_appbar.dart';
import 'package:policy_dukaan/widgets/primary_button.dart';



class ReportsScreen extends StatelessWidget {
  const ReportsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(backgroundColor: Colors.white,
      appBar: CustomAppBar(title: "Reports",showBackButton: true,),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _buildReportCategory(
                        icon: Icons.description,
                        title: 'Policy',
                        count: 4,
                        color: AppColors.primary
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildReportCategory(
                        icon: Icons.bar_chart,
                        title: 'Financial',
                        count: 4,
                        color: const Color(0xFF00BFA5),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildReportCategory(
                        icon: Icons.pie_chart,
                        title: 'Customer',
                        count: 4,
                        color: AppColors.orange,
                    )),
                  ],
                ),
                const SizedBox(height: 24),
                const Text(
                  'Recent Reports',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color:AppColors.textColor1
                  ),
                ),
                const SizedBox(height: 16),
                _buildReportItem(
                  title: 'Monthly Summary - July',
                  category: 'Policy',
                  date: 'Aug 1',
                ),
                const SizedBox(height: 12),
                _buildReportItem(
                  title: 'Commission Q2',
                  category: 'Financial',
                  date: 'Jul 30',
                ),
                const SizedBox(height: 12),
                _buildReportItem(
                  title: 'Customer Retention',
                  category: 'Customer',
                  date: 'Jul 28',
                ),
                const SizedBox(height: 24),
               PrimaryButton(label: "Genrate New Report", onPressed: () {

               },)
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReportCategory({
    required IconData icon,
    required String title,
    required int count,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              icon,
              color: Colors.white,
              size: 32,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textColor1,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '$count reports',
            style:  TextStyle(
              fontSize: 14,
              color: AppColors.textColor2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReportItem({
    required String title,
    required String category,
    required String date,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF5F5F5),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.description_outlined,
              color: Colors.grey,
              size: 28,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textColor1,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$category • $date',
                  style: const TextStyle(
                    fontSize: 14,
                    color:AppColors.textColor2,
                  ),
                ),
              ],
            ),
          ),
          const Icon(
            Icons.download_sharp,
            color:AppColors.primary,
            size: 24,
          ),
        ],
      ),
    );
  }

}