import 'package:flutter/material.dart';
import 'package:policy_dukaan/utils/app_colors.dart';
import 'package:policy_dukaan/views/add_lead.dart';
import 'package:policy_dukaan/views/tab_screen.dart';
import 'package:policy_dukaan/widgets/custom_appbar.dart';
import 'package:fl_chart/fl_chart.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  bool isLoading = true;
  Map<String, dynamic> dashboardData = {};

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    setState(() => isLoading = true);

    try {
      // TODO: Replace with your actual API calls
      // final commissionsResponse = await apiService.getCommissions();
      // final policiesResponse = await apiService.getPolicies();

      // Simulate API call
      await Future.delayed(const Duration(seconds: 1));

      // Parse your API response here
      // Example structure - adjust based on your actual API response:
      // {
      //   "commissions": [...],
      //   "policies": [
      //     {
      //       "id": "1",
      //       "type": "Life Insurance",
      //       "status": "Active",
      //       "premium": 50000,
      //       "customer_name": "John Doe",
      //       "created_at": "2025-11-15",
      //       ...
      //     }
      //   ]
      // }

      setState(() {
        dashboardData = _parseApiData();
        isLoading = false;
      });
    } catch (e) {
      print('Error loading dashboard data: $e');
      setState(() => isLoading = false);
    }
  }

  Map<String, dynamic> _parseApiData() {
    // TODO: Replace this with actual parsing from your API response
    // For now, using mock data structure

    // Parse commissions for revenue analysis
    List<Map<String, dynamic>> revenueData = _parseRevenueData();

    // Parse policies for distribution
    List<Map<String, dynamic>> policyDistribution = _parsePolicyDistribution();

    // Parse policy status
    Map<String, int> policyStatus = _parsePolicyStatus();

    // Parse customer growth
    List<Map<String, dynamic>> customerGrowth = _parseCustomerGrowth();

    // Calculate totals
    int totalPolicies = policyStatus.values.fold(0, (sum, count) => sum + count);
    int activeCustomers = policyStatus['Active'] ?? 0;
    double monthlyRevenue = revenueData.isNotEmpty ? revenueData.last['revenue'] : 0;
    int renewalsDue = 23; // Calculate from your API data

    return {
      'totalPolicies': totalPolicies,
      'activeCustomers': activeCustomers,
      'monthlyRevenue': monthlyRevenue,
      'renewalsDue': renewalsDue,
      'revenueAnalysis': revenueData,
      'policyDistribution': policyDistribution,
      'policyStatusOverview': policyStatus,
      'customerGrowth': customerGrowth,
    };
  }

  // Parse revenue data from commissions API
  List<Map<String, dynamic>> _parseRevenueData() {
    // TODO: Parse from your actual API response
    // Example: Group commissions by month and sum the amounts

    List<String> months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];

    // Mock data - replace with actual parsing
    return months.asMap().entries.map((entry) {
      int index = entry.key;
      String month = entry.value;

      // TODO: Calculate actual revenue from your API data for each month
      double revenue = index < 10 ? 0 : (index == 10 ? 15000 : 88888);

      return {
        'month': month,
        'revenue': revenue,
      };
    }).toList();
  }

  // Parse policy distribution from policies API
  List<Map<String, dynamic>> _parsePolicyDistribution() {
    // TODO: Parse from your actual API response
    // Example: Group policies by type and count them

    // Mock data - replace with actual parsing
    // Count policies by type from your API response
    Map<String, int> typeCounts = {
      'Life Insurance': 800,
      'Health Insurance': 250,
      'Car Insurance': 184,
      'Home Insurance': 120,
      'Term Insurance': 95,
    };

    int total = typeCounts.values.fold(0, (sum, count) => sum + count);

    return typeCounts.entries.map((entry) {
      double percentage = (entry.value / total) * 100;
      return {
        'type': entry.key,
        'count': entry.value,
        'percentage': percentage,
      };
    }).toList();
  }

  // Parse policy status from policies API
  Map<String, int> _parsePolicyStatus() {
    // TODO: Parse from your actual API response
    // Example: Group policies by status and count them

    // Mock data - replace with actual parsing
    return {
      'Active': 987,
      'Expired': 150,
      'Pending': 75,
      'Cancelled': 22,
    };
  }

  // Parse customer growth from policies API
  List<Map<String, dynamic>> _parseCustomerGrowth() {
    // TODO: Parse from your actual API response
    // Example: Group policies by creation month and count unique customers

    List<String> months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];

    // Mock data - replace with actual parsing
    return months.asMap().entries.map((entry) {
      int index = entry.key;
      String month = entry.value;

      // TODO: Calculate cumulative customers from your API data
      int customers = index < 10 ? 0 : (index == 10 ? 1 : 5);

      return {
        'month': month,
        'customers': customers,
      };
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CustomAppBar(title: "Dashboard", centerTitle: true),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
        onRefresh: _loadDashboardData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const WelcomeCard(),
              const SizedBox(height: 16),
              StatisticsGrid(data: dashboardData),
              const SizedBox(height: 24),
              const QuickActionsSection(),
              const SizedBox(height: 24),
              RevenueAnalysisChart(
                revenueData: dashboardData['revenueAnalysis'] ?? [],
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: PolicyStatusChart(
                      statusData: dashboardData['policyStatusOverview'] ?? {},
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: PolicyDistributionChart(
                      distributionData: dashboardData['policyDistribution'] ?? [],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              CustomerGrowthChart(
                growthData: dashboardData['customerGrowth'] ?? [],
              ),
              const SizedBox(height: 24),
              const RecentActivitySection(),
              const SizedBox(height: 24),
              const UpcomingRenewalsSection(),
              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
    );
  }
}

// Revenue Analysis Chart
class RevenueAnalysisChart extends StatelessWidget {
  final List<Map<String, dynamic>> revenueData;

  const RevenueAnalysisChart({Key? key, required this.revenueData}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (revenueData.isEmpty) {
      return const SizedBox.shrink();
    }

    final maxRevenue = revenueData.map((e) => e['revenue'] as num).reduce((a, b) => a > b ? a : b).toDouble();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF7E57C2), Color(0xFF5E35B1)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.trending_up, color: Colors.white, size: 20),
              SizedBox(width: 8),
              Text(
                'Revenue Analysis (2025)',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          const Text(
            'Monthly premium collection trends',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 200,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(show: false),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 50,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          '₹${(value / 1000).toStringAsFixed(0)}k',
                          style: const TextStyle(color: Colors.white70, fontSize: 10),
                        );
                      },
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        if (value.toInt() >= 0 && value.toInt() < revenueData.length) {
                          return Text(
                            revenueData[value.toInt()]['month'],
                            style: const TextStyle(color: Colors.white70, fontSize: 10),
                          );
                        }
                        return const Text('');
                      },
                    ),
                  ),
                  topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                borderData: FlBorderData(show: false),
                minY: 0,
                maxY: maxRevenue * 1.2,
                lineBarsData: [
                  LineChartBarData(
                    spots: revenueData.asMap().entries.map((e) {
                      return FlSpot(e.key.toDouble(), (e.value['revenue'] as num).toDouble());
                    }).toList(),
                    isCurved: true,
                    color: Colors.white,
                    barWidth: 3,
                    dotData: FlDotData(show: true),
                    belowBarData: BarAreaData(
                      show: true,
                      color: Colors.white.withOpacity(0.1),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Policy Status Overview Chart
class PolicyStatusChart extends StatelessWidget {
  final Map<String, int> statusData;

  const PolicyStatusChart({Key? key, required this.statusData}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (statusData.isEmpty) {
      return const SizedBox.shrink();
    }

    final maxValue = statusData.values.reduce((a, b) => a > b ? a : b).toDouble();

    return Container(
      margin: const EdgeInsets.only(left: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF00ACC1), Color(0xFF0097A7)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.pie_chart, color: Colors.white, size: 20),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Policy Status',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          const Text(
            'Current status breakdown',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 180,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: maxValue * 1.2,
                barTouchData: BarTouchData(enabled: false),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        final keys = statusData.keys.toList();
                        if (value.toInt() >= 0 && value.toInt() < keys.length) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              keys[value.toInt()],
                              style: const TextStyle(color: Colors.white70, fontSize: 9),
                            ),
                          );
                        }
                        return const Text('');
                      },
                    ),
                  ),
                ),
                gridData: FlGridData(show: false),
                borderData: FlBorderData(show: false),
                barGroups: statusData.entries.toList().asMap().entries.map((e) {
                  final colors = [
                    const Color(0xFF4CAF50), // Active - Green
                    const Color(0xFFFF9800), // Expired - Orange
                    const Color(0xFFFFEB3B), // Pending - Yellow
                    const Color(0xFFF44336), // Cancelled - Red
                  ];

                  return BarChartGroupData(
                    x: e.key,
                    barRods: [
                      BarChartRodData(
                        toY: e.value.value.toDouble(),
                        color: colors[e.key % colors.length],
                        width: 20,
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Policy Distribution Donut Chart
class PolicyDistributionChart extends StatelessWidget {
  final List<Map<String, dynamic>> distributionData;

  const PolicyDistributionChart({Key? key, required this.distributionData}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (distributionData.isEmpty) {
      return const SizedBox.shrink();
    }

    final colors = [
      const Color(0xFF7E57C2), // Purple
      const Color(0xFFFFB74D), // Orange
      const Color(0xFF64B5F6), // Blue
      const Color(0xFF81C784), // Green
      const Color(0xFFE57373), // Red
      const Color(0xFFFFD54F), // Yellow
    ];

    return Container(
      margin: const EdgeInsets.only(right: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF4CAF50), Color(0xFF388E3C)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.donut_small, color: Colors.white, size: 20),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Policy Distribution',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          const Text(
            'Breakdown by Type',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 180,
            child: Row(
              children: [
                Expanded(
                  flex: 3,
                  child: PieChart(
                    PieChartData(
                      sectionsSpace: 2,
                      centerSpaceRadius: 40,
                      sections: distributionData.asMap().entries.map((e) {
                        return PieChartSectionData(
                          value: (e.value['count'] as num).toDouble(),
                          color: colors[e.key % colors.length],
                          radius: 45,
                          title: '${e.value['percentage'].toStringAsFixed(1)}%',
                          titleStyle: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: distributionData.asMap().entries.map((e) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Row(
                            children: [
                              Container(
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  color: colors[e.key % colors.length],
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  e.value['type'].toString(),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 9,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Customer Growth Chart
class CustomerGrowthChart extends StatelessWidget {
  final List<Map<String, dynamic>> growthData;

  const CustomerGrowthChart({Key? key, required this.growthData}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (growthData.isEmpty) {
      return const SizedBox.shrink();
    }

    final maxCustomers = growthData.map((e) => e['customers'] as num).reduce((a, b) => a > b ? a : b).toDouble();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFEC407A), Color(0xFFD81B60)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.trending_up, color: Colors.white, size: 20),
              SizedBox(width: 8),
              Text(
                'Customer Growth Trend',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          const Text(
            'Cumulative customer acquisition',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 200,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(show: false),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 40,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          value.toInt().toString(),
                          style: const TextStyle(color: Colors.white70, fontSize: 10),
                        );
                      },
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        if (value.toInt() >= 0 && value.toInt() < growthData.length) {
                          return Text(
                            growthData[value.toInt()]['month'],
                            style: const TextStyle(color: Colors.white70, fontSize: 10),
                          );
                        }
                        return const Text('');
                      },
                    ),
                  ),
                  topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                borderData: FlBorderData(show: false),
                minY: 0,
                maxY: maxCustomers * 1.2,
                lineBarsData: [
                  LineChartBarData(
                    spots: growthData.asMap().entries.map((e) {
                      return FlSpot(e.key.toDouble(), (e.value['customers'] as num).toDouble());
                    }).toList(),
                    isCurved: true,
                    color: Colors.white,
                    barWidth: 3,
                    dotData: FlDotData(show: true),
                    belowBarData: BarAreaData(
                      show: true,
                      color: Colors.white.withOpacity(0.1),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// WelcomeCard Widget
class WelcomeCard extends StatelessWidget {
  const WelcomeCard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, AppColors.primaryVariant],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Text(
            'Welcome back,',
            style: TextStyle(
              color: AppColors.textWhite,
              fontSize: 16,
            ),
          ),
          SizedBox(height: 4),
          Text(
            'Admin User',
            style: TextStyle(
              color: AppColors.textWhite,
              fontSize: 28,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'You have 5 tasks pending today',
            style: TextStyle(
              color: AppColors.textWhite,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}

// StatisticsGrid Widget
class StatisticsGrid extends StatelessWidget {
  final Map<String, dynamic> data;

  const StatisticsGrid({Key? key, required this.data}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: StatCard(
                  icon: Icons.description,
                  iconColor: AppColors.primary,
                  value: data['totalPolicies']?.toString() ?? '0',
                  label: 'Total Policies',
                  percentage: '+12%',
                  isPositive: true,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: StatCard(
                  icon: Icons.people,
                  iconColor: AppColors.teal,
                  value: data['activeCustomers']?.toString() ?? '0',
                  label: 'Active Customers',
                  percentage: '+8%',
                  isPositive: true,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: StatCard(
                  icon: Icons.currency_rupee,
                  iconColor: AppColors.orange,
                  value: '₹${((data['monthlyRevenue'] ?? 0) / 1000).toStringAsFixed(2)}K',
                  label: 'Monthly Revenue',
                  percentage: '+15%',
                  isPositive: true,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: StatCard(
                  icon: Icons.refresh,
                  iconColor: AppColors.error,
                  value: data['renewalsDue']?.toString() ?? '0',
                  label: 'Renewals Due',
                  percentage: '-5%',
                  isPositive: false,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// StatCard Widget
class StatCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String value;
  final String label;
  final String percentage;
  final bool isPositive;

  const StatCard({
    Key? key,
    required this.icon,
    required this.iconColor,
    required this.value,
    required this.label,
    required this.percentage,
    required this.isPositive,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: iconColor, size: 24),
              ),
              Row(
                children: [
                  Icon(
                    isPositive ? Icons.arrow_upward : Icons.arrow_downward,
                    color: isPositive ? Colors.green : Colors.red,
                    size: 16,
                  ),
                  const SizedBox(width: 2),
                  Text(
                    percentage,
                    style: TextStyle(
                      color: isPositive ? AppColors.success : AppColors.error,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            value,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: AppColors.textColor1,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.textColor2,
            ),
          ),
        ],
      ),
    );
  }
}

// QuickActionsSection Widget
class QuickActionsSection extends StatelessWidget {
  const QuickActionsSection({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Quick Actions',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.textColor1,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              QuickActionButton(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => TabScreen(initialIndex: 3),
                    ),
                  );
                },
                icon: Icons.add,
                label: 'New Policy',
                color: AppColors.primary,
              ),
              QuickActionButton(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AddLead(),
                    ),
                  );
                },
                icon: Icons.person_add,
                label: 'Add Lead',
                color: AppColors.teal,
              ),
              const QuickActionButton(
                icon: Icons.refresh,
                label: 'Renewals',
                color: AppColors.orange,
              ),
              const QuickActionButton(
                icon: Icons.description,
                label: 'Reports',
                color: AppColors.secondary,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// QuickActionButton Widget
class QuickActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback? onTap;

  const QuickActionButton({
    Key? key,
    required this.icon,
    required this.label,
    required this.color,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: Colors.white, size: 32),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.textColor1,
            ),
          ),
        ],
      ),
    );
  }
}

// RecentActivitySection Widget
class RecentActivitySection extends StatelessWidget {
  const RecentActivitySection({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Recent Activity',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textColor1,
                ),
              ),
              TextButton(
                onPressed: () {},
                child: const Text(
                  'See all',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const ActivityItem(
            title: 'New policy created',
            subtitle: 'John Doe',
            time: '2 min',
            color: AppColors.teal,
          ),
          const ActivityItem(
            title: 'Policy renewal',
            subtitle: 'Jane Smith',
            time: '15 min',
            color: AppColors.secondary,
          ),
          const ActivityItem(
            title: 'Payment received',
            subtitle: 'Mike Johnson',
            time: '1 hr',
            color: AppColors.teal,
          ),
          const ActivityItem(
            title: 'Policy expired',
            subtitle: 'Sarah Wilson',
            time: '2 hr',
            color: AppColors.orange,
          ),
        ],
      ),
    );
  }
}

// ActivityItem Widget
class ActivityItem extends StatelessWidget {
  final String title;
  final String subtitle;
  final String time;
  final Color color;

  const ActivityItem({
    Key? key,
    required this.title,
    required this.subtitle,
    required this.time,
    required this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
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
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
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
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textColor1,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textColor2,
                  ),
                ),
              ],
            ),
          ),
          Text(
            time,
            style: const TextStyle(
              fontSize: 13,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}

// UpcomingRenewalsSection Widget
class UpcomingRenewalsSection extends StatelessWidget {
  const UpcomingRenewalsSection({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Upcoming Renewals',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textColor1,
                ),
              ),
              TextButton(
                onPressed: () {},
                child: const Text(
                  'See all',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const RenewalItem(
            name: 'Alice Brown',
            type: 'Health Insurance',
            amount: '₹15K',
            date: 'Aug 25',
            initial: 'A',
          ),
          const RenewalItem(
            name: 'Bob Davis',
            type: 'Car Insurance',
            amount: '₹8.5K',
            date: 'Aug 27',
            initial: 'B',
          ),
        ],
      ),
    );
  }
}

// RenewalItem Widget
class RenewalItem extends StatelessWidget {
  final String name;
  final String type;
  final String amount;
  final String date;
  final String initial;

  const RenewalItem({
    Key? key,
    required this.name,
    required this.type,
    required this.amount,
    required this.date,
    required this.initial,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
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
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: AppColors.background,
            child: Text(
              initial,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textColor1,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textColor1,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  type,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                amount,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 2),
              Row(
                children: [
                  const Icon(
                    Icons.calendar_today,
                    size: 12,
                    color: AppColors.orange,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    date,
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.orange,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }}