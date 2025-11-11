import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../core/services/api_service.dart';

class AdminReportScreen extends StatefulWidget {
  const AdminReportScreen({super.key});

  @override
  State<AdminReportScreen> createState() => _AdminReportScreenState();
}

class _AdminReportScreenState extends State<AdminReportScreen> {
  final ApiService _api = Get.find<ApiService>();
  final DateFormat _dateFormat = DateFormat('EEEE, dd MMM yyyy', 'id_ID');
  final NumberFormat _currency = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

  bool _isLoading = true;
  List<_DailySummary> _summary = const [];
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadSummary();
  }

  Future<void> _loadSummary() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final raw = await _api.getData('/laporan/harian');
      final data = (raw is Map && raw['data'] is Map)
          ? raw['data'] as Map
          : null;
      final List summaryList = data?['summary'] as List? ?? const [];
      final parsed =
          summaryList
              .whereType<Map<String, dynamic>>()
              .map(_DailySummary.fromMap)
              .toList()
            ..sort((a, b) => b.date.compareTo(a.date));
      setState(() {
        _summary = parsed;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _summary = const [];
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ringkasan Pemasukan Harian'),
        actions: [
          IconButton(
            tooltip: 'Muat ulang',
            onPressed: _isLoading ? null : _loadSummary,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: Padding(padding: const EdgeInsets.all(16.0), child: _buildBody()),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return Center(
        child: Text(
          'Gagal memuat laporan: $_error',
          textAlign: TextAlign.center,
          style: const TextStyle(color: Colors.redAccent),
        ),
      );
    }
    if (_summary.isEmpty) {
      return const Center(
        child: Text(
          'Belum ada data pemasukan harian.',
          style: TextStyle(color: Colors.grey),
        ),
      );
    }

    return ListView.separated(
      itemCount: _summary.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (_, index) {
        final item = _summary[index];
        return Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 2,
          child: ListTile(
            leading: const Icon(Icons.calendar_month, color: Colors.teal),
            title: Text(_dateFormat.format(item.date)),
            subtitle: Text('${item.transactions} transaksi'),
            trailing: Text(
              _currency.format(item.totalAmount),
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
        );
      },
    );
  }
}

class _DailySummary {
  const _DailySummary({
    required this.date,
    required this.totalAmount,
    required this.transactions,
  });

  final DateTime date;
  final double totalAmount;
  final int transactions;

  static _DailySummary fromMap(Map<String, dynamic> map) {
    final dateString = map['tanggal']?.toString() ?? '';
    DateTime parsedDate;
    try {
      parsedDate = DateTime.parse(dateString);
    } catch (_) {
      parsedDate = DateTime.now();
    }
    final total = (map['totalPemasukkan'] as num?)?.toDouble() ?? 0;
    final trx = map['jumlahTransaksi'] is int
        ? map['jumlahTransaksi'] as int
        : int.tryParse('${map['jumlahTransaksi']}') ?? 0;
    return _DailySummary(
      date: parsedDate,
      totalAmount: total,
      transactions: trx,
    );
  }
}
