import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/models/user.dart';
import '../../../core/models/role.dart';
import '../../../core/services/api_service.dart';

class ManageUserDetailController extends GetxController {
  final ApiService _apiService = Get.find<ApiService>();

  // Form controllers
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final gajiPerJamController = TextEditingController();

  // State
  final RxBool isLoading = false.obs;
  final RxBool isEditMode = false.obs;
  final Rx<String?> selectedRole = Rx<String?>(null);
  final RxList<Role> roles = <Role>[].obs;

  // Hardcoded role options
  final List<String> roleOptions = ['Admin', 'Employee', 'Cashier'];

  User? currentUser;

  @override
  void onInit() {
    super.onInit();
    _initializeData();
  }

  @override
  void onClose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    gajiPerJamController.dispose();
    super.onClose();
  }

  void _initializeData() {
    final args = Get.arguments as Map<String, dynamic>?;

    if (args != null) {
      currentUser = args['user'] as User?;
      roles.value = args['roles'] as List<Role>? ?? [];

      if (currentUser != null) {
        isEditMode.value = true;
        nameController.text = currentUser!.nama ?? '';
        emailController.text = currentUser!.email ?? '';
        selectedRole.value = currentUser!.role?.nama;
        gajiPerJamController.text =
            currentUser!.gajiPerJam?.toInt().toString() ?? '';
      }
    }
  }

  /// Validate form
  String? validateForm() {
    if (nameController.text.trim().isEmpty) {
      return 'Nama tidak boleh kosong';
    }
    if (emailController.text.trim().isEmpty) {
      return 'Email tidak boleh kosong';
    }
    if (!GetUtils.isEmail(emailController.text.trim())) {
      return 'Format email tidak valid';
    }
    if (!isEditMode.value && passwordController.text.trim().isEmpty) {
      return 'Password tidak boleh kosong';
    }
    if (!isEditMode.value && passwordController.text.length < 6) {
      return 'Password minimal 6 karakter';
    }
    if (selectedRole.value == null) {
      return 'Role harus dipilih';
    }
    // Validasi gaji per jam harus integer
    if (gajiPerJamController.text.trim().isNotEmpty) {
      final gaji = int.tryParse(gajiPerJamController.text.trim());
      if (gaji == null) {
        return 'Gaji per jam harus berupa angka bulat';
      }
    }
    return null;
  }

  /// Convert role name to roleId (hardcoded mapping)
  int _getRoleIdFromName(String roleName) {
    switch (roleName.toLowerCase()) {
      case 'admin':
        return 1;
      case 'employee':
        return 2;
      case 'cashier':
        return 3;
      default:
        return 2; // default to employee
    }
  }

  /// Save user (create or update)
  Future<void> saveUser() async {
    final error = validateForm();
    if (error != null) {
      Get.snackbar(
        'Validasi Error',
        error,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Get.theme.colorScheme.error.withOpacity(0.9),
        colorText: Get.theme.colorScheme.onError,
      );
      return;
    }

    try {
      isLoading.value = true;

      // Parse gaji per jam as integer
      final gajiPerJam = gajiPerJamController.text.trim().isEmpty
          ? null
          : int.tryParse(gajiPerJamController.text.trim())?.toDouble();

      final roleId = _getRoleIdFromName(selectedRole.value!);

      if (isEditMode.value && currentUser?.id != null) {
        // Update existing user
        await _apiService.updateUser(
          currentUser!.id!,
          nama: nameController.text.trim(),
          email: emailController.text.trim(),
          password: passwordController.text.trim().isEmpty
              ? null
              : passwordController.text.trim(),
          roleId: roleId,
          gajiPerJam: gajiPerJam,
        );

        Get.snackbar(
          'Berhasil',
          'User berhasil diupdate',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Get.theme.colorScheme.primary.withOpacity(0.9),
          colorText: Get.theme.colorScheme.onPrimary,
        );
      } else {
        // Create new user
        await _apiService.createUser(
          nama: nameController.text.trim(),
          email: emailController.text.trim(),
          password: passwordController.text.trim(),
          roleId: roleId,
          gajiPerJam: gajiPerJam,
        );

        Get.snackbar(
          'Berhasil',
          'User berhasil ditambahkan',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Get.theme.colorScheme.primary.withOpacity(0.9),
          colorText: Get.theme.colorScheme.onPrimary,
        );
      }

      // Navigate back
      Get.back();
    } catch (e) {
      Get.snackbar(
        'Error',
        'Gagal menyimpan user: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Get.theme.colorScheme.error.withOpacity(0.9),
        colorText: Get.theme.colorScheme.onError,
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Get role name by id
  String getRoleName(int? roleId) {
    if (roleId == null) return 'Pilih Role';
    try {
      return roles.firstWhere((r) => r.id == roleId).nama ?? 'Unknown';
    } catch (_) {
      return 'Unknown';
    }
  }
}
