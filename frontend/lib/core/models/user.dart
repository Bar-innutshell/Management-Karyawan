class User {
  final int? id;
  final String? nama;
  final String? email;
  final int? roleId;
  final double? gajiPerJam; 
  final RoleSummary? role; 

  User({
    this.id,
    this.nama,
    this.email,
    this.roleId,
    this.gajiPerJam,
    this.role,
  });

  factory User.fromJson(Map<String, dynamic> json) => User(
    id: json['id'] is int ? json['id'] as int : int.tryParse('${json['id']}'),
    nama: json['nama']?.toString() ?? json['name']?.toString(),
    email: json['email']?.toString(),
    roleId: json['roleId'] is int
        ? json['roleId'] as int
        : int.tryParse('${json['roleId']}') ??
              int.tryParse('${json['role_id']}'),
    gajiPerJam: _parseDouble(json['gajiPerJam']),
    role: json['role'] is Map<String, dynamic>
        ? RoleSummary.fromJson(json['role'] as Map<String, dynamic>)
        : null,
  );

  Map<String, dynamic> toJson() => {
    if (id != null) 'id': id,
    if (nama != null) 'nama': nama,
    if (email != null) 'email': email,
    if (roleId != null) 'roleId': roleId,
    if (gajiPerJam != null) 'gajiPerJam': gajiPerJam,
    if (role != null) 'role': role!.toJson(),
  };

  User copyWith({
    int? id,
    String? nama,
    String? email,
    int? roleId,
    double? gajiPerJam,
    RoleSummary? role,
  }) => User(
    id: id ?? this.id,
    nama: nama ?? this.nama,
    email: email ?? this.email,
    roleId: roleId ?? this.roleId,
    gajiPerJam: gajiPerJam ?? this.gajiPerJam,
    role: role ?? this.role,
  );

  factory User.fromJwtPayload(Map<String, dynamic> payload) => User(
    id: payload['userId'] is int
        ? payload['userId'] as int
        : int.tryParse('${payload['userId']}'),
    email: payload['email']?.toString(),
    roleId: payload['roleId'] is int
        ? payload['roleId'] as int
        : int.tryParse('${payload['roleId']}') ??
              int.tryParse('${payload['role_id']}'),
  );

  static double? _parseDouble(Object? v) {
    if (v == null) return null;
    if (v is num) return v.toDouble();
    return double.tryParse(v.toString());
  }
}

class RoleSummary {
  final String? nama;
  final int? gajiPokok;
  RoleSummary({this.nama, this.gajiPokok});
  factory RoleSummary.fromJson(Map<String, dynamic> json) => RoleSummary(
    nama: json['nama']?.toString(),
    gajiPokok: json['gajiPokok'] is int
        ? json['gajiPokok'] as int
        : int.tryParse('${json['gajiPokok']}'),
  );
  Map<String, dynamic> toJson() => {
    if (nama != null) 'nama': nama,
    if (gajiPokok != null) 'gajiPokok': gajiPokok,
  };
}
