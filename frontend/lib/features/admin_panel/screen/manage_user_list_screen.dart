import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import '../../../core/config/app_theme.dart';
import '../../../core/models/user.dart';
import '../controllers/manage_user_list_controller.dart';

class ManageUserListScreen extends StatelessWidget {
  const ManageUserListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ManageUserListController());

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(gradient: AppTheme.backgroundGradient),
        child: SafeArea(
          child: Column(
            children: [
              // Custom AppBar
              _buildAppBar(context),

              // Search Bar
              _buildSearchBar(controller)
                  .animate()
                  .fadeIn(duration: 300.ms, delay: 100.ms)
                  .slideY(begin: -0.2, end: 0),

              // Content
              Expanded(
                child: Obx(() {
                  if (controller.isLoading.value) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: AppTheme.primaryBlue,
                      ),
                    );
                  }

                  if (controller.error.value.isNotEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.error_outline,
                            size: 64,
                            color: AppTheme.error.withOpacity(0.5),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            controller.error.value,
                            style: Theme.of(context).textTheme.bodyLarge
                                ?.copyWith(color: AppTheme.textSecondary),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 24),
                          ElevatedButton(
                            onPressed: controller.loadData,
                            child: const Text('Coba Lagi'),
                          ),
                        ],
                      ),
                    );
                  }

                  if (controller.filteredUsers.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.people_outline,
                            size: 64,
                            color: AppTheme.textSecondary.withOpacity(0.5),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            controller.searchQuery.value.isEmpty
                                ? 'Belum ada karyawan'
                                : 'Tidak ada hasil pencarian',
                            style: Theme.of(context).textTheme.bodyLarge
                                ?.copyWith(color: AppTheme.textSecondary),
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.separated(
                    padding: const EdgeInsets.all(20),
                    itemCount: controller.filteredUsers.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final user = controller.filteredUsers[index];
                      return _UserCard(user: user, controller: controller)
                          .animate()
                          .fadeIn(duration: 300.ms, delay: (50 * index).ms)
                          .slideX(begin: -0.1, end: 0);
                    },
                  );
                }),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton:
          FloatingActionButton(
            onPressed: () => controller.navigateToUserDetail(),
            backgroundColor: AppTheme.primaryBlue,
            child: const Icon(Icons.add, color: Colors.white),
          ).animate().scale(
            duration: 400.ms,
            delay: 300.ms,
            curve: Curves.elasticOut,
          ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
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
          Text(
            'Informasi Karyawan',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 300.ms).slideX(begin: -0.1, end: 0);
  }

  Widget _buildSearchBar(ManageUserListController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: TextField(
        onChanged: controller.setSearchQuery,
        style: const TextStyle(color: AppTheme.textPrimary),
        decoration: InputDecoration(
          hintText: 'Cari nama, email, atau role...',
          hintStyle: const TextStyle(color: AppTheme.textHint),
          prefixIcon: const Icon(Icons.search, color: AppTheme.textSecondary),
          filled: true,
          fillColor: AppTheme.cardBg.withOpacity(0.7),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 16,
          ),
        ),
      ),
    );
  }
}

// User Card Widget
class _UserCard extends StatelessWidget {
  final User user;
  final ManageUserListController controller;

  const _UserCard({required this.user, required this.controller});

  @override
  Widget build(BuildContext context) {
    final roleName =
        user.role?.nama ?? controller.getRoleName(user.roleId) ?? '-';

    return GestureDetector(
      onTap: () => controller.navigateToUserDetail(user: user),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: AppTheme.cardDecoration,
        child: Row(
          children: [
            // Avatar
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: AppTheme.primaryBlue.withOpacity(0.2),
                borderRadius: BorderRadius.circular(25),
                border: Border.all(
                  color: AppTheme.primaryBlue.withOpacity(0.5),
                  width: 2,
                ),
              ),
              child: const Icon(
                Icons.person,
                color: AppTheme.primaryBlue,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),

            // User Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Name
                  Text(
                    user.nama ?? 'N/A',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),

                  // Email
                  Text(
                    user.email ?? '-',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppTheme.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 6),

                  // Role Badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.accentCyan.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: AppTheme.accentCyan.withOpacity(0.5),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      roleName,
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: AppTheme.accentCyan,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Action Buttons
            Column(
              children: [
                // Delete Button
                IconButton(
                  onPressed: () {
                    if (user.id != null && user.nama != null) {
                      controller.deleteUser(user.id!, user.nama!);
                    }
                  },
                  icon: const Icon(Icons.delete_outline),
                  color: AppTheme.error,
                  style: IconButton.styleFrom(
                    backgroundColor: AppTheme.error.withOpacity(0.1),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
