import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/config/routes.dart';

class AdminPanelScreen extends StatelessWidget {
  const AdminPanelScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final String userName = "Nama Admin";
    final String userRole = "Admin";

    const Color bgColor = Color(0xFF0F172A);
    const Color cardColor = Color(0xFF1E293B);
    const Color textPrimary = Colors.white;
    const Color textSecondary = Color(0xFFCBD5E1);
    const Color accentRed = Color(0xFFEF4444);

    return Scaffold(
      body: Container(
        color: bgColor,
        child: SafeArea(
          child: Column(
            children: [
              // ===== HEADER =====
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 20),
                decoration: BoxDecoration(
                  color: cardColor,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // kiri: Nama & Role
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Selamat datang,",
                          style: TextStyle(fontSize: 14, color: textSecondary),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          userName,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 22,
                            color: textPrimary,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: accentRed.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text(
                            "Admin",
                            style: TextStyle(
                              fontSize: 13,
                              color: textPrimary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                    // kanan: Log Out
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.red, width: 1),
                        borderRadius: BorderRadius.circular(6),
                        color: cardColor,
                      ),
                      child: TextButton(
                        onPressed: () {
                          Get.offAllNamed(Routes.auth);
                        },
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          backgroundColor: cardColor,
                        ),
                        child: const Text(
                          "Log Out",
                          style: TextStyle(
                            color: Colors.red,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // ===== KONTEN SCROLLABLE =====
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    // HERO IMAGE
                    Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 800),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: AspectRatio(
                            aspectRatio: 16 / 9,
                            child: Image.asset(
                              'assets/gedung_untirta.png',
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // ===== MENU ADMIN LABEL =====
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 4),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          "Menu Admin",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    // ===== CARD MENU ADMIN =====
                    _buildAdminCard(
                      context,
                      icon: Icons.group,
                      title: "User",
                      description:
                          "Kelola data karyawan: tambah, edit, dan hapus.",
                      routeName: Routes.manageUser,
                    ),
                    _buildAdminCard(
                      context,
                      icon: Icons.calendar_month,
                      title: "Manage Jadwal",
                      description:
                          "Atur jadwal kerja berdasarkan shift dan karyawan.",
                      routeName: Routes.manageSchedule,
                    ),
                    _buildAdminCard(
                      context,
                      icon: Icons.bar_chart,
                      title: "Lihat Laporan Pemasukan",
                      description:
                          "Lihat history pemasukan sesuai data laporan.",
                      routeName: Routes.manageReport,
                    ),
                    _buildAdminCard(
                      context,
                      icon: Icons.payments,
                      title: "Manage Gaji",
                      description:
                          "Kelola gaji dan bonus untuk setiap karyawan.",
                      routeName: Routes.managePayroll,
                    ),

                    const SizedBox(height: 12),

                    const Center(
                      child: Text(
                        "Admin Panel • Manajemen Karyawan v1.0",
                        style: TextStyle(fontSize: 12, color: textSecondary),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ===== CARD MENU ADMIN =====
  Widget _buildAdminCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String description,
    required String routeName,
  }) {
    const Color cardColor = Color(0xFF1E293B);
    const Color textPrimary = Colors.white;
    const Color textSecondary = Color(0xFFCBD5E1);
    const Color accentRed = Color(0xFFEF4444);

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            Get.toNamed(routeName);
          },
          borderRadius: BorderRadius.circular(12),
          child: Ink(
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 6,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: accentRed.withOpacity(0.18),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(icon, color: accentRed),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: textPrimary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          description,
                          style: const TextStyle(
                            fontSize: 13,
                            color: textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
