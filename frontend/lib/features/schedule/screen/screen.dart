import 'package:flutter/material.dart';

// ===== Schedule Screen =====
class ScheduleScreen extends StatelessWidget {
  const ScheduleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Schedule")),
      body: const Center(
        child: Text(
          "Hello World - Schedule Screen",
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}
