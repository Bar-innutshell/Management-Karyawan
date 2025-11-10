import 'package:flutter/material.dart';

// ===== ManagePayroll Screen =====
class ManagePayrollScreen extends StatelessWidget {
  const ManagePayrollScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Manage Payroll")),
      body: const Center(
        child: Text(
          "Hello World - Manage Payroll Screen",
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}
