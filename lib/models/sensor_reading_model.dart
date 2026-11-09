class SensorReadingModel {
  final double ph;
  final double suhu;
  final double ketinggianAir;
  final String status;
  final double skor;
  final double dolomitKg;
  final List<String> saran;
  final String waktu;

  // Getter alias untuk kompatibilitas
  double get amonia => ketinggianAir;

  SensorReadingModel({
    required this.ph,
    required this.suhu,
    required this.ketinggianAir,
    required this.status,
    required this.skor,
    required this.dolomitKg,
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
        0.0;

    return SensorReadingModel(
      ph: (sensor['ph'] as num?)?.toDouble() ??
          (json['ph'] as num?)?.toDouble() ??
          0.0,
      suhu: (sensor['suhu'] as num?)?.toDouble() ??
          (json['suhu'] as num?)?.toDouble() ??
          0.0,
      ketinggianAir: (rawTinggi as num).toDouble(),
      status: json['status'] as String? ?? 'Tidak Diketahui',
      skor: (json['skor'] as num?)?.toDouble() ?? 0.0,
      dolomitKg: (json['dolomit_kg'] as num?)?.toDouble() ?? 0.0,
      saran: saranList,
      waktu: json['waktu'] as String? ??
          json['recorded_at'] as String? ??
          json['updated_at'] as String? ??
          '',
    );
  }
}
