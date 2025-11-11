import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/config/routes.dart';
import '../../auth/controllers/controller.dart';

class AdminPanelScreen extends StatelessWidget {
  const AdminPanelScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final AuthController auth = Get.isRegistered<AuthController>()
        ? Get.find<AuthController>()
        : Get.put(AuthController());

    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        actions: [
          IconButton(
            tooltip: 'Logout',
            onPressed: auth.logout,
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            ListTile(
              leading: const Icon(Icons.group_outlined),
              title: const Text('Register User'),
              subtitle: const Text(
                'Tambahkan akun baru dan tentukan role pengguna',
              ),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => Get.toNamed(Routes.registerUser),
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.payments_outlined),
              title: const Text('Informasi Gaji'),
              subtitle: const Text('Tinjau dan atur data penggajian'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => Get.toNamed(Routes.salaryInfo),
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.insert_chart_outlined),
              title: const Text('View Reports'),
              subtitle: const Text('Analisis laporan pemasukan karyawan'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => Get.toNamed(Routes.adminReport),
            ),
          ],
        ),
      ),
    );
  }
}
