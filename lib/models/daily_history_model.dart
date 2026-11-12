class DailyHistoryModel {
  final String tanggal;
  final double ketinggianAir;
  final double tekananUdara;
  final double suhuBox;
  final int totalHujan;

  // Getter alias untuk kompatibilitas
  double get suhu => suhuBox;
  double get ph => 7.0;
  double get amonia => ketinggianAir;

  DailyHistoryModel({
    required this.tanggal,
    required this.ketinggianAir,
    required this.tekananUdara,
    required this.suhuBox,
    required this.totalHujan,
  });

  factory DailyHistoryModel.fromJson(Map<String, dynamic> json) {
    final rawTinggi = json['ketinggian_air'] ?? json['tinggi_air'] ?? json['amonia'] ?? 85.0;
    final rawTekanan = json['tekanan_udara'] ?? json['pressure'] ?? 1013.25;
    final rawSuhuBox = json['suhu_box'] ?? json['suhu'] ?? 28.0;
    final rawHujan = json['total_hujan'] ?? (json['hujan'] == true ? 1 : 0);

    return DailyHistoryModel(
      tanggal: json['tanggal'] as String? ?? '',
      ketinggianAir: (rawTinggi as num).toDouble(),
      tekananUdara: (rawTekanan as num).toDouble(),
      suhuBox: (rawSuhuBox as num).toDouble(),
      totalHujan: (rawHujan as num).toInt(),
    );
  }
}
