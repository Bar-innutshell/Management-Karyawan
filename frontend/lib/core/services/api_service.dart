import 'dart:convert';
import 'package:flutter/foundation.dart';

import 'package:dio/dio.dart';
import '../config/app_constants.dart';
import 'storage_service.dart';
// models
import '../models/role.dart';
import '../models/user.dart';
import '../models/attendance.dart';
import '../models/gaji.dart';
import '../models/report.dart';
import '../models/schedule.dart';

class ApiService {
  //service api
  final Dio _dio;
  final StorageService _storage;

  ApiService._(this._dio, this._storage);

  factory ApiService({StorageService? storage}) {
    final dio = Dio(
      BaseOptions(
        baseUrl: AppConstants.baseUrl,
        connectTimeout: AppConstants.apiTimeout,
        receiveTimeout: AppConstants.apiTimeout,
      ),
    );
    debugPrint(
      'ApiService: constructing Dio with baseUrl=${AppConstants.baseUrl}',
    );
    assert(!AppConstants.baseUrl.contains('/api'));
    final s = storage ?? StorageService();
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await s.readToken();
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
        onError: (err, handler) async {
          return handler.next(err);
        },
      ),
    );

    dio.interceptors.add(LogInterceptor(requestBody: true, responseBody: true));

    return ApiService._(dio, s);
  }

  //fitur login
  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final resp = await _dio.post(
        '/auth/login',
        data: {'email': email, 'password': password},
      );
      final data = resp.data as Map<String, dynamic>;
      final token = data['token'] as String?;
      if (token != null) {
        await _storage.saveToken(token);
      }
      return data;
    } on DioException catch (e) {
      final respData = e.response?.data;
      if (respData is Map && respData['message'] != null) {
        throw Exception(respData['message'].toString());
      }
      throw Exception(e.message);
    }
  }

  //fitur role
  Future<Map<String, dynamic>?> getRoleById(int id) async {
    try {
      final resp = await _dio.get('/roles/$id');
      return resp.data as Map<String, dynamic>;
    } catch (e) {
      return null;
    }
  }

  // =============================================================
  // ROLES
  // =============================================================
  /// Ambil daftar semua role (GET /roles)
  Future<List<Role>> fetchRoles() async {
    try {
      final resp = await _dio.get('/roles');
      final payload = resp.data;
      final list = (payload is Map && payload['data'] is List)
          ? payload['data'] as List
          : (payload as List? ?? const []);
      return list.whereType<Map<String, dynamic>>().map(Role.fromJson).toList();
    } catch (e) {
      rethrow;
    }
  }

  /// Ambil satu role by id (GET /roles/:id) typed
  Future<Role?> fetchRole(int id) async {
    try {
      final resp = await _dio.get('/roles/$id');
      final data = resp.data;
      final map = (data is Map && data['data'] is Map)
          ? data['data'] as Map<String, dynamic>
          : (data as Map<String, dynamic>);
      return Role.fromJson(map);
    } catch (_) {
      return null;
    }
  }

  /// Buat role baru (POST /roles)
  Future<Role> createRole({
    required String nama,
    int? gajiPokok,
    String? deskripsi,
  }) async {
    try {
      final resp = await _dio.post(
        '/roles',
        data: {
          'nama': nama,
          if (gajiPokok != null) 'gajiPokok': gajiPokok,
          if (deskripsi != null) 'deskripsi': deskripsi,
        },
      );
      final map = resp.data['data'] as Map<String, dynamic>;
      return Role.fromJson(map);
    } on DioException catch (e) {
      throw Exception(_extractMessage(e));
    }
  }

  /// Update role (PUT /roles/:id)
  Future<Role> updateRole(
    int id, {
    String? nama,
    int? gajiPokok,
    String? deskripsi,
  }) async {
    try {
      final resp = await _dio.put(
        '/roles/$id',
        data: {
          if (nama != null) 'nama': nama,
          if (gajiPokok != null) 'gajiPokok': gajiPokok,
          if (deskripsi != null) 'deskripsi': deskripsi,
        },
      );
      final map = resp.data['data'] as Map<String, dynamic>;
      return Role.fromJson(map);
    } on DioException catch (e) {
      throw Exception(_extractMessage(e));
    }
  }

  /// Hapus role (DELETE /roles/:id)
  Future<void> deleteRole(int id) async {
    try {
      await _dio.delete('/roles/$id');
    } on DioException catch (e) {
      throw Exception(_extractMessage(e));
    }
  }

  // =============================================================
  // ABSENSI (attendance)
  // =============================================================
  /// Clock In (POST /absensi/clock-in)
  Future<AttendanceRecord> clockIn(String shift) async {
    try {
      final resp = await _dio.post('/absensi/clock-in', data: {'shift': shift});
      final data = resp.data['data'] ?? resp.data; // adapt if wrapped
      return AttendanceRecord.fromJson((data as Map<String, dynamic>));
    } on DioException catch (e) {
      throw Exception(_extractMessage(e));
    }
  }

  /// Clock Out (POST /absensi/clock-out)
  Future<AttendanceRecord> clockOut() async {
    try {
      final resp = await _dio.post('/absensi/clock-out');
      final data = resp.data['data'] ?? resp.data;
      return AttendanceRecord.fromJson((data as Map<String, dynamic>));
    } on DioException catch (e) {
      throw Exception(_extractMessage(e));
    }
  }

  /// Ambil riwayat absensi milik user login (GET /absensi/my)
  Future<List<AttendanceRecord>> fetchMyAttendance() async {
    try {
      final resp = await _dio.get('/absensi/my');
      final list = resp.data['data'] ?? resp.data;
      if (list is List) {
        return list
            .whereType<Map<String, dynamic>>()
            .map(AttendanceRecord.fromJson)
            .toList();
      }
      return const [];
    } catch (e) {
      rethrow;
    }
  }

  /// Ambil absensi hari ini (GET /absensi/today)
  Future<AttendanceRecord?> fetchTodayAttendance() async {
    try {
      final resp = await _dio.get('/absensi/today');
      final data = resp.data['data'] ?? resp.data;
      if (data is Map<String, dynamic>) {
        return AttendanceRecord.fromJson(data);
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  /// Ambil semua absensi (admin) (GET /absensi/all)
  Future<List<AttendanceRecord>> fetchAllAttendance() async {
    try {
      final resp = await _dio.get('/absensi/all');
      final list = resp.data['data'] ?? resp.data;
      if (list is List) {
        return list
            .whereType<Map<String, dynamic>>()
            .map(AttendanceRecord.fromJson)
            .toList();
      }
      return const [];
    } catch (e) {
      rethrow;
    }
  }

  // =============================================================
  // GAJI (salary)
  // =============================================================
  /// Set gaji per jam (POST /gaji/set-gaji-perjam)
  Future<UserGajiDetail> setGajiPerJam({
    required int userId,
    required double gajiPerJam,
  }) async {
    try {
      final resp = await _dio.post(
        '/gaji/set-gaji-perjam',
        data: {'userId': userId, 'gajiPerJam': gajiPerJam},
      );
      final data = resp.data['data'] ?? resp.data;
      return UserGajiDetail.fromJson(data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw Exception(_extractMessage(e));
    }
  }

  /// Hitung gaji dari gaji pokok role (POST /gaji/hitung-dari-gaji-pokok)
  Future<UserGajiDetail> hitungDariGajiPokok({required int userId}) async {
    try {
      final resp = await _dio.post(
        '/gaji/hitung-dari-gaji-pokok',
        data: {'userId': userId},
      );
      final data = resp.data['data'] ?? resp.data;
      return UserGajiDetail.fromJson(data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw Exception(_extractMessage(e));
    }
  }

  /// Detail gaji user (GET /gaji/user/:userId)
  Future<UserGajiDetail?> fetchUserGaji(int userId) async {
    try {
      final resp = await _dio.get('/gaji/user/$userId');
      final data = resp.data['data'] ?? resp.data;
      if (data is Map<String, dynamic>) {
        return UserGajiDetail.fromJson(data);
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  /// Daftar gaji semua user (GET /gaji/all)
  Future<List<UserGajiListItem>> fetchAllUserGaji() async {
    try {
      final resp = await _dio.get('/gaji/all');
      final data = resp.data['data'] ?? resp.data;
      if (data is List) {
        return data
            .whereType<Map<String, dynamic>>()
            .map(UserGajiListItem.fromJson)
            .toList();
      }
      return const [];
    } catch (e) {
      rethrow;
    }
  }

  // =============================================================
  // LAPORAN / PEMASUKKAN (reports & income)
  // =============================================================
  /// Total pemasukkan (GET /laporan/total)
  Future<TotalIncomeSummary?> fetchTotalIncome({
    String? startDate,
    String? endDate,
    String? shift,
  }) async {
    try {
      final resp = await _dio.get(
        '/laporan/total',
        queryParameters: {
          if (startDate != null) 'startDate': startDate,
          if (endDate != null) 'endDate': endDate,
          if (shift != null) 'shift': shift,
        },
      );
      final data = resp.data['data'] ?? resp.data;
      if (data is Map<String, dynamic>) {
        return TotalIncomeSummary.fromJson(data);
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  /// Laporan harian (GET /laporan/harian)
  Future<List<DailyIncomeSummary>> fetchDailyIncome({
    String? startDate,
    String? endDate,
    String? shift,
  }) async {
    try {
      final resp = await _dio.get(
        '/laporan/harian',
        queryParameters: {
          if (startDate != null) 'startDate': startDate,
          if (endDate != null) 'endDate': endDate,
          if (shift != null) 'shift': shift,
        },
      );
      final data = resp.data['data'] ?? resp.data;
      if (data is List) {
        return data
            .whereType<Map<String, dynamic>>()
            .map(DailyIncomeSummary.fromJson)
            .toList();
      }
      return const [];
    } catch (e) {
      rethrow;
    }
  }

  /// Laporan detail pemasukkan (GET /laporan/detail)
  Future<List<IncomeReport>> fetchIncomeDetail({
    String? startDate,
    String? endDate,
    String? shift,
  }) async {
    try {
      final resp = await _dio.get(
        '/laporan/detail',
        queryParameters: {
          if (startDate != null) 'startDate': startDate,
          if (endDate != null) 'endDate': endDate,
          if (shift != null) 'shift': shift,
        },
      );
      final data = resp.data['data'] ?? resp.data;
      if (data is List) {
        return data
            .whereType<Map<String, dynamic>>()
            .map(IncomeReport.fromJson)
            .toList();
      }
      return const [];
    } catch (e) {
      rethrow;
    }
  }

  /// Daftar pemasukkan (GET /pemasukkan/show)
  Future<List<IncomeReport>> fetchPemasukkan() async {
    try {
      final resp = await _dio.get('/pemasukkan/show');
      final data = resp.data['data'] ?? resp.data;
      if (data is List) {
        return data
            .whereType<Map<String, dynamic>>()
            .map(IncomeReport.fromJson)
            .toList();
      }
      return const [];
    } catch (e) {
      rethrow;
    }
  }

  /// Tambah pemasukkan baru (POST /pemasukkan/insert)
  Future<IncomeReport> createPemasukkan({
    required double jumlahPemasukan,
    required String shift,
  }) async {
    try {
      final resp = await _dio.post(
        '/pemasukkan/insert',
        data: {'jumlahPemasukkan': jumlahPemasukan, 'shift': shift},
      );
      final data = resp.data['data'] ?? resp.data;
      return IncomeReport.fromJson(data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw Exception(_extractMessage(e));
    }
  }

  // =============================================================
  // JADWAL (schedule) - ASSUMPTION endpoints (adjust if different)
  // =============================================================
  /// Ambil jadwal (GET /schedule) asumsi path
  Future<List<ScheduleItem>> fetchSchedule() async {
    try {
      final resp = await _dio.get('/schedule');
      final data = resp.data['data'] ?? resp.data;
      if (data is List) {
        return data
            .whereType<Map<String, dynamic>>()
            .map(ScheduleItem.fromJson)
            .toList();
      }
      return const [];
    } catch (e) {
      rethrow;
    }
  }

  /// Generate / create jadwal baru (POST /schedule/create) asumsi path
  Future<List<ScheduleItem>> createSchedule() async {
    try {
      final resp = await _dio.post('/schedule/create');
      final data = resp.data['data'] ?? resp.data;
      if (data is List) {
        return data
            .whereType<Map<String, dynamic>>()
            .map(ScheduleItem.fromJson)
            .toList();
      }
      return const [];
    } on DioException catch (e) {
      throw Exception(_extractMessage(e));
    }
  }

  //fitur logout
  Future<void> logout() async {
    await _storage.deleteToken();
  }

  //model jwt
  Map<String, dynamic>? decodeJwtPayload(String token) {
    try {
      final parts = token.split('.');
      if (parts.length != 3) return null;
      final payload = parts[1];
      final normalized = base64Url.normalize(payload);
      final decoded = utf8.decode(base64Url.decode(normalized));
      return jsonDecode(decoded) as Map<String, dynamic>?;
    } catch (e) {
      return null;
    }
  }

  // =============================================================
  // USERS MANAGEMENT
  // =============================================================
  /// Ambil semua user (GET /auth/users)
  Future<List<User>> getUsers() async {
    try {
      final resp = await _dio.get('/auth/users');
      final data = resp.data['data'] ?? resp.data;
      if (data is List) {
        return data
            .whereType<Map<String, dynamic>>()
            .map(User.fromJson)
            .toList();
      }
      return const [];
    } catch (e) {
      rethrow;
    }
  }

  /// Ambil detail satu user (GET /auth/user/:id)
  Future<User?> getUser(int id) async {
    try {
      final resp = await _dio.get('/auth/user/$id');
      final data = resp.data['data'] ?? resp.data;
      if (data is Map<String, dynamic>) {
        return User.fromJson(data);
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  /// Buat user baru (POST /auth/register)
  Future<User> createUser({
    required String nama,
    required String email,
    required String password,
    required int roleId,
    double? gajiPerJam,
  }) async {
    try {
      final resp = await _dio.post(
        '/auth/register',
        data: {
          'nama': nama,
          'email': email,
          'password': password,
          'roleId': roleId,
          if (gajiPerJam != null) 'gajiPerJam': gajiPerJam,
        },
      );
      final data = resp.data['data'] ?? resp.data;
      return User.fromJson(data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw Exception(_extractMessage(e));
    }
  }

  /// Update user (PUT /auth/user/:id)
  Future<User> updateUser(
    int id, {
    String? nama,
    String? email,
    String? password,
    int? roleId,
    double? gajiPerJam,
  }) async {
    try {
      final resp = await _dio.put(
        '/auth/user/$id',
        data: {
          if (nama != null) 'nama': nama,
          if (email != null) 'email': email,
          if (password != null) 'password': password,
          if (roleId != null) 'roleId': roleId,
          if (gajiPerJam != null) 'gajiPerJam': gajiPerJam,
        },
      );
      final data = resp.data['data'] ?? resp.data;
      return User.fromJson(data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw Exception(_extractMessage(e));
    }
  }

  /// Hapus user (DELETE /auth/user/:id)
  Future<void> deleteUser(int id) async {
    try {
      await _dio.delete('/auth/user/$id');
    } on DioException catch (e) {
      throw Exception(_extractMessage(e));
    }
  }

  // =============================================================
  // Helpers
  // =============================================================
  String _extractMessage(DioException e) {
    final d = e.response?.data;
    if (d is Map && d['message'] != null) {
      return d['message'].toString();
    }
    return e.message ?? 'Network error';
  }
}
