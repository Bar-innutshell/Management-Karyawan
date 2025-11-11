import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/register_user_controller.dart';
import '../../../core/widgets/button.dart';

class RegisterUserScreen extends StatelessWidget {
  const RegisterUserScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final RegisterUserController controller = Get.put(RegisterUserController());

    return Scaffold(
      appBar: AppBar(title: const Text('Register User')),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF0F1115), Color(0xFF111827)],
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 40),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: Card(
                color: const Color(0xFF1F2937),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
                elevation: 8,
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Form(
                    key: controller.formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Tambah User Baru',
                          style: Theme.of(context).textTheme.headlineSmall
                              ?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                              ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Isi data lengkap pengguna. Role default akan otomatis menjadi Employee.',
                          style: TextStyle(color: Colors.white70),
                        ),
                        const SizedBox(height: 24),
                        TextFormField(
                          controller: controller.nameController,
                          validator: controller.validateName,
                          decoration: _fieldDecoration(
                            label: 'Nama Lengkap',
                            icon: Icons.person_outline,
                          ),
                          textInputAction: TextInputAction.next,
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: controller.emailController,
                          validator: controller.validateEmail,
                          decoration: _fieldDecoration(
                            label: 'Email',
                            icon: Icons.email_outlined,
                          ),
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.next,
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: controller.passwordController,
                          validator: controller.validatePassword,
                          decoration: _fieldDecoration(
                            label: 'Password',
                            icon: Icons.lock_outline,
                          ),
                          obscureText: true,
                        ),
                        const SizedBox(height: 20),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Role default',
                              style: TextStyle(
                                color: Colors.white70,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              '${controller.defaultRoleName} (ID ${controller.defaultRoleId})',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              'Role ini dikirim otomatis ke backend setiap registrasi.',
                              style: TextStyle(color: Colors.white54),
                            ),
                          ],
                        ),
                        const SizedBox(height: 28),
                        Obx(
                          () => Button(
                            isLoading: controller.isSubmitting.value,
                            text: 'Daftarkan User',
                            onPressed: controller.submit,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _fieldDecoration({
    required String label,
    required IconData icon,
  }) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: Colors.white70),
      filled: true,
      fillColor: const Color(0xFF111827),
      labelStyle: const TextStyle(color: Colors.white70),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.white24),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF2563EB), width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.redAccent),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.redAccent),
      ),
    );
  }
}
