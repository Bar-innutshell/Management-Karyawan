import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import '../../../core/config/routes.dart';
import '../../../core/config/app_theme.dart';
import '../../../core/services/api_service.dart';
import '../../../core/services/storage_service.dart';
import '../../../core/models/user.dart';

class AuthController extends GetxController {
  // Use Get.find() for dependency injection
  final ApiService _apiService = Get.find<ApiService>();
  final StorageService _storage = Get.find<StorageService>();

  // State loading
  final RxBool isLoading = false.obs;
  // State role
  final RxString userRole = ''.obs;
  // State user
  final Rxn<User> currentUser = Rxn<User>();

  Future<void> login(String email, String password) async {
    try {
      isLoading.value = true;
      final data = await _apiService.login(email, password);
      debugPrint('AuthController.login: raw login response: $data');
      final token = data['token'] as String?;
      debugPrint('AuthController.login: token: $token');
      if (token == null) {
        Get.snackbar(
          'Login Gagal',
          'Token tidak diterima dari server',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppTheme.error.withOpacity(0.9),
          colorText: AppTheme.textPrimary,
        );
        return;
      }

      // Fitur decode token
      final payload = _apiService.decodeJwtPayload(token);
      debugPrint('AuthController.login: decoded token payload: $payload');

      if (payload == null) {
        Get.snackbar(
          'Login Gagal',
          'Token tidak valid',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppTheme.error.withOpacity(0.9),
          colorText: AppTheme.textPrimary,
        );
        return;
      }

      final roleId = payload['roleId'] ?? payload['role_id'];

      // Fitur simpan user
      await _storage.saveUserJson(jsonEncode(payload));
      final u = User.fromJwtPayload(payload);
      currentUser.value = u;

      // Fitur ambil role
      String roleName = '';
      if (roleId != null) {
        final role = await _apiService.fetchRole(int.parse(roleId.toString()));
        debugPrint('AuthController.login: role: $role');
        if (role != null) {
          roleName = role.nama ?? '';
        }
      }

      // Fitur simpan role dan navigasi
      userRole.value = roleName;

      final rn = roleName.toLowerCase();
      if (rn == 'admin') {
        Get.offAllNamed(Routes.adminDashboard);
      } else if (rn == 'cashier' || rn == 'kasir') {
        Get.offAllNamed(Routes.employeeDashboard);
      } else {
        Get.offAllNamed(Routes.employeeDashboard);
      }
    } catch (e) {
      debugPrint('AuthController.login error: $e');
      final msg = e is Exception
          ? e.toString().replaceFirst('Exception: ', '')
          : 'Login gagal. Silakan coba lagi.';

      Get.snackbar(
        'Login Error',
        msg,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppTheme.error.withOpacity(0.9),
        colorText: AppTheme.textPrimary,
        duration: const Duration(seconds: 3),
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> logout() async {
    await _apiService.logout();
    await _storage.deleteUserJson();
    Get.offAllNamed(Routes.auth);
  }
}
