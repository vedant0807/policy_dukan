import 'dart:convert';
import 'dart:io';
import 'package:excel/excel.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:policy_dukaan/session_manager.dart';

class ApiService {
  // Base URL - you can move this to a constants file later if needed
  static const String baseUrl = 'https://app.policydukan.in/api';
  // static const String baseUrl = 'http://192.168.1.10:3000/api';

  final SessionManager _sessionManager = SessionManager();

  // ✅ UPDATED: Helper method to get headers with Cookie auth
  Future<Map<String, String>> _getHeaders() async {
    final token = await _sessionManager.getToken();
    final headers = {
      'Content-Type': 'application/json',
    };

    if (token != null && token.isNotEmpty) {
      headers['Cookie'] = 'auth_token=$token'; // ✅ Changed to Cookie format
      print('🔑 Using token in request: ${token}...');
    }

    return headers;
  }

  /// Sign Up API call
  Future<Map<String, dynamic>> signUp({
    required String name,
    required String email,
    required String mobileNumber,
  }) async {
    final url = Uri.parse('$baseUrl/auth/signup');

    print('📤 SignUp Request URL: $url');
    print('📤 SignUp Payload: ${jsonEncode({
      "name": name.trim(),
      "email": email.trim(),
      "mobileNumber": mobileNumber.trim(),
    })}');

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        "name": name.trim(),
        "email": email.trim(),
        "mobileNumber": mobileNumber.trim(),
      }),
    );

    print('📥 SignUp Response Status: ${response.statusCode}');
    print('📥 SignUp Response Body: ${response.body}');

    final Map<String, dynamic> responseBody = jsonDecode(response.body);

    if (response.statusCode == 200 || response.statusCode == 201) {
      return {
        'success': true,
        'data': responseBody,
      };
    } else {
      return {
        'success': false,
        'message': responseBody['message'] ?? 'Signup failed',
      };
    }
  }

  Future<Map<String, dynamic>> sendOtp({required String email}) async {
    final url = Uri.parse('$baseUrl/auth/send-otp');

    print('📤 SendOtp Request URL: $url');
    print('📤 SendOtp Payload: ${jsonEncode({"email": email.trim()})}');

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        "email": email.trim(),
      }),
    );

    print('📥 SendOtp Response Status: ${response.statusCode}');
    print('📥 SendOtp Response Body: ${response.body}');

    final Map<String, dynamic> responseBody = jsonDecode(response.body);

    if (response.statusCode == 200 || response.statusCode == 201) {
      return {
        'success': true,
        'data': responseBody,
      };
    } else {
      return {
        'success': false,
        'message': responseBody['message'] ?? 'Failed to send OTP',
      };
    }
  }

  Future<Map<String, dynamic>> verifyOtp({
    required String email,
    required String otp,
  }) async {
    final url = Uri.parse('$baseUrl/auth/verify-otp');

    print('📤 VerifyOtp Request URL: $url');
    print('📤 VerifyOtp Payload: ${jsonEncode({
      "email": email.trim(),
      "otp": otp.trim(),
    })}');

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        "email": email.trim(),
        "otp": otp.trim(),
      }),
    );

    print('📥 VerifyOtp Response Status: ${response.statusCode}');
    print('📥 VerifyOtp Response Body: ${response.body}');

    final Map<String, dynamic> responseBody = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return {
        'success': true,
        'message': responseBody['message'] ?? 'Login successful',
        'token': responseBody['token'],
        'user': responseBody['user'],
      };
    } else {
      return {
        'success': false,
        'message': responseBody['message'] ?? 'Invalid or expired OTP',
      };
    }
  }

  /// Get Customers API call
  Future<Map<String, dynamic>> getCustomers() async {
    final url = Uri.parse('$baseUrl/customers');

    print('📤 GetCustomers Request URL: $url');

    try {
      final headers = await _getHeaders(); // ✅ Now uses Cookie format

      final response = await http.get(
        url,
        headers: headers,
      );

      print('📥 GetCustomers Response Status: ${response.statusCode}');
      print('📥 GetCustomers Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final List<dynamic> responseBody = jsonDecode(response.body);
        return {
          'success': true,
          'data': responseBody,
        };
      } else {
        final Map<String, dynamic> errorBody = jsonDecode(response.body);
        return {
          'success': false,
          'message': errorBody['message'] ?? 'Failed to fetch customers',
        };
      }
    } catch (e) {
      print('❌ GetCustomers Error: $e');
      return {
        'success': false,
        'message': 'Error: $e',
      };
    }
  }

  /// Add Customer API call
  Future<Map<String, dynamic>> addCustomer({
    required String firstName,
    required String lastName,
    required String email,
    required String phone,
    required String aadharNumber,
    required String panNumber,
    required String customerGroup,
    required String joinDate,
    required String status,
  }) async {
    final url = Uri.parse('$baseUrl/customers');

    final payload = {
      "firstName": firstName.trim(),
      "lastName": lastName.trim(),
      "email": email.trim(),
      "phone": phone.trim(),
      "aadharNumber": aadharNumber.trim(),
      "panNumber": panNumber.trim(),
      "customerGroup": customerGroup.trim(),
      "joinDate": joinDate.trim(),
      "status": status,
    };

    print('📤 AddCustomer Request URL: $url');
    print('📤 AddCustomer Payload: ${jsonEncode(payload)}');

    try {
      final headers = await _getHeaders(); // ✅ Now uses Cookie format

      final response = await http.post(
        url,
        headers: headers,
        body: jsonEncode(payload),
      );

      print('📥 AddCustomer Response Status: ${response.statusCode}');
      print('📥 AddCustomer Response Body: ${response.body}');

      final Map<String, dynamic> responseBody = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return {
          'success': true,
          'data': responseBody,
        };
      } else {
        return {
          'success': false,
          'message': responseBody['message'] ?? 'Failed to add customer',
        };
      }
    } catch (e) {
      print('❌ AddCustomer Error: $e');
      return {
        'success': false,
        'message': 'Error: $e',
      };
    }
  }

  /// Get Policies API call
  Future<Map<String, dynamic>> getPolicies() async {
    final url = Uri.parse('$baseUrl/policies');

    print('📤 GetPolicies Request URL: $url');

    try {
      final headers = await _getHeaders(); // ✅ Now uses Cookie format

      print('🧾 Request Headers:');
      headers.forEach((key, value) {
        if (key.toLowerCase() == 'cookie') {
          print('   $key: ${value.substring(0, 30)}...');
        } else {
          print('   $key: $value');
        }
      });

      final response = await http.get(
        url,
        headers: headers,
      );

      print('📥 GetPolicies Response Status: ${response.statusCode}');
      print('📥 GetPolicies Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);

        List<dynamic> policiesList = [];
        if (decoded is List) {
          policiesList = decoded;
        } else if (decoded is Map && decoded.containsKey('data')) {
          policiesList = decoded['data'] is List ? decoded['data'] : [];
        } else if (decoded is Map && decoded.containsKey('policies')) {
          policiesList = decoded['policies'] is List ? decoded['policies'] : [];
        }

        return {
          'success': true,
          'data': policiesList,
        };
      } else {
        final errorBody = jsonDecode(response.body);
        return {
          'success': false,
          'message': errorBody['message'] ?? 'Failed to fetch policies',
        };
      }
    } catch (e) {
      print('❌ GetPolicies Error: $e');
      return {
        'success': false,
        'message': 'Error: $e',
      };
    }
  }

  /// Get Staff API call
  Future<Map<String, dynamic>> getStaff() async {
    final url = Uri.parse('$baseUrl/admin/staff');

    print('📤 GetStaff Request URL: $url');

    try {
      final headers = await _getHeaders(); // ✅ Now uses Cookie format

      final response = await http.get(
        url,
        headers: headers,
      );

      print('📥 GetStaff Response Status: ${response.statusCode}');
      print('📥 GetStaff Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseBody = jsonDecode(response.body);
        return {
          'success': true,
          'data': responseBody['staff'] ?? [],
        };
      } else {
        final Map<String, dynamic> errorBody = jsonDecode(response.body);
        return {
          'success': false,
          'message': errorBody['message'] ?? 'Failed to fetch staff',
        };
      }
    } catch (e) {
      print('❌ GetStaff Error: $e');
      return {
        'success': false,
        'message': 'Error: $e',
      };
    }
  }

  /// Add Staff Member API call
  Future<Map<String, dynamic>> addStaff({
    required String name,
    required String email,
    required String mobileNumber,
    required String salary,
    required List<String> permissions,
  }) async {
    final url = Uri.parse('$baseUrl/admin/staff');

    final payload = {
      "name": name.trim(),
      "email": email.trim(),
      "mobileNumber": mobileNumber.trim(),
      "salary": salary.trim(),
      "permissions": permissions,
    };

    print('📤 AddStaff Request URL: $url');
    print('📤 AddStaff Payload: ${jsonEncode(payload)}');

    try {
      final headers = await _getHeaders(); // ✅ Now uses Cookie format

      print('🧾 Request Headers:');
      headers.forEach((key, value) {
        if (key.toLowerCase() == 'cookie') {
          print('   $key: ${value.substring(0, 30)}...');
        } else {
          print('   $key: $value');
        }
      });

      final response = await http.post(
        url,
        headers: headers,
        body: jsonEncode(payload),
      );

      print('📥 AddStaff Response Status: ${response.statusCode}');
      print('📥 AddStaff Response Body: ${response.body}');

      final Map<String, dynamic> responseBody = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return {
          'success': true,
          'data': responseBody,
        };
      } else {
        return {
          'success': false,
          'message': responseBody['message'] ?? 'Failed to add staff',
        };
      }
    } catch (e) {
      print('❌ AddStaff Error: $e');
      return {
        'success': false,
        'message': 'Error: $e',
      };
    }
  }

  /// Delete Staff Member API call
  Future<Map<String, dynamic>> deleteStaff({
    required String staffId,
  }) async {
    final url = Uri.parse('$baseUrl/admin/staff/$staffId');

    print('📤 DeleteStaff Request URL: $url');

    try {
      final headers = await _getHeaders(); // ✅ Now uses Cookie format

      final response = await http.delete(
        url,
        headers: headers,
      );

      print('📥 DeleteStaff Response Status: ${response.statusCode}');
      print('📥 DeleteStaff Response Body: ${response.body}');

      final Map<String, dynamic> responseBody = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': responseBody['message'] ?? 'Staff deleted successfully',
        };
      } else {
        return {
          'success': false,
          'message': responseBody['message'] ?? 'Failed to delete staff',
        };
      }
    } catch (e) {
      print('❌ DeleteStaff Error: $e');
      return {
        'success': false,
        'message': 'Error: $e',
      };
    }
  }

  /// Get Companies API call
  Future<Map<String, dynamic>> getCompanies() async {
    final url = Uri.parse('$baseUrl/companies');

    print('📤 GetCompanies Request URL: $url');

    try {
      final headers = await _getHeaders(); // ✅ Now uses Cookie format

      final response = await http.get(
        url,
        headers: headers,
      );

      print('📥 GetCompanies Response Status: ${response.statusCode}');
      print('📥 GetCompanies Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final List<dynamic> responseBody = jsonDecode(response.body);
        return {
          'success': true,
          'data': responseBody,
        };
      } else {
        final Map<String, dynamic> errorBody = jsonDecode(response.body);
        return {
          'success': false,
          'message': errorBody['message'] ?? 'Failed to fetch companies',
        };
      }
    } catch (e) {
      print('❌ GetCompanies Error: $e');
      return {
        'success': false,
        'message': 'Error: $e',
      };
    }
  }

  /// Add Company API call
  Future<Map<String, dynamic>> addCompany({
    required String name,
    required String commissionRate,
  }) async {
    final url = Uri.parse('$baseUrl/companies');

    final payload = {
      "name": name.trim(),
      "commissionRate": int.tryParse(commissionRate.trim()) ?? 0,
    };

    print('📤 AddCompany Request URL: $url');
    print('📤 AddCompany Payload: ${jsonEncode(payload)}');

    try {
      final headers = await _getHeaders(); // ✅ Now uses Cookie format

      final response = await http.post(
        url,
        headers: headers,
        body: jsonEncode(payload),
      );

      print('📥 AddCompany Response Status: ${response.statusCode}');
      print('📥 AddCompany Response Body: ${response.body}');

      final Map<String, dynamic> responseBody = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return {
          'success': true,
          'data': responseBody,
        };
      } else {
        return {
          'success': false,
          'message': responseBody['message'] ?? 'Failed to add company',
        };
      }
    } catch (e) {
      print('❌ AddCompany Error: $e');
      return {
        'success': false,
        'message': 'Error: $e',
      };
    }
  }

  /// Add Policy API call
  Future<Map<String, dynamic>> addPolicy({
    // Required fields
    required String customerFirstName,
    required String customerLastName,
    required String mobile,
    required String email,
    required String dateOfBirth,
    required String policyNumber,
    required String policyType,
    required String policyStartDate,
    required String policyEndDate,
    required String premiumWithGst,
    // Optional fields
    String? aadharNumber,
    String? panNumber,
    String? customerGroup,
    String? customerRemark,
    String? agentName,
    String? monthTerm,
    String? odAmount,
    String? freshRenewal,
    String? paymentMode,
    String? yearOfBooking,
    String? thisYearPremium,
    String? lastYearPremium,
    String? currentInsuranceCompany,
    String? previousInsuranceCompany,
    String? policyRemark,
    String? vehicleNumber,
    String? vehicleModel,
    String? vehicleType,
    String? fuelType,
    String? make,
    String? vehicleRemark,
    String? nomineeName,
    String? nomineeRelation,
    String? additionalRemark,
  }) async {
    final url = Uri.parse('$baseUrl/policies');

    // Build payload with required fields
    final Map<String, dynamic> payload = {
      "customer_first_name": customerFirstName.trim(),
      "customer_last_name": customerLastName.trim(),
      "mobile": mobile.trim(),
      "email": email.trim(),
      "date_of_birth": dateOfBirth.trim(),
      "policy_number": policyNumber.trim(),
      "policy_type": policyType.trim(),
      "policy_start_date": policyStartDate.trim(),
      "policy_end_date": policyEndDate.trim(),
      "premium_with_gst": double.tryParse(premiumWithGst.trim()) ?? 0.0,
    };

    // Add optional fields only if they have values
    if (aadharNumber != null && aadharNumber.trim().isNotEmpty) {
      payload["aadhar_number"] = aadharNumber.trim();
    }
    if (panNumber != null && panNumber.trim().isNotEmpty) {
      payload["pan_number"] = panNumber.trim();
    }
    if (customerGroup != null && customerGroup.trim().isNotEmpty) {
      payload["customer_group"] = customerGroup.trim();
    }
    if (customerRemark != null && customerRemark.trim().isNotEmpty) {
      payload["customer_remark"] = customerRemark.trim();
    }
    if (agentName != null && agentName.trim().isNotEmpty) {
      payload["agent_name"] = agentName.trim();
    }
    if (monthTerm != null && monthTerm.trim().isNotEmpty) {
      payload["month_term"] = int.tryParse(monthTerm.trim()) ?? 0;
    }
    if (odAmount != null && odAmount.trim().isNotEmpty) {
      payload["od_amount"] = double.tryParse(odAmount.trim()) ?? 0.0;
    }
    if (freshRenewal != null && freshRenewal.trim().isNotEmpty) {
      payload["fresh_renewal"] = freshRenewal.trim();
    }
    if (paymentMode != null && paymentMode.trim().isNotEmpty) {
      payload["payment_mode"] = paymentMode.trim();
    }
    if (yearOfBooking != null && yearOfBooking.trim().isNotEmpty) {
      payload["year_of_booking"] = yearOfBooking.trim();
    }
    if (thisYearPremium != null && thisYearPremium.trim().isNotEmpty) {
      payload["this_year_premium"] = double.tryParse(thisYearPremium.trim()) ?? 0.0;
    }
    if (lastYearPremium != null && lastYearPremium.trim().isNotEmpty) {
      payload["last_year_premium"] = double.tryParse(lastYearPremium.trim()) ?? 0.0;
    }
    if (currentInsuranceCompany != null && currentInsuranceCompany.trim().isNotEmpty) {
      payload["current_insurance_company"] = currentInsuranceCompany.trim();
    }
    if (previousInsuranceCompany != null && previousInsuranceCompany.trim().isNotEmpty) {
      payload["previous_insurance_company"] = previousInsuranceCompany.trim();
    }
    if (policyRemark != null && policyRemark.trim().isNotEmpty) {
      payload["policy_remark"] = policyRemark.trim();
    }
    if (vehicleNumber != null && vehicleNumber.trim().isNotEmpty) {
      payload["vehicle_number"] = vehicleNumber.trim();
    }
    if (vehicleModel != null && vehicleModel.trim().isNotEmpty) {
      payload["vehicle_model"] = vehicleModel.trim();
    }
    if (vehicleType != null && vehicleType.trim().isNotEmpty) {
      payload["vehicle_type"] = vehicleType.trim();
    }
    if (fuelType != null && fuelType.trim().isNotEmpty) {
      payload["fuel_type"] = fuelType.trim();
    }
    if (make != null && make.trim().isNotEmpty) {
      payload["make"] = make.trim();
    }
    if (vehicleRemark != null && vehicleRemark.trim().isNotEmpty) {
      payload["vehicle_remark"] = vehicleRemark.trim();
    }
    if (nomineeName != null && nomineeName.trim().isNotEmpty) {
      payload["nominee_name"] = nomineeName.trim();
    }
    if (nomineeRelation != null && nomineeRelation.trim().isNotEmpty) {
      payload["nominee_relation"] = nomineeRelation.trim();
    }
    if (additionalRemark != null && additionalRemark.trim().isNotEmpty) {
      payload["additional_remark"] = additionalRemark.trim();
    }

    print('📤 AddPolicy Request URL: $url');
    print('📤 AddPolicy Payload: ${jsonEncode(payload)}');

    try {
      final headers = await _getHeaders(); // ✅ Now uses Cookie format

      final response = await http.post(
        url,
        headers: headers,
        body: jsonEncode(payload),
      );

      print('📥 AddPolicy Response Status: ${response.statusCode}');
      print('📥 AddPolicy Response Body: ${response.body}');

      final Map<String, dynamic> responseBody = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return {
          'success': true,
          'data': responseBody,
          'message': responseBody['message'] ?? 'Policy added successfully',
        };
      } else {
        return {
          'success': false,
          'message': responseBody['message'] ?? 'Failed to add policy',
        };
      }
    } catch (e) {
      print('❌ AddPolicy Error: $e');
      return {
        'success': false,
        'message': 'Error: $e',
      };
    }
  }

  Future<List<Map<String, dynamic>>> getLeads() async {
    final Uri url = Uri.parse('$baseUrl/leads');

    try {
      final headers = await _getHeaders();

      final http.Response response = await http.get(
        url,
        headers: headers,
      );

      print('📥 GetLeads Status Code: ${response.statusCode}');
      print('📥 GetLeads Raw Response: ${response.body}');

      if (response.statusCode == 200) {
        final List<dynamic> decoded = jsonDecode(response.body);

        // 🔥 Print each lead nicely
        for (var lead in decoded) {
          print('👉 Lead: $lead');
        }

        return List<Map<String, dynamic>>.from(decoded);
      } else {
        throw Exception(
          "Failed to fetch leads: ${response.statusCode}",
        );
      }
    } catch (e) {
      print('❌ GetLeads Error: $e');
      throw Exception('Error calling get leads API');
    }
  }

  Future<Map<String, dynamic>> addLead({
    required String firstName,
    required String lastName,
    required String email,
    required String phone,
    required String interest,
    required String priority,
    required String source,
    required String notes,
  }) async {
    try {
      // 1️⃣ URL
      final url = Uri.parse('$baseUrl/leads');

      // 2️⃣ Headers (FROM YOUR METHOD)
      final headers = await _getHeaders();

      // 3️⃣ Payload
      final Map<String, dynamic> payload = {
        "first_name": firstName,
        "last_name": lastName,
        "email": email,
        "phone": phone,
        "interest": interest,
        "priority": priority,
        "source": source,
        "notes": notes,
        "status": "New",
      };

      print('📤 AddLead URL: $url');
      print('📤 AddLead Payload: ${jsonEncode(payload)}');

      // 4️⃣ POST CALL
      final response = await http.post(
        url,
        headers: headers,
        body: jsonEncode(payload),
      );

      print('📥 Status Code: ${response.statusCode}');
      print('📥 Response Body: ${response.body}');

      // 5️⃣ Response handling
      final responseBody = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return {
          'success': true,
          'data': responseBody,
        };
      } else {
        return {
          'success': false,
          'message': responseBody['message'] ?? 'Failed to add lead',
        };
      }
    } catch (e) {
      print('❌ AddLead Error: $e');
      return {
        'success': false,
        'message': 'Something went wrong',
      };
    }
  }

// Future<Map<String,dynamic>> addLead({
  //   required String firstName,
  //   required String lastName,
  //   required String email,
  //   required String phone,
  //   required String interest,
  //   required String source,
  //   required String priority,
  //   required String notes,
  //
  // }) async {
  //
  //   try{
  //     final url = Uri.parse("$baseUrl/leads");
  //
  //     final headers = _getHeaders();
  //
  //     final Map<String,dynamic> payload ={
  //       "first_name" : firstName,
  //       "last_name": lastName,
  //       "email": email,
  //       "phone": phone,
  //       "interest": interest,
  //       "priority": priority,
  //       "source": source,
  //       "notes": notes,
  //       "status": "New",
  //     };
  //
  //     final response = await http.post(
  //       url,
  //       headers: headers,
  //       body: jsonEncode(payload),
  //     );
  //
  //     if(response.statusCode==200 || response.statusCode ==201){
  //       return{
  //         'sucess':true,
  //         'data': responseBody,
  //       };
  //     }else{
  //       return{
  //         'sucess':false,
  //         'message': responseBody['message'] ?? 'Failed to add lead',
  //
  //       };
  //     }
  //
  //   }catch(e){
  //     print('❌ AddLead Error: $e');
  //     return {
  //       'success': false,
  //       'message': 'Something went wrong',
  //     };
  //   }
  //
  // }

  Future<Map<String, dynamic>> deleteLead(String leadId) async {
    final Uri url = Uri.parse('$baseUrl/leads/$leadId');

    print('🗑️ DeleteLead URL: $url');

    try {
      final headers = await _getHeaders();

      final http.Response response = await http.delete(
        url,
        headers: headers,
      );

      print('📥 DeleteLead Status: ${response.statusCode}');
      print('📥 DeleteLead Body: ${response.body}');

      // ✅ 204 = SUCCESS (No Content)
      if (response.statusCode == 200 || response.statusCode == 204) {
        return {
          'success': true,
          'message': 'Lead deleted successfully',
        };
      }

      // ❌ Only decode body if it exists
      if (response.body.isNotEmpty) {
        final errorBody = jsonDecode(response.body);
        return {
          'success': false,
          'message': errorBody['message'] ?? 'Failed to delete lead',
        };
      }

      return {
        'success': false,
        'message': 'Failed to delete lead',
      };
    } catch (e) {
      print('❌ DeleteLead Error: $e');
      return {
        'success': false,
        'message': 'Something went wrong',
      };
    }
  }

  Future<Map<String, dynamic>> getCommissions() async {
    final url = Uri.parse('$baseUrl/commissions');

    print('📤 GetCommissions URL: $url');

    try {
      final headers = await _getHeaders();

      final response = await http.get(
        url,
        headers: headers,
      );

      print('📥 GetCommissions Status: ${response.statusCode}');
      print('📥 GetCommissions Body: ${response.body}');

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);

        return {
          'success': true,
          'stats': decoded['stats'],
          'items': decoded['items'],
        };
      } else {
        return {
          'success': false,
          'message': 'Failed to load commissions',
        };
      }
    } catch (e) {
      print('❌ GetCommissions Error: $e');
      return {
        'success': false,
        'message': e.toString(),
      };
    }
  }

  Future<Map<String, dynamic>?> fetchCurrentPlan(String token) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/subscriptions'),
        headers: {'Cookie': 'auth_token=$token'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data;
      }
      return null;
    } catch (e) {
      throw Exception('Error fetching plan: $e');
    }
  }

  /// Create Razorpay order
  Future<String?> createRazorpayOrder(String token, int amount) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/razorpay/order'),
        headers: {
          'Cookie': 'auth_token=$token',
          'Content-Type': 'application/json',
        },
        body: json.encode({'amount': amount}),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = json.decode(response.body);
        return data['id'];
      }
      throw Exception('Failed to create order: ${response.statusCode}');
    } catch (e) {
      throw Exception('Error creating Razorpay order: $e');
    }
  }

  /// Create invoice
  Future<void> createInvoice(
      String token, {
        required String planId,
        required String name,
        required String email,
        required String mobileNumber,
        required String address,
        required String gstNumber,
        required String state,
      }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/invoices'),
        headers: {
          'Cookie': 'auth_token=$token',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'planId': planId,
          'name': name,
          'email': email,
          'mobileNumber': mobileNumber,
          'address': address,
          'gstNumber': gstNumber,
          'state': state,
        }),
      );

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception('Failed to create invoice: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error creating invoice: $e');
    }
  }

  Future<Map<String, dynamic>> bulkImportPolicies(File file) async {
    final url = Uri.parse('$baseUrl/policies/import');

    print('📤 BulkImportPolicies Request URL: $url');
    print('📤 File path: ${file.path}');

    try {
      final headers = await _getHeaders();

      // Remove Content-Type from headers as multipart will set it automatically
      headers.remove('Content-Type');

      // Create multipart request
      var request = http.MultipartRequest('POST', url);

      // Add headers (Cookie for auth)
      request.headers.addAll(headers);

      // Add file to request
      request.files.add(
        await http.MultipartFile.fromPath(
          'file', // This is the field name expected by the backend
          file.path,
        ),
      );

      print('📤 Sending multipart request...');

      // Send request
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      print('📥 BulkImportPolicies Response Status: ${response.statusCode}');
      print('📥 BulkImportPolicies Response Body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> responseBody = jsonDecode(response.body);
        return {
          'success': true,
          'data': responseBody,
          'message': responseBody['message'] ?? 'Import completed successfully',
          'inserted': responseBody['inserted'] ?? 0,
          'total': responseBody['total'] ?? 0,
          'skippedInFile': responseBody['skippedInFile'] ?? 0,
          'skipReasons': responseBody['skipReasons'] ?? {},
        };
      } else {
        final Map<String, dynamic> errorBody = jsonDecode(response.body);
        return {
          'success': false,
          'message': errorBody['message'] ?? 'Failed to import policies',
        };
      }
    } catch (e) {
      print('❌ BulkImportPolicies Error: $e');
      return {
        'success': false,
        'message': 'Error: $e',
      };
    }
  }

  Future<Map<String, dynamic>> getExpiredPolicies() async {
    final url = Uri.parse('$baseUrl/policies/expired');

    print('📤 GetExpiredPolicies Request URL: $url');

    try {
      final headers = await _getHeaders();

      final response = await http.get(
        url,
        headers: headers,
      );

      print('📥 GetExpiredPolicies Response Status: ${response.statusCode}');
      print('📥 GetExpiredPolicies Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);

        List<dynamic> policiesList = [];
        if (decoded is List) {
          policiesList = decoded;
        } else if (decoded is Map && decoded.containsKey('data')) {
          policiesList = decoded['data'] is List ? decoded['data'] : [];
        } else if (decoded is Map && decoded.containsKey('policies')) {
          policiesList = decoded['policies'] is List ? decoded['policies'] : [];
        }

        return {
          'success': true,
          'data': policiesList,
        };
      } else {
        final errorBody = jsonDecode(response.body);
        return {
          'success': false,
          'message': errorBody['message'] ?? 'Failed to fetch expired policies',
        };
      }
    } catch (e) {
      print('❌ GetExpiredPolicies Error: $e');
      return {
        'success': false,
        'message': 'Error: $e',
      };
    }
  }

  Future<Map<String, dynamic>> exportPolicies() async {
    final url = Uri.parse('$baseUrl/policies/export?format=xlsx');

    print('📤 ExportPolicies Request URL: $url');

    try {
      final headers = await _getHeaders();

      print('📤 Sending export request...');

      // Make the GET request
      final response = await http.get(url, headers: headers);

      print('📥 ExportPolicies Response Status: ${response.statusCode}');
      print('📥 ExportPolicies Response Content-Type: ${response.headers['content-type']}');

      if (response.statusCode == 200) {
        // Get the appropriate directory based on platform
        Directory? directory;
        String directoryPath;

        if (Platform.isAndroid) {
          // For Android, try to use the Downloads directory
          // This works without needing storage permissions on Android 10+
          final downloadsDir = Directory('/storage/emulated/0/Download');

          if (await downloadsDir.exists()) {
            directory = downloadsDir;
            directoryPath = downloadsDir.path;
          } else {
            // Fallback to app's external storage
            directory = await getExternalStorageDirectory();
            directoryPath = directory?.path ?? '';
          }
        } else if (Platform.isIOS) {
          // For iOS, use application documents directory
          directory = await getApplicationDocumentsDirectory();
          directoryPath = directory.path;
        } else {
          return {
            'success': false,
            'message': 'Unsupported platform',
          };
        }

        if (directoryPath.isEmpty) {
          return {
            'success': false,
            'message': 'Could not access storage directory',
          };
        }

        // Create filename with timestamp
        final timestamp = DateTime.now().millisecondsSinceEpoch;
        final fileName = 'policies_export_$timestamp.xlsx';
        final filePath = '$directoryPath/$fileName';

        print('💾 Saving file to: $filePath');

        // Write the file
        final file = File(filePath);
        await file.writeAsBytes(response.bodyBytes);

        // Verify file was created
        final fileExists = await file.exists();
        final fileSize = await file.length();

        print('✅ File saved successfully');
        print('📊 File exists: $fileExists, Size: $fileSize bytes');

        return {
          'success': true,
          'message': 'File downloaded successfully',
          'filePath': filePath,
          'fileName': fileName,
        };
      } else {
        print('❌ Export failed with status: ${response.statusCode}');
        return {
          'success': false,
          'message': 'Failed to export: ${response.statusCode} - ${response.reasonPhrase}',
        };
      }
    } catch (e) {
      print('❌ ExportPolicies Error: $e');
      return {
        'success': false,
        'message': 'Error: $e',
      };
    }
  }

  Future<Map<String, dynamic>> downloadSampleExcel() async {
    try {
      // Create Excel
      final excel = Excel.createExcel();
      final Sheet sheet = excel['Sample'];
      excel.setDefaultSheet('Sample');

      // Headers (EXACT backend match)
      final headers = [
        'customer_first_name',
        'customer_last_name',
        'mobile',
        'email',
        'date_of_birth',
        'policy_number',
        'policy_type',
        'policy_start_date',
        'policy_end_date',
        'premium_with_gst',
        'agent_name',
        'customer_group',
        'customer_remark',
        'month_term',
        'od_amount',
        'fresh_renewal',
        'payment_mode',
        'year_of_booking',
        'this_year_premium',
        'last_year_premium',
        'current_insurance_company',
        'previous_insurance_company',
        'policy_remark',
        'vehicle_number',
        'vehicle_model',
        'fuel_type',
        'vehicle_type',
        'make',
        'vehicle_remark',
        'nominee_name',
        'nominee_relation',
        'additional_remark',
      ];

      sheet.appendRow(
        headers.map((e) => TextCellValue(e)).toList(),
      );
      // Save location
      Directory directory = Directory('/storage/emulated/0/Download');

      final fileName = 'policies_sample_template.xlsx';
      final filePath = '${directory.path}/$fileName';

      // Encode Excel
      final List<int>? bytes = excel.encode();
      if (bytes == null) {
        return {
          'success': false,
          'message': 'Failed to generate Excel file',
        };
      }

      // Write as BYTES (IMPORTANT)
      final file = File(filePath);
      await file.writeAsBytes(bytes, flush: true);

      return {
        'success': true,
        'filePath': filePath,
        'fileName': fileName,
      };
    } catch (e) {
      return {
        'success': false,
        'message': e.toString(),
      };
    }
  }

  Future<Map<String, dynamic>> bulkDeletePolicies(List<String> policyIds) async {
    final url = Uri.parse('$baseUrl/policies/bulk-delete');

    print('📤 BulkDeletePolicies Request URL: $url');
    print('📤 BulkDeletePolicies Payload: ${jsonEncode({"ids": policyIds})}');

    try {
      final headers = await _getHeaders();

      final response = await http.post(
        url,
        headers: headers,
        body: jsonEncode({
          "ids": policyIds,
        }),
      );

      print('📥 BulkDeletePolicies Response Status: ${response.statusCode}');
      print('📥 BulkDeletePolicies Response Body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 204) {
        final responseBody = response.body.isNotEmpty
            ? jsonDecode(response.body)
            : {'message': 'Policies deleted successfully'};

        return {
          'success': true,
          'message': responseBody['message'] ?? 'Policies deleted successfully',
          'data': responseBody,
        };
      } else {
        final errorBody = jsonDecode(response.body);
        return {
          'success': false,
          'message': errorBody['message'] ?? 'Failed to delete policies',
        };
      }
    } catch (e) {
      print('❌ BulkDeletePolicies Error: $e');
      return {
        'success': false,
        'message': 'Error: $e',
      };
    }
  }

  Future<Map<String,dynamic>> updateProfile({
    required String name,
    required String email,
    required String mobileNumber,

  }) async{

    final url = Uri.parse("$baseUrl/auth/profile");

    final payload ={
      "name":name.trim(),
      "email":email.trim(),
      "mobileNumber":mobileNumber.trim(),
    };

    try{
      final headers = await _getHeaders();

      final response = await http.put(url,
      headers: headers,
        body: jsonEncode(payload)
      );

      final decoded = jsonDecode(response.body);

      if(response.statusCode==200){
        return{
          "success":true,
          "data":decoded,
          "message":decoded['message']??"Profile Updated Successfully",
        };
      }else{
        return{
          "success":false,
          "message":decoded['message']??"Profile Updated Successfully",
        };
      }
    }catch(e){
      return{
        "success":false,
        "message":e.toString(),
      };
    }
  }


  Future<Map<String, dynamic>> fetchProfile() async {
    final url = Uri.parse('$baseUrl/auth/profile');

    try {
      final headers = await _getHeaders();

      final response = await http.get(url, headers: headers);
      final decoded = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {
          'success': true,
          'data': decoded['data'] ?? decoded,
          'message': decoded['message'] ?? 'Profile loaded',
        };
      } else {
        return {
          'success': false,
          'message': decoded['message'] ?? 'Failed to load profile',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': e.toString(),
      };
    }
  }



}