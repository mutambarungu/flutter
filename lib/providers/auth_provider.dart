import 'package:flutter/foundation.dart';
import '../services/auth_service.dart';

class AuthProvider with ChangeNotifier {
  String? _userEmail;
  String? _firstName;
  bool _isAuthenticated = false;

  String? get userEmail => _userEmail;
  String? get firstName => _firstName;
  bool get isAuthenticated => _isAuthenticated;

  /// Login user
  Future<bool> login(String email, String password) async {
    final authService = AuthService();
    bool isSuccess = await authService.loginUser(email, password);

    if (isSuccess) {
      final user = await authService.getUserDetails(email);
      if (user != null) {
        _userEmail = email;
        _firstName = user['first_name'];
        _isAuthenticated = true;
        notifyListeners();
      }
    }
    return isSuccess;
  }

  /// Logout user
  Future<void> logout() async {
    await AuthService().logoutUser();
    _userEmail = null;
    _firstName = null;
    _isAuthenticated = false;
    notifyListeners();
  }

  /// Check if user is already logged in
Future<void> checkAuthStatus() async {
  final authService = AuthService();
  final savedCredentials = await authService.getUserCredentials();

  if (savedCredentials['email'] != null && savedCredentials['email']!.isNotEmpty) {
    final user = await authService.getUserDetails(savedCredentials['email']!);

    if (user != null) {
      _userEmail = savedCredentials['email'];
      _firstName = user['first_name'];
      _isAuthenticated = true;
      notifyListeners();
      return;
    }
  }
  _clearUserData(); // Reset state if user is not logged in
}

/// Clears user session
void _clearUserData() {
  _userEmail = null;
  _firstName = null;
  _isAuthenticated = false;
  notifyListeners();
}

}

