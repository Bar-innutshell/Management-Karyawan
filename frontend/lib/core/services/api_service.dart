import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import '../config/app_constants.dart';
import 'storage_service.dart';

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

  // ==================== FITUR LOGIN ====================
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

  // ==================== FITUR ROLE ====================
  Future<Map<String, dynamic>?> getRoleById(int id) async {
    try {
      final resp = await _dio.get('/roles/$id');
      return resp.data as Map<String, dynamic>;
    } catch (e) {
      return null;
    }
  }

  // ==================== FITUR LOGOUT ====================
  Future<void> logout() async {
    await _storage.deleteToken();
  }

  // ==================== JWT DECODER ====================
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

  // =====================================================
  // 🌐 GENERIC API METHODS (untuk fitur lain, termasuk laporan)
  // =====================================================

  Future<dynamic> getData(String endpoint) async {
  try {
    final response = await _dio.get(endpoint);
    return response.data;
  } on DioException catch (e) {
    throw Exception(e.response?.data['message'] ?? e.message);
  }
}

  Future<dynamic> postData(String endpoint, Map<String, dynamic> data) async {
  try {
    final response = await _dio.post(endpoint, data: data);
    return response.data;
  } on DioException catch (e) {
    throw Exception(e.response?.data['message'] ?? e.message);
  }
}

  Future<dynamic> putData(String endpoint, Map<String, dynamic> data) async {
    try {
      final resp = await _dio.put(endpoint, data: data);
      return resp.data;
    } on DioException catch (e) {
      _handleError(e);
    }
  }

  Future<dynamic> deleteData(String endpoint) async {
    try {
      final resp = await _dio.delete(endpoint);
      return resp.data;
    } on DioException catch (e) {
      _handleError(e);
    }
  }

  void _handleError(DioException e) {
    final respData = e.response?.data;
    if (respData is Map && respData['message'] != null) {
      throw Exception(respData['message'].toString());
    } else {
      throw Exception(e.message);
    }
  }
  
}
