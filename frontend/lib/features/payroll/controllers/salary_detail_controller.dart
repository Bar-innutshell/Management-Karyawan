import 'package:get/get.dart';
import '../../../core/models/gaji.dart';
import '../../../core/services/api_service.dart';
import 'package:intl/intl.dart';

class SalaryDetailController extends GetxController {
  final ApiService _apiService = Get.find<ApiService>();

  final Rx<UserGajiDetail?> salaryDetail = Rx<UserGajiDetail?>(null);
  final RxBool isLoading = false.obs;
  final RxString error = ''.obs;

  // User info dari list
  final int userId;
  final String userName;
  final String userEmail;
  final String? roleName;

  SalaryDetailController({
    required this.userId,
    required this.userName,
    required this.userEmail,
    this.roleName,
  });

  @override
  void onInit() {
    super.onInit();
    loadSalaryDetail();
  }

  /// Load detail gaji dari API
  Future<void> loadSalaryDetail() async {
    try {
      isLoading.value = true;
      error.value = '';

      final detail = await _apiService.fetchUserGaji(userId);

      if (detail != null) {
        salaryDetail.value = detail;
      } else {
        error.value = 'Data gaji tidak ditemukan';
      }
    } catch (e) {
      error.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  /// Format currency IDR
  String formatCurrency(num? value) {
    if (value == null) return 'Rp. 0';
    final formatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp. ',
      decimalDigits: 0,
    );
    return formatter.format(value);
  }

  /// Format jam kerja
  String formatHours(double? hours) {
    if (hours == null) return '0 Jam';
    return '${hours.toStringAsFixed(0)} Jam';
  }

  /// Get current period (bulan tahun)
  String getCurrentPeriod() {
    final now = DateTime.now();
    final months = [
      'Januari',
      'Februari',
      'Maret',
      'April',
      'Mei',
      'Juni',
      'Juli',
      'Agustus',
      'September',
      'Oktober',
      'November',
      'Desember',
    ];
    return '${months[now.month - 1]} ${now.year}';
  }
}
