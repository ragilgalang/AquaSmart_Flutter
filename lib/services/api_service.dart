import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../config.dart';

class ApiService {
  final _storage = const FlutterSecureStorage();
  late final Dio dio;

  ApiService() {
    dio = Dio(BaseOptions(
      baseUrl: AppConfig.baseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: {
        'Accept': 'application/json',
        'Bypass-Tunnel-Reminder': 'true',
      },
    ));

    // Otomatis sisipkan token di setiap request
    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await _storage.read(key: 'token');
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        handler.next(options);
      },
    ));
  }

  Future<void> login(String email, String password) async {
    try {
      final res = await dio.post('/login',
          data: {'email': email, 'password': password});
      await _storage.write(key: 'token', value: res.data['token']);
      await _storage.write(key: 'name', value: res.data['user']['name']);
    } on DioException catch (e) {
      final code = e.response?.statusCode;
      if (code == 401) throw 'Email atau password salah';
      if (code == 422) throw 'Format email atau password tidak valid';
      throw 'Tidak dapat terhubung ke server';
    }
  }

  Future<void> logout() async {
    try {
      await dio.post('/logout');
    } catch (_) {}
    await _storage.deleteAll();
  }

  Future<bool> hasToken() async => (await _storage.read(key: 'token')) != null;
  Future<String?> userName() => _storage.read(key: 'name');

  /// Null bila belum ada data (404).
  Future<Map<String, dynamic>?> rekomendasi() async {
    try {
      final res = await dio.get('/rekomendasi');
      return Map<String, dynamic>.from(res.data);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) return null;
      throw 'Gagal mengambil data dari server';
    }
  }

  /// Riwayat harian (agregat per hari untuk grafik)
  Future<List<Map<String, dynamic>>> riwayatHarian([int hari = 7]) async {
    try {
      final res = await dio.get('/riwayat/harian', queryParameters: {'hari': hari});
      return List<Map<String, dynamic>>.from(res.data['data']);
    } on DioException {
      throw 'Gagal mengambil riwayat harian';
    }
  }

  /// Riwayat mentah
  Future<List<Map<String, dynamic>>> riwayat([int hari = 7]) async {
    try {
      final res = await dio.get('/riwayat', queryParameters: {'hari': hari});
      return List<Map<String, dynamic>>.from(res.data['data']);
    } on DioException {
      throw 'Gagal mengambil log';
    }
  }

  /// Sinkronisasi Firebase RTDB
  Future<Map<String, dynamic>?> syncFirebase() async {
    try {
      final res = await dio.post('/firebase/sync');
      return Map<String, dynamic>.from(res.data);
    } catch (_) {
      return null;
    }
  }

  /// Hitung status Fuzzy langsung dari parameter sensor
  Future<Map<String, dynamic>> evaluasi(double ph, double suhu, double amonia) async {
    try {
      final res = await dio.post('/evaluasi',
          data: {'ph': ph, 'suhu': suhu, 'amonia': amonia});
      return Map<String, dynamic>.from(res.data);
    } on DioException {
      throw 'Gagal menghitung status dari server';
    }
  }
}
