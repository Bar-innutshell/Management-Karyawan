import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import '../../../core/config/app_theme.dart';
import '../../../core/widgets/button.dart';
import '../../../core/widgets/custom_text_field.dart';
import '../controllers/manage_user_detail_controller.dart';

class ManageUserDetailScreen extends StatelessWidget {
  const ManageUserDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ManageUserDetailController());

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(gradient: AppTheme.backgroundGradient),
        child: SafeArea(
          child: Column(
            children: [
              // Custom AppBar
              _buildAppBar(context, controller),

              // Form Content
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 10),

                      // Form Fields
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Nama Field
                          CustomTextField(
                                controller: controller.nameController,
                                labelText: 'Nama',
                                hintText: 'Masukkan nama lengkap',
                                prefixIcon: Icons.person_outline,
                              )
                              .animate()
                              .fadeIn(duration: 400.ms, delay: 100.ms)
                              .slideX(begin: 0.2, end: 0),
                          const SizedBox(height: 16),

                          // Role Dropdown
                          Obx(() => _buildRoleDropdown(controller))
                              .animate()
                              .fadeIn(duration: 400.ms, delay: 150.ms)
                              .slideX(begin: 0.2, end: 0),
                          const SizedBox(height: 16),

                          // Email Field
                          CustomTextField(
                                controller: controller.emailController,
                                labelText: 'Email',
                                hintText: 'Masukkan email',
                                prefixIcon: Icons.email_outlined,
                                keyboardType: TextInputType.emailAddress,
                              )
                              .animate()
                              .fadeIn(duration: 400.ms, delay: 200.ms)
                              .slideX(begin: 0.2, end: 0),
                          const SizedBox(height: 16),

                          // Password Field
                          Obx(
                                () => CustomTextField(
                                  controller: controller.passwordController,
                                  labelText: 'Password',
                                  hintText: controller.isEditMode.value
                                      ? 'Kosongkan jika tidak ingin mengubah'
                                      : 'Masukkan password',
                                  prefixIcon: Icons.lock_outline,
                                  obscureText: controller.isEditMode.value,
                                ),
                              )
                              .animate()
                              .fadeIn(duration: 400.ms, delay: 250.ms)
                              .slideX(begin: 0.2, end: 0),
                          const SizedBox(height: 16),

                          // Gaji per Jam Field
                          CustomTextField(
                                controller: controller.gajiPerJamController,
                                labelText: 'Gaji per jam',
                                hintText: 'Masukkan gaji per jam (opsional)',
                                prefixIcon: Icons.attach_money,
                                keyboardType: TextInputType.number,
                              )
                              .animate()
                              .fadeIn(duration: 400.ms, delay: 300.ms)
                              .slideX(begin: 0.2, end: 0),
                        ],
                      ),

                      const SizedBox(height: 24),

                      // Save Button
                      Obx(
                        () => Button(
                          text: controller.isEditMode.value
                              ? 'Selesai'
                              : 'Tambah User',
                          onPressed: controller.saveUser,
                          isLoading: controller.isLoading.value,
                          backgroundColor: AppTheme.primaryBlue,
                        ),
                      ).animate().fadeIn(duration: 400.ms, delay: 350.ms),

                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar(
    BuildContext context,
    ManageUserDetailController controller,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Get.back(),
            icon: const Icon(Icons.arrow_back, color: AppTheme.textPrimary),
            style: IconButton.styleFrom(
              backgroundColor: AppTheme.cardBg.withOpacity(0.5),
            ),
          ),
          const SizedBox(width: 12),
          Obx(
            () => Text(
              controller.isEditMode.value ? 'Edit Karyawan' : 'Tambah Karyawan',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary,
              ),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 300.ms).slideX(begin: -0.1, end: 0);
  }

  Widget _buildRoleDropdown(ManageUserDetailController controller) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF374151),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF4B5563)),
      ),
      child: DropdownButtonFormField<String>(
        value: controller.selectedRole.value,
        decoration: const InputDecoration(
          labelText: 'Role',
          labelStyle: TextStyle(color: Colors.white70),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          prefixIcon: Icon(
            Icons.badge_outlined,
            color: Colors.white70,
            size: 20,
          ),
        ),
        dropdownColor: const Color(0xFF374151),
        style: const TextStyle(color: Colors.white, fontSize: 16),
        hint: const Text('Pilih Role', style: TextStyle(color: Colors.white38)),
        items: controller.roleOptions.map((role) {
          return DropdownMenuItem<String>(value: role, child: Text(role));
        }).toList(),
        onChanged: (value) {
          controller.selectedRole.value = value;
        },
      ),
    );
  }
}
