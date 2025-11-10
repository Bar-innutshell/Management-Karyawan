import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../attendance/controllers/controller.dart';
import '../../auth/controllers/controller.dart';
import '../../../core/widgets/button.dart';

class PayrollScreen extends StatelessWidget {
	const PayrollScreen({super.key});

	String _formatCurrency(int amount) {
		final f = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
		return f.format(amount);
	}

	String _formatDate(DateTime d) {
		return DateFormat('d MMM yyyy').format(d);
	}

	@override
	Widget build(BuildContext context) {
		final AttendanceController ac = Get.put(AttendanceController());
		final AuthController auth = Get.isRegistered<AuthController>()
				? Get.find<AuthController>()
				: Get.put(AuthController());

		// derive hours
		final start = ac.startAt.value;
		DateTime? effectiveEnd;
		if (ac.isWorking) {
			// still working, use now or targetEnd whichever is smaller for regular hours calc
			effectiveEnd = DateTime.now();
		} else if (ac.finished.value && start != null && ac.targetEndAt.value != null) {
			effectiveEnd = ac.targetEndAt.value;
		}

		double totalHours = 0;
		if (start != null && effectiveEnd != null) {
			totalHours = effectiveEnd.difference(start).inMinutes / 60.0;
			if (totalHours < 0) totalHours = 0;
		}

		// split into regular (max 3) and overtime remainder
		final regularHours = totalHours.clamp(0, 3);
		final overtimeHours = totalHours > 3 ? (totalHours - 3) : 0.0;

		// rates
		const int regularRate = 100000; // per hour
		const int overtimeRate = 150000; // per hour

		final int basicPay = (regularHours * regularRate).round();
		final int overtimePay = (overtimeHours * overtimeRate).round();
		final int deduction = 0; // placeholder (potongan belum pasti)
		final int total = basicPay + overtimePay - deduction;

		final userName = auth.currentUser.value?.nama ?? auth.currentUser.value?.email ?? 'User';
		final slipDate = _formatDate(DateTime.now());
		final slipId = 'SLIP-${DateTime.now().millisecondsSinceEpoch.toString().substring(6)}';

		return Scaffold(
			appBar: AppBar(
				title: const Text('Slip Gaji'),
				backgroundColor: Colors.transparent,
				elevation: 0,
				foregroundColor: Colors.white,
			),
			extendBodyBehindAppBar: true,
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
						padding: const EdgeInsets.fromLTRB(20, kToolbarHeight + 16, 20, 40),
						child: ConstrainedBox(
							constraints: const BoxConstraints(maxWidth: 520),
							child: Card(
								color: const Color(0xFF1F2937),
								elevation: 6,
								shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
								child: Padding(
									padding: const EdgeInsets.all(20.0),
									child: Column(
										crossAxisAlignment: CrossAxisAlignment.start,
										children: [
											// Top total (larger)
											Text(
												_formatCurrency(total),
												style: Theme.of(context).textTheme.headlineMedium?.copyWith(
															color: Colors.white,
															fontWeight: FontWeight.w800,
														),
											),
											const SizedBox(height: 4),
											Text('Total Gaji Bersih', style: const TextStyle(color: Colors.white70)),
											const SizedBox(height: 20),

											// Detail rows
											_detailRow('Nama', userName, context),
											_detailRow('Tanggal', slipDate, context),
											_detailRow('ID Slip', slipId, context),
											const Divider(color: Colors.white12, height: 28),
											_detailRow('Jam Reguler', '${regularHours.toStringAsFixed(2)} j', context),
											_detailRow('Jam Lembur', '${overtimeHours.toStringAsFixed(2)} j', context),
											_detailRow('Gaji Pokok', _formatCurrency(basicPay), context),
											_detailRow('Bonus Lembur', _formatCurrency(overtimePay), context),
											_detailRow('Potongan', _formatCurrency(deduction), context),
											const Divider(color: Colors.white24, height: 32),
											_detailRow('Total', _formatCurrency(total), context, bold: true),
											const SizedBox(height: 28),
											Button(
												isLoading: false,
												text: 'Tutup',
												onPressed: () => Get.back(),
											),
										],
									),
								),
							),
						),
					),
				),
			),
		);
	}

	Widget _detailRow(String label, String value, BuildContext context, {bool bold = false}) {
		return Padding(
			padding: const EdgeInsets.symmetric(vertical: 6.0),
			child: Row(
				children: [
					Expanded(
						flex: 2,
						child: Text(
							label,
							style: Theme.of(context).textTheme.bodyMedium?.copyWith(
										color: Colors.white70,
									),
						),
					),
					Expanded(
						flex: 3,
						child: Text(
							value,
							textAlign: TextAlign.right,
							style: Theme.of(context).textTheme.bodyMedium?.copyWith(
										color: Colors.white,
										fontWeight: bold ? FontWeight.w700 : FontWeight.w500,
									),
						),
					),
				],
			),
		);
	}
}

