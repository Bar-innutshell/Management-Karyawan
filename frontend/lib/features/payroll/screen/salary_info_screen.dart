import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/config/routes.dart';
import '../controllers/salary_info_controller.dart';

class SalaryInfoScreen extends StatelessWidget {
  const SalaryInfoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(SalaryInfoController());

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Get.back(),
        ),
        title: const Text(
          'Informasi Gaji',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Background Gradient
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF0F1115), Color(0xFF111827)],
              ),
            ),
          ),

          // Accent Glows
          Positioned(
            top: -60,
            left: -40,
            child: _Glow(
              color: const Color(0xFF2563EB).withOpacity(0.18),
              size: 160,
            ),
          ),
          Positioned(
            bottom: -80,
            right: -50,
            child: _Glow(
              color: const Color(0xFF10B981).withOpacity(0.15),
              size: 200,
            ),
          ),

          // Content
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  // Filter Row: Bulan & Tahun
                  Row(
                        children: [
                          Expanded(
                            child: Obx(
                              () => _FilterDropdown(
                                label: 'Bulan',
                                value: controller.selectedMonth.value,
                                items: controller.months,
                                onChanged: controller.setMonth,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Obx(
                              () => _FilterDropdown(
                                label: 'Tahun',
                                value: controller.selectedYear.value,
                                items: controller.years,
                                onChanged: controller.setYear,
                              ),
                            ),
                          ),
                        ],
                      )
                      .animate()
                      .fadeIn(duration: 300.ms)
                      .slideY(begin: -0.1, end: 0),

                  const SizedBox(height: 12),

                  // Search Bar
                  Row(
                        children: [
                          Expanded(
                            child: TextField(
                              style: const TextStyle(color: Colors.white),
                              decoration: InputDecoration(
                                hintText: 'Search nama',
                                hintStyle: const TextStyle(
                                  color: Colors.white54,
                                ),
                                filled: true,
                                fillColor: const Color(0xFF1F2937),
                                prefixIcon: const Icon(
                                  Icons.search,
                                  color: Colors.white70,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide.none,
                                ),
                              ),
                              onChanged: controller.setSearch,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            decoration: BoxDecoration(
                              color: const Color(0xFF2563EB),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: IconButton(
                              icon: const Icon(
                                Icons.search,
                                color: Colors.white,
                              ),
                              onPressed: () {
                                // Trigger manual search if needed
                              },
                            ),
                          ),
                        ],
                      )
                      .animate()
                      .fadeIn(duration: 300.ms, delay: 100.ms)
                      .slideY(begin: -0.1, end: 0),

                  const SizedBox(height: 16),

                  // List Gaji
                  Expanded(
                    child: Obx(() {
                      if (controller.isLoading.value) {
                        return const Center(
                          child: CircularProgressIndicator(
                            color: Color(0xFF2563EB),
                          ),
                        );
                      }

                      if (controller.error.value != null) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.error_outline,
                                color: Colors.redAccent,
                                size: 48,
                              ),
                              const SizedBox(height: 12),
                              Text(
                                controller.error.value!,
                                style: const TextStyle(color: Colors.redAccent),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 16),
                              ElevatedButton(
                                onPressed: controller.loadSalaries,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF2563EB),
                                ),
                                child: const Text('Retry'),
                              ),
                            ],
                          ),
                        );
                      }

                      if (controller.filteredSalaries.isEmpty) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.monetization_on_outlined,
                                color: Colors.white38,
                                size: 64,
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'Tidak ada data gaji',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        );
                      }

                      return ListView.separated(
                        itemCount: controller.filteredSalaries.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final item = controller.filteredSalaries[index];
                          return GestureDetector(
                            onTap: () {
                              // Navigate to detail with parameters
                              Get.toNamed(
                                Routes.salaryDetail,
                                arguments: {
                                  'userId': item.userId ?? 0,
                                  'userName': item.nama ?? 'N/A',
                                  'userEmail': item.email ?? '',
                                  'roleName': item.roleName,
                                },
                              );
                            },
                            child:
                                _SalaryCard(
                                      nama: item.nama ?? 'N/A',
                                      roleName: item.roleName ?? '-',
                                      rateGaji: controller.formatCurrency(
                                        item.gajiPerJam,
                                      ),
                                      total: controller.formatCurrency(
                                        item.gajiBulanan ??
                                            controller
                                                .calculateMonthlyFromHourly(
                                                  item.gajiPerJam,
                                                ),
                                      ),
                                    )
                                    .animate()
                                    .fadeIn(
                                      duration: 300.ms,
                                      delay: (50 * index).ms,
                                    )
                                    .slideX(begin: -0.1, end: 0),
                          );
                        },
                      );
                    }),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Filter Dropdown Widget
class _FilterDropdown extends StatelessWidget {
  final String label;
  final String? value;
  final List<String> items;
  final ValueChanged<String?> onChanged;

  const _FilterDropdown({
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF1F2937),
        borderRadius: BorderRadius.circular(12),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          isExpanded: true,
          hint: Text(label, style: const TextStyle(color: Colors.white70)),
          value: value,
          dropdownColor: const Color(0xFF1F2937),
          style: const TextStyle(color: Colors.white),
          icon: const Icon(Icons.arrow_drop_down, color: Colors.white70),
          items: [
            DropdownMenuItem<String>(
              value: null,
              child: Text(
                'Semua $label',
                style: const TextStyle(color: Colors.white70),
              ),
            ),
            ...items.map(
              (item) =>
                  DropdownMenuItem<String>(value: item, child: Text(item)),
            ),
          ],
          onChanged: onChanged,
        ),
      ),
    );
  }
}

// Salary Card Widget
class _SalaryCard extends StatelessWidget {
  final String nama;
  final String roleName;
  final String rateGaji;
  final String total;

  const _SalaryCard({
    required this.nama,
    required this.roleName,
    required this.rateGaji,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1F2937).withOpacity(0.85),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF2563EB).withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.person,
                  color: Color(0xFF93C5FD),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      nama,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      roleName,
                      style: const TextStyle(
                        color: Colors.white54,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _InfoRow(label: 'Rate Gaji', value: rateGaji),
          const SizedBox(height: 8),
          _InfoRow(label: 'Total', value: total, isHighlight: true),
        ],
      ),
    );
  }
}

// Info Row Widget
class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isHighlight;

  const _InfoRow({
    required this.label,
    required this.value,
    this.isHighlight = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            color: isHighlight ? const Color(0xFF10B981) : Colors.white70,
            fontSize: 14,
            fontWeight: isHighlight ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: isHighlight ? const Color(0xFF10B981) : Colors.white,
            fontSize: 14,
            fontWeight: isHighlight ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

// Glow Widget
class _Glow extends StatelessWidget {
  final Color color;
  final double size;
  const _Glow({required this.color, required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
        boxShadow: [BoxShadow(color: color, blurRadius: 80, spreadRadius: 40)],
      ),
    );
  }
}
