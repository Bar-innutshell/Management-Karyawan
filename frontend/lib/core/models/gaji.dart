class UserGajiDetail {
  final UserInfo? user;
  final GajiInfo? gaji;

  UserGajiDetail({this.user, this.gaji});

  // Helper getters for backward compatibility
  double? get gajiPerJam => gaji?.gajiPerJam;
  double? get gajiHarian => gaji?.gajiHarian;
  double? get gajiBulanan => gaji?.gajiBulanan;
  double? get gajiPokokBulanan => gaji?.gajiPokokBulanan;
  String? get formula => gaji?.formula;

  factory UserGajiDetail.fromJson(Map<String, dynamic> json) {
    // Backend response: { user: {...}, gaji: {...} }
    return UserGajiDetail(
      user: json['user'] is Map<String, dynamic>
          ? UserInfo.fromJson(json['user'] as Map<String, dynamic>)
          : null,
      gaji: json['gaji'] is Map<String, dynamic>
          ? GajiInfo.fromJson(json['gaji'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
    if (user != null) 'user': user!.toJson(),
    if (gaji != null) 'gaji': gaji!.toJson(),
  };
}

class UserInfo {
  final int? id;
  final String? nama;
  final String? email;
  final String? role; // role name as string

  UserInfo({this.id, this.nama, this.email, this.role});

  factory UserInfo.fromJson(Map<String, dynamic> json) => UserInfo(
    id: _parseInt(json['id']),
    nama: json['nama']?.toString(),
    email: json['email']?.toString(),
    role: json['role']?.toString(),
  );

  Map<String, dynamic> toJson() => {
    if (id != null) 'id': id,
    if (nama != null) 'nama': nama,
    if (email != null) 'email': email,
    if (role != null) 'role': role,
  };

  static int? _parseInt(Object? v) {
    if (v == null) return null;
    if (v is int) return v;
    return int.tryParse(v.toString());
  }
}

class GajiInfo {
  final double? gajiPokokBulanan;
  final double? gajiPerJam;
  final double? gajiHarian;
  final double? gajiBulanan;
  final String? formula;

  GajiInfo({
    this.gajiPokokBulanan,
    this.gajiPerJam,
    this.gajiHarian,
    this.gajiBulanan,
    this.formula,
  });

  factory GajiInfo.fromJson(Map<String, dynamic> json) => GajiInfo(
    gajiPokokBulanan: _parseDouble(json['gajiPokokBulanan']),
    gajiPerJam: _parseDouble(json['gajiPerJam']),
    gajiHarian: _parseDouble(json['gajiHarian']),
    gajiBulanan: _parseDouble(json['gajiBulanan']),
    formula: json['formula']?.toString(),
  );

  Map<String, dynamic> toJson() => {
    if (gajiPokokBulanan != null) 'gajiPokokBulanan': gajiPokokBulanan,
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
  final UserInfo? user;
  final GajiInfo? gaji;

  UserGajiListItem({this.user, this.gaji});

  // Helper getters for backward compatibility
  int? get userId => user?.id;
  String? get nama => user?.nama;
  String? get email => user?.email;
  String? get roleName => user?.role;
  double? get gajiPerJam => gaji?.gajiPerJam;
  double? get gajiHarian => gaji?.gajiHarian;
  double? get gajiBulanan => gaji?.gajiBulanan;
  double? get gajiPokokBulanan => gaji?.gajiPokokBulanan;

  factory UserGajiListItem.fromJson(Map<String, dynamic> json) {
    // Backend response: { user: { id, nama, email, role }, gaji: { ... } }
    return UserGajiListItem(
      user: json['user'] is Map<String, dynamic>
          ? UserInfo.fromJson(json['user'] as Map<String, dynamic>)
          : null,
      gaji: json['gaji'] is Map<String, dynamic>
          ? GajiInfo.fromJson(json['gaji'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
    if (user != null) 'user': user!.toJson(),
    if (gaji != null) 'gaji': gaji!.toJson(),
  };
}

class GajiSummary {
  final int? totalUser;
  final double? totalGajiBulanan;

  GajiSummary({this.totalUser, this.totalGajiBulanan});

  factory GajiSummary.fromJson(Map<String, dynamic> json) => GajiSummary(
    totalUser: json['totalUser'] is int
        ? json['totalUser'] as int
        : int.tryParse(json['totalUser']?.toString() ?? ''),
    totalGajiBulanan: _parseDouble(json['totalGajiBulanan']),
  );

  Map<String, dynamic> toJson() => {
    if (totalUser != null) 'totalUser': totalUser,
    if (totalGajiBulanan != null) 'totalGajiBulanan': totalGajiBulanan,
  };

  static double? _parseDouble(Object? v) {
    if (v == null) return null;
    if (v is num) return v.toDouble();
    return double.tryParse(v.toString());
  }
}
