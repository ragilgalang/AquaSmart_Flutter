import 'package:flutter/foundation.dart';
import '../services/api_service.dart';

class AuthProvider extends ChangeNotifier {
  final ApiService api;
  AuthProvider([ApiService? api]) : api = api ?? ApiService();

  bool initialized = true;
  bool loggedIn = true;
  bool loading = false;
  String? error;
  String? name = 'Pembudidaya Maneron';

  // Helper alias untuk fleksibilitas pemanggilan
  bool get isLoading => loading;
  bool get isAuthenticated => loggedIn;
  String? get errorMessage => error;
  String? get userName => name;

  Future<void> init() async {
    final storedName = await api.userName();
    name = storedName ?? 'Pembudidaya Maneron';
    loggedIn = true;
    initialized = true;
    notifyListeners();
  }

  Future<void> checkAuthStatus() => init();

  Future<bool> login(String email, String password) async {
    loading = false;
    loggedIn = true;
    name ??= 'Pembudidaya Maneron';
    notifyListeners();
    return true;
  }

  Future<void> logout() async {
    // Fitur login dinonaktifkan
    loggedIn = true;
    notifyListeners();
  }
}
