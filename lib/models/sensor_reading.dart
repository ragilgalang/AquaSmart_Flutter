class SensorReading {
  final bool hujan;
  final double ketinggianAir;
  final double tekananUdara;
  final double suhuBox;
  final bool kipas;
  final DateTime? waktu;

  // Getter alias untuk kompatibilitas
  double get suhu => suhuBox;
  double get amonia => ketinggianAir;
  double get ph => 7.0;

  SensorReading({
    required this.hujan,
    required this.ketinggianAir,
    required this.tekananUdara,
    required this.suhuBox,
    required this.kipas,
    this.waktu,
  });

  factory SensorReading.fromMap(Map<dynamic, dynamic> m) {
    final ts = m['timestamp'];
    final rawTinggi = m['ketinggian_air'] ?? m['tinggi_air'] ?? m['jarak'] ?? m['amonia'] ?? 85.0;
    final rawSuhuBox = m['suhu_box'] ?? m['suhu'] ?? 28.0;
    final rawTekanan = m['tekanan_udara'] ?? m['pressure'] ?? 1013.25;
    final rawHujan = m['hujan'] ?? m['rain'] ?? false;
    final isHujan = rawHujan is bool ? rawHujan : (rawHujan is num && rawHujan > 0);
    final rawKipas = m['kipas'];
    final isKipas = rawKipas != null
        ? (rawKipas is bool ? rawKipas : rawKipas.toString().toUpperCase() == 'ON' || rawKipas == 1)
        : ((rawSuhuBox as num).toDouble() >= 35.0);

    return SensorReading(
      hujan: isHujan,
      ketinggianAir: (rawTinggi as num).toDouble(),
      tekananUdara: (rawTekanan as num).toDouble(),
      suhuBox: (rawSuhuBox as num).toDouble(),
      kipas: isKipas,
      waktu: (ts is num && ts > 1700000000)
          ? DateTime.fromMillisecondsSinceEpoch(ts.toInt() * 1000)
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'hujan': hujan,
      'ketinggian_air': ketinggianAir,
      'tekanan_udara': tekananUdara,
      'suhu_box': suhuBox,
      'kipas': kipas,
      'timestamp': waktu?.millisecondsSinceEpoch != null
          ? waktu!.millisecondsSinceEpoch ~/ 1000
          : null,
    };
  }
}
