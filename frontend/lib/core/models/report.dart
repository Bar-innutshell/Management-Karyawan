class Report {
  final int? id;
  final double jumlahPemasukan;
  final DateTime tanggalLaporan;
  final String shift;
  final String user;
  final int userId;

  Report({
    this.id,
    required this.jumlahPemasukan,
    required this.tanggalLaporan,
    required this.shift,
    required this.user,
    required this.userId,
  });

  factory Report.fromJson(Map<String, dynamic> json) {
    return Report(
      id: json['id'] as int?,
      jumlahPemasukan: (json['jumlahPemasukan'] as num).toDouble(),
      tanggalLaporan: DateTime.parse(json['tanggalLaporan']),
      shift: json['shift'] ?? '',
      user: json['user'] ?? '',
      userId: json['userId'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'jumlahPemasukan': jumlahPemasukan,
      'tanggalLaporan': tanggalLaporan.toIso8601String(),
      'shift': shift,
      'user': user,
      'userId': userId,
    };
  }
}
