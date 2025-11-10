import 'package:get/get.dart';
import '../../../core/config/routes.dart';
import '../../../core/models/user.dart';
import '../../../core/models/role.dart';
import '../../../core/services/api_service.dart';

class ManageUserListController extends GetxController {
  final ApiService _apiService = Get.find<ApiService>();

  final RxList<User> users = <User>[].obs;
  final RxList<User> filteredUsers = <User>[].obs;
  final RxList<Role> roles = <Role>[].obs;

  final RxBool isLoading = false.obs;
  final RxString error = ''.obs;
  final RxString searchQuery = ''.obs;

  @override
  void onInit() {
    super.onInit();
    loadData();
  }

  /// Load users dan roles
  Future<void> loadData() async {
    try {
      isLoading.value = true;
      error.value = '';

      // Load users dan roles secara parallel
      final results = await Future.wait([
        _apiService.getUsers(),
        _apiService.fetchRoles(),
      ]);

      users.value = results[0] as List<User>;
      roles.value = results[1] as List<Role>;

      _applyFilters();
    } catch (e) {
      error.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  /// Set search query dan filter
  void setSearchQuery(String query) {
    searchQuery.value = query.toLowerCase();
    _applyFilters();
  }

  /// Apply filters
  void _applyFilters() {
    if (searchQuery.value.isEmpty) {
      filteredUsers.value = users;
    } else {
      filteredUsers.value = users.where((user) {
        final nama = user.nama?.toLowerCase() ?? '';
        final email = user.email?.toLowerCase() ?? '';
        final role = user.role?.nama?.toLowerCase() ?? '';
        return nama.contains(searchQuery.value) ||
            email.contains(searchQuery.value) ||
            role.contains(searchQuery.value);
      }).toList();
    }
  }

  /// Get role name by id
  String? getRoleName(int? roleId) {
    if (roleId == null) return null;
    try {
      return roles.firstWhere((r) => r.id == roleId).nama;
    } catch (_) {
      return null;
    }
  }

  /// Delete user dengan konfirmasi
  Future<bool> deleteUser(int userId, String userName) async {
    try {
      // Tampilkan dialog konfirmasi
      final confirm = await Get.defaultDialog<bool>(
        title: 'Yakin hapus?',
        middleText: 'User "$userName" akan dihapus permanen.\n\nLanjutkan?',
        textConfirm: 'Hapus',
        textCancel: 'Batal',
        confirmTextColor: Get.theme.colorScheme.onError,
        buttonColor: Get.theme.colorScheme.error,
        cancelTextColor: Get.theme.colorScheme.onSurface,
        onConfirm: () => Get.back(result: true),
        onCancel: () => Get.back(result: false),
      );

      if (confirm != true) return false;

      // Hapus dari API
      await _apiService.deleteUser(userId);

      // Hapus dari list lokal
      users.removeWhere((u) => u.id == userId);
      _applyFilters();

      // Show success message
      Get.snackbar(
        'Berhasil',
        'User $userName telah dihapus',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Get.theme.colorScheme.primary.withOpacity(0.9),
        colorText: Get.theme.colorScheme.onPrimary,
      );

      return true;
    } catch (e) {
      Get.snackbar(
        'Error',
        'Gagal menghapus user: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Get.theme.colorScheme.error.withOpacity(0.9),
        colorText: Get.theme.colorScheme.onError,
      );
      return false;
    }
  }

  /// Navigate to user detail (create/edit)
  void navigateToUserDetail({User? user}) {
    Get.toNamed(
      Routes.userDetail,
      arguments: {'user': user, 'roles': roles},
    )?.then((_) {
      // Reload data setelah kembali dari detail
      loadData();
    });
  }
}
