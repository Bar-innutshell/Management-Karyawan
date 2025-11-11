import 'package:flutter/material.dart';

// ===== ManageSchedule Screen =====
class ManageScheduleScreen extends StatelessWidget {
  const ManageScheduleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Manage Schedule")),
      body: const Center(
        child: Text(
          "Hello World - Manage Schedule Screen",
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}
