import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/config/routes.dart';

class AdminPanelScreen extends StatelessWidget {
  const AdminPanelScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Admin Dashboard')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            ListTile(
              title: const Text('Informasi Karyawan'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () => Get.toNamed(Routes.userList),
            ),
            ListTile(
              title: const Text('Informasi Gaji'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () => Get.toNamed(Routes.salaryInfo),
            ),
            // TODO: Schedule feature - waiting for backend implementation
            // ListTile(
            //   title: const Text('Manage Jadwal'),
            //   trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            //   onTap: () => Get.toNamed(Routes.manageSchedule),
            // ),
            ListTile(
              title: const Text('Manage Roles'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                // TODO: Navigate to roles
              },
            ),
            ListTile(
              title: const Text('View Reports'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                // TODO: Navigate to reports
              },
            ),
          ],
        ),
      ),
    );
  }
}
