import 'user.dart';

class AttendanceRecord {
  final int? id;
  final int? userId;
  final DateTime? tanggal; // date of attendance
  final String? shift; // Pagi / Siang / Sore / Malam
  final DateTime? jamMasuk;
  final DateTime? jamKeluar;
  final int? menitTerlambat;
  final double? jamKerja; // computed hours worked
  final double? gajiDihasilkan; // computed wage result
  final String? status; // Hadir / Telat / (others)
  final User? user; // when included

  AttendanceRecord({
    this.id,
    this.userId,
    this.tanggal,
    this.shift,
    this.jamMasuk,
    this.jamKeluar,
    this.menitTerlambat,
    this.jamKerja,
    this.gajiDihasilkan,
    this.status,
    this.user,
  });

  factory AttendanceRecord.fromJson(Map<String, dynamic> json) =>
      AttendanceRecord(
        id: _parseInt(json['id']),
        userId: _parseInt(json['userId'] ?? json['user_id']),
        tanggal: _parseDate(json['tanggal'] ?? json['tanggalLaporan']),
        shift: json['shift']?.toString(),
        jamMasuk: _parseDate(json['jamMasuk']),
        jamKeluar: _parseDate(json['jamKeluar']),
        menitTerlambat: _parseInt(json['menitTerlambat']),
        jamKerja: _parseDouble(json['jamKerja']),
        gajiDihasilkan: _parseDouble(json['gajiDihasilkan'] ?? json['gaji']),
        status: json['status']?.toString(),
        user: json['user'] is Map<String, dynamic>
            ? User.fromJson(json['user'] as Map<String, dynamic>)
            : null,
      );

  Map<String, dynamic> toJson() => {
    if (id != null) 'id': id,
    if (userId != null) 'userId': userId,
    if (tanggal != null) 'tanggal': tanggal!.toIso8601String(),
    if (shift != null) 'shift': shift,
    if (jamMasuk != null) 'jamMasuk': jamMasuk!.toIso8601String(),
    if (jamKeluar != null) 'jamKeluar': jamKeluar!.toIso8601String(),
    if (menitTerlambat != null) 'menitTerlambat': menitTerlambat,
    if (jamKerja != null) 'jamKerja': jamKerja,
    if (gajiDihasilkan != null) 'gajiDihasilkan': gajiDihasilkan,
    if (status != null) 'status': status,
    if (user != null) 'user': user!.toJson(),
  };

  static int? _parseInt(Object? v) {
    if (v == null) return null;
    if (v is int) return v;
    return int.tryParse(v.toString());
  }

  static double? _parseDouble(Object? v) {
    if (v == null) return null;
    if (v is num) return v.toDouble();
    return double.tryParse(v.toString());
  }

  static DateTime? _parseDate(Object? v) {
    if (v == null) return null;
    try {
      return DateTime.parse(v.toString());
    } catch (_) {
      return null;
    }
  }
}
