import 'app_config.dart';

export 'app_config.dart';

class ApiConfig {
  /// Base URL diambil langsung dari AppConfig
  static const String baseUrl = AppConfig.baseUrl;

  // Endpoints
  static const String login = '/login';
  static const String logout = '/logout';
  static const String me = '/me';
  static const String log = '/log';
  static const String riwayat = '/riwayat';
  static const String riwayatHarian = '/riwayat/harian';
  static const String rekomendasi = '/rekomendasi';
  static const String firebaseSync = '/firebase/sync';
}
