import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../config/app_theme.dart';
import '../services/api_service.dart';

class RiwayatScreen extends StatefulWidget {
  const RiwayatScreen({super.key});
  @override
  State<RiwayatScreen> createState() => _RiwayatScreenState();
}

class _RiwayatScreenState extends State<RiwayatScreen> {
  // 0: 24 jam (1 hari), 1: 7 hari, 2: 30 hari
  int _selectedTabIndex = 1; // Default ke 7 hari yang pasti memiliki data seeder lengkap
  bool _isLoading = true;
  String? _error;

  List<Map<String, dynamic>> _harianData = [];
  List<Map<String, dynamic>> _logsData = [];

  final List<String> _tabLabels = ['24 jam', '7 hari', '30 hari'];
  final List<int> _tabDays = [1, 7, 30];

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    final api = context.read<ApiService>();
    final days = _tabDays[_selectedTabIndex];

    try {
      final results = await Future.wait([
        api.riwayatHarian(days).catchError((_) => <Map<String, dynamic>>[]),
        api.riwayat(days).catchError((_) => <Map<String, dynamic>>[]),
      ]);

      if (!mounted) return;
      setState(() {
        _harianData = results[0];
        _logsData = results[1];
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  double _parseNum(dynamic v) {
    if (v == null) return 0.0;
    if (v is num) return v.toDouble();
    return double.tryParse(v.toString()) ?? 0.0;
  }

  String _formatWaktuSingkat(String iso) {
    try {
      final t = DateTime.parse(iso).toLocal();
      String d(int n) => n.toString().padLeft(2, '0');
      return '${d(t.hour)}.${d(t.minute)}';
    } catch (_) {
      return '-';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _fetchData,
          color: AppColors.primary,
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            children: [
              // Header
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'Kolam 1',
                    style: TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    'Riwayat',
                    style: TextStyle(
                      color: AppColors.textDark,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),

              // Segmented Tab Filter (24 jam, 7 hari, 30 hari)
              Container(
                height: 48,
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: const Color(0xFFE4EFEB),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Row(
                  children: List.generate(_tabLabels.length, (index) {
                    final isSelected = _selectedTabIndex == index;
                    return Expanded(
                      child: GestureDetector(
                        onTap: () {
                          if (_selectedTabIndex != index) {
                            setState(() => _selectedTabIndex = index);
                            _fetchData();
                          }
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          decoration: BoxDecoration(
                            color: isSelected ? AppColors.primary : Colors.transparent,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            _tabLabels[index],
                            style: TextStyle(
                              color: isSelected ? Colors.white : const Color(0xFF4A6058),
                              fontSize: 14,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ),
              const SizedBox(height: 20),

              if (_isLoading)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 40),
                  child: Center(
                    child: CircularProgressIndicator(color: AppColors.primary),
                  ),
                )
              else if (_error != null && _logsData.isEmpty && _harianData.isEmpty)
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Column(
                    children: [
                      Text(
                        'Tidak dapat terhubung ke server Laravel.\nPastikan php artisan serve sedang berjalan.',
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.red, fontSize: 13),
                      ),
                      const SizedBox(height: 12),
                      ElevatedButton(
                        onPressed: _fetchData,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: const Text('Coba lagi', style: TextStyle(color: Colors.white)),
                      ),
                    ],
                  ),
                )
              else ...[
                // Kartu Utama: Suhu rata-rata + Grafik Besar
                _buildMainAverageCard(),
                const SizedBox(height: 24),

                // Header Catatan
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _selectedTabIndex == 0 ? 'Catatan hari ini' : 'Catatan riwayat',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textDark,
                      ),
                    ),
                    const Text(
                      'Terbaru di atas',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Daftar Log Riwayat
                _buildLogsGroupCard(),
                const SizedBox(height: 20),
              ],
            ],
          ),
        ),
      ),
    );
  }

  /// Kartu Suhu Box Rata-rata & Grafik
  Widget _buildMainAverageCard() {
    List<double> chartPoints = [];
    List<String> xLabels = [];
    double avgSuhu = 28.1;

    if (_logsData.isNotEmpty) {
      final sampleLogs = _logsData.take(15).toList().reversed.toList();
      chartPoints = sampleLogs.map((l) => _parseNum(l['suhu_box'] ?? l['suhu'])).toList();
      xLabels = sampleLogs.map((l) => _formatWaktuSingkat(l['recorded_at'].toString())).toList();
      
      final sum = chartPoints.reduce((a, b) => a + b);
      avgSuhu = sum / chartPoints.length;
    } else if (_harianData.isNotEmpty) {
      chartPoints = _harianData.map((d) => _parseNum(d['suhu_box'] ?? d['suhu'])).toList();
      xLabels = _harianData.map((d) => d['tanggal'].toString().substring(5)).toList();
      final sum = chartPoints.reduce((a, b) => a + b);
      avgSuhu = sum / chartPoints.length;
    } else {
      chartPoints = [27.2, 27.8, 27.0, 28.1, 28.4, 28.0, 28.6, 28.2, 29.1, 28.8];
      xLabels = ['19.00', '01.00', '07.00', '13.00', '18.59'];
    }

    if (chartPoints.length < 2) {
      chartPoints = [avgSuhu, avgSuhu];
      xLabels = ['00.00', '12.00'];
    }

    final minVal = chartPoints.reduce((a, b) => a < b ? a : b);
    final maxVal = chartPoints.reduce((a, b) => a > b ? a : b);
    final pad = (maxVal - minVal) == 0 ? 0.5 : (maxVal - minVal) * 0.2;

    final spots = [
      for (int i = 0; i < chartPoints.length; i++) FlSpot(i.toDouble(), chartPoints[i])
    ];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.border, width: 1.2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Suhu Box IoT rata-rata',
                style: TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.normalBg,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'Stabil',
                  style: TextStyle(
                    color: AppColors.normalText,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                avgSuhu.toStringAsFixed(1).replaceAll('.', ','),
                style: const TextStyle(
                  color: AppColors.textDark,
                  fontSize: 34,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 4),
              const Text(
                '°C',
                style: TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Area LineChart
          SizedBox(
            height: 170,
            child: LineChart(
              LineChartData(
                minY: minVal - pad,
                maxY: maxVal + pad,
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: (value) => const FlLine(
                    color: Color(0xFFF0F4F2),
                    strokeWidth: 1,
                  ),
                ),
                borderData: FlBorderData(show: false),
                titlesData: FlTitlesData(
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 28,
                      interval: (chartPoints.length / 4).clamp(1.0, 10.0),
                      getTitlesWidget: (val, meta) {
                        final idx = val.toInt();
                        if (idx >= 0 && idx < xLabels.length) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 10),
                            child: Text(
                              xLabels[idx],
                              style: const TextStyle(
                                color: AppColors.textMuted,
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                  ),
                ),
                lineBarsData: [
                  LineChartBarData(
                    spots: spots,
                    isCurved: true,
                    curveSmoothness: 0.35,
                    color: AppColors.primary,
                    barWidth: 3.2,
                    isStrokeCapRound: true,
                    dotData: const FlDotData(show: false),
                    belowBarData: BarAreaData(
                      show: true,
                      color: const Color(0xFFE3F5EE),
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

  /// Kelompok Daftar Catatan Log Persis Gambar 2
  Widget _buildLogsGroupCard() {
    if (_logsData.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.border),
        ),
        child: const Center(
          child: Text(
            'Belum ada catatan pada rentang ini',
            style: TextStyle(color: AppColors.textMuted),
          ),
        ),
      );
    }

    final logs = _logsData.take(10).toList();

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border, width: 1.2),
      ),
      child: Column(
        children: List.generate(logs.length, (index) {
          final l = logs[index];
          final ketinggianAir = _parseNum(l['ketinggian_air'] ?? l['amonia'] ?? 85.0);
          final rawHujan = l['hujan'];
          final isHujan = rawHujan is bool ? rawHujan : (rawHujan == 1 || rawHujan.toString().toLowerCase() == 'true');
          final tekanan = _parseNum(l['tekanan_udara'] ?? 1013.25);
          final suhuBox = _parseNum(l['suhu_box'] ?? l['suhu'] ?? 28.0);
          final rawKipas = l['kipas'];
          final isKipas = rawKipas != null
              ? (rawKipas is bool ? rawKipas : rawKipas == 1 || rawKipas.toString().toUpperCase() == 'ON')
              : (suhuBox >= 35.0);

          final status = l['status']?.toString() ?? 'Sangat Aman';
          final isNormal = (status == 'Sangat Aman' || status == 'Aman');
          final timeStr = _formatWaktuSingkat(l['recorded_at']?.toString() ?? '');

          String title = isNormal ? 'Sistem Aman (Kipas ${isKipas ? "ON" : "OFF"})' : status;
          if (isHujan && ketinggianAir > 120) {
            title = 'Waspada Hujan & Air Meluap';
          } else if (isHujan) {
            title = 'Sensor FC-37: Hujan';
          } else if (suhuBox >= 35.0) {
            title = 'Suhu Box Hangat (Kipas ON)';
          } else if (ketinggianAir < 70) {
            title = 'Air Tambak Surut';
          }

          final subtitle =
              '${isHujan ? "Hujan" : "Kering"} · Tinggi: ${ketinggianAir.toStringAsFixed(0)}cm · Tekanan: ${tekanan.toStringAsFixed(0)}hPa · Box: ${suhuBox.toStringAsFixed(1)}°C (${isKipas ? "Kipas ON" : "Kipas OFF"})';

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                child: Row(
                  children: [
                    // Icon Box
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: isNormal ? AppColors.normalBg : AppColors.warningBg,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        isNormal ? Icons.check_rounded : Icons.warning_amber_rounded,
                        color: isNormal ? AppColors.normalText : AppColors.warningText,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 14),
                    // Detail Text
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: const TextStyle(
                              color: AppColors.textDark,
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            subtitle,
                            style: const TextStyle(
                              color: AppColors.textMuted,
                              fontSize: 12.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Timestamp
                    Text(
                      timeStr,
                      style: const TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              if (index < logs.length - 1)
                const Divider(
                  height: 1,
                  thickness: 1,
                  color: AppColors.border,
                  indent: 70,
                ),
            ],
          );
        }),
      ),
    );
  }
}
