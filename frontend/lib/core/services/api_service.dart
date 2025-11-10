import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import '../config/app_constants.dart';
import 'storage_service.dart';
// Models
import '../models/role.dart';
import '../models/user.dart';
import '../models/gaji.dart';

/// API Service - HTTP Client Layer
/// Handles all communication with backend server
class ApiService {
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

    debugPrint('ApiService: baseUrl=${AppConstants.baseUrl}');
    assert(!AppConstants.baseUrl.contains('/api'));

    final s = storage ?? StorageService();

    // Add Authorization interceptor
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

    // Add logging interceptor
    dio.interceptors.add(LogInterceptor(requestBody: true, responseBody: true));

    return ApiService._(dio, s);
  }

  // ═══════════════════════════════════════════════════════════
  // AUTHENTICATION ENDPOINTS (authRoute.js)
  // ═══════════════════════════════════════════════════════════

  /// POST /auth/login
  /// Login user and save token
  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await _dio.post(
        '/auth/login',
        data: {'email': email, 'password': password},
      );

      final data = response.data as Map<String, dynamic>;
      final token = data['token'] as String?;

      if (token != null) {
        await _storage.saveToken(token);
      }

      return data;
    } on DioException catch (e) {
      throw Exception(_extractMessage(e));
    }
  }

  /// POST /auth/register
  /// Register new user
  Future<User> register({
    required String nama,
    required String email,
    required String password,
    required int roleId,
    double? gajiPerJam,
  }) async {
    try {
      final response = await _dio.post(
        '/auth/register',
        data: {
          'nama': nama,
          'email': email,
          'password': password,
          'roleId': roleId,
          if (gajiPerJam != null) 'gajiPerJam': gajiPerJam,
        },
      );

      final userData = response.data['user'] ?? response.data['data'];
      return User.fromJson(userData as Map<String, dynamic>);
    } on DioException catch (e) {
      throw Exception(_extractMessage(e));
    }
  }

  /// Logout user (clear token)
  Future<void> logout() async {
    await _storage.deleteToken();
  }

  /// Decode JWT token payload
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
    double? gajiPokokBulanan, // ✅ Changed to double to match model
    String? deskripsi,
  }) async {
    try {
      final resp = await _dio.post(
        '/roles',
        data: {
          'nama': nama,
          // Backend expects 'gajiPokok' but we use gajiPokokBulanan internally
          if (gajiPokokBulanan != null) 'gajiPokok': gajiPokokBulanan,
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
    double? gajiPokokBulanan, // ✅ Changed to double to match model
    String? deskripsi,
  }) async {
    try {
      final resp = await _dio.put(
        '/roles/$id',
        data: {
          if (nama != null) 'nama': nama,
          // Backend expects 'gajiPokok' but we use gajiPokokBulanan internally
          if (gajiPokokBulanan != null) 'gajiPokok': gajiPokokBulanan,
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

  // ═══════════════════════════════════════════════════════════
  // GAJI ENDPOINTS (gajiRoute.js)
  // ═══════════════════════════════════════════════════════════

  /// POST /gaji/set-gaji-perjam
  /// Set hourly wage for a user
  Future<UserGajiDetail> setGajiPerJam({
    required int userId,
    required double gajiPerJam,
  }) async {
    try {
      final response = await _dio.post(
        '/gaji/set-gaji-perjam',
        data: {'userId': userId, 'gajiPerJam': gajiPerJam},
      );

      final data = response.data['data'] ?? response.data;
      return UserGajiDetail.fromJson(data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw Exception(_extractMessage(e));
    }
  }

  /// POST /gaji/hitung-dari-gaji-pokok
  /// Calculate salary from role's base salary
  Future<UserGajiDetail> hitungDariGajiPokok({required int userId}) async {
    try {
      final response = await _dio.post(
        '/gaji/hitung-dari-gaji-pokok',
        data: {'userId': userId},
      );

      final data = response.data['data'] ?? response.data;
      return UserGajiDetail.fromJson(data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw Exception(_extractMessage(e));
    }
  }

  /// GET /gaji/user/:userId
  /// Get salary details for a specific user
  Future<UserGajiDetail?> fetchUserGaji(int userId) async {
    try {
      final response = await _dio.get('/gaji/user/$userId');
      final data = response.data['data'] ?? response.data;

      if (data is Map<String, dynamic>) {
        return UserGajiDetail.fromJson(data);
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  /// GET /gaji/all
  /// Get salary list for all users
  Future<List<UserGajiListItem>> fetchAllUserGaji() async {
    try {
      final response = await _dio.get('/gaji/all');
      final data = response.data['data'] ?? response.data;

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

  // ═══════════════════════════════════════════════════════════
  // USER MANAGEMENT ENDPOINTS (authRoute.js)
  // ═══════════════════════════════════════════════════════════

  /// GET /auth/users
  /// Get all users
  Future<List<User>> getUsers() async {
    try {
      final response = await _dio.get('/auth/users');
      final data = response.data['data'] ?? response.data;

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

  /// GET /auth/user/:id
  /// Get user by ID
  Future<User?> getUser(int id) async {
    try {
      final response = await _dio.get('/auth/user/$id');
      final data = response.data['data'] ?? response.data;

      if (data is Map<String, dynamic>) {
        return User.fromJson(data);
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  /// PUT /auth/user/:id
  /// Update user
  Future<User> updateUser(
    int id, {
    String? nama,
    String? email,
    String? password,
    int? roleId,
    double? gajiPerJam,
  }) async {
    try {
      final response = await _dio.put(
        '/auth/user/$id',
        data: {
          if (nama != null) 'nama': nama,
          if (email != null) 'email': email,
          if (password != null) 'password': password,
          if (roleId != null) 'roleId': roleId,
          if (gajiPerJam != null) 'gajiPerJam': gajiPerJam,
        },
      );

      final data = response.data['data'] ?? response.data;
      return User.fromJson(data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw Exception(_extractMessage(e));
    }
  }

  /// DELETE /auth/user/:id
  /// Delete user
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
