import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:policy_dukaan/widgets/custom_appbar.dart';
import 'package:policy_dukaan/widgets/primary_button.dart';
import 'package:policy_dukaan/widgets/primary_text_field.dart';

import '../api_service.dart';

class AddLead extends StatefulWidget {
  const AddLead({super.key});

  @override
  State<AddLead> createState() => _AddLeadState();
}

class _AddLeadState extends State<AddLead> {

  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController sourceController = TextEditingController();
  final TextEditingController notesController = TextEditingController();

  // Multi-select insurance interests
  List<String> selectedInsurances = [];

  String priority = 'Medium';

  final ApiService _apiService = ApiService();
  bool isLoading = false;

  final List<String> insuranceTypes = [
    'Life Insurance',
    'Health Insurance',
    'Auto Insurance',
    'Home Insurance',
    'Travel Insurance',
    'Business Insurance',
  ];

  final List<String> priorities = ['Low', 'Medium', 'High'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      appBar: const CustomAppBar(
        title: "Add Lead",
        centerTitle: true,
        showBackButton: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // First & Last Name
              Row(
                children: [
                  Expanded(
                    child: _buildLabeledField(
                      label: "First Name *",
                      child: PrimaryTextField(
                        hintText: "Enter first name",controller: firstNameController,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildLabeledField(
                      label: "Last Name *",
                      child: PrimaryTextField(
                        hintText: "Enter last name",controller: lastNameController,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 14),

              // Email
              _buildLabeledField(
                label: "Email *",
                child: PrimaryTextField(
                  hintText: "Enter email address",controller: emailController,
                ),
              ),

              const SizedBox(height: 14),

              // Phone
              _buildLabeledField(
                label: "Phone *",
                child: PrimaryTextField(
                  hintText: "Enter phone number",
                  keyboardType: TextInputType.number,controller: phoneController,

                ),
              ),

              const SizedBox(height: 14),

              // Insurance Interests (Multi Select)
              _buildLabel("Insurance Interests *"),
              GestureDetector(
                onTap: _openInsuranceBottomSheet,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 14),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          selectedInsurances.isEmpty
                              ? "Select insurance types..."
                              : selectedInsurances.join(', '),
                          style: TextStyle(
                            color: selectedInsurances.isEmpty
                                ? Colors.grey
                                : Colors.black87,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const Icon(Icons.arrow_drop_down),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 14),

              // Source
              _buildLabeledField(
                label: "Source",
                child: PrimaryTextField(
                  hintText: "How did you find this lead?",controller: sourceController,
                ),
              ),

              const SizedBox(height: 14),

              // Priority
              _buildLabel("Priority"),
              _buildDropdown(
                value: priority,
                items: priorities,
                onChanged: (val) {
                  setState(() => priority = val!);
                },
              ),

              const SizedBox(height: 14),

              // Notes
              _buildLabeledField(
                label: "Notes",
                child: PrimaryTextField(
                  hintText: "Additional notes about this lead",
                  controller: notesController,
                ),
              ),

              const SizedBox(height: 20),
    PrimaryButton(
    label: isLoading ? "Adding..." : "Add Lead",
    onPressed: () async {
    if (firstNameController.text.isEmpty ||
    lastNameController.text.isEmpty ||
    emailController.text.isEmpty ||
    phoneController.text.length != 10 ||
    selectedInsurances.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(content: Text("Please fill all required fields")),
    );
    return;
    }

    setState(() => isLoading = true);

    final result = await _apiService.addLead(
    firstName: firstNameController.text.trim(),
    lastName: lastNameController.text.trim(),
    email: emailController.text.trim(),
    phone: phoneController.text.trim(),
    interest: selectedInsurances.join(', '), // 👈 multi-select
    priority: priority,
    source: sourceController.text.trim(),
    notes: notesController.text.trim(),
    );

    setState(() => isLoading = false);

    if (result['success']) {
    ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(content: Text("Lead added successfully")),
    );
    Navigator.pop(context, true); // ✅ tells previous screen to refresh
    } else {
    ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(result['message'])),
    );
    }
    },
    )

            ],
          ),
        ),
      ),
    );
  }

  // ---------- Multi Select Bottom Sheet ----------

  void _openInsuranceBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Select Insurance Types",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),

                  ...insuranceTypes.map((type) {
                    final isSelected =
                    selectedInsurances.contains(type);

                    return CheckboxListTile(
                      value: isSelected,
                      title: Text(type),
                      controlAffinity:
                      ListTileControlAffinity.leading,
                      onChanged: (val) {
                        setModalState(() {
                          if (val == true) {
                            selectedInsurances.add(type);
                          } else {
                            selectedInsurances.remove(type);
                          }
                        });
                      },
                    );
                  }).toList(),

                  const SizedBox(height: 12),

                  Align(
                    alignment: Alignment.centerRight,
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() {});
                        Navigator.pop(context);
                      },
                      child: const Text("Done"),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // ---------- Reusable Widgets ----------

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

  Widget _buildDropdown({
    String? value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          items: items
              .map(
                (e) => DropdownMenuItem(
              value: e,
              child: Text(e),
            ),
          )
              .toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}
