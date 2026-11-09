class DailyHistoryModel {
  final String tanggal;
  final double ph;
  final double suhu;
  final double ketinggianAir;

  // Getter alias untuk kompatibilitas
  double get amonia => ketinggianAir;

  DailyHistoryModel({
    required this.tanggal,
    required this.ph,
    required this.suhu,
    required this.ketinggianAir,
  });

  factory DailyHistoryModel.fromJson(Map<String, dynamic> json) {
    final rawTinggi = json['ketinggian_air'] ?? json['tinggi_air'] ?? json['amonia'] ?? 0.0;
    return DailyHistoryModel(
      tanggal: json['tanggal'] as String? ?? '',
      ph: (json['ph'] as num?)?.toDouble() ?? 0.0,
      suhu: (json['suhu'] as num?)?.toDouble() ?? 0.0,
      ketinggianAir: (rawTinggi as num).toDouble(),
    );
  }
}
