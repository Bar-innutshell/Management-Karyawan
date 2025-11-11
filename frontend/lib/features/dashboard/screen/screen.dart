import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../auth/controllers/controller.dart';
import '../../../core/config/routes.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final AuthController authController = Get.find();

    return Scaffold(
      appBar: AppBar(title: const Text('Dashboard')),
      body: Obx(() {
        final role = authController.userRole.value;
        if (role == 'admin') {
          return _buildAdminDashboard();
        } else if (role == 'cashier') {
          return _buildCashierDashboard();
        } else {
          return _buildEmployeeDashboard();
        }
      }),
    );
  }

  Widget _buildAdminDashboard() {
    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        ListTile(
          title: const Text('Manage Users'),
          onTap: () => Get.toNamed(Routes.manageUser),
        ),
        ListTile(
          title: const Text('Manage Schedules'),
          onTap: () => Get.toNamed(Routes.manageSchedule),
        ),
        ListTile(
          title: const Text('View Reports'),
          onTap: () => Get.toNamed(Routes.manageReport),
        ),
      ],
    );
  }

  Widget _buildCashierDashboard() {
    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        ListTile(
          title: const Text('Submit Daily Report'),
          onTap: () => Get.toNamed('/reporting'), // Placeholder
        ),
        ListTile(
          title: const Text('View Attendance'),
          onTap: () => Get.toNamed('/attendance'), // Placeholder
        ),
      ],
    );
  }

  Widget _buildEmployeeDashboard() {
    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        ListTile(
          title: const Text('View Payroll'),
          onTap: () => Get.toNamed('/payroll'), // Placeholder
        ),
        ListTile(
          title: const Text('Mark Attendance'),
          onTap: () => Get.toNamed('/attendance'), // Placeholder
        ),
      ],
    );
  }
}
