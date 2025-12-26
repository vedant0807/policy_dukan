import 'package:flutter/material.dart';
import 'package:policy_dukaan/api_service.dart';
import 'package:policy_dukaan/widgets/custom_appbar.dart';
import 'package:policy_dukaan/widgets/primary_button.dart';
import 'package:policy_dukaan/widgets/primary_text_field.dart';

class AddStaff extends StatefulWidget {
  const AddStaff({super.key});

  @override
  State<AddStaff> createState() => _AddStaffState();
}

class _AddStaffState extends State<AddStaff> {
  final ApiService _apiService = ApiService();

  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController salaryController = TextEditingController();

  bool isLoading = false;

  final Map<String, bool> permissions = {
    'leads': false,
    'customers': false,
    'add-policy': false,
    'all-policies': false,
    'expired-policies': false,
    'plans': false,
    'renewals': false,
    'add-company': false,
    'commissions': false,
  };

  final Map<String, String> permissionLabels = {
    'leads': 'Leads',
    'customers': 'Customers',
    'add-policy': 'Add Policy',
    'all-policies': 'All Policies',
    'expired-policies': 'Expired Policies',
    'plans': 'Plans',
    'renewals': 'Renewals',
    'add-company': 'Add Company',
    'commissions': 'Commissions',
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      appBar: const CustomAppBar(
        title: "Add New Staff",
        centerTitle: true,
        showBackButton: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            _buildLabeledField(
              label: "Full Name *",
              child: PrimaryTextField(
                hintText: "Enter full name",
                controller: nameController,
              ),
            ),

            const SizedBox(height: 14),

            _buildLabeledField(
              label: "Email *",
              child: PrimaryTextField(
                hintText: "Enter email",
                keyboardType: TextInputType.emailAddress,
                controller: emailController,
              ),
            ),

            const SizedBox(height: 14),

            _buildLabeledField(
              label: "Phone Number *",
              child: PrimaryTextField(
                hintText: "Enter phone number",
                keyboardType: TextInputType.phone,
                controller: phoneController,
              ),
            ),

            const SizedBox(height: 14),

            _buildLabeledField(
              label: "Salary *",
              child: PrimaryTextField(
                hintText: "Enter salary",
                keyboardType: TextInputType.number,
                controller: salaryController,
              ),
            ),

            const SizedBox(height: 20),

            _buildLabel("Permissions *"),
            const SizedBox(height: 10),
            _buildPermissions(),

            const SizedBox(height: 24),

            PrimaryButton(
              label: isLoading ? "Adding..." : "Add Staff",
              onPressed: isLoading ? null : _submitStaff,
            ),
          ],
        ),
      ),
    );
  }

  // ---------------- SUBMIT STAFF ----------------

  Future<void> _submitStaff() async {
    if (nameController.text.isEmpty ||
        emailController.text.isEmpty ||
        phoneController.text.length != 10 ||
        salaryController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill all required fields")),
      );
      return;
    }

    final selectedPermissions = permissions.entries
        .where((e) => e.value)
        .map((e) => e.key)
        .toList();

    setState(() => isLoading = true);

    final result = await _apiService.addStaff(
      name: nameController.text.trim(),
      email: emailController.text.trim(),
      mobileNumber: phoneController.text.trim(),
      salary: salaryController.text.trim(),
      permissions: selectedPermissions, // ✅ empty list allowed
    );

    setState(() => isLoading = false);

    if (result['success']) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Staff added successfully")),
      );
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result['message'])),
      );
    }
  }

  // ---------------- UI HELPERS ----------------

  Widget _buildLabeledField({
    required String label,
    required Widget child,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel(label),
        child,
      ],
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: Colors.black87,
        ),
      ),
    );
  }

  Widget _buildPermissions() {
    return Wrap(
      spacing: 12,
      runSpacing: 8,
      children: permissions.keys.map((key) {
        return InkWell(
          onTap: () {
            setState(() {
              permissions[key] = !permissions[key]!;
            });
          },
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Checkbox(
                value: permissions[key],
                onChanged: (val) {
                  setState(() {
                    permissions[key] = val!;
                  });
                },
                activeColor: const Color(0xFF6366F1),
              ),
              Text(permissionLabels[key] ?? key),
              const SizedBox(width: 12),
            ],
          ),
        );
      }).toList(),
    );
  }
}
