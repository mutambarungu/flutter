import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:expense_tracker_pro/services/db_helper.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter/foundation.dart'; 

class AuthService {
  final DBHelper _dbHelper = DBHelper();
  final Uuid _uuid = Uuid();

  // Hash password before storing
  String _hashPassword(String password) {
    final hash = sha256.convert(utf8.encode(password)).toString();
    print("Hashing password: $password -> $hash");
    return hash;
  }

  /// Register user (Handles both Web and Mobile)
  Future<bool> registerUser(String firstName, String lastName, String email, String password) async {
    final hashedPassword = _hashPassword(password);

    try {
      if (kIsWeb) { // Handle Web using SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        if (prefs.containsKey(email)) {
          print("User already exists in Web Storage");
          return false;
        }
        prefs.setString(email, hashedPassword);
        return true;
      } else {
        // Mobile (SQLite)
        final existingUser = await _dbHelper.getUserByEmail(email);
        if (existingUser != null) return false;
        return (await _dbHelper.insertUser({
          'id': _uuid.v4(),
          'first_name': firstName,
          'last_name': lastName,
          'email': email,
          'password': hashedPassword,
          'created_on': DateTime.now().toIso8601String(),
        })) > 0;
      }
    } catch (e) {
      print("Error registering user: $e");
      return false;
    }
  }

  /// Login user (Handles both Web and Mobile)
  Future<bool> loginUser(String email, String password) async {
    final hashedPassword = _hashPassword(password);

    try {
      if (kIsWeb) {  // Web-based authentication
        final prefs = await SharedPreferences.getInstance();
        String? storedPassword = prefs.getString(email);

        if (storedPassword != null && storedPassword == hashedPassword) {
          print("Web Login Successful!");
          await saveUserCredentials(email);
          return true;
        }
        print("Web: Invalid email or password");
        return false;
      } else {
        // Mobile authentication (SQLite)
        final user = await _dbHelper.getUserByEmail(email);
        print("Checking credentials for: $email");
        print("User found: $user");

        if (user != null && user['password'] == hashedPassword) {
          await saveUserCredentials(email);
          print("Login Successful!");
          return true;
        }
        print("Invalid email or password");
        return false;
      }
    } catch (e) {
      print("Error during login: $e");
      return false;
    }
  }

  /// Save user credentials
  Future<void> saveUserCredentials(String email) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('email', email);
    } catch (e) {
      print("Error saving user credentials: $e");
    }
  }

  /// Get user details by email
  Future<Map<String, dynamic>?> getUserDetails(String email) async {
    try {
      return await _dbHelper.getUserByEmail(email);
    } catch (e) {
      print("Error getting user details: $e");
      return null;
    }
  }

  /// Logout user
  Future<void> logoutUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('email');
      print("User logged out successfully");
    } catch (e) {
      print("Error logging out user: $e");
    }
  }

  /// Get saved user credentials (for auto-login)
Future<Map<String, String>> getUserCredentials() async {
  try {
    final prefs = await SharedPreferences.getInstance();
    return {'email': prefs.getString('email') ?? ""};
  } catch (e) {
    print("Error getting user credentials: $e");
    return {'email': ""};
  }
}

}
