class Role {
  final int? id;
  final String? nama;
  final double? gajiPokokBulanan;  
  final String? deskripsi;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final int? jumlahUser;

  Role({
    this.id,
    this.nama,
    this.gajiPokokBulanan,
    this.deskripsi,
    this.createdAt,
    this.updatedAt,
    this.jumlahUser,
  });

  factory Role.fromJson(Map<String, dynamic> json) => Role(
    id: json['id'] is int ? json['id'] as int : int.tryParse('${json['id']}'),
    nama: json['nama']?.toString() ?? json['name']?.toString(),
    gajiPokokBulanan: _parseDouble(
      json['gajiPokokBulanan'] ?? json['gajiPokok'],
    ), // ✅ Support both field names
    deskripsi: json['deskripsi']?.toString() ?? json['description']?.toString(),
    createdAt: _parseDate(json['createdAt']),
    updatedAt: _parseDate(json['updatedAt']),
    jumlahUser: _extractCount(json),
  );

  Map<String, dynamic> toJson() => {
    if (id != null) 'id': id,
    if (nama != null) 'nama': nama,
    if (gajiPokokBulanan != null) 'gajiPokokBulanan': gajiPokokBulanan,
    if (deskripsi != null) 'deskripsi': deskripsi,
    if (createdAt != null) 'createdAt': createdAt!.toIso8601String(),
    if (updatedAt != null) 'updatedAt': updatedAt!.toIso8601String(),
    if (jumlahUser != null) '_count': {'users': jumlahUser},
  };

  static DateTime? _parseDate(Object? v) {
    if (v == null) return null;
    final s = v.toString();
    try {
      return DateTime.parse(s);
    } catch (_) {
      return null;
    }
  }

  static double? _parseDouble(Object? v) {
    if (v == null) return null;
    if (v is num) return v.toDouble();
    return double.tryParse(v.toString());
  }

  static int? _extractCount(Map<String, dynamic> json) {
    final count = json['_count'];
    if (count is Map && count['users'] != null) {
      final raw = count['users'];
      return raw is int ? raw : int.tryParse('$raw');
    }
    return null;
  }

  Role copyWith({
    int? id,
    String? nama,
    double? gajiPokokBulanan,
    String? deskripsi,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? jumlahUser,
  }) => Role(
    id: id ?? this.id,
    nama: nama ?? this.nama,
    gajiPokokBulanan: gajiPokokBulanan ?? this.gajiPokokBulanan,
    deskripsi: deskripsi ?? this.deskripsi,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    jumlahUser: jumlahUser ?? this.jumlahUser,
  );
}
