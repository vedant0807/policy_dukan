import 'package:flutter/material.dart';
import 'package:policy_dukaan/utils/app_colors.dart';
import 'package:policy_dukaan/widgets/custom_appbar.dart';
import 'package:policy_dukaan/api_service.dart';

class AddPolicyScreen extends StatefulWidget {
  const AddPolicyScreen({Key? key}) : super(key: key);

  @override
  State<AddPolicyScreen> createState() => _AddPolicyScreenState();
}

class _AddPolicyScreenState extends State<AddPolicyScreen> {
  final _formKey = GlobalKey<FormState>();
  final ApiService _apiService = ApiService();
  bool _isSubmitting = false;

  // Controllers for all form fields
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _mobileController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();
  final TextEditingController _aadharController = TextEditingController();
  final TextEditingController _panController = TextEditingController();
  final TextEditingController _groupController = TextEditingController();
  final TextEditingController _remarkController = TextEditingController();
  final TextEditingController _policyNumberController = TextEditingController();
  final TextEditingController _agentNameController = TextEditingController();
  final TextEditingController _policyStartDateController = TextEditingController();
  final TextEditingController _policyEndDateController = TextEditingController();
  final TextEditingController _premiumController = TextEditingController();
  final TextEditingController _monthTermController = TextEditingController();
  final TextEditingController _odAmountController = TextEditingController();
  final TextEditingController _yearOfBookingController = TextEditingController();
  final TextEditingController _thisYearPremiumController = TextEditingController();
  final TextEditingController _lastYearPremiumController = TextEditingController();
  final TextEditingController _currentInsuranceCompanyController = TextEditingController();
  final TextEditingController _previousInsuranceCompanyController = TextEditingController();
  final TextEditingController _policyRemarkController = TextEditingController();
  final TextEditingController _nomineeNameController = TextEditingController();
  final TextEditingController _nomineeRelationController = TextEditingController();
  final TextEditingController _additionalRemarkController = TextEditingController();
  final TextEditingController _vehicleNumberController = TextEditingController();
  final TextEditingController _vehicleModelController = TextEditingController();
  final TextEditingController _vehicleMakeController = TextEditingController();
  final TextEditingController _vehicleRemarkController = TextEditingController();

  String? _selectedPolicyType;
  String? _selectedFreshRenewal;
  String? _selectedPaymentMode;
  String? _selectedGroup;
  String? _selectedNomineeRelation;
  String? _selectedVehicleType;
  String? _selectedFuelType;

  List<dynamic> _companies = [];
  String? _selectedCompany;
  bool _isCompanyLoading = false;


  bool get _shouldShowVehicleInfo {
    if (_selectedPolicyType == null) return false;
    return _selectedPolicyType == 'Motor Insurance' ||
        _selectedPolicyType == 'Car Insurance' ||
        _selectedPolicyType == 'Bike Insurance';
  }

  // Helper function to convert dd-mm-yyyy to yyyy-mm-dd (ISO format)
  String? _convertDateToISO(String dateString) {
    if (dateString.isEmpty) return null;
    try {
      final parts = dateString.split('-');
      if (parts.length == 3) {
        return '${parts[2]}-${parts[1]}-${parts[0]}'; // yyyy-mm-dd
      }
    } catch (e) {
      print('Date conversion error: $e');
    }
    return null;
  }

  @override
  void initState() {
    super.initState();
    _fetchCompanies();
  }

  Future<void> _fetchCompanies() async {
    setState(() {
      _isCompanyLoading = true;
    });

    final response = await _apiService.getCompanies();

    if (response['success'] == true) {
      setState(() {
        _companies = response['data'];
      });
    } else {
      _showErrorSnackBar(response['message'] ?? 'Failed to load companies');
    }

    setState(() {
      _isCompanyLoading = false;
    });
  }



  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      // Convert dates to ISO format
      final dobISO = _convertDateToISO(_dobController.text);
      final startDateISO = _convertDateToISO(_policyStartDateController.text);
      final endDateISO = _convertDateToISO(_policyEndDateController.text);

      if (dobISO == null || startDateISO == null || endDateISO == null) {
        _showErrorSnackBar('Invalid date format. Please check all dates.');
        return;
      }

      final response = await _apiService.addPolicy(
        // Required fields
        customerFirstName: _firstNameController.text,
        customerLastName: _lastNameController.text,
        mobile: _mobileController.text,
        email: _emailController.text,
        dateOfBirth: dobISO,
        policyNumber: _policyNumberController.text,
        policyType: _selectedPolicyType!,
        policyStartDate: startDateISO,
        policyEndDate: endDateISO,
        premiumWithGst: _premiumController.text,
        // Optional fields
        aadharNumber: _aadharController.text.isEmpty ? null : _aadharController.text,
        panNumber: _panController.text.isEmpty ? null : _panController.text,
        customerGroup: _selectedGroup,
        customerRemark: _remarkController.text.isEmpty ? null : _remarkController.text,
        agentName: _agentNameController.text.isEmpty ? null : _agentNameController.text,
        monthTerm: _monthTermController.text.isEmpty ? null : _monthTermController.text,
        odAmount: _odAmountController.text.isEmpty ? null : _odAmountController.text,
        freshRenewal: _selectedFreshRenewal,
        paymentMode: _selectedPaymentMode,
        yearOfBooking: _yearOfBookingController.text.isEmpty ? null : _yearOfBookingController.text,
        thisYearPremium: _thisYearPremiumController.text.isEmpty ? null : _thisYearPremiumController.text,
        lastYearPremium: _lastYearPremiumController.text.isEmpty ? null : _lastYearPremiumController.text,
        currentInsuranceCompany: _selectedCompany,
        previousInsuranceCompany: _selectedCompany,
        policyRemark: _policyRemarkController.text.isEmpty ? null : _policyRemarkController.text,
        vehicleNumber: _vehicleNumberController.text.isEmpty ? null : _vehicleNumberController.text,
        vehicleModel: _vehicleModelController.text.isEmpty ? null : _vehicleModelController.text,
        vehicleType: _selectedVehicleType,
        fuelType: _selectedFuelType,
        make: _vehicleMakeController.text.isEmpty ? null : _vehicleMakeController.text,
        vehicleRemark: _vehicleRemarkController.text.isEmpty ? null : _vehicleRemarkController.text,
        nomineeName: _nomineeNameController.text.isEmpty ? null : _nomineeNameController.text,
        nomineeRelation: _selectedNomineeRelation,
        additionalRemark: _additionalRemarkController.text.isEmpty ? null : _additionalRemarkController.text,
      );

      if (response['success'] == true) {
        _showSuccessSnackBar(response['message']?.toString() ?? 'Policy added successfully!');
        _clearForm();
        // Optional: Navigate back or to policy list
        // Navigator.pop(context);
      } else {
        _showErrorSnackBar(response['message']?.toString() ?? 'Failed to add policy');
      }
    } catch (e) {
      print('Error submitting form: $e');
      _showErrorSnackBar('Error adding policy: ${e.toString()}');
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  void _clearForm() {
    _formKey.currentState?.reset();
    _firstNameController.clear();
    _lastNameController.clear();
    _mobileController.clear();
    _emailController.clear();
    _dobController.clear();
    _aadharController.clear();
    _panController.clear();
    _groupController.clear();
    _remarkController.clear();
    _policyNumberController.clear();
    _agentNameController.clear();
    _policyStartDateController.clear();
    _policyEndDateController.clear();
    _premiumController.clear();
    _monthTermController.clear();
    _odAmountController.clear();
    _yearOfBookingController.clear();
    _thisYearPremiumController.clear();
    _lastYearPremiumController.clear();
    _currentInsuranceCompanyController.clear();
    _previousInsuranceCompanyController.clear();
    _policyRemarkController.clear();
    _nomineeNameController.clear();
    _nomineeRelationController.clear();
    _additionalRemarkController.clear();
    _vehicleNumberController.clear();
    _vehicleModelController.clear();
    _vehicleMakeController.clear();
    _vehicleRemarkController.clear();

    setState(() {
      _selectedPolicyType = null;
      _selectedFreshRenewal = null;
      _selectedPaymentMode = null;
      _selectedGroup = null;
      _selectedNomineeRelation = null;
      _selectedVehicleType = null;
      _selectedFuelType = null;
    });
  }

  void _showSuccessSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _mobileController.dispose();
    _emailController.dispose();
    _dobController.dispose();
    _aadharController.dispose();
    _panController.dispose();
    _groupController.dispose();
    _remarkController.dispose();
    _policyNumberController.dispose();
    _agentNameController.dispose();
    _policyStartDateController.dispose();
    _policyEndDateController.dispose();
    _premiumController.dispose();
    _monthTermController.dispose();
    _odAmountController.dispose();
    _yearOfBookingController.dispose();
    _thisYearPremiumController.dispose();
    _lastYearPremiumController.dispose();
    _currentInsuranceCompanyController.dispose();
    _previousInsuranceCompanyController.dispose();
    _policyRemarkController.dispose();
    _nomineeNameController.dispose();
    _nomineeRelationController.dispose();
    _additionalRemarkController.dispose();
    _vehicleNumberController.dispose();
    _vehicleModelController.dispose();
    _vehicleMakeController.dispose();
    _vehicleRemarkController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context, TextEditingController controller) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        controller.text = "${picked.day.toString().padLeft(2, '0')}-${picked.month.toString().padLeft(2, '0')}-${picked.year}";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const CustomAppBar(
        title: "Add Policy",
        centerTitle: true,
        showNotificationDot: true,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'General Insurance Application',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Complete your insurance policy application with ease.',
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
              const SizedBox(height: 20),

              // Customer Information
              _buildSectionHeader('Customer Information', Icons.person),
              const SizedBox(height: 12),
              _buildCard([
                _buildTextField('First Name *', 'Enter first name', _firstNameController, isRequired: true),
                const SizedBox(height: 16),
                _buildTextField('Last Name *', 'Enter last name', _lastNameController, isRequired: true),
                const SizedBox(height: 16),
                _buildTextField('Mobile Number *', 'Enter mobile number', _mobileController, isRequired: true, keyboardType: TextInputType.phone),
                const SizedBox(height: 16),
                _buildTextField('Email Address *', 'Enter email address', _emailController, isRequired: true, keyboardType: TextInputType.emailAddress),
                const SizedBox(height: 16),
                _buildDateField('Date of Birth *', 'dd-mm-yyyy', _dobController, isRequired: true),
                const SizedBox(height: 16),
                _buildTextField('Aadhar Number', 'Enter Aadhar number', _aadharController),
                const SizedBox(height: 16),
                _buildTextField('PAN Number', 'Enter PAN number', _panController),
                const SizedBox(height: 16),
                _buildDropdownField('Group', 'Select group', _selectedGroup, ['Family', 'Individual', 'Corporate'], (value) {
                  setState(() => _selectedGroup = value);
                }),
                const SizedBox(height: 16),
                _buildTextField('Remark', 'Enter any additional remarks', _remarkController, maxLines: 3),
              ]),

              const SizedBox(height: 24),

              // Policy Information
              _buildSectionHeader('Policy Information', Icons.shield),
              const SizedBox(height: 12),
              _buildCard([
                _buildTextField('Policy Number *', 'Enter policy number', _policyNumberController, isRequired: true),
                const SizedBox(height: 16),
                _buildDropdownField(
                  'Policy Type *',
                  'Select policy type',
                  _selectedPolicyType,
                  ['Health Insurance', 'Life Insurance', 'Motor Insurance', 'Car Insurance', 'Bike Insurance', 'Travel Insurance', 'Home Insurance'],
                      (value) {
                    setState(() {
                      _selectedPolicyType = value;
                      if (!_shouldShowVehicleInfo) {
                        _vehicleNumberController.clear();
                        _vehicleModelController.clear();
                        _vehicleMakeController.clear();
                        _vehicleRemarkController.clear();
                        _selectedVehicleType = null;
                        _selectedFuelType = null;
                      }
                    });
                  },
                  isRequired: true,
                ),
                const SizedBox(height: 16),
                _buildTextField('Agent Name', 'Enter agent name', _agentNameController),
                const SizedBox(height: 16),
                _buildDateField('Policy Start Date *', 'dd-mm-yyyy', _policyStartDateController, isRequired: true),
                const SizedBox(height: 16),
                _buildDateField('Policy End Date *', 'dd-mm-yyyy', _policyEndDateController, isRequired: true),
                const SizedBox(height: 16),
                _buildTextField('Premium with GST *', 'Enter premium amount', _premiumController, isRequired: true, keyboardType: TextInputType.number),
                const SizedBox(height: 16),
                _buildDropdownField('Fresh / Renewal', 'Select type', _selectedFreshRenewal, ['Fresh', 'Renewal'], (value) {
                  setState(() => _selectedFreshRenewal = value);
                }),
                const SizedBox(height: 16),
                _buildDropdownField('Payment Mode', 'Select payment mode', _selectedPaymentMode, ['Cash', 'Cheque', 'Online', 'UPI'], (value) {
                  setState(() => _selectedPaymentMode = value);
                }),
                const SizedBox(height: 16),
                _buildTextField('Year of Booking', 'Enter year', _yearOfBookingController, keyboardType: TextInputType.number),
                const SizedBox(height: 16),
                _buildTextField('Month Term', 'Enter months', _monthTermController, keyboardType: TextInputType.number),
                const SizedBox(height: 16),
                _buildTextField('OD Amount', 'Enter OD amount', _odAmountController, keyboardType: TextInputType.number),
                const SizedBox(height: 16),
                _buildTextField('This Year Premium', 'Enter this year premium', _thisYearPremiumController, keyboardType: TextInputType.number),
                const SizedBox(height: 16),
                _buildTextField('Last Year Premium', 'Enter last year premium', _lastYearPremiumController, keyboardType: TextInputType.number),
                const SizedBox(height: 16),
                _buildCompanyDropdown(),
                const SizedBox(height: 16),
                const SizedBox(height: 16),
                _buildTextField('Previous Insurance Company', 'Enter company name', _previousInsuranceCompanyController),
                const SizedBox(height: 16),
                _buildTextField('Policy Remark', 'Enter remark', _policyRemarkController, maxLines: 3),
              ]),

              const SizedBox(height: 24),

              // Vehicle Information (Conditional)
              if (_shouldShowVehicleInfo) ...[
                _buildSectionHeader('Vehicle Information', Icons.directions_car),
                const SizedBox(height: 12),
                _buildCard([
                  _buildTextField('Vehicle Number *', 'Enter vehicle number', _vehicleNumberController, isRequired: true),
                  const SizedBox(height: 16),
                  _buildTextField('Vehicle Model', 'Enter vehicle model', _vehicleModelController),
                  const SizedBox(height: 16),
                  _buildDropdownField('Fuel Type', 'Select fuel type', _selectedFuelType, ['Petrol', 'Diesel', 'CNG', 'Electric', 'Hybrid'], (value) {
                    setState(() => _selectedFuelType = value);
                  }),
                  const SizedBox(height: 16),
                  _buildDropdownField('Vehicle Type', 'Select vehicle type', _selectedVehicleType, ['Two Wheeler', 'Four Wheeler', 'Commercial Vehicle', 'Heavy Vehicle'], (value) {
                    setState(() => _selectedVehicleType = value);
                  }),
                  const SizedBox(height: 16),
                  _buildTextField('Make', 'Enter vehicle make', _vehicleMakeController),
                  const SizedBox(height: 16),
                  _buildTextField('Vehicle Remark', 'Enter vehicle remarks', _vehicleRemarkController, maxLines: 3),
                ]),
                const SizedBox(height: 24),
              ],

              // Nominee Information
              _buildSectionHeader('Nominee Information', Icons.person_outline),
              const SizedBox(height: 12),
              _buildCard([
                _buildTextField('Nominee Name', 'Enter nominee name', _nomineeNameController),
                const SizedBox(height: 16),
                _buildDropdownField('Nominee Relation', 'Select relation', _selectedNomineeRelation, ['Spouse', 'Child', 'Parent', 'Sibling', 'Other'], (value) {
                  setState(() => _selectedNomineeRelation = value);
                }),
              ]),

              const SizedBox(height: 24),

              // Additional Information
              _buildSectionHeader('Additional Information', Icons.description),
              const SizedBox(height: 12),
              _buildCard([
                _buildTextField('Additional Remark', 'Enter any additional information or remarks', _additionalRemarkController, maxLines: 4),
              ]),

              const SizedBox(height: 24),

              // Submit Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _submitForm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    disabledBackgroundColor: AppColors.primary.withOpacity(0.6),
                    padding: const EdgeInsets.symmetric(vertical: 16),
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
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                      : const Text(
                    'Submit',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: AppColors.primary, size: 20),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }

  Widget _buildCard(List<Widget> children) {
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
      child: Column(children: children),
    );
  }

  Widget _buildTextField(
      String label,
      String hint,
      TextEditingController controller, {
        bool isRequired = false,
        TextInputType keyboardType = TextInputType.text,
        int maxLines = 1,
      }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          enabled: !_isSubmitting,
          keyboardType: keyboardType,
          maxLines: maxLines,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.grey[400]),
            filled: true,
            fillColor: Colors.grey[50],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppColors.primary, width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
          validator: isRequired
              ? (value) {
            if (value == null || value.isEmpty) {
              return 'This field is required';
            }
            return null;
          }
              : null,
        ),
      ],
    );
  }

  Widget _buildDateField(
      String label,
      String hint,
      TextEditingController controller, {
        bool isRequired = false,
      }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          readOnly: true,
          enabled: !_isSubmitting,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.grey[400]),
            filled: true,
            fillColor: Colors.grey[50],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppColors.primary, width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            suffixIcon: Icon(Icons.calendar_today, color: Colors.grey[600], size: 20),
          ),
          onTap: () => _selectDate(context, controller),
          validator: isRequired
              ? (value) {
            if (value == null || value.isEmpty) {
              return 'This field is required';
            }
            return null;
          }
              : null,
        ),
      ],
    );
  }

  Widget _buildDropdownField(
      String label,
      String hint,
      String? value,
      List<String> items,
      Function(String?) onChanged, {
        bool isRequired = false,
      }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: value,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.grey[400]),
            filled: true,
            fillColor: Colors.grey[50],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppColors.primary, width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
          items: items.map((String item) {
            return DropdownMenuItem<String>(
              value: item,
              child: Text(item),
            );
          }).toList(),
          onChanged: _isSubmitting ? null : onChanged,
          validator: isRequired
              ? (value) {
            if (value == null || value.isEmpty) {
              return 'This field is required';
            }
            return null;
          }
              : null,
        ),
      ],
    );
  }


  Widget _buildCompanyDropdown() {
    if (_isCompanyLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return _buildDropdownField(
      'Insurance Company *',
      'Select company',
      _selectedCompany,
      _companies.map<String>((company) {
        return company['name'].toString();
      }).toList(),
          (value) {
        setState(() {
          _selectedCompany = value;
        });
      },
      isRequired: true,
    );
  }

}




