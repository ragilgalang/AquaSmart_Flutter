import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../config.dart';
import '../config/app_theme.dart';
import '../models/sensor_reading.dart';
import '../providers/auth_provider.dart';
import '../services/api_service.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});
  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  late final ApiService _api;
  StreamSubscription<DatabaseEvent>? _sub;
  SensorReading? _reading = SensorReading(
    hujan: false,
    ketinggianAir: 85.0,
    tekananUdara: 1013.25,
    suhuBox: 28.4,
    kipas: false,
    waktu: DateTime.now(),
  );
  Map<String, dynamic>? _hasil = {
    'status': 'Sangat Aman',
    'skor': 15.0,
    'status_kipas': 'OFF',
    'status_hujan': 'Tidak Hujan',
    'saran': ['Semua sensor IoT dalam kondisi normal dan terkendali'],
  };
  String? _error;
  bool _firebaseConnected = false;
  List<double> _suhu24h = [27.0, 27.5, 26.8, 28.1, 28.5, 27.9, 28.4, 29.1, 28.8, 28.4];

  @override
  void initState() {
    super.initState();
    _api = context.read<ApiService>();
    _connectFirebase();
    _loadFromBackend();
    _loadHistoryPreview();
  }

  /// Ambil data terakhir dari API backend sebagai data awal / fallback
  Future<void> _loadFromBackend() async {
    try {
      final res = await _api.rekomendasi();
      if (res != null && mounted) {
        final sensor = res['sensor'] as Map<String, dynamic>?;
        if (sensor != null && _reading == null) {
          setState(() {
            _reading = SensorReading(
              hujan: sensor['hujan'] == true,
              ketinggianAir: (sensor['ketinggian_air'] ?? sensor['tinggi_air'] ?? sensor['amonia'] as num?)?.toDouble() ?? 85.0,
              tekananUdara: (sensor['tekanan_udara'] ?? sensor['pressure'] as num?)?.toDouble() ?? 1013.25,
              suhuBox: (sensor['suhu_box'] ?? sensor['suhu'] as num?)?.toDouble() ?? 28.4,
              kipas: sensor['kipas'] == true || (sensor['status_kipas'] == 'ON'),
              waktu: DateTime.tryParse(res['waktu']?.toString() ?? ''),
            );
            _hasil = res;
          });
        }
      }
    } catch (_) {}
  }

  void _connectFirebase() {
    _sub?.cancel();
    setState(() {
      _error = null;
    });

    try {
      final ref = FirebaseDatabase.instanceFor(
        app: Firebase.app(),
        databaseURL: AppConfig.firebaseDbUrl,
      ).ref('tambak/maneron/sensor');

      _sub = ref.onValue.listen(
        _onData,
        onError: (e) {
          if (!mounted) return;
          String errStr = e.toString();
          if (errStr.contains('permission-denied') || errStr.contains('Permission denied')) {
            errStr = 'firebase_database/permission-denied';
          }
          setState(() {
            _firebaseConnected = false;
            // Jika sudah ada data dari backend, jangan blokir layar sepenuhnya
            if (_reading == null) {
              _error = errStr;
            }
          });
          // Coba panggil backend saat Firebase permission denied
          _loadFromBackend();
        },
      );
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _firebaseConnected = false;
        if (_reading == null) {
          _error = e.toString();
        }
      });
      _loadFromBackend();
    }
  }

  Future<void> _loadHistoryPreview() async {
    try {
      final res = await _api.riwayat(1);
      if (res.isNotEmpty) {
        final list = res.map((e) => double.tryParse(e['suhu'].toString()) ?? 28.0).toList();
        if (mounted && list.length >= 2) {
          setState(() => _suhu24h = list.reversed.toList());
        }
      }
    } catch (_) {}
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  Future<void> _onData(DatabaseEvent event) async {
    final v = event.snapshot.value;
    if (v is! Map) return;

    try {
      final r = SensorReading.fromMap(v);
      setState(() {
        _reading = r;
        _firebaseConnected = true;
        _error = null;
      });
      final h = await _api.evaluasi(
        ketinggianAir: r.ketinggianAir,
        hujan: r.hujan,
        tekananUdara: r.tekananUdara,
        suhuBox: r.suhuBox,
        kipas: r.kipas,
      );
      if (!mounted) return;
      setState(() => _hasil = h);
    } catch (e) {
      if (!mounted) return;
      if (_reading == null) {
        setState(() => _error = e.toString());
      }
    }
  }

  String _salamWaktu() {
    final hour = DateTime.now().hour;
    if (hour >= 4 && hour < 11) return 'Selamat pagi';
    if (hour >= 11 && hour < 15) return 'Selamat siang';
    if (hour >= 15 && hour < 18) return 'Selamat sore';
    return 'Selamat malam';
  }

  String _formatWaktu(DateTime? t) {
    final time = t ?? DateTime.now();
    String d(int n) => n.toString().padLeft(2, '0');
    return '${d(time.hour)}:${d(time.minute)}';
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    // Jika error Firebase dan tidak ada data sama sekali dari API, tampilkan error view
    if (_error != null && _reading == null) {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: _buildErrorView(auth),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: _buildDashboardView(auth),
      ),
    );
  }

  /// Tampilan Error jika Firebase belum diberi izin DAN backend belum ada data
  Widget _buildErrorView(AuthProvider auth) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(auth),
          const Spacer(),
          Center(
            child: Container(
              width: 120,
              height: 120,
              decoration: const BoxDecoration(
                color: AppColors.mintLight,
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: Icon(
                  Icons.waves_rounded,
                  size: 56,
                  color: AppColors.primary,
                ),
              ),
            ),
          ),
          const SizedBox(height: 32),
          Center(
            child: Text(
              'Data kolam belum bisa dimuat',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.textDark,
                    fontSize: 22,
                  ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 12),
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'Aplikasi belum diizinkan membaca data sensor. Coba muat ulang. Kalau masih sama, hubungi admin untuk memeriksa hak akses akunmu.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textMuted,
                      height: 1.4,
                      fontSize: 14,
                    ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          const SizedBox(height: 32),
          // Tombol Coba lagi
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton.icon(
              onPressed: () {
                _connectFirebase();
                _loadFromBackend();
              },
              icon: const Icon(Icons.refresh_rounded, color: Colors.white, size: 20),
              label: const Text(
                'Coba lagi',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(26),
                ),
                elevation: 0,
              ),
            ),
          ),
          const SizedBox(height: 24),
          // Detail teknis card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border, width: 1.2),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Detail teknis',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textMuted,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _error ?? 'firebase_database/permission-denied',
                  style: const TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 12,
                    color: AppColors.textDark,
                  ),
                ),
              ],
            ),
          ),
          const Spacer(),
        ],
      ),
    );
  }

  /// Tampilan Dashboard Utama
  Widget _buildDashboardView(AuthProvider auth) {
    final r = _reading;
    final h = _hasil;

    final String statusText = (h?['status'] != null)
        ? (h!['status'] == 'Sangat Aman' ? 'Kondisi Sistem Aman' : h['status'])
        : 'Kondisi Sistem Aman';

    final bool hujanVal = r?.hujan ?? false;
    final double ketinggianVal = r?.ketinggianAir ?? 85.0;
    final double tekananVal = r?.tekananUdara ?? 1013.25;
    final double suhuBoxVal = r?.suhuBox ?? 28.4;
    final bool kipasVal = r?.kipas ?? (suhuBoxVal >= 35.0);

    return RefreshIndicator(
      onRefresh: () async {
        _connectFirebase();
        await _loadFromBackend();
        await _loadHistoryPreview();
      },
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        children: [
          _buildHeader(auth),
          const SizedBox(height: 20),

          // Hero Dark Teal Card
          Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Tambak Maneron - Box IoT',
                      style: TextStyle(
                        color: Color(0xFFA3D9CA),
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.primaryLight,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 7,
                            height: 7,
                            decoration: BoxDecoration(
                              color: _firebaseConnected ? const Color(0xFF38E586) : Colors.amber,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            _firebaseConnected ? 'Terhubung' : 'Sensor Aktif',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Text(
                  statusText,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Sensor FC-37, HC-SR04, BMP280 & DS18B20 aktif. Diperbarui ${_formatWaktu(r?.waktu)}.',
                  style: const TextStyle(
                    color: Color(0xFFD4ECE6),
                    fontSize: 13,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Status Kipas Pendingin Box IoT
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: kipasVal ? const Color(0xFFE8F5E9) : Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: kipasVal ? const Color(0xFF81C784) : AppColors.border,
                width: 1.2,
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: kipasVal ? const Color(0xFF2E7D32) : const Color(0xFF757575),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.mode_fan_off_rounded,
                    color: Colors.white,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Kipas Box IoT',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textDark,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        kipasVal
                            ? 'MENYALA (Suhu Box ${suhuBoxVal.toStringAsFixed(1)}°C ≥ 35°C)'
                            : 'STANDBY (Suhu Box ${suhuBoxVal.toStringAsFixed(1)}°C < 35°C)',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: kipasVal ? const Color(0xFF2E7D32) : AppColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: kipasVal ? const Color(0xFF4CAF50) : const Color(0xFFEEEEEE),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    kipasVal ? 'ON' : 'OFF',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: kipasVal ? Colors.white : Colors.black87,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Header Parameter Sensor
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text(
                'Parameter Sensor IoT',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDark,
                ),
              ),
              Text(
                '4 Sensor Aktif',
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.textMuted,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Grid 2x2 Parameter Cards
          Row(
            children: [
              Expanded(
                child: _buildParameterCard(
                  label: 'Sensor Hujan',
                  value: hujanVal ? 'Hujan' : 'Kering',
                  unit: 'FC-37',
                  badgeText: hujanVal ? 'Terdeteksi' : 'Kering',
                  isNormal: !hujanVal,
                  icon: Icons.water_drop_rounded,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: _buildParameterCard(
                  label: 'Ketinggian Air',
                  value: ketinggianVal.toStringAsFixed(0),
                  unit: 'cm',
                  badgeText: (ketinggianVal >= 70 && ketinggianVal <= 120) ? 'Normal' : 'Waspada',
                  isNormal: (ketinggianVal >= 70 && ketinggianVal <= 120),
                  icon: Icons.straighten_rounded,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _buildParameterCard(
                  label: 'Tekanan Udara',
                  value: tekananVal.toStringAsFixed(0),
                  unit: 'hPa',
                  badgeText: (tekananVal >= 1005 && tekananVal <= 1020) ? 'Normal' : 'Waspada',
                  isNormal: (tekananVal >= 1005 && tekananVal <= 1020),
                  icon: Icons.speed_rounded,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: _buildParameterCard(
                  label: 'Suhu Box IoT',
                  value: suhuBoxVal.toStringAsFixed(1).replaceAll('.', ','),
                  unit: '°C',
                  badgeText: kipasVal ? 'Kipas: ON' : 'Kipas: OFF',
                  isNormal: suhuBoxVal < 35.0,
                  icon: Icons.thermostat_rounded,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Mini 24h Suhu Chart Card
          _buildMiniChartCard(suhuBoxVal),
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  /// Header Atas (Bebas Overflow dengan Expanded)
  Widget _buildHeader(AuthProvider auth) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _salamWaktu(),
                style: const TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'Halo, ${auth.name ?? 'Pembudidaya\nManeron'}',
                style: const TextStyle(
                  color: AppColors.textDark,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  height: 1.2,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        InkWell(
          onTap: () {
            _connectFirebase();
            _loadFromBackend();
            _loadHistoryPreview();
          },
          borderRadius: BorderRadius.circular(16),
          child: Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border, width: 1.2),
            ),
            child: const Icon(
              Icons.refresh_rounded,
              color: AppColors.textDark,
              size: 22,
            ),
          ),
        ),
      ],
    );
  }

  /// Komponen Kartu Parameter (2x2 Grid)
  Widget _buildParameterCard({
    required String label,
    required String value,
    required String unit,
    required String badgeText,
    required bool isNormal,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border, width: 1.2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: const TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: isNormal ? AppColors.mintLight : AppColors.warningBg,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  icon,
                  size: 18,
                  color: isNormal ? AppColors.primary : AppColors.warningText,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                value,
                style: const TextStyle(
                  color: AppColors.textDark,
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (unit.isNotEmpty) ...[
                const SizedBox(width: 4),
                Text(
                  unit,
                  style: const TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: isNormal ? AppColors.normalBg : AppColors.warningBg,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              badgeText,
              style: TextStyle(
                color: isNormal ? AppColors.normalText : AppColors.warningText,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Kartu Grafik Mini 24 Jam Terakhir
  Widget _buildMiniChartCard(double currentSuhu) {
    final values = _suhu24h;
    final minVal = values.reduce((a, b) => a < b ? a : b);
    final maxVal = values.reduce((a, b) => a > b ? a : b);

    final spots = [
      for (int i = 0; i < values.length; i++) FlSpot(i.toDouble(), values[i])
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border, width: 1.2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Suhu 24 jam terakhir',
                style: TextStyle(
                  color: AppColors.textDark,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '${minVal.toStringAsFixed(1).replaceAll('.', ',')} – ${maxVal.toStringAsFixed(1).replaceAll('.', ',')}°C',
                style: const TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 90,
            child: LineChart(
              LineChartData(
                minY: minVal - 0.5,
                maxY: maxVal + 0.5,
                gridData: const FlGridData(show: false),
                borderData: FlBorderData(show: false),
                titlesData: const FlTitlesData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: spots,
                    isCurved: true,
                    curveSmoothness: 0.35,
                    color: AppColors.primary,
                    barWidth: 2.8,
                    isStrokeCapRound: true,
                    dotData: FlDotData(
                      show: true,
                      checkToShowDot: (spot, barData) => spot.x == (values.length - 1).toDouble(),
                      getDotPainter: (spot, percent, barData, index) => FlDotCirclePainter(
                        radius: 4,
                        color: AppColors.primary,
                        strokeWidth: 2,
                        strokeColor: Colors.white,
                      ),
                    ),
                    belowBarData: BarAreaData(
                      show: true,
                      color: AppColors.mintLight.withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
