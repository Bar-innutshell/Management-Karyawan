import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/services/api_service.dart';

class RegisterUserController extends GetxController {
  RegisterUserController({ApiService? apiService})
    : _api = apiService ?? Get.find<ApiService>();

  final ApiService _api;
  static const int _defaultRoleId = 3;
  static const String _defaultRoleName = 'Employee';

  final formKey = GlobalKey<FormState>();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  final RxBool isSubmitting = false.obs;
  int get defaultRoleId => _defaultRoleId;
  String get defaultRoleName => _defaultRoleName;

  String? validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Nama wajib diisi';
    }
    if (value.trim().length < 3) {
      return 'Nama minimal 3 karakter';
    }
    return null;
  }

  String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email wajib diisi';
    }
    final trimmed = value.trim();
    final regex = RegExp(r'^[\w\.-]+@[\w\.-]+\.[a-zA-Z]{2,}$');
    if (!regex.hasMatch(trimmed)) {
      return 'Format email tidak valid';
    }
    return null;
  }

  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password wajib diisi';
    }
    if (value.length < 6) {
      return 'Password minimal 6 karakter';
    }
    return null;
  }

  Future<void> submit() async {
    if (!(formKey.currentState?.validate() ?? false)) {
      return;
    }

    try {
      isSubmitting.value = true;
      await _api.register(
        nama: nameController.text.trim(),
        email: emailController.text.trim(),
        password: passwordController.text,
        roleId: _defaultRoleId,
      );
      Get.snackbar(
        'Berhasil',
        'User baru berhasil terdaftar.',
        snackPosition: SnackPosition.BOTTOM,
      );
      clearForm();
    } catch (e) {
      Get.snackbar(
        'Registrasi gagal',
        _friendlyMessage(e),
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isSubmitting.value = false;
    }
  }

  void clearForm() {
    nameController.clear();
    emailController.clear();
    passwordController.clear();
  }

  String _friendlyMessage(Object? error) {
    if (error == null) {
      return 'Terjadi kesalahan yang tidak diketahui.';
    }
    final message = error.toString();
    return message.replaceFirst('Exception: ', '');
  }

  @override
  void onClose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}
