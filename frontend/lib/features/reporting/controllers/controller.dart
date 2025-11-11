import 'package:flutter/material.dart';
import '../../../../core/services/api_service.dart';
import '../../../core/models/report.dart';

class ReportController extends ChangeNotifier {
  final ApiService _api = ApiService();

  bool isLoading = false;
  List<Report> _reports = [];

  List<Report> get reports => _reports;

  /// 🔹 Ambil semua laporan pemasukan
  Future<void> fetchReports() async {
    isLoading = true;
    notifyListeners();

    try {
      final response = await _api.getData('/laporanpemasukan');
      if (response is List) {
        _reports = response.map((e) => Report.fromJson(e)).toList();
      } else {
        _reports = [];
      }
    } catch (e) {
      debugPrint('❌ Error fetching reports: $e');
      _reports = [];
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  /// 🔹 Tambah laporan pemasukan baru
  Future<bool> addReport(Report report) async {
    try {
      final response = await _api.postData('/laporanpemasukan', report.toJson());
      debugPrint('✅ Report added: $response');
      await fetchReports(); // refresh list
      return true;
    } catch (e) {
      debugPrint('❌ Error adding report: $e');
      return false;
    }
  }

  /// 🔹 Ambil laporan berdasarkan tanggal
  Future<List<Report>> fetchReportsByDate(DateTime date) async {
    try {
      final formattedDate = date.toIso8601String().split('T').first;
      final response = await _api.getData('/laporanpemasukan?tanggal=$formattedDate');
      if (response is List) {
        return response.map((e) => Report.fromJson(e)).toList();
      }
      return [];
    } catch (e) {
      debugPrint('❌ Error fetching reports by date: $e');
      return [];
    }
  }

  /// 🔹 Ambil laporan berdasarkan shift
  Future<List<Report>> fetchReportsByShift(String shift) async {
    try {
      final response = await _api.getData('/laporanpemasukan?shift=$shift');
      if (response is List) {
        return response.map((e) => Report.fromJson(e)).toList();
      }
      return [];
    } catch (e) {
      debugPrint('❌ Error fetching reports by shift: $e');
      return [];
    }
  }
}
