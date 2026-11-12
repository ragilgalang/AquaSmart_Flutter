class SensorReadingModel {
  final bool hujan;
  final double ketinggianAir;
  final double tekananUdara;
  final double suhuBox;
  final bool kipas;
  final String status;
  final double skor;
  final List<String> saran;
  final String waktu;

  // Getter alias untuk kompatibilitas
  double get ph => 7.0;
  double get suhu => suhuBox;
  double get amonia => ketinggianAir;
  double get dolomitKg => 0.0;
  String get statusKipas => kipas ? 'ON' : 'OFF';
  String get statusHujan => hujan ? 'Hujan' : 'Tidak Hujan';

  SensorReadingModel({
    required this.hujan,
    required this.ketinggianAir,
    required this.tekananUdara,
    required this.suhuBox,
    required this.kipas,
    required this.status,
    required this.skor,
    required this.saran,
    required this.waktu,
  });

  factory SensorReadingModel.fromJson(Map<String, dynamic> json) {
    final sensor = json['sensor'] as Map<String, dynamic>? ?? {};
    final saranList = (json['saran'] as List<dynamic>?)
            ?.map((e) => e.toString())
            .toList() ??
        [];

    final rawTinggi = sensor['ketinggian_air'] ??
        sensor['tinggi_air'] ??
        json['ketinggian_air'] ??
        sensor['amonia'] ??
        json['amonia'] ??
        85.0;

    final rawTekanan = sensor['tekanan_udara'] ??
        json['tekanan_udara'] ??
        sensor['pressure'] ??
        1013.25;

    final rawSuhuBox = sensor['suhu_box'] ??
        json['suhu_box'] ??
        sensor['suhu'] ??
        json['suhu'] ??
        28.0;

    final rawHujan = sensor['hujan'] ?? json['hujan'] ?? false;
    final isHujan = rawHujan is bool ? rawHujan : (rawHujan is num && rawHujan > 0);

    final rawKipas = sensor['kipas'] ?? json['kipas'];
    final isKipas = rawKipas != null
        ? (rawKipas is bool ? rawKipas : rawKipas.toString().toUpperCase() == 'ON' || rawKipas == 1)
        : ((rawSuhuBox as num).toDouble() >= 35.0);

    return SensorReadingModel(
      hujan: isHujan,
      ketinggianAir: (rawTinggi as num).toDouble(),
      tekananUdara: (rawTekanan as num).toDouble(),
      suhuBox: (rawSuhuBox as num).toDouble(),
      kipas: isKipas,
      status: json['status'] as String? ?? 'Tidak Diketahui',
      skor: (json['skor'] as num?)?.toDouble() ?? 0.0,
      saran: saranList,
      waktu: json['waktu'] as String? ??
          json['recorded_at'] as String? ??
          json['updated_at'] as String? ??
          '',
    );
  }
}
