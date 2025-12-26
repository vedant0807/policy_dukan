import 'package:flutter/material.dart';
import 'package:policy_dukaan/views/add_staff.dart';
import 'package:policy_dukaan/widgets/custom_appbar.dart';
import 'package:policy_dukaan/api_service.dart';

import '../widgets/primary_button.dart';

class StaffManagement extends StatefulWidget {
  const StaffManagement({super.key});

  @override
  State<StaffManagement> createState() => _StaffManagementState();
}

class _StaffManagementState extends State<StaffManagement> {
  final ApiService _apiService = ApiService();
  List<dynamic> _staffList = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchStaff();
  }

  Future<void> _fetchStaff() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final response = await _apiService.getStaff();

      if (response['success']) {
        setState(() {
          _staffList = response['data'];
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(response['message'] ?? 'Failed to fetch staff'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _deleteStaff(String staffId, String staffName) async {
    // Show confirmation dialog
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(backgroundColor: Colors.white,
        title: const Text('Delete Staff Member'),
        content: Text('Are you sure you want to delete $staffName?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (shouldDelete != true) return;

    try {
      final response = await _apiService.deleteStaff(staffId: staffId);

      if (mounted) {
        if (response['success']) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(response['message'] ?? 'Staff deleted successfully'),
              backgroundColor: Colors.green,
            ),
          );
          _fetchStaff(); // Refresh the list
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(response['message'] ?? 'Failed to delete staff'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: CustomAppBar(
        title: "Staff Management",
        centerTitle: true,
        showBackButton: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
        children: [
          SizedBox(height: 20,),
          // 🔹 Add Staff Button (TOP)
          Padding(
            padding: const EdgeInsets.all(16),
            child: PrimaryButton(
              label: "Add Staff",
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AddStaff()),
                );

                if (result == true) {
                  _fetchStaff(); // 🔄 refresh list after adding
                }
              },
            ),
          ),

          // 🔹 Staff List
          Expanded(
            child: _staffList.isEmpty
                ? const Center(
              child: Text(
                'No staff members found',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            )
                : Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: GridView.builder(
                gridDelegate:
                const SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 380,
                  mainAxisExtent: 300,
                  crossAxisSpacing: 24,
                  mainAxisSpacing: 24,
                ),
                itemCount: _staffList.length,
                itemBuilder: (context, index) {
                  final staff = _staffList[index];
                  return StaffCard(
                    staff: staff,
                    onDelete: () => _deleteStaff(
                      staff['_id'] ?? '',
                      staff['name'] ?? 'Unknown',
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),

    );
  }
}

class StaffCard extends StatelessWidget {
  final dynamic staff;
  final VoidCallback onDelete;

  const StaffCard({
    super.key,
    required this.staff,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final name = staff['name'] ?? 'N/A';
    final email = staff['email'] ?? 'N/A';
    final mobile = staff['mobileNumber'] ?? 'N/A';
    final salary = staff['salary']?.toString() ?? '0';
    final permissions = List<String>.from(staff['permissions'] ?? []);

    return Container(
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
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  name,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit, size: 20, color: Color(0xFF6366F1)),
                    onPressed: () {
                      // TODO: Edit functionality
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, size: 20, color: Colors.red),
                    onPressed: onDelete,
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildInfoRow('Email:', email),
          const SizedBox(height: 6),
          _buildInfoRow('Mobile:', mobile),
          const SizedBox(height: 6),
          _buildInfoRow('Salary:', '₹$salary'),
          const SizedBox(height: 12),
          const Text(
            'Permissions:',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: permissions.map((permission) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF6366F1).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  permission,
                  style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFF6366F1),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return RichText(
      text: TextSpan(
        style: const TextStyle(fontSize: 14, color: Colors.black87),
        children: [
          TextSpan(
            text: '$label ',
            style: const TextStyle(color: Colors.grey),
          ),
          TextSpan(
            text: value,
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
        ],
      ),
      overflow: TextOverflow.ellipsis,
    );
  }
}

