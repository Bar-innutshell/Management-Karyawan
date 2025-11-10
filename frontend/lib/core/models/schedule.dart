import 'user.dart';

class ScheduleItem {
  final int? id;
  final int? userId;
  final DateTime? waktuMulai;
  final DateTime? waktuSelesai;
  final User? user;

  ScheduleItem({
    this.id,
    this.userId,
    this.waktuMulai,
    this.waktuSelesai,
    this.user,
  });

  factory ScheduleItem.fromJson(Map<String, dynamic> json) => ScheduleItem(
    id: _pInt(json['id']),
    userId: _pInt(json['userId'] ?? json['user_id']),
    waktuMulai: _pDate(json['waktuMulai'] ?? json['start'] ?? json['mulai']),
    waktuSelesai: _pDate(
      json['waktuSelesai'] ?? json['end'] ?? json['selesai'],
    ),
    user: json['user'] is Map<String, dynamic>
        ? User.fromJson(json['user'] as Map<String, dynamic>)
        : null,
  );

  Map<String, dynamic> toJson() => {
    if (id != null) 'id': id,
    if (userId != null) 'userId': userId,
    if (waktuMulai != null) 'waktuMulai': waktuMulai!.toIso8601String(),
    if (waktuSelesai != null) 'waktuSelesai': waktuSelesai!.toIso8601String(),
    if (user != null) 'user': user!.toJson(),
  };
}

int? _pInt(Object? v) {
  if (v == null) return null;
  if (v is int) return v;
  return int.tryParse(v.toString());
}

DateTime? _pDate(Object? v) {
  if (v == null) return null;
  try {
    return DateTime.parse(v.toString());
  } catch (_) {
    return null;
  }
}
