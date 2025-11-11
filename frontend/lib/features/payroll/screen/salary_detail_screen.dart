import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import '../../../core/config/app_theme.dart';
import '../../../core/widgets/button.dart';
import '../../../core/models/gaji.dart';
import '../controllers/salary_detail_controller.dart';

class SalaryDetailScreen extends StatelessWidget {
  const SalaryDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Get parameters dari route
    final args = Get.arguments as Map<String, dynamic>;
    final controller = Get.put(
      SalaryDetailController(
        userId: args['userId'] as int,
        userName: args['userName'] as String,
        userEmail: args['userEmail'] as String,
        roleName: args['roleName'] as String?,
      ),
    );

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(gradient: AppTheme.backgroundGradient),
        child: SafeArea(
          child: Column(
            children: [
              // Custom AppBar
              _buildAppBar(context, controller),

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
                          Button(
                            text: 'Coba Lagi',
                            onPressed: controller.loadSalaryDetail,
                            backgroundColor: AppTheme.primaryBlue,
                          ).paddingSymmetric(horizontal: 48),
                        ],
                      ),
                    );
                  }

                  final detail = controller.salaryDetail.value;
                  if (detail == null) {
                    return const Center(child: Text('Data tidak tersedia'));
                  }

                  return _buildContent(context, controller, detail);
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context, SalaryDetailController controller) {
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
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Detail Gaji',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary,
                  ),
                ),
                Text(
                  controller.userName,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 300.ms).slideX(begin: -0.1, end: 0);
  }

  Widget _buildContent(
    BuildContext context,
    SalaryDetailController controller,
    UserGajiDetail detail,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Card - User Info
          _buildUserInfoCard(context, controller)
              .animate()
              .fadeIn(duration: 400.ms, delay: 100.ms)
              .slideY(begin: 0.2, end: 0),

          const SizedBox(height: 20),

          // Period Info
          _buildPeriodCard(context, controller)
              .animate()
              .fadeIn(duration: 400.ms, delay: 200.ms)
              .slideY(begin: 0.2, end: 0),

          const SizedBox(height: 20),

          // Rate Gaji
          _buildRateCard(context, controller, detail)
              .animate()
              .fadeIn(duration: 400.ms, delay: 300.ms)
              .slideY(begin: 0.2, end: 0),

          const SizedBox(height: 20),

          // Jam Kerja Breakdown
          _buildWorkHoursCard(context, controller, detail)
              .animate()
              .fadeIn(duration: 400.ms, delay: 400.ms)
              .slideY(begin: 0.2, end: 0),

          const SizedBox(height: 20),

          // Ringkasan Pembayaran
          _buildSummaryCard(context, controller, detail)
              .animate()
              .fadeIn(duration: 400.ms, delay: 500.ms)
              .slideY(begin: 0.2, end: 0),

          const SizedBox(height: 24),

          // Action Button
          Button(
            text: 'Simpan Penyesuaian',
            onPressed: () {
              // TODO: Implement salary adjustment
              Get.snackbar(
                'Info',
                'Fitur penyesuaian gaji akan segera tersedia',
                backgroundColor: AppTheme.info.withOpacity(0.9),
                colorText: Colors.white,
                snackPosition: SnackPosition.BOTTOM,
                margin: const EdgeInsets.all(16),
              );
            },
            backgroundColor: AppTheme.primaryBlue,
          ).animate().fadeIn(duration: 400.ms, delay: 600.ms),

          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildUserInfoCard(
    BuildContext context,
    SalaryDetailController controller,
  ) {
    return Container(
      decoration: AppTheme.cardDecoration,
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: AppTheme.primaryBlue.withOpacity(0.2),
              borderRadius: BorderRadius.circular(30),
              border: Border.all(
                color: AppTheme.primaryBlue.withOpacity(0.5),
                width: 2,
              ),
            ),
            child: const Icon(
              Icons.person,
              color: AppTheme.primaryBlue,
              size: 32,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  controller.userName,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  controller.userEmail,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppTheme.textSecondary,
                  ),
                ),
                if (controller.roleName != null) ...[
                  const SizedBox(height: 4),
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
                      controller.roleName!,
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: AppTheme.accentCyan,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPeriodCard(
    BuildContext context,
    SalaryDetailController controller,
  ) {
    return Container(
      decoration: AppTheme.cardDecoration,
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.info.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.calendar_today,
              color: AppTheme.info,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Periode',
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: AppTheme.textSecondary),
              ),
              const SizedBox(height: 4),
              Text(
                controller.getCurrentPeriod(),
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRateCard(
    BuildContext context,
    SalaryDetailController controller,
    UserGajiDetail detail,
  ) {
    return Container(
      decoration: AppTheme.cardDecoration,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Rate Gaji',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Per Jam',
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: AppTheme.textSecondary),
              ),
              Text(
                '${controller.formatCurrency(detail.gajiPerJam)}/jam',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryBlue,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWorkHoursCard(
    BuildContext context,
    SalaryDetailController controller,
    UserGajiDetail detail,
  ) {
    // Estimate jam kerja dari gaji (assuming 8 jam/hari, 22 hari/bulan = 176 jam)
    final estimatedRegularHours = 150.0;
    final estimatedOvertimeHours = 4.0;
    final estimatedAbsentHours = 2.0;

    return Container(
      decoration: AppTheme.cardDecoration,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Jam Kerja',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 16),

          // Reguler
          _buildWorkHourRow(
            context,
            'Jam kerja Reguler',
            controller.formatHours(estimatedRegularHours),
            AppTheme.success,
          ),
          const SizedBox(height: 12),

          // Lembur
          _buildWorkHourRow(
            context,
            'Jam kerja Lembur',
            controller.formatHours(estimatedOvertimeHours),
            AppTheme.warning,
          ),
          const SizedBox(height: 12),

          // Kurang
          _buildWorkHourRow(
            context,
            'Jam kerja Kurang',
            controller.formatHours(estimatedAbsentHours),
            AppTheme.error,
          ),
        ],
      ),
    );
  }

  Widget _buildWorkHourRow(
    BuildContext context,
    String label,
    String value,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3), width: 1),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: AppTheme.textPrimary),
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(
    BuildContext context,
    SalaryDetailController controller,
    UserGajiDetail detail,
  ) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.primaryBlue.withOpacity(0.2),
            AppTheme.accentCyan.withOpacity(0.2),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.primaryBlue.withOpacity(0.3),
          width: 2,
        ),
        boxShadow: AppTheme.glowEffect,
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Ringkasan',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 16),

          _buildSummaryRow(
            context,
            'Reguler',
            controller.formatCurrency(detail.gajiBulanan),
          ),
          const SizedBox(height: 8),
          _buildSummaryRow(context, 'Lembur', controller.formatCurrency(0)),
          const SizedBox(height: 8),
          _buildSummaryRow(context, 'Potongan', controller.formatCurrency(0)),
          const SizedBox(height: 8),
          _buildSummaryRow(
            context,
            'Bonus Tambahan',
            controller.formatCurrency(0),
          ),
          const SizedBox(height: 8),
          _buildSummaryRow(
            context,
            'Potongan Tambahan',
            controller.formatCurrency(0),
          ),

          const SizedBox(height: 16),
          const Divider(color: AppTheme.textSecondary, thickness: 1),
          const SizedBox(height: 16),

          // Total
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
              ),
              Text(
                controller.formatCurrency(detail.gajiBulanan),
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryBlue,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(BuildContext context, String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: AppTheme.textSecondary),
        ),
        Text(
          value,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: AppTheme.textPrimary,
          ),
        ),
      ],
    );
  }
}
