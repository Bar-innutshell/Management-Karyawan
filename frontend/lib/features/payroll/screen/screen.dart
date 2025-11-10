import 'package:flutter/material.dart';

class PayrollScreen extends StatelessWidget {
  const PayrollScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Payroll")),
      body: const Center(
        child: Text(
          "Hello World - Payroll Screen",
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}
