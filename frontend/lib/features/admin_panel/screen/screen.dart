import 'package:flutter/material.dart';

class AdminPanelScreen extends StatelessWidget {
  const AdminPanelScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final String userName = "Nama Admin";
    final String userRole = "Admin";

    const Color bgColor = Color(0xFF0F172A);
    const Color cardColor = Color(0xFF1E293B);
    const Color textPrimary = Colors.white;
    const Color textSecondary = Color(0xFFCBD5E1);
    const Color accentRed = Color(0xFFEF4444);

    return Scaffold(
      appBar: AppBar(title: const Text('Admin Dashboard')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: const [
            ListTile(title: Text('Manage Users')),
            ListTile(title: Text('Manage Schedules')),
            ListTile(title: Text('Manage Roles')),
            ListTile(title: Text('Payroll / Bonuses')),
            ListTile(title: Text('View Reports')),
          ],
        ),
      ),
    );
  }
}
