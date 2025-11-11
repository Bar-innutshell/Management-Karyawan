import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/config/routes.dart';
import '../../auth/controllers/controller.dart';
import '../../reporting/screen/screen.dart';

class EmployeeScreen extends StatelessWidget {
  const EmployeeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final AuthController auth = Get.isRegistered<AuthController>()
        ? Get.find<AuthController>()
        : Get.put(AuthController());

    return Scaffold(
      appBar: AppBar(
        title: const Text('Employee Dashboard'),
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
              leading: const Icon(Icons.receipt_long_outlined),
              title: const Text('View Payroll'),
              subtitle: const Text('Lihat slip gaji dan rincian penghasilan'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => Get.toNamed(Routes.payroll),
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.assignment_outlined),
              title: const Text('Submit Daily Report'),
              subtitle: const Text('Catat pemasukan shift hari ini'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                final user = auth.currentUser.value;
                final userId = user?.id;
                if (userId == null) {
                  Get.snackbar(
                    'Data belum lengkap',
                    'Silakan login ulang sebelum mengisi laporan.',
                    snackPosition: SnackPosition.BOTTOM,
                  );
                  return;
                }

                final displayName = (user?.nama?.trim().isNotEmpty ?? false)
                    ? user!.nama!
                    : user?.email ?? 'User';

                Get.to(
                  () => LaporanInputScreen(user: displayName, userId: userId),
                );
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.access_time),
              title: const Text('Mark Attendance'),
              subtitle: const Text('Absen masuk atau pulang shift'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => Get.toNamed(Routes.attendance),
            ),
          ],
        ),
      ),
    );
  }
}
