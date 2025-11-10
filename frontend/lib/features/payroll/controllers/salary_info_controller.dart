import 'package:get/get.dart';
import '../../../core/services/api_service.dart';
import '../../../core/models/gaji.dart';

class SalaryInfoController extends GetxController {
  // Use Get.find() for dependency injection
  final ApiService _api = Get.find<ApiService>();

  final RxList<UserGajiListItem> salaries = <UserGajiListItem>[].obs;
  final RxList<UserGajiListItem> filteredSalaries = <UserGajiListItem>[].obs;
  final RxBool isLoading = false.obs;
  final RxnString error = RxnString();

  final RxnString selectedMonth = RxnString();
  final RxnString selectedYear = RxnString();
  final RxString searchQuery = ''.obs;

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

  final years = <String>[];

  @override
  void onInit() {
    super.onInit();
    _initYears();
    loadSalaries();
  }

  void _initYears() {
    final currentYear = DateTime.now().year;
    for (int i = currentYear; i >= currentYear - 5; i--) {
      years.add(i.toString());
    }
  }

  Future<void> loadSalaries() async {
    try {
      isLoading.value = true;
      error.value = null;
      final data = await _api.fetchAllUserGaji();
      salaries.assignAll(data);
      _applyFilters();
    } catch (e) {
      error.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  void setMonth(String? month) {
    selectedMonth.value = month;
    _applyFilters();
  }

  void setYear(String? year) {
    selectedYear.value = year;
    _applyFilters();
  }

  void setSearch(String query) {
    searchQuery.value = query;
    _applyFilters();
  }

  void _applyFilters() {
    var result = salaries.toList();

    // Filter by search query (nama atau email)
    if (searchQuery.value.isNotEmpty) {
      final query = searchQuery.value.toLowerCase();
      result = result.where((item) {
        final nama = (item.nama ?? '').toLowerCase();
        final email = (item.email ?? '').toLowerCase();
        return nama.contains(query) || email.contains(query);
      }).toList();
    }

    // TODO: Filter by month & year jika backend support

    filteredSalaries.assignAll(result);
  }

  String formatCurrency(double? amount) {
    if (amount == null || amount == 0) return 'Rp 0';
    final formatted = amount
        .toStringAsFixed(0)
        .replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.');
    return 'Rp $formatted';
  }

  double calculateMonthlyFromHourly(double? gajiPerJam) {
    if (gajiPerJam == null || gajiPerJam == 0) return 0;
    // Formula: gajiPerJam × 6 jam × 20 hari
    return gajiPerJam * 6 * 20;
  }
}
