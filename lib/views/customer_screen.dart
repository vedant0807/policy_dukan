import 'package:flutter/material.dart';
import 'package:policy_dukaan/widgets/custom_appbar.dart';
import 'package:policy_dukaan/widgets/primary_button.dart';
import '../api_service.dart';
import '../utils/app_colors.dart';
import '../widgets/custom_searchbar.dart';
import '../widgets/primary_text_field.dart';

class CustomersScreen extends StatefulWidget {
  const CustomersScreen({Key? key}) : super(key: key);

  @override
  State<CustomersScreen> createState() => _CustomersScreenState();
}

class _CustomersScreenState extends State<CustomersScreen> {
  final ApiService _apiService = ApiService();
  List<dynamic> _customers = [];
  List<dynamic> _filteredCustomers = [];
  bool _isLoading = true;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchCustomers();
  }

  Future<void> _fetchCustomers() async {
    setState(() {
      _isLoading = true;
    });

    try {
      print('📥 Fetching customers...');
      final response = await _apiService.getCustomers();
      print('✅ Get Customers Response: ${response.toString()}');

      if (response['success']) {
        setState(() {
          _customers = response['data'] ?? [];
          _filteredCustomers = List.from(_customers); // important
          _isLoading = false;
        });
        print('📊 Total customers loaded: ${_customers.length}');
      } else {
        setState(() {
          _isLoading = false;
        });
        print('❌ Failed to fetch customers: ${response['message']}');
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      print('❌ Error fetching customers: $e');
    }
  }

  void _onSearchChanged(String query) {
    if (query.isEmpty) {
      setState(() {
        _filteredCustomers = List.from(_customers);
      });
      return;
    }

    final lowerQuery = query.toLowerCase();

    setState(() {
      _filteredCustomers = _customers.where((customer) {
        final firstName = (customer['firstName'] ?? '').toLowerCase();
        final lastName = (customer['lastName'] ?? '').toLowerCase();
        final phone = (customer['phone'] ?? '').toLowerCase();
        final email = (customer['email'] ?? '').toLowerCase();

        return firstName.contains(lowerQuery) ||
            lastName.contains(lowerQuery) ||
            phone.contains(lowerQuery) ||
            email.contains(lowerQuery);
      }).toList();
    });
  }


  void _showAddCustomerDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AddCustomerDialog(
          onCustomerAdded: () {
            _fetchCustomers();
          },
        );
      },
    );
  }

  int get _totalCustomers => _customers.length;
  int get _activeCustomers => _customers.where((c) => c['status'] != 'Inactive').length;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: "Customers",
        centerTitle: true,
        showBackButton: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
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
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '$_totalCustomers',
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textColor1,
                              ),
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              'Total Customers',
                              style: TextStyle(
                                fontSize: 14,
                                color: AppColors.textColor2,
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
                          color: const Color(0xffE2F3EF),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '$_activeCustomers',
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF66DBB6),
                              ),
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              'Active',
                              style: TextStyle(
                                fontSize: 14,
                                color: AppColors.textColor2,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                CustomSearchBar(
                  controller: _searchController,
                  hintText: 'Search customers',
                  onChanged: _onSearchChanged,
                  onClear: () {
                    _searchController.clear();
                    setState(() {
                      _filteredCustomers = List.from(_customers);
                    });
                  },
                ),

                const SizedBox(height: 16),
                // PrimaryButton(label: "+ Add Customer", onPressed: _showAddCustomerDialog),
                const SizedBox(height: 16),

                if (_filteredCustomers.isEmpty)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(32.0),
                      child: Text(
                        'No customers found',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                  )
                else
                  ..._filteredCustomers.map((customer) {

                    final firstName = customer['firstName'] ?? '';
                    final lastName = customer['lastName'] ?? '';

                    final creatorName =
                    customer['creator'] != null && customer['creator']['name'] != null
                        ? customer['creator']['name']
                        : 'Unknown';

                    final initials =
                    '${firstName.isNotEmpty ? firstName[0] : ''}${lastName.isNotEmpty ? lastName[0] : ''}'
                        .toUpperCase();

                    final isActive = customer['status'] != 'Inactive';


                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _buildCustomerCard(
                        initials: initials,
                        name: '$firstName $lastName',
                        phone: customer['phone'] ?? 'N/A',
                        email: customer['email'] ?? 'N/A',
                        policies: 0,
                        amount: '₹0',
                        isActive: isActive,
                        backgroundColor: AppColors.primary,
                        creatorName: creatorName,
                      ),

                    );
                  }).toList(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomerCard({
    required String initials,
    required String name,
    required String phone,
    required String email,
    required int policies,
    required String amount,
    required bool isActive,
    required Color backgroundColor,
    required String creatorName,

  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 45,
                height: 45,
                decoration: BoxDecoration(
                  color: backgroundColor,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    initials,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            name,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textColor1,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: isActive
                                ? const Color(0xFFE8F8F5)
                                : const Color(0xFFFFE5E5),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            isActive ? 'Active' : 'Inactive',
                            style: TextStyle(
                              color: isActive ? AppColors.success : AppColors.error,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(
                          Icons.phone_outlined,
                          size: 16,
                          color: Colors.grey,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          phone,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(
                          Icons.person_outline,
                          size: 14,
                          color: Colors.grey,
                        ),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            'Added by – $creatorName',
                            style: const TextStyle(
                              fontSize: 13,
                              color: Colors.grey,
                              fontStyle: FontStyle.italic,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),

                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    policies.toString(),
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textColor1,
                    ),
                  ),
                  const Text(
                    'Policies',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    const Icon(
                      Icons.email_outlined,
                      size: 18,
                      color: Colors.grey,
                    ),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        email,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                amount,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class AddCustomerDialog extends StatefulWidget {
  final VoidCallback onCustomerAdded;

  const AddCustomerDialog({
    Key? key,
    required this.onCustomerAdded,
  }) : super(key: key);

  @override
  State<AddCustomerDialog> createState() => _AddCustomerDialogState();
}

class _AddCustomerDialogState extends State<AddCustomerDialog> {
  final ApiService _apiService = ApiService();

  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _aadharController = TextEditingController();
  final TextEditingController _panController = TextEditingController();
  final TextEditingController _groupController = TextEditingController();
  final TextEditingController _joinDateController = TextEditingController();

  String _status = 'Active';
  bool _isSubmitting = false;

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _aadharController.dispose();
    _panController.dispose();
    _groupController.dispose();
    _joinDateController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (picked != null) {
      setState(() {
        _joinDateController.text =
        picked.toIso8601String().split('T')[0];
      });
    }
  }

  Future<void> _submitForm() async {
    setState(() => _isSubmitting = true);

    try {
      final response = await _apiService.addCustomer(
        firstName: _firstNameController.text,
        lastName: _lastNameController.text,
        email: _emailController.text,
        phone: _phoneController.text,
        aadharNumber: _aadharController.text,
        panNumber: _panController.text,
        customerGroup: _groupController.text,
        joinDate: _joinDateController.text,
        status: _status,
      );

      setState(() => _isSubmitting = false);

      if (response['success']) {
        Navigator.pop(context);
        widget.onCustomerAdded();

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Customer added successfully'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response['message'] ?? 'Failed to add customer'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      setState(() => _isSubmitting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ---------- HEADER ----------
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Add Customer",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),

            const SizedBox(height: 8),
            const Text(
              "Customer Information",
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.grey,
              ),
            ),

            const SizedBox(height: 20),

            // ---------- NAME ----------
            Row(
              children: [
                Expanded(
                  child: PrimaryTextField(
                    hintText: "First Name",
                    controller: _firstNameController,
                    prefixIcon: const Icon(Icons.person_outline),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: PrimaryTextField(
                    hintText: "Last Name",
                    controller: _lastNameController,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // ---------- EMAIL & PHONE ----------
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: PrimaryTextField(
                    hintText: "Email Address",
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    prefixIcon: const Icon(Icons.email_outlined),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: PrimaryTextField(
                    hintText: "Phone",
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    prefixIcon: const Icon(Icons.phone_outlined),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // ---------- AADHAR & PAN ----------
            Row(
              children: [
                Expanded(
                  child: PrimaryTextField(
                    hintText: "Aadhaar Number",
                    controller: _aadharController,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: PrimaryTextField(
                    hintText: "PAN Number",
                    controller: _panController,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // ---------- GROUP & STATUS ----------
            Row(
              children: [
                Expanded(
                  child: PrimaryTextField(
                    hintText: "Customer Group",
                    controller: _groupController,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _status,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'Active', child: Text('Active')),
                      DropdownMenuItem(value: 'Inactive', child: Text('Inactive')),
                    ],
                    onChanged: (val) => setState(() => _status = val!),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // ---------- JOIN DATE ----------
            GestureDetector(
              onTap: _selectDate,
              child: AbsorbPointer(
                child: PrimaryTextField(
                  hintText: "Join Date",
                  controller: _joinDateController,
                  prefixIcon: const Icon(Icons.calendar_today),
                ),
              ),
            ),

            const SizedBox(height: 28),

            // ---------- ACTIONS ----------
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed:
                  _isSubmitting ? null : () => Navigator.pop(context),
                  child: const Text("Cancel"),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: _isSubmitting ? null : _submitForm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 28,
                      vertical: 14,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isSubmitting
                      ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor:
                      AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                      : const Text(
                    "Add Customer",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
