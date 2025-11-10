import 'package:flutter/material.dart';

class ReportingScreen extends StatelessWidget {
  const ReportingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Reporting")),
      body: const Center(
        child: Text(
          "Hello World - Reporting Screen",
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}
