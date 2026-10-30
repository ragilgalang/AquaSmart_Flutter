class SensorReading {
  final double ph;
  final double suhu;
  final double amonia;
  final DateTime? waktu;

  SensorReading({
    required this.ph,
    required this.suhu,
    required this.amonia,
    this.waktu,
  });

  factory SensorReading.fromMap(Map<dynamic, dynamic> m) {
    final ts = m['timestamp'];
    return SensorReading(
      ph: (m['ph'] as num).toDouble(),
      suhu: (m['suhu'] as num).toDouble(),
      amonia: (m['amonia'] as num).toDouble(),
      waktu: (ts is num && ts > 1700000000)
          ? DateTime.fromMillisecondsSinceEpoch(ts.toInt() * 1000)
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'ph': ph,
      'suhu': suhu,
      'amonia': amonia,
      'timestamp': waktu?.millisecondsSinceEpoch != null
          ? waktu!.millisecondsSinceEpoch ~/ 1000
          : null,
    };
  }
}
