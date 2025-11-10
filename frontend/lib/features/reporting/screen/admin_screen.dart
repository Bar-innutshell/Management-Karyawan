import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../controllers/controller.dart';
import '../../../../core/models/report.dart';

class AdminReportScreen extends StatefulWidget {
  const AdminReportScreen({super.key});

  @override
  State<AdminReportScreen> createState() => _AdminReportScreenState();
}

class _AdminReportScreenState extends State<AdminReportScreen> {
  final ReportController _controller = ReportController();
  final DateFormat _dateFormat = DateFormat('dd MMM yyyy', 'id_ID');

  DateTime? _selectedDate;
  String? _selectedShift;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadReports();
  }

  Future<void> _loadReports() async {
    setState(() => _isLoading = true);
    await _controller.fetchReports();
    setState(() => _isLoading = false);
  }

  Future<void> _filterByDate() async {
    if (_selectedDate == null) return;
    setState(() => _isLoading = true);
    final result = await _controller.fetchReportsByDate(_selectedDate!);
    setState(() {
      _controller.reports
        ..clear()
        ..addAll(result);
      _isLoading = false;
    });
  }

  Future<void> _filterByShift() async {
    if (_selectedShift == null) return;
    setState(() => _isLoading = true);
    final result = await _controller.fetchReportsByShift(_selectedShift!);
    setState(() {
      _controller.reports
        ..clear()
        ..addAll(result);
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Laporan Pemasukan (Admin)'),
        centerTitle: true,
        backgroundColor: Colors.teal,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // 🔹 Filter Section
            Card(
              elevation: 3,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  alignment: WrapAlignment.spaceBetween,
                  children: [
                    // Filter tanggal
                    ElevatedButton.icon(
                      onPressed: () async {
                        final date = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime(2024),
                          lastDate: DateTime.now(),
                          locale: const Locale('id', 'ID'),
                        );
                        if (date != null) {
                          setState(() => _selectedDate = date);
                          await _filterByDate();
                        }
                      },
                      icon: const Icon(Icons.date_range),
                      label: Text(_selectedDate == null
                          ? 'Pilih Tanggal'
                          : _dateFormat.format(_selectedDate!)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.teal,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),

                    // Filter shift
                    DropdownButton<String>(
                      hint: const Text("Pilih Shift"),
                      value: _selectedShift,
                      items: const [
                        DropdownMenuItem(value: 'Pagi', child: Text("Shift Pagi")),
                        DropdownMenuItem(value: 'Siang', child: Text("Shift Siang")),
                        DropdownMenuItem(value: 'Malam', child: Text("Shift Malam")),
                      ],
                      onChanged: (val) async {
                        setState(() => _selectedShift = val);
                        await _filterByShift();
                      },
                    ),

                    // Tombol reset
                    IconButton(
                      icon: const Icon(Icons.refresh, color: Colors.teal),
                      onPressed: () async {
                        setState(() {
                          _selectedDate = null;
                          _selectedShift = null;
                        });
                        await _loadReports();
                      },
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // 🔹 Tabel laporan
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _controller.reports.isEmpty
                      ? const Center(
                          child: Text(
                            "Belum ada laporan pemasukan",
                            style: TextStyle(color: Colors.grey),
                          ),
                        )
                      : ListView.builder(
                          itemCount: _controller.reports.length,
                          itemBuilder: (context, index) {
                            final report = _controller.reports[index];
                            return Card(
                              elevation: 2,
                              margin: const EdgeInsets.symmetric(vertical: 6),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: ListTile(
                                leading: const Icon(Icons.receipt_long,
                                    color: Colors.teal),
                                title: Text(
                                  "Rp ${report.jumlahPemasukan.toStringAsFixed(0)}",
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                subtitle: Text(
                                  "${_dateFormat.format(report.tanggalLaporan)} | Shift: ${report.shift}\nKasir: ${report.user}",
                                ),
                              ),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }
}
