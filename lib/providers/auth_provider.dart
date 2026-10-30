import 'package:flutter/foundation.dart';
import '../services/api_service.dart';

class AuthProvider extends ChangeNotifier {
  final ApiService api;
  AuthProvider([ApiService? api]) : api = api ?? ApiService();

  bool initialized = false;
  bool loggedIn = false;
  bool loading = false;
  String? error;
  String? name;

  // Helper alias untuk fleksibilitas pemanggilan
  bool get isLoading => loading;
  bool get isAuthenticated => loggedIn;
  String? get errorMessage => error;
  String? get userName => name;

  Future<void> init() async {
    loggedIn = await api.hasToken();
    name = await api.userName();
    initialized = true;
    notifyListeners();
  }

  Future<void> checkAuthStatus() => init();

  Future<bool> login(String email, String password) async {
    loading = true;
    error = null;
    notifyListeners();
    try {
      await api.login(email, password);
      name = await api.userName();
      loggedIn = true;
      return true;
    } catch (e) {
      error = e.toString();
      return false;
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    await api.logout();
    loggedIn = false;
    name = null;
    notifyListeners();
  }
}
