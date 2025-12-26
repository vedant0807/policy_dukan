import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class SessionManager {
  // Singleton pattern
  static final SessionManager _instance = SessionManager._internal();
  factory SessionManager() => _instance;
  SessionManager._internal();

  // Keys for storage
  static const String _keyToken = 'auth_token';
  static const String _keyUserId = 'user_id';
  static const String _keyUserName = 'user_name';
  static const String _keyUserEmail = 'user_email';
  static const String _keyUserMobile = 'user_mobile';
  static const String _keyUserRole = 'user_role';
  static const String _keyUserPermissions = 'user_permissions';
  static const String _keyIsLoggedIn = 'is_logged_in';

  // Save login session
  Future<bool> saveLoginSession({
    required String token,
    required Map<String, dynamic> user,
  }) async {
    try {
      print('💾 Saving login session...');
      print('💾 Token: $token');
      print('💾 User Data: ${jsonEncode(user)}');

      final prefs = await SharedPreferences.getInstance();

      await prefs.setString(_keyToken, token);
      await prefs.setString(_keyUserId, user['id'] ?? '');
      await prefs.setString(_keyUserName, user['name'] ?? '');
      await prefs.setString(_keyUserEmail, user['email'] ?? '');
      await prefs.setString(_keyUserMobile, user['mobileNumber'] ?? '');
      await prefs.setString(_keyUserRole, user['role'] ?? '');
      await prefs.setString(
        _keyUserPermissions,
        jsonEncode(user['permissions'] ?? []),
      );
      await prefs.setBool(_keyIsLoggedIn, true);

      print('✅ Login session saved successfully!');
      return true;
    } catch (e) {
      print('❌ Error saving login session: $e');
      return false;
    }
  }

  // Get token
  Future<String?> getToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString(_keyToken);
      print('🔑 Retrieved Token: ${token ?? "null"}');
      return token;
    } catch (e) {
      print('❌ Error getting token: $e');
      return null;
    }
  }

  // Get user ID
  Future<String?> getUserId() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_keyUserId);
    } catch (e) {
      print('❌ Error getting user ID: $e');
      return null;
    }
  }

  // Get user name
  Future<String?> getUserName() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_keyUserName);
    } catch (e) {
      print('❌ Error getting user name: $e');
      return null;
    }
  }

  // Get user email
  Future<String?> getUserEmail() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_keyUserEmail);
    } catch (e) {
      print('❌ Error getting user email: $e');
      return null;
    }
  }

  // Get user mobile
  Future<String?> getUserMobile() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_keyUserMobile);
    } catch (e) {
      print('❌ Error getting user mobile: $e');
      return null;
    }
  }

  // Get user role
  Future<String?> getUserRole() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_keyUserRole);
    } catch (e) {
      print('❌ Error getting user role: $e');
      return null;
    }
  }

  // Get user permissions
  Future<List<String>> getUserPermissions() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final permissionsJson = prefs.getString(_keyUserPermissions);
      if (permissionsJson != null) {
        final List<dynamic> permissions = jsonDecode(permissionsJson);
        return permissions.map((e) => e.toString()).toList();
      }
      return [];
    } catch (e) {
      print('❌ Error getting user permissions: $e');
      return [];
    }
  }

  // Get complete user data
  Future<Map<String, dynamic>?> getUserData() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      if (!prefs.containsKey(_keyUserId)) {
        return null;
      }

      final permissionsJson = prefs.getString(_keyUserPermissions);
      List<dynamic> permissions = [];
      if (permissionsJson != null) {
        permissions = jsonDecode(permissionsJson);
      }

      return {
        'id': prefs.getString(_keyUserId),
        'name': prefs.getString(_keyUserName),
        'email': prefs.getString(_keyUserEmail),
        'mobileNumber': prefs.getString(_keyUserMobile),
        'role': prefs.getString(_keyUserRole),
        'permissions': permissions,
      };
    } catch (e) {
      print('❌ Error getting user data: $e');
      return null;
    }
  }

  // Check if user is logged in
  Future<bool> isLoggedIn() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final isLoggedIn = prefs.getBool(_keyIsLoggedIn) ?? false;
      final token = prefs.getString(_keyToken);

      print('🔐 Is Logged In: $isLoggedIn');
      print('🔐 Has Token: ${token != null}');

      return isLoggedIn && token != null;
    } catch (e) {
      print('❌ Error checking login status: $e');
      return false;
    }
  }

  // Clear session (logout)
  Future<bool> clearSession() async {
    try {
      print('🚪 Clearing session (logout)...');
      final prefs = await SharedPreferences.getInstance();

      await prefs.remove(_keyToken);
      await prefs.remove(_keyUserId);
      await prefs.remove(_keyUserName);
      await prefs.remove(_keyUserEmail);
      await prefs.remove(_keyUserMobile);
      await prefs.remove(_keyUserRole);
      await prefs.remove(_keyUserPermissions);
      await prefs.setBool(_keyIsLoggedIn, false);

      print('✅ Session cleared successfully!');
      return true;
    } catch (e) {
      print('❌ Error clearing session: $e');
      return false;
    }
  }

  // Update token (for token refresh scenarios)
  Future<bool> updateToken(String newToken) async {
    try {
      print('🔄 Updating token...');
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_keyToken, newToken);
      print('✅ Token updated successfully!');
      return true;
    } catch (e) {
      print('❌ Error updating token: $e');
      return false;
    }
  }

  // Check if user has specific permission
  Future<bool> hasPermission(String permission) async {
    try {
      final permissions = await getUserPermissions();
      return permissions.contains(permission);
    } catch (e) {
      print('❌ Error checking permission: $e');
      return false;
    }
  }

  // Check if user has admin role
  Future<bool> isAdmin() async {
    try {
      final role = await getUserRole();
      return role?.toLowerCase() == 'admin';
    } catch (e) {
      print('❌ Error checking admin status: $e');
      return false;
    }
  }
}