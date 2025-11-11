import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../controllers/employee_report_controller.dart';

class LaporanInputScreen extends StatefulWidget {
  final String user;
  final int userId;

  const LaporanInputScreen({
    super.key,
    required this.user,
    required this.userId,
  });

  @override
  State<LaporanInputScreen> createState() => _LaporanInputScreenState();
}

class _LaporanInputScreenState extends State<LaporanInputScreen> {
  static const _controllerTag = 'employee-report-controller';
  late final EmployeeReportController _controller;
  final TextEditingController _amountController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (Get.isRegistered<EmployeeReportController>(tag: _controllerTag)) {
      _controller = Get.find<EmployeeReportController>(tag: _controllerTag);
    } else {
      _controller = Get.put(EmployeeReportController(), tag: _controllerTag);
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    if (Get.isRegistered<EmployeeReportController>(tag: _controllerTag)) {
      Get.delete<EmployeeReportController>(tag: _controllerTag, force: true);
    }
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    final raw = _amountController.text.trim();
    if (raw.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Masukkan nominal pemasukan terlebih dahulu.'),
        ),
      );
      return;
    }

    final amount = int.tryParse(raw);
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nominal harus berupa angka positif.')),
      );
      return;
    }

    try {
      await _controller.submit(amount: amount);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pemasukan harian tersimpan.')),
      );
      _amountController.clear();
    } catch (e) {
      if (!mounted) return;
      final message = e.toString().replaceFirst('Exception: ', '');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Gagal menyimpan: $message')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final tanggal = DateFormat('EEEE, dd MMMM yyyy', 'id_ID').format(now);
    final autoShift = _controller.deriveShift(now);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Input Pemasukan Harian'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Halo, ${widget.user}',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 4),
                Text(tanggal, style: const TextStyle(color: Colors.grey)),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.teal.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.access_time, color: Colors.teal),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Shift otomatis: $autoShift',
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                TextField(
                  controller: _amountController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: InputDecoration(
                    labelText: 'Nominal pemasukan (Rp)',
                    prefixIcon: const Icon(Icons.attach_money),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Obx(
                  () => SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _controller.isSubmitting.value
                          ? null
                          : _handleSubmit,
                      icon: const Icon(Icons.check_circle_outline),
                      label: _controller.isSubmitting.value
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Kirim Pemasukan'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
