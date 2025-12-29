import 'package:flutter/material.dart';
import 'package:policy_dukaan/utils/app_colors.dart';
import 'package:policy_dukaan/views/add_lead.dart';
import 'package:policy_dukaan/views/renewal_screen.dart';
import 'package:policy_dukaan/views/tab_screen.dart';
import 'package:policy_dukaan/widgets/custom_appbar.dart';
import 'package:policy_dukaan/session_manager.dart';
import 'package:fl_chart/fl_chart.dart';
import '../api_service.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final ApiService _apiService = ApiService();
  final SessionManager _sessionManager = SessionManager();

  bool _isLoading = true;

  // Dashboard data
  int totalPolicies = 0;
  int totalCustomers = 0;
  int activeCustomers = 0;
  double monthlyRevenue = 0.0;
  int totalLeads = 0;
  double thisMonthCommission = 0.0;
  int totalStaff = 0;
  String subscriptionStatus = 'INACTIVE';

  // Analytics data
  List<double> monthlyRevenueData = List.filled(12, 0);
  Map<String, int> policyTypeDistribution = {};
  Map<String, int> policyStatusBreakdown = {};
  List<int> customerGrowthData = List.filled(12, 0);

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final results = await Future.wait([
        _apiService.getPolicies(),
        _apiService.getCustomers(),
        _apiService.getLeads(),
        _apiService.getStaff(),
        _apiService.getCommissions(),
        _fetchSubscriptionStatus(),
      ]);

      final policiesResponse = results[0] as Map<String, dynamic>;
      if (policiesResponse['success'] == true) {
        final policies = policiesResponse['data'] as List;
        totalPolicies = policies.length;
        monthlyRevenue = policies.fold(0.0, (sum, policy) {
          final premium = policy['premium_with_gst'];
          return sum + (premium is num ? premium.toDouble() : 0.0);
        });
        _processRevenueAnalytics(policies);
        _processPolicyDistribution(policies);
        _processPolicyStatusBreakdown(policies);
      }

      final customersResponse = results[1] as Map<String, dynamic>;
      if (customersResponse['success'] == true) {
        final customers = customersResponse['data'] as List;
        totalCustomers = customers.length;
        activeCustomers = customers.where((c) =>
        c['status']?.toString().toLowerCase() == 'active').length;
        _processCustomerGrowth(customers);
      }

      final leads = results[2] as List<Map<String, dynamic>>;
      totalLeads = leads.length;

      final staffResponse = results[3] as Map<String, dynamic>;
      if (staffResponse['success'] == true) {
        totalStaff = (staffResponse['data'] as List).length;
      }

      final commissionsResponse = results[4] as Map<String, dynamic>;
      if (commissionsResponse['success'] == true) {
        final stats = commissionsResponse['stats'];
        if (stats?['monthlyCommission'] != null) {
          thisMonthCommission = (stats['monthlyCommission'] as num).toDouble();
        }
      }

      setState(() => _isLoading = false);
    } catch (e) {
      print('❌ Error: $e');
      setState(() => _isLoading = false);
    }
  }

  void _processRevenueAnalytics(List policies) {
    monthlyRevenueData = List.filled(12, 0);
    for (var policy in policies) {
      try {
        final startDate = policy['policy_start_date'];
        final premium = policy['premium_with_gst'];
        if (startDate != null && premium != null) {
          final month = DateTime.parse(startDate).month - 1;
          monthlyRevenueData[month] += (premium as num).toDouble();
        }
      } catch (e) {}
    }
  }

  void _processPolicyDistribution(List policies) {
    policyTypeDistribution = {};
    for (var p in policies) {
      final type = p['policy_type']?.toString() ?? 'Unknown';
      policyTypeDistribution[type] = (policyTypeDistribution[type] ?? 0) + 1;
    }
  }

  void _processPolicyStatusBreakdown(List policies) {
    policyStatusBreakdown = {'Active': 0, 'Expired': 0, 'Pending': 0, 'Cancelled': 0};
    final now = DateTime.now();
    for (var p in policies) {
      try {
        final endDate = p['policy_end_date'];
        if (endDate != null && DateTime.parse(endDate).isAfter(now)) {
          policyStatusBreakdown['Active'] = policyStatusBreakdown['Active']! + 1;
        } else if (endDate != null) {
          policyStatusBreakdown['Expired'] = policyStatusBreakdown['Expired']! + 1;
        } else {
          policyStatusBreakdown['Pending'] = policyStatusBreakdown['Pending']! + 1;
        }
      } catch (e) {
        policyStatusBreakdown['Pending'] = policyStatusBreakdown['Pending']! + 1;
      }
    }
  }

  void _processCustomerGrowth(List customers) {
    customerGrowthData = List.filled(12, 0);
    for (var c in customers) {
      try {
        final joinDate = c['joinDate'];
        if (joinDate != null) {
          customerGrowthData[DateTime.parse(joinDate).month - 1]++;
        }
      } catch (e) {}
    }
    for (int i = 1; i < 12; i++) {
      customerGrowthData[i] += customerGrowthData[i - 1];
    }
  }

  Future<String> _fetchSubscriptionStatus() async {
    try {
      final token = await _sessionManager.getToken();
      if (token != null) {
        final planData = await _apiService.fetchCurrentPlan(token);
        if (planData?['status'] != null) {
          subscriptionStatus = planData!['status'].toString().toUpperCase();
        }
      }
    } catch (e) {}
    return subscriptionStatus;
  }

  String _formatCurrency(double amount) {
    if (amount >= 100000) return '₹${(amount / 100000).toStringAsFixed(2)}L';
    if (amount >= 1000) return '₹${(amount / 1000).toStringAsFixed(2)}K';
    return '₹${amount.toStringAsFixed(0)}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CustomAppBar(title: "Dashboard", centerTitle: true),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : RefreshIndicator(
        onRefresh: _loadDashboardData,
        color: AppColors.primary,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 15,right: 15),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Dashboard Overview",
                    style:  TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w500,
                      color: AppColors.primary
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),
              StatisticsGrid(
                totalPolicies: totalPolicies,
                totalCustomers: totalCustomers,
                activeCustomers: activeCustomers,
                monthlyRevenue: monthlyRevenue,
                totalLeads: totalLeads,
                thisMonthCommission: thisMonthCommission,
                totalStaff: totalStaff,
                subscriptionStatus: subscriptionStatus,
                formatCurrency: _formatCurrency,
              ),
              const SizedBox(height: 24),
              AnalyticsCharts(
                monthlyRevenueData: monthlyRevenueData,
                policyTypeDistribution: policyTypeDistribution,
                policyStatusBreakdown: policyStatusBreakdown,
                customerGrowthData: customerGrowthData,
                formatCurrency: _formatCurrency,
              ),
              const SizedBox(height: 24),
              const QuickActionsSection(),
              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
    );
  }
}

class AnalyticsCharts extends StatelessWidget {
  final List<double> monthlyRevenueData;
  final Map<String, int> policyTypeDistribution;
  final Map<String, int> policyStatusBreakdown;
  final List<int> customerGrowthData;
  final String Function(double) formatCurrency;

  const AnalyticsCharts({
    Key? key,
    required this.monthlyRevenueData,
    required this.policyTypeDistribution,
    required this.policyStatusBreakdown,
    required this.customerGrowthData,
    required this.formatCurrency,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          _RevenueChart(data: monthlyRevenueData, format: formatCurrency),
          const SizedBox(height: 12),
          _PolicyPieChart(distribution: policyTypeDistribution),
          const SizedBox(height: 12),
          _StatusBarChart(breakdown: policyStatusBreakdown),
          const SizedBox(height: 12),
          _GrowthChart(data: customerGrowthData),
        ],
      ),
    );
  }
}

class _RevenueChart extends StatelessWidget {
  final List<double> data;
  final String Function(double) format;
  const _RevenueChart({required this.data, required this.format});

  @override
  Widget build(BuildContext context) {
    final maxY = data.reduce((a, b) => a > b ? a : b);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Color(0xFF7C3AED), Color(0xFF5B21B6)]),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.bar_chart, color: Colors.white, size: 20),
              SizedBox(width: 8),
              Expanded(
                child: Text('Revenue Analysis (2025)',
                    style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
              ),
            ],
          ),
          const SizedBox(height: 4),
          const Text('Monthly premium collection trends',
              style: TextStyle(color: Colors.white70, fontSize: 12)),
          const SizedBox(height: 20),
          SizedBox(
            height: 180,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(show: false),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 40,
                      getTitlesWidget: (v, _) => Text(format(v),
                          style: const TextStyle(color: Colors.white70, fontSize: 10)),
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (v, _) {
                        const m = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
                        return Text(v.toInt() < m.length ? m[v.toInt()] : '',
                            style: const TextStyle(color: Colors.white70, fontSize: 10));
                      },
                    ),
                  ),
                  rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                borderData: FlBorderData(show: false),
                minX: 0, maxX: 11, minY: 0, maxY: maxY > 0 ? maxY * 1.2 : 100,
                lineBarsData: [
                  LineChartBarData(
                    spots: List.generate(data.length, (i) => FlSpot(i.toDouble(), data[i])),
                    isCurved: true,
                    color: Colors.white,
                    barWidth: 3,
                    dotData: FlDotData(show: true),
                    belowBarData: BarAreaData(show: true, color: Colors.white.withOpacity(0.2)),
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

class _PolicyPieChart extends StatelessWidget {
  final Map<String, int> distribution;
  const _PolicyPieChart({required this.distribution});

  @override
  Widget build(BuildContext context) {
    final total = distribution.values.fold(0, (s, v) => s + v);
    final top = distribution.isNotEmpty ? distribution.entries.reduce((a, b) => a.value > b.value ? a : b) : null;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Color(0xFF059669), Color(0xFF047857)]),
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
                child: Text('Policy Distribution',
                    style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
              ),
            ],
          ),
          const Text('Breakdown by Policy Type', style: TextStyle(color: Colors.white70, fontSize: 12)),
          const SizedBox(height: 20),
          SizedBox(
            height: 180,
            child: total > 0
                ? Stack(
              children: [
                PieChart(
                  PieChartData(
                    sectionsSpace: 2,
                    centerSpaceRadius: 50,
                    sections: distribution.entries.map((e) {
                      final pct = (e.value / total * 100);
                      final colors = [Color(0xFF8B5CF6), Color(0xFFA78BFA), Color(0xFFC4B5FD), Color(0xFFDDD6FE)];
                      return PieChartSectionData(
                        color: colors[distribution.keys.toList().indexOf(e.key) % colors.length],
                        value: e.value.toDouble(),
                        title: '${pct.toStringAsFixed(0)}%',
                        radius: 45,
                        titleStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
                      );
                    }).toList(),
                  ),
                ),
                if (top != null)
                  Positioned.fill(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(top.key,
                            style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
                            textAlign: TextAlign.center),
                      ],
                    ),
                  ),
              ],
            )
                : const Center(child: Text('No data', style: TextStyle(color: Colors.white70))),
          ),
        ],
      ),
    );
  }
}

class _StatusBarChart extends StatelessWidget {
  final Map<String, int> breakdown;
  const _StatusBarChart({required this.breakdown});

  @override
  Widget build(BuildContext context) {
    final maxVal = breakdown.values.fold(0, (m, v) => v > m ? v : m);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Color(0xFF0891B2), Color(0xFF0E7490)]),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.stacked_bar_chart, color: Colors.white, size: 20),
              SizedBox(width: 8),
              Expanded(child: Text('Policy Status Overview',
                  style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600))),
            ],
          ),
          const Text('Current status breakdown', style: TextStyle(color: Colors.white70, fontSize: 12)),
          const SizedBox(height: 20),
          SizedBox(
            height: 180,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: maxVal > 0 ? maxVal * 1.2 : 10,
                titlesData: FlTitlesData(
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (v, _) {
                        final labels = breakdown.keys.toList();
                        return Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(v.toInt() < labels.length ? labels[v.toInt()] : '',
                              style: const TextStyle(color: Colors.white70, fontSize: 10)),
                        );
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                gridData: FlGridData(show: false),
                borderData: FlBorderData(show: false),
                barGroups: breakdown.entries.toList().asMap().entries.map((e) {
                  final colors = {'Active': Color(0xFF10B981), 'Expired': Color(0xFFEF4444),
                    'Pending': Color(0xFFF59E0B), 'Cancelled': Color(0xFF6B7280)};
                  return BarChartGroupData(
                    x: e.key,
                    barRods: [
                      BarChartRodData(
                        toY: e.value.value.toDouble(),
                        color: colors[e.value.key] ?? Colors.white,
                        width: 30,
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

class _GrowthChart extends StatelessWidget {
  final List<int> data;
  const _GrowthChart({required this.data});

  @override
  Widget build(BuildContext context) {
    final maxY = data.reduce((a, b) => a > b ? a : b);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Color(0xFFDB2777), Color(0xFFBE185D)]),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.trending_up, color: Colors.white, size: 20),
              SizedBox(width: 8),
              Expanded(child: Text('Customer Growth Trend',
                  style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600))),
            ],
          ),
          const Text('Cumulative customer acquisition', style: TextStyle(color: Colors.white70, fontSize: 12)),
          const SizedBox(height: 20),
          SizedBox(
            height: 180,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(show: false),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (v, _) {
                        const m = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
                        return Text(v.toInt() < m.length ? m[v.toInt()] : '',
                            style: const TextStyle(color: Colors.white70, fontSize: 10));
                      },
                    ),
                  ),
                  rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                borderData: FlBorderData(show: false),
                minX: 0, maxX: 11, minY: 0, maxY: maxY > 0 ? maxY * 1.2 : 10,
                lineBarsData: [
                  LineChartBarData(
                    spots: List.generate(data.length, (i) => FlSpot(i.toDouble(), data[i].toDouble())),
                    isCurved: true,
                    color: Colors.white,
                    barWidth: 3,
                    dotData: FlDotData(show: true),
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
        ],
      ),
    );
  }
}

class StatisticsGrid extends StatelessWidget {
  final int totalPolicies;
  final int totalCustomers;
  final int activeCustomers;
  final double monthlyRevenue;
  final int totalLeads;
  final double thisMonthCommission;
  final int totalStaff;
  final String subscriptionStatus;
  final String Function(double) formatCurrency;

  const StatisticsGrid({
    Key? key,
    required this.totalPolicies,
    required this.totalCustomers,
    required this.activeCustomers,
    required this.monthlyRevenue,
    required this.totalLeads,
    required this.thisMonthCommission,
    required this.totalStaff,
    required this.subscriptionStatus,
    required this.formatCurrency,
  }) : super(key: key);

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
                  value: totalPolicies.toString(),
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
                  value: totalCustomers.toString(),
                  label: 'Total Customers',
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
                  icon: Icons.people_outline,
                  iconColor: AppColors.teal,
                  value: activeCustomers.toString(),
                  label: 'Active Customers',
                  percentage: '+5%',
                  isPositive: true,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: StatCard(
                  icon: Icons.currency_rupee,
                  iconColor: AppColors.orange,
                  value: formatCurrency(monthlyRevenue),
                  label: 'Monthly Revenue',
                  percentage: '+15%',
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
                  icon: Icons.person_add,
                  iconColor: AppColors.secondary,
                  value: totalLeads.toString(),
                  label: 'Total Leads',
                  percentage: '+10%',
                  isPositive: true,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: StatCard(
                  icon: Icons.attach_money,
                  iconColor: AppColors.teal,
                  value: formatCurrency(thisMonthCommission),
                  label: 'This Month\nCommission',
                  percentage: '+18%',
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
                  icon: Icons.groups,
                  iconColor: AppColors.primary,
                  value: totalStaff.toString(),
                  label: 'Total Staff',
                  percentage: '+2%',
                  isPositive: true,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                  child: StatCard(
                  icon: Icons.card_membership,
                  iconColor: subscriptionStatus == 'ACTIVE'
                      ? AppColors.success
                      : AppColors.error,
                  value: '',
                  label: 'Subscription\nStatus',
                  percentage: subscriptionStatus,
                  isPositive: subscriptionStatus == 'ACTIVE',
                  isStatus: true,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class StatCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String value;
  final String label;
  final String percentage;
  final bool isPositive;
  final bool isStatus;

  const StatCard({
    Key? key,
    required this.icon,
    required this.iconColor,
    required this.value,
    required this.label,
    required this.percentage,
    required this.isPositive,
    this.isStatus = false,
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
          // Top row with label and icon
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.textColor2,
                ),
              ),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: iconColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: Colors.white, size: 20),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Value
          if (value.isNotEmpty)
            Text(
              value,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: AppColors.textColor1,
              ),
            ),
          if (value.isEmpty && !isStatus)
            const SizedBox(height: 28),
          // Status badge for subscription
          if (isStatus) ...[
            const SizedBox(height: 4),
            Text(
              percentage,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: percentage == 'ACTIVE' ? AppColors.success : AppColors.error,
              ),
            ),
          ],
          // Progress bar
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: 1.0,
              backgroundColor: iconColor.withOpacity(0.1),
              valueColor: AlwaysStoppedAnimation<Color>(iconColor),
              minHeight: 4,
            ),
          ),
        ],
      ),
    );
  }
}

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
               QuickActionButton(onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => RenewalsScreen(),));
              },
                icon: Icons.refresh,
                label: 'Renewals',
                color: AppColors.orange,
              ),

            ],
          ),
        ],
      ),
    );
  }
}

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
  }
}