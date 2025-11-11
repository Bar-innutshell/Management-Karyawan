import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../controllers/controller.dart';
import '../../../core/widgets/button.dart';

class AttendanceScreen extends StatelessWidget {
	const AttendanceScreen({super.key});

	String _formatToday() {
		try {
			// Simple readable format; locale-sensitive if device supports it
			return DateFormat('EEEE, d MMMM yyyy').format(DateTime.now());
		} catch (_) {
			final d = DateTime.now();
			return '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
		}
	}

	@override
	Widget build(BuildContext context) {
		final AttendanceController c = Get.put(AttendanceController());

			return Scaffold(
				extendBodyBehindAppBar: true,
				appBar: AppBar(
					backgroundColor: Colors.transparent,
					elevation: 0,
					title: const Text('Absensi', style: TextStyle(color: Colors.white)),
					iconTheme: const IconThemeData(color: Colors.white),
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
						const Positioned(
							top: -60,
							left: -40,
										child: const Glow(color: Color(0xFF2563EB), size: 160),
						),
						const Positioned(
							bottom: -80,
							right: -50,
										child: const Glow(color: Color(0xFF10B981), size: 200),
						),
						// Content Card
						Center(
							child: ConstrainedBox(
								constraints: const BoxConstraints(maxWidth: 480),
								child: Card(
									color: const Color(0xFF1F2937),
									elevation: 8,
									shape: RoundedRectangleBorder(
										borderRadius: BorderRadius.circular(16),
									),
									child: Padding(
										padding: const EdgeInsets.all(20.0),
										child: Column(
											mainAxisSize: MainAxisSize.min,
											crossAxisAlignment: CrossAxisAlignment.start,
											children: [
												// Header
												Obx(
													() => Text(
														'Halo, ${c.greetingName}',
														style: Theme.of(context).textTheme.headlineSmall?.copyWith(
																	color: Colors.white,
																	fontWeight: FontWeight.w700,
																),
													),
												),
												const SizedBox(height: 4),
												Text(
													_formatToday(),
													style: Theme.of(context)
															.textTheme
															.bodyMedium
															?.copyWith(color: Colors.white70),
												),
												const SizedBox(height: 20),

												// Status + elapsed
												Obx(
													() => Row(
														children: [
															Text(
																c.statusText,
																style: Theme.of(context).textTheme.titleMedium?.copyWith(
																			color: Colors.white,
																			fontWeight: FontWeight.w600,
																		),
															),
															const Spacer(),
															if (c.isWorking) ...[
																const Icon(Icons.timelapse, size: 18, color: Colors.white70),
																const SizedBox(width: 6),
																Text(
																	c.elapsedLabel,
																	style: Theme.of(context)
																			.textTheme
																			.bodyMedium
																			?.copyWith(color: Colors.white70),
																),
															]
														],
													),
												),
												const SizedBox(height: 8),
																		Obx(() => c.isWorking
																				? Row(
																						children: [
																							const Text('Sisa waktu:', style: TextStyle(color: Colors.white70)),
																							const SizedBox(width: 8),
																							Container(
																								padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
																								decoration: BoxDecoration(
																									color: const Color(0xFF2563EB),
																									borderRadius: BorderRadius.circular(999),
																								),
																								child: Text(
																									c.remainingLabel,
																									style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
																								),
																							),
																						],
																					)
																				: const SizedBox.shrink()),

												const SizedBox(height: 24),
																		// Main button (reuse app Button style)
																		Obx(() => SizedBox(
																					width: double.infinity,
																					child: Button(
																						isLoading: false,
																						text: c.buttonText,
																						onPressed: c.isButtonEnabled ? c.onAttendancePressed : null,
																					),
																				)),

																		const SizedBox(height: 12),
																		// History & Overtime row (show history in closable window)
																		Row(
																			children: [
																				TextButton.icon(
																					onPressed: () => _openHistory(context, c),
																					icon: const Icon(Icons.history, color: Colors.white70),
																					label: const Text('Riwayat', style: TextStyle(color: Colors.white70)),
																					style: TextButton.styleFrom(
																						foregroundColor: Colors.white70,
																						disabledForegroundColor: Colors.white30,
																					),
																				),
																				const Spacer(),
																				TextButton.icon(
																					onPressed: c.canOvertime ? c.onOvertimePressed : null,
																					icon: const Icon(Icons.add_alarm, size: 18, color: Colors.white70),
																					label: const Text('Lembur +1 jam', style: TextStyle(color: Colors.white70)),
																					style: TextButton.styleFrom(
																						foregroundColor: Colors.white70,
																						disabledForegroundColor: Colors.white30,
																					),
																				),
																		],
																		),
											],
										),
									),
								).animate().fadeIn(duration: 400.ms).slideY(begin: 0.1, end: 0, curve: Curves.easeOut),
							),
						),
					],
				),
			);
	}

									String _fmtEvent(AttendanceEvent e) {
									final hh = e.at.hour.toString().padLeft(2, '0');
									final mm = e.at.minute.toString().padLeft(2, '0');
									switch (e.action) {
										case 'clock_in':
											return 'Masuk: $hh:$mm';
										case 'clock_out':
											return 'Pulang: $hh:$mm';
										case 'overtime+1h':
											return 'Lembur +1j: $hh:$mm';
										case 'overtime+1h (reactivate)':
											return 'Lembur (aktif ulang): $hh:$mm';
										default:
											return '${e.action} $hh:$mm';
									}
								}

		void _openHistory(BuildContext context, AttendanceController c) {
			showModalBottomSheet(
				context: context,
				isScrollControlled: true,
				backgroundColor: const Color(0xFF1F2937),
				shape: const RoundedRectangleBorder(
					borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
				),
				builder: (ctx) {
					return DraggableScrollableSheet(
						expand: false,
						initialChildSize: 0.6,
						minChildSize: 0.3,
						maxChildSize: 0.9,
						builder: (context, scrollController) {
							return Column(
								children: [
									Padding(
										padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
										child: Row(
											children: [
												const Text('Riwayat Hari Ini', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 16)),
												const Spacer(),
												IconButton(
													onPressed: () => Navigator.of(ctx).pop(),
													icon: const Icon(Icons.close, color: Colors.white70),
													tooltip: 'Tutup',
												)
											],
										),
									),
									const Divider(color: Colors.white12, height: 1),
									Expanded(
										child: Obx(() {
											final items = c.history.reversed.toList();
											if (items.isEmpty) {
												return const Center(
													child: Text('Belum ada aktivitas', style: TextStyle(color: Colors.white70)),
												);
											}
											return ListView.separated(
												controller: scrollController,
												itemCount: items.length,
												separatorBuilder: (_, __) => const Divider(color: Colors.white12, height: 1),
												itemBuilder: (_, i) {
													final e = items[i];
													IconData icon;
													Color color;
													switch (e.action) {
														case 'clock_in':
															icon = Icons.login;
															color = const Color(0xFF10B981);
															break;
														case 'clock_out':
															icon = Icons.logout;
															color = const Color(0xFFEF4444);
															break;
														case 'overtime+1h':
														case 'overtime+1h (reactivate)':
															icon = Icons.alarm_add;
															color = const Color(0xFFF59E0B);
															break;
														default:
															icon = Icons.circle;
															color = Colors.white54;
													}
													final time = '${e.at.hour.toString().padLeft(2, '0')}:${e.at.minute.toString().padLeft(2, '0')}';
													return ListTile(
														leading: Icon(icon, color: color),
														title: Text(_fmtEvent(e), style: const TextStyle(color: Colors.white)),
														subtitle: Text(time, style: const TextStyle(color: Colors.white54)),
													);
												},
											);
										}),
									),
								],
							);
						},
					);
				},
			);
		}
}

class Glow extends StatelessWidget {
	final Color color;
	final double size;
	const Glow({super.key, required this.color, required this.size});

	@override
	Widget build(BuildContext context) {
		return Container(
			width: size,
			height: size,
			decoration: BoxDecoration(
				shape: BoxShape.circle,
				color: color.withOpacity(0.35),
				boxShadow: [
					BoxShadow(color: color.withOpacity(0.6), blurRadius: 80, spreadRadius: 40),
				],
			),
		);
	}
}

