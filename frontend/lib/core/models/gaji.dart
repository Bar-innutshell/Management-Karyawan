import 'user.dart';

class UserGajiDetail {
  final User? user;
  final double? gajiPerJam;
  final double? gajiHarian;
  final double? gajiBulanan;
  final String? formula; // textual formula from controller

  UserGajiDetail({
    this.user,
    this.gajiPerJam,
    this.gajiHarian,
    this.gajiBulanan,
    this.formula,
  });

  factory UserGajiDetail.fromJson(Map<String, dynamic> json) => UserGajiDetail(
    user: json['user'] is Map<String, dynamic>
        ? User.fromJson(json['user'] as Map<String, dynamic>)
        : null,
    gajiPerJam: _parseDouble(json['gajiPerJam'] ?? json['gaji_per_jam']),
    gajiHarian: _parseDouble(json['gajiHarian'] ?? json['gaji_harian']),
    gajiBulanan: _parseDouble(json['gajiBulanan'] ?? json['gaji_bulanan']),
    formula: json['formula']?.toString(),
  );

  Map<String, dynamic> toJson() => {
    if (user != null) 'user': user!.toJson(),
    if (gajiPerJam != null) 'gajiPerJam': gajiPerJam,
    if (gajiHarian != null) 'gajiHarian': gajiHarian,
    if (gajiBulanan != null) 'gajiBulanan': gajiBulanan,
    if (formula != null) 'formula': formula,
  };

  static double? _parseDouble(Object? v) {
    if (v == null) return null;
    if (v is num) return v.toDouble();
    return double.tryParse(v.toString());
  }
}

class UserGajiListItem {
  final int? userId;
  final String? nama;
  final String? email;
  final String? roleName;
  final double? gajiPerJam;
  final double? gajiBulanan;

  UserGajiListItem({
    this.userId,
    this.nama,
    this.email,
    this.roleName,
    this.gajiPerJam,
    this.gajiBulanan,
  });

  factory UserGajiListItem.fromJson(Map<String, dynamic> json) {
    // Backend mengirim: { id, nama, email, gajiPerJam, role: { nama, gajiPokok }, gajiBulanan }
    final role = json['role'];
    return UserGajiListItem(
      userId: _parseInt(json['id']),
      nama: json['nama']?.toString(),
      email: json['email']?.toString(),
      roleName: role is Map ? role['nama']?.toString() : null,
      gajiPerJam: _parseDouble(json['gajiPerJam']),
      gajiBulanan: _parseDouble(json['gajiBulanan']),
    );
  }

  Map<String, dynamic> toJson() => {
    if (userId != null) 'id': userId,
    if (nama != null) 'nama': nama,
    if (email != null) 'email': email,
    if (roleName != null) 'role': {'nama': roleName},
    if (gajiPerJam != null) 'gajiPerJam': gajiPerJam,
    if (gajiBulanan != null) 'gajiBulanan': gajiBulanan,
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
}
