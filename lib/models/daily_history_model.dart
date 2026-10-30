class DailyHistoryModel {
  final String tanggal;
  final double ph;
  final double suhu;
  final double amonia;

  DailyHistoryModel({
    required this.tanggal,
    required this.ph,
    required this.suhu,
    required this.amonia,
  });

  factory DailyHistoryModel.fromJson(Map<String, dynamic> json) {
    return DailyHistoryModel(
      tanggal: json['tanggal'] as String? ?? '',
      ph: (json['ph'] as num?)?.toDouble() ?? 0.0,
      suhu: (json['suhu'] as num?)?.toDouble() ?? 0.0,
      amonia: (json['amonia'] as num?)?.toDouble() ?? 0.0,
    );
  }
}
