import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../controllers/controller.dart';
import '../../../../core/models/report.dart';

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
  final ReportController _controller = ReportController();
  final TextEditingController _jumlahController = TextEditingController();
  String _selectedShift = '';
  bool _isLoading = false;

  Future<void> _simpanLaporan() async {
    final jumlah = double.tryParse(_jumlahController.text);
    if (jumlah == null || jumlah <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Masukkan jumlah pemasukan yang valid')),
      );
      return;
    }

    if (_selectedShift.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pilih shift terlebih dahulu')),
      );
      return;
    }

    final laporan = Report(
      jumlahPemasukan: jumlah,
      tanggalLaporan: DateTime.now(),
      shift: _selectedShift,
      user: widget.user,
      userId: widget.userId,
    );

    setState(() => _isLoading = true);

    final success = await _controller.addReport(laporan);

    setState(() => _isLoading = false);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('✅ Laporan berhasil disimpan!')),
      );
      _jumlahController.clear();
      setState(() => _selectedShift = '');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('❌ Gagal menyimpan laporan')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final tanggal = DateFormat('EEEE, dd MMMM yyyy', 'id_ID').format(DateTime.now());

    return Scaffold(
      appBar: AppBar(
        title: const Text("Input Laporan Pemasukan"),
        centerTitle: true,
        backgroundColor: Colors.teal,
        elevation: 2,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Column(
                    children: [
                      const Icon(Icons.point_of_sale,
                          size: 70, color: Colors.teal),
                      const SizedBox(height: 10),
                      Text(
                        "Laporan Kasir",
                        style: Theme.of(context)
                            .textTheme
                            .headlineSmall
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        tanggal,
                        style: const TextStyle(color: Colors.grey, fontSize: 16),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 30),

                // Input jumlah pemasukan
                TextField(
                  controller: _jumlahController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: "Jumlah Pemasukan (Rp)",
                    prefixIcon: const Icon(Icons.attach_money, color: Colors.teal),
                    filled: true,
                    fillColor: Colors.grey[100],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Dropdown shift
                DropdownButtonFormField<String>(
                  value: _selectedShift.isEmpty ? null : _selectedShift,
                  items: const [
                    DropdownMenuItem(value: 'Pagi', child: Text("Shift Pagi")),
                    DropdownMenuItem(value: 'Siang', child: Text("Shift Siang")),
                    DropdownMenuItem(value: 'Malam', child: Text("Shift Malam")),
                  ],
                  onChanged: (val) {
                    if (val != null) setState(() => _selectedShift = val);
                  },
                  decoration: InputDecoration(
                    labelText: "Pilih Shift",
                    prefixIcon:
                        const Icon(Icons.access_time, color: Colors.teal),
                    filled: true,
                    fillColor: Colors.grey[100],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 30),

                // Tombol simpan
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton.icon(
                    onPressed: _isLoading ? null : _simpanLaporan,
                    icon: const Icon(Icons.save),
                    label: _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                            "Simpan Laporan",
                            style: TextStyle(fontSize: 18),
                          ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
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
