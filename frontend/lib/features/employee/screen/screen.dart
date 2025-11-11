import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/config/routes.dart';

class EmployeeScreen extends StatelessWidget {
  const EmployeeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final String userName = "Nama Lengkap";
    final String userRole = "Employee";

    const Color bgColor = Color(0xFF0F172A);
    const Color cardColor = Color(0xFF1E293B);
    const Color textPrimary = Colors.white;
    const Color textSecondary = Color(0xFFCBD5E1);
    const Color accentBlue = Color(0xFF3B82F6);

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
                    // kiri: Nama dan Role
                    Column(
                      mainAxisSize: MainAxisSize.min,
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
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: accentBlue.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            userRole,
                            style: const TextStyle(
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

              // ===== KONTEN =====
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 800),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: AspectRatio(
                            aspectRatio: 16 / 9,
                            child: Image.asset(
                              'assets/coe.png',
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 4),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          "Menu Employee",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    // ===== MENU CARDS DENGAN ROUTING =====
                    _buildMenuCard(
                      context,
                      icon: Icons.calendar_today,
                      title: "Lihat Jadwal",
                      description: "Lihat detail jadwal kerja mu.",
                      routeName: Routes.schedule,
                    ),
                    _buildMenuCard(
                      context,
                      icon: Icons.access_time,
                      title: "Absensi Harian",
                      description: "Cek dan catat kehadiran kamu setiap hari.",
                      routeName: Routes.attendance,
                    ),
                    _buildMenuCard(
                      context,
                      icon: Icons.attach_money,
                      title: "Cek Gaji",
                      description: "Lihat detail gaji dan tunjangan bulanan.",
                      routeName: Routes.payroll,
                    ),

                    const SizedBox(height: 12),

                    const Center(
                      child: Text(
                        "Manajemen Karyawan v1.0",
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

  // ===== MENU CARD W/ ROUTING =====
  Widget _buildMenuCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String description,
    required String routeName,
  }) {
    const Color cardColor = Color(0xFF1E293B);
    const Color textPrimary = Colors.white;
    const Color textSecondary = Color(0xFFCBD5E1);
    const Color accentBlue = Color(0xFF3B82F6);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
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
      child: InkWell(
        onTap: () {
          Get.toNamed(routeName);
        },
        borderRadius: BorderRadius.circular(12),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: accentBlue.withOpacity(0.18),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: accentBlue),
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
                    style: const TextStyle(fontSize: 13, color: textSecondary),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
