import 'dart:async';
import 'dart:convert';

import 'package:get/get.dart';

import '../../../core/models/user.dart';
import '../../../core/services/storage_service.dart';
import '../../auth/controllers/controller.dart';
 
class AttendanceEvent {
	final String action; // 'clock_in', 'clock_out', 'overtime+'
	final DateTime at;

	AttendanceEvent(this.action, this.at);

	Map<String, dynamic> toJson() => {
				'action': action,
				'at': at.toIso8601String(),
			};

	factory AttendanceEvent.fromJson(Map<String, dynamic> j) =>
			AttendanceEvent(j['action']?.toString() ?? 'unknown', DateTime.tryParse(j['at']?.toString() ?? '') ?? DateTime.now());

	@override
	String toString() => '$action @ ${at.toLocal()}';
}

class AttendanceController extends GetxController {
	// User state
	final user = Rxn<User>();

	// Daily session state
	final startAt = Rxn<DateTime>();
	final targetEndAt = Rxn<DateTime>(); // start + 3h + overtime
	final finished = false.obs;
	final overtimeHours = 0.obs;

	// Live counters
	final elapsedSeconds = 0.obs;
	final remainingSeconds = 0.obs;

		// History (today only)
		final history = <AttendanceEvent>[].obs;

	Timer? _timer;

	String get greetingName {
		final u = user.value;
		if (u == null) return 'user';
		final nm = (u.nama ?? '').trim();
		if (nm.isNotEmpty) return nm;
		final em = (u.email ?? '').trim();
		if (em.isNotEmpty) return em.split('@').first;
		return 'user';
	}

	String get statusText => isWorking
			? 'Status: Masuk kerja'
			: finished.value
					? 'Status: Pulang kerja'
					: 'Status: Belum mulai';

	String get buttonText => isWorking
			? 'Keluar'
			: finished.value
					? 'Masuk'
					: 'Masuk';

	bool get isButtonEnabled => isWorking || (!finished.value && !hasWorkedToday);

	bool get isWorking => startAt.value != null && !finished.value;

	bool get hasWorkedToday =>
			// has started today and either still working or finished
			_isSameDay(startAt.value, DateTime.now());

		bool get canOvertime => isWorking || (finished.value && hasWorkedToday);

	String get elapsedLabel {
		final s = elapsedSeconds.value;
		final hh = (s ~/ 3600).toString().padLeft(2, '0');
		final mm = ((s % 3600) ~/ 60).toString().padLeft(2, '0');
		final ss = (s % 60).toString().padLeft(2, '0');
		return '$hh:$mm:$ss';
	}

	String get remainingLabel {
		final s = remainingSeconds.value;
		final hh = (s ~/ 3600).toString().padLeft(2, '0');
		final mm = ((s % 3600) ~/ 60).toString().padLeft(2, '0');
		final ss = (s % 60).toString().padLeft(2, '0');
		return '$hh:$mm:$ss';
	}

	@override
	void onInit() {
		super.onInit();
		_hydrateUser();
		_hydrateAttendance();
	}

	Future<void> _hydrateUser() async {
		try {
			if (Get.isRegistered<AuthController>()) {
				final auth = Get.find<AuthController>();
				if (auth.currentUser.value != null) {
					user.value = auth.currentUser.value;
				}
			}
			if (user.value == null) {
				final storage = StorageService();
				final raw = await storage.readUserJson();
				if (raw != null && raw.isNotEmpty) {
					final map = jsonDecode(raw) as Map<String, dynamic>;
					user.value = User.fromJwtPayload(map);
				}
			}
		} catch (_) {}
	}

	Future<void> _hydrateAttendance() async {
		final storage = StorageService();
		final raw = await storage.readAttendanceState();
		if (raw == null || raw.isEmpty) return;
		try {
			final map = jsonDecode(raw) as Map<String, dynamic>;
			final dateStr = map['date']?.toString();
			final todayStr = _dateOnly(DateTime.now());
			if (dateStr != todayStr) {
				// different day, clear old state
				await storage.deleteAttendanceState();
				return;
			}
					final s = map['startAt']?.toString();
			final e = map['targetEndAt']?.toString();
			final f = map['finished'] == true;
			final ot = int.tryParse(map['overtimeHours']?.toString() ?? '0') ?? 0;
			if (s != null) startAt.value = DateTime.tryParse(s);
			if (e != null) targetEndAt.value = DateTime.tryParse(e);
			finished.value = f;
			overtimeHours.value = ot;
					// history
					final hist = map['history'];
					if (hist is List) {
						history.assignAll(hist
								.whereType<Map>()
								.map((e) => AttendanceEvent.fromJson(e.cast<String, dynamic>()))
								.toList());
					}
			if (isWorking) _startTicker();
		} catch (_) {
			// ignore corrupt state
		}
	}

	Future<void> _persist() async {
		final storage = StorageService();
		final map = {
			'date': _dateOnly(DateTime.now()),
			'startAt': startAt.value?.toIso8601String(),
			'targetEndAt': targetEndAt.value?.toIso8601String(),
			'finished': finished.value,
			'overtimeHours': overtimeHours.value,
				'history': history.map((e) => e.toJson()).toList(),
		};
		await storage.saveAttendanceState(jsonEncode(map));
	}

		void _addHistory(String action) {
			history.add(AttendanceEvent(action, DateTime.now()));
			_persist();
		}

	void onAttendancePressed() {
			if (isWorking) {
			_clockOut(manual: true);
		} else {
			if (finished.value || hasWorkedToday) {
				Get.snackbar('Absensi', 'Kerja hanya sekali per hari. Gunakan lembur.');
				return;
			}
			_clockIn();
		}
	}

		void onOvertimePressed() {
			// If currently working: extend by +1 hour
					if (isWorking) {
				overtimeHours.value += 1;
				targetEndAt.value = targetEndAt.value!.add(const Duration(hours: 1));
						_addHistory('overtime+1h');
				Get.snackbar('Lembur', 'Lembur +1 jam ditambahkan');
				return;
			}

			// If already finished today: re-activate work for 1 hour
					if (finished.value && hasWorkedToday) {
				overtimeHours.value += 1;
				finished.value = false;
				// Start a fresh overtime window from now for 1 hour
				targetEndAt.value = DateTime.now().add(const Duration(hours: 1));
				// Keep original startAt to represent total time today
						_addHistory('overtime+1h (reactivate)');
				_startTicker();
				Get.snackbar('Lembur', 'Lembur 1 jam dimulai');
				return;
			}

			Get.snackbar('Lembur', 'Mulai kerja dulu sebelum lembur');
		}

	void _clockIn() {
		final now = DateTime.now();
		startAt.value = now;
		finished.value = false;
		overtimeHours.value = 0;
		targetEndAt.value = now.add(const Duration(hours: 3));
			_addHistory('clock_in');
		_startTicker();
		Get.snackbar('Absensi', 'Absensi anda telah di catat');
	}

	void _clockOut({bool manual = false}) {
		finished.value = true;
		_stopTicker();
			_addHistory('clock_out');
		if (manual) {
			Get.snackbar('Absensi', 'Absensi anda telah di catat');
		} else {
			Get.snackbar('Absensi', 'Waktu kerja selesai, otomatis pulang kerja');
		}
	}

	void _startTicker() {
		_stopTicker();
		_tick();
		_timer = Timer.periodic(const Duration(seconds: 1), (_) => _tick());
	}

	void _stopTicker() {
		_timer?.cancel();
		_timer = null;
	}

	void _tick() {
		if (!isWorking) return;
		final now = DateTime.now();
		final start = startAt.value!;
		elapsedSeconds.value = now.difference(start).inSeconds.clamp(0, 86400);

		final end = targetEndAt.value!;
		final remain = end.difference(now).inSeconds;
		remainingSeconds.value = remain > 0 ? remain : 0;

		if (remain <= 0) {
			_clockOut(manual: false);
		}
	}

	bool _isSameDay(DateTime? a, DateTime? b) {
		if (a == null || b == null) return false;
		return a.year == b.year && a.month == b.month && a.day == b.day;
	}

	String _dateOnly(DateTime d) => '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

	@override
	void onClose() {
		_stopTicker();
		super.onClose();
	}
}

