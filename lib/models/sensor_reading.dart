class SensorReading {
  final double ph;
  final double suhu;
  final double ketinggianAir;
  final DateTime? waktu;

  // Getter alias untuk kompatibilitas
  double get amonia => ketinggianAir;

  SensorReading({
    required this.ph,
    required this.suhu,
    required this.ketinggianAir,
    this.waktu,
  });

  factory SensorReading.fromMap(Map<dynamic, dynamic> m) {
    final ts = m['timestamp'];
    final rawTinggi = m['ketinggian_air'] ?? m['tinggi_air'] ?? m['amonia'] ?? 0;
    return SensorReading(
      ph: (m['ph'] as num?)?.toDouble() ?? 0.0,
      suhu: (m['suhu'] as num?)?.toDouble() ?? 0.0,
      ketinggianAir: (rawTinggi as num).toDouble(),
      waktu: (ts is num && ts > 1700000000)
          ? DateTime.fromMillisecondsSinceEpoch(ts.toInt() * 1000)
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'ph': ph,
      'suhu': suhu,
      'ketinggian_air': ketinggianAir,
      'amonia': ketinggianAir,
      'timestamp': waktu?.millisecondsSinceEpoch != null
          ? waktu!.millisecondsSinceEpoch ~/ 1000
          : null,
    };
  }
}
