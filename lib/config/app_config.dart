class AppConfig {
  // Terhubung langsung via kabel USB dengan 'adb reverse tcp:8000 tcp:8000'
  // (Lebih cepat, stabil, dan tidak terhalang firewall Hotspot/Wi-Fi Windows)
  static const baseUrl = 'http://localhost:8000/api';

  // Catatan: Jika menggunakan kabel USB + adb reverse tcp:8000 tcp:8000,
  // baru bisa gunakan 'http://localhost:8000/api'

  static const firebaseDbUrl =
      'https://aquasmart-20418-default-rtdb.asia-southeast1.firebasedatabase.app';
}
