import 'package:flutter/material.dart';
import 'package:policy_dukaan/api_service.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:policy_dukaan/utils/app_colors.dart';
import 'package:policy_dukaan/views/add_lead.dart';
import 'package:policy_dukaan/widgets/custom_appbar.dart';
import 'package:policy_dukaan/widgets/primary_button.dart';

class LeadsScreen extends StatefulWidget {
  const LeadsScreen({Key? key}) : super(key: key);

  @override
  State<LeadsScreen> createState() => _LeadsScreenState();
}

class _LeadsScreenState extends State<LeadsScreen> {
  final ApiService _apiService = ApiService();

  String selectedTab = 'All Leads';
  String? selectedFilter;
  bool showFilterDialog = false;
  bool isLoading = false;

  // API leads list
  List<Map<String, dynamic>> leads = [];

  @override
  void initState() {
    super.initState();
    loadLeads();
  }

  Future<void> loadLeads() async {
    setState(() => isLoading = true);

    try {
      final data = await _apiService.getLeads();
      setState(() {
        leads = List<Map<String, dynamic>>.from(data);
      });
    } catch (e) {
      debugPrint('❌ Error loading leads: $e');
    }

    setState(() => isLoading = false);
  }

  // Filters
  List<Map<String, dynamic>> get filteredLeads {
    if (selectedTab == 'Follow-ups') return [];
    if (selectedFilter == null) return leads;

    return leads.where((l) => l['status'] == selectedFilter).toList();
  }

  // Stats
  int get totalLeads => leads.length;
  int get qualifiedLeads =>
      leads.where((l) => l['status'] == 'Qualified').length;
  int get followUps => 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const CustomAppBar(
        title: "Leads",
        centerTitle: true,
      ),
      body: Stack(
        children: [
          Column(
            children: [
              // Stats
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Expanded(
                        child: _buildStatCard(
                            '$totalLeads', 'Total Leads', const Color(0xFF6C5CE7))),
                    const SizedBox(width: 12),
                    Expanded(
                        child: _buildStatCard(
                            '$qualifiedLeads', 'Qualified', const Color(0xFF00B894))),
                    const SizedBox(width: 12),
                    Expanded(
                        child: _buildStatCard(
                            '$followUps', 'Follow-ups', const Color(0xFFFFA940))),
                  ],
                ),
              ),

              // Tabs
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Expanded(child: _buildTabButton('All Leads')),
                    const SizedBox(width: 12),
                    Expanded(child: _buildTabButton('Follow-ups')),
                  ],
                ),
              ),

              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.all(15.0),
                child: PrimaryButton(
                  label: "Add Lead",
                  onPressed: () async {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const AddLead()),
                    );

                    if (result == true) {
                      loadLeads(); // ✅ refresh list
                    }
                  },
                ),

              ),

              // List
              Expanded(
                child: isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : filteredLeads.isEmpty
                    ? _buildEmptyState()
                    : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: filteredLeads.length,
                  itemBuilder: (_, index) =>
                      _buildLeadCard(filteredLeads[index]),
                ),
              ),
            ],
          ),

          if (showFilterDialog) _buildFilterDialog(),
        ],
      ),
      floatingActionButton: selectedTab == 'All Leads'
          ? FloatingActionButton(
        onPressed: () => setState(() => showFilterDialog = !showFilterDialog),
        backgroundColor: const Color(0xFF6C5CE7),
        child: const Icon(Icons.filter_list),
      )
          : null,
    );
  }

  // ---------------- UI Widgets ----------------

  Widget _buildStatCard(String count, String label, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration:
      BoxDecoration(color: color, borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(count,
              style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white)),
          const SizedBox(height: 4),
          Text(label,
              style:
              const TextStyle(fontSize: 14, color: Colors.white70)),
        ],
      ),
    );
  }

  Widget _buildTabButton(String label) {
    final isSelected = selectedTab == label;
    return GestureDetector(
      onTap: () => setState(() {
        selectedTab = label;
        selectedFilter = null;
      }),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : const Color(0xFFF5F5F5),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(label,
            textAlign: TextAlign.center,
            style: TextStyle(
                fontWeight:
                isSelected ? FontWeight.w600 : FontWeight.w500)),
      ),
    );
  }

  Widget _buildLeadCard(Map<String, dynamic> lead) {
    final initials =
    '${lead['first_name']?[0] ?? ''}${lead['last_name']?[0] ?? ''}'
        .toUpperCase();

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: Colors.grey.withOpacity(0.08),
              blurRadius: 10,
              offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: const Color(0xFF6C5CE7),
                child: Text(initials,
                    style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${lead['first_name']} ${lead['last_name']}',
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w600),
                      ),
                      Text(lead['interest'] ?? '',
                          style:
                          TextStyle(fontSize: 13, color: Colors.grey[600])),
                    ]),
              ),
              const SizedBox(width: 22),
              IconButton(onPressed: () async {
                final result = await _apiService.deleteLead(lead['id']);

                if (result['success']) {
                  Fluttertoast.showToast(
                    msg: 'Lead deleted successfully',
                    toastLength: Toast.LENGTH_SHORT,
                    gravity: ToastGravity.BOTTOM,
                    backgroundColor: Colors.green,
                    textColor: Colors.white,
                  );
                  loadLeads(); // 🔄 refresh list
                } else {
                  Fluttertoast.showToast(
                    msg: result['message'] ?? 'Failed to delete lead',
                    toastLength: Toast.LENGTH_SHORT,
                    gravity: ToastGravity.BOTTOM,
                    backgroundColor: Colors.red,
                    textColor: Colors.white,
                  );
                }

              },
       icon: Icon(Icons.delete_outline_outlined,color: Colors.red,))

            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(Icons.phone_outlined,
                  size: 16, color: Colors.grey[600]),
              const SizedBox(width: 6),
              Text(lead['phone'] ?? ''),

              const SizedBox(width: 16),
              Icon(Icons.email_outlined,
                  size: 16, color: Colors.grey[600]),
              const SizedBox(width: 6),
              Expanded(
                  child: Text(lead['email'] ?? '',
                      overflow: TextOverflow.ellipsis)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Text('No leads available'),
    );
  }

  Widget _buildFilterDialog() {
    final statuses = ['New', 'Contacted', 'Qualified', 'Converted', 'Lost'];

    return GestureDetector(
      onTap: () => setState(() => showFilterDialog = false),
      child: Container(
        color: Colors.black54,
        child: Center(
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0xFF2D2D2D),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: statuses
                  .map((s) => ListTile(
                title:
                Text(s, style: const TextStyle(color: Colors.white)),
                onTap: () {
                  setState(() {
                    selectedFilter = s;
                    showFilterDialog = false;
                  });
                },
              ))
                  .toList(),
            ),
          ),
        ),
      ),
    );
  }
}
