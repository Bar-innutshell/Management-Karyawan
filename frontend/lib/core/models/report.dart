import 'user.dart';

int? _pInt(Object? v) {
  if (v == null) return null;
  if (v is int) return v;
  return int.tryParse(v.toString());
}

double? _pDouble(Object? v) {
  if (v == null) return null;
  if (v is num) return v.toDouble();
  return double.tryParse(v.toString());
}

DateTime? _pDate(Object? v) {
  if (v == null) return null;
  try {
    return DateTime.parse(v.toString());
  } catch (_) {
    return null;
  }
}

class IncomeReport {
  final int? id;
  final double? jumlahPemasukan;
  final DateTime? tanggalLaporan;
  final String? shift;
  final int? userId;
  final User? user;

  IncomeReport({
    this.id,
    this.jumlahPemasukan,
    this.tanggalLaporan,
    this.shift,
    this.userId,
    this.user,
  });

  factory IncomeReport.fromJson(Map<String, dynamic> json) => IncomeReport(
    id: _pInt(json['id']),
    jumlahPemasukan: _pDouble(
      json['jumlahPemasukan'] ?? json['jumlah_pemasukan'],
    ),
    tanggalLaporan: _pDate(json['tanggalLaporan'] ?? json['tanggal_laporan']),
    shift: json['shift']?.toString(),
    userId: _pInt(json['userId'] ?? json['user_id']),
    user: json['user'] is Map<String, dynamic>
        ? User.fromJson(json['user'] as Map<String, dynamic>)
        : null,
  );

  Map<String, dynamic> toJson() => {
    if (id != null) 'id': id,
    if (jumlahPemasukan != null) 'jumlahPemasukan': jumlahPemasukan,
    if (tanggalLaporan != null)
      'tanggalLaporan': tanggalLaporan!.toIso8601String(),
    if (shift != null) 'shift': shift,
    if (userId != null) 'userId': userId,
    if (user != null) 'user': user!.toJson(),
  };

  // helper methods above
}

class ReportFilter {
  final String? startDate; 
  final String? endDate;
  final String? shift;

  ReportFilter({this.startDate, this.endDate, this.shift});

  factory ReportFilter.fromJson(Map<String, dynamic> json) => ReportFilter(
    startDate: json['startDate']?.toString(),
    endDate: json['endDate']?.toString(),
    shift: json['shift']?.toString(),
  );

  Map<String, dynamic> toJson() => {
    if (startDate != null) 'startDate': startDate,
    if (endDate != null) 'endDate': endDate,
    if (shift != null) 'shift': shift,
  };
}

class TotalIncomeSummary {
  final double? totalPemasukkan;
  final int? jumlahTransaksi;
  final ReportFilter? filter;

  TotalIncomeSummary({this.totalPemasukkan, this.jumlahTransaksi, this.filter});

  factory TotalIncomeSummary.fromJson(Map<String, dynamic> json) =>
      TotalIncomeSummary(
        totalPemasukkan: _pDouble(
          json['totalPemasukkan'] ?? json['total_pemasukkan'],
        ),
        jumlahTransaksi: _pInt(
          json['jumlahTransaksi'] ?? json['jumlah_transaksi'],
        ),
        filter: json['filter'] is Map<String, dynamic>
            ? ReportFilter.fromJson(json['filter'] as Map<String, dynamic>)
            : null,
      );

  Map<String, dynamic> toJson() => {
    if (totalPemasukkan != null) 'totalPemasukkan': totalPemasukkan,
    if (jumlahTransaksi != null) 'jumlahTransaksi': jumlahTransaksi,
    if (filter != null) 'filter': filter!.toJson(),
  };
}

class DailyIncomeSummary {
  final DateTime? tanggal;
  final double? totalPemasukan;
  final int? jumlahTransaksi;
  final List<IncomeReport>? items; 

  DailyIncomeSummary({
    this.tanggal,
    this.totalPemasukan,
    this.jumlahTransaksi,
    this.items,
  });

  factory DailyIncomeSummary.fromJson(
    Map<String, dynamic> json,
  ) => DailyIncomeSummary(
    tanggal: _pDate(json['tanggal'] ?? json['date']),
    totalPemasukan: _pDouble(json['totalPemasukan'] ?? json['total_pemasukan']),
    jumlahTransaksi: _pInt(json['jumlahTransaksi'] ?? json['jumlah_transaksi']),
    items: json['items'] is List
        ? (json['items'] as List)
              .whereType<Map<String, dynamic>>()
              .map(IncomeReport.fromJson)
              .toList()
        : null,
  );

  Map<String, dynamic> toJson() => {
    if (tanggal != null) 'tanggal': tanggal!.toIso8601String(),
    if (totalPemasukan != null) 'totalPemasukan': totalPemasukan,
    if (jumlahTransaksi != null) 'jumlahTransaksi': jumlahTransaksi,
    if (items != null) 'items': items!.map((e) => e.toJson()).toList(),
  };
}
