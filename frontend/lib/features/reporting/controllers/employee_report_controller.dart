import 'package:get/get.dart';

import '../../../core/services/api_service.dart';

class EmployeeReportController extends GetxController {
  EmployeeReportController({ApiService? apiService})
    : _api = apiService ?? Get.find<ApiService>();

  final ApiService _api;
  final RxBool isSubmitting = false.obs;

  String deriveShift(DateTime dateTime) {
    final hour = dateTime.hour;
    if (hour < 12) {
      return 'Pagi';
    }
    if (hour < 17) {
      return 'Siang';
    }
    if (hour < 21) {
      return 'Sore';
    }
    return 'Malam';
  }

  Future<void> submit({required int amount}) async {
    final now = DateTime.now();
    final shift = deriveShift(now);

    try {
      isSubmitting.value = true;
      await _api.postData('/pemasukkan/insert', {
        'jumlahPemasukkan': amount,
        'shift': shift,
      });
    } finally {
      isSubmitting.value = false;
    }
  }
}
