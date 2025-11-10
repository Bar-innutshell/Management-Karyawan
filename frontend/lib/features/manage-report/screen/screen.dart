import 'package:flutter/material.dart';

// ===== ManageReport Screen =====
class ManageReportScreen extends StatelessWidget {
  const ManageReportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Manage Report")),
      body: const Center(
        child: Text(
          "Hello World - Manage Report Screen",
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}
