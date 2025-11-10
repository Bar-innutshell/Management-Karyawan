import 'package:flutter/material.dart';

// ===== ManageUser Screen =====
class ManageUserScreen extends StatelessWidget {
  const ManageUserScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Manage User")),
      body: const Center(
        child: Text(
          "Hello World - Manage User Screen",
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}
