import 'package:flutter/material.dart';

/// Hardcoded credential gate for the admin dashboard.
///
/// IMPORTANT: this check runs entirely on-device / in the browser bundle,
/// so it only keeps out casual visitors — it is NOT real security. Anyone
/// who inspects the compiled web app can read these constants. Real admin
/// auth (Supabase Auth + RLS policies scoped to an admin role) should
/// replace this before this app is exposed on a public URL.
class AdminAuthProvider extends ChangeNotifier {
  static const _validUsername = 'labhealth';
  static const _validPassword = '123456789';

  bool _isAuthenticated = false;
  bool get isAuthenticated => _isAuthenticated;

  String? _error;
  String? get error => _error;

  bool login(String username, String password) {
    if (username.trim() == _validUsername && password == _validPassword) {
      _isAuthenticated = true;
      _error = null;
      notifyListeners();
      return true;
    }
    _error = 'Invalid username or password';
    notifyListeners();
    return false;
  }

  void logout() {
    _isAuthenticated = false;
    notifyListeners();
  }
}
