# Management Karyawan – Flutter Frontend

Flutter frontend untuk sistem manajemen karyawan (absensi, gaji, pemasukkan, jadwal, role & dashboard) yang terhubung ke backend Express + Prisma + JWT.

## ✅ Ringkasan Fitur Saat Ini

| Area                       | Status              | Catatan                                                                      |
| -------------------------- | ------------------- | ---------------------------------------------------------------------------- |
| Auth (Login)               | Selesai             | JWT disimpan di secure storage, decode payload untuk userId & roleId         |
| Role-based Routing         | Selesai             | `DashboardScreen` mengarahkan ke Admin / Employee / Cashier                  |
| Model Dart                 | Selesai             | User, Role, Attendance, Gaji, Income/Laporan, Schedule, ApiResponse          |
| ApiService Endpoints       | Selesai             | Semua modul: /roles, /absensi, /gaji, /laporan, /pemasukkan, (jadwal asumsi) |
| Admin Panel (Manage Users) | Skeleton            | Tampilan list + form dasar (belum terhubung endpoint real)                   |
| Dark Auth & Splash UI      | Selesai             | Desain gradient gelap + glow + animasi                                       |
| Global Dark Theme          | Pending             | Perlu file `app_theme.dart` + apply di `main.dart`                           |
| Dashboard Styling          | Pending             | Perlu redesign mengikuti gaya splash/auth                                    |
| MetricCard Widget          | Selesai (minor fix) | Perlu update text style (headline6 -> titleLarge)                            |

## 🏗 Struktur Project (Ringkas)

```
lib/
	main.dart
	core/
		config/ (konfigurasi global: baseUrl, routes)
		models/ (translasi JSON backend -> objek Dart)
		services/ (ApiService, AuthService, StorageService)
		widgets/ (komponen UI reusable: button, custom_text_field)
	features/
		splash/ (SplashScreen animasi gelap)
		auth/ (Login screen + controller)
		dashboard/ (Router berdasarkan role + future widgets)
		admin_panel/ (Admin dashboard & manage users)
		attendance/ (Absensi – akan konsumsi absensi API)
		payroll/ (Gaji – integrasi endpoints /gaji)
		reporting/ (Pemasukkan + laporan harian & total)
		schedule/ (Jadwal kerja – generate & tampilkan)
```

## 🔐 Alur Login & Navigasi Role

1. User input email & password → `ApiService.login()` memanggil `POST /auth/login`.
2. Token JWT disimpan di `StorageService`.
3. Decode payload JWT (userId, email, roleId) → Role detail bisa diambil via `/roles/:id`.
4. `AuthController` set `userRole` dan arahkan ke `DashboardScreen`.
5. `DashboardScreen` menampilkan: `AdminPanelScreen` untuk admin, `EmployeeScreen` untuk selain admin (kasir / pegawai).

## 🧩 Model Data (Inti)

| Model              | Fields Utama                                                                                            |
| ------------------ | ------------------------------------------------------------------------------------------------------- |
| User               | id, nama, email, roleId, gajiPerJam, role (summary)                                                     |
| Role               | id, nama, gajiPokok, deskripsi, createdAt, updatedAt, jumlahUser                                        |
| AttendanceRecord   | id, userId, tanggal, shift, jamMasuk, jamKeluar, menitTerlambat, jamKerja, gajiDihasilkan, status, user |
| UserGajiDetail     | user, gajiPerJam, gajiHarian, gajiBulanan, formula                                                      |
| UserGajiListItem   | userId, nama, email, gajiPerJam, gajiBulananPerRole                                                     |
| IncomeReport       | id, jumlahPemasukan, tanggalLaporan, shift, userId, user                                                |
| TotalIncomeSummary | totalPemasukkan, jumlahTransaksi, filter                                                                |
| DailyIncomeSummary | tanggal, totalPemasukan, jumlahTransaksi, items                                                         |
| ScheduleItem       | id, userId, waktuMulai, waktuSelesai, user                                                              |
| ApiResponse<T>     | message, data                                                                                           |

## 🌐 Pemetaan Endpoint Backend → ApiService

| Backend                           | Method          | ApiService Method                |
| --------------------------------- | --------------- | -------------------------------- |
| POST /auth/login                  | login           | login(email,password)            |
| GET /roles                        | list roles      | fetchRoles()                     |
| GET /roles/:id                    | detail role     | fetchRole(id)                    |
| POST /roles                       | create          | createRole(...)                  |
| PUT /roles/:id                    | update          | updateRole(id, ...)              |
| DELETE /roles/:id                 | delete          | deleteRole(id)                   |
| POST /absensi/clock-in            | clock in        | clockIn(shift)                   |
| POST /absensi/clock-out           | clock out       | clockOut()                       |
| GET /absensi/my                   | my attendance   | fetchMyAttendance()              |
| GET /absensi/today                | today           | fetchTodayAttendance()           |
| GET /absensi/all                  | all (admin)     | fetchAllAttendance()             |
| POST /gaji/set-gaji-perjam        | set per jam     | setGajiPerJam(userId,gajiPerJam) |
| POST /gaji/hitung-dari-gaji-pokok | derive rate     | hitungDariGajiPokok(userId)      |
| GET /gaji/user/:userId            | detail gaji     | fetchUserGaji(userId)            |
| GET /gaji/all                     | all gaji        | fetchAllUserGaji()               |
| GET /laporan/total                | total           | fetchTotalIncome(...)            |
| GET /laporan/harian               | harian          | fetchDailyIncome(...)            |
| GET /laporan/detail               | detail          | fetchIncomeDetail(...)           |
| GET /pemasukkan/show              | income list     | fetchPemasukkan()                |
| POST /pemasukkan/insert           | create income   | createPemasukkan(jumlah,shift)   |
| GET /schedule (ASUMSI)            | list jadwal     | fetchSchedule()                  |
| POST /schedule/create (ASUMSI)    | generate jadwal | createSchedule()                 |

> Catatan: Endpoint jadwal belum terdaftar di `index.js`, sesuaikan metode jika backend menambahkan path berbeda.

## 💾 Konfigurasi & Base URL

- `AppConstants.baseUrl` default: `http://localhost:3000`
- Bisa di override lewat `--dart-define=BASE_URL=https://domain` saat build/run.
- Interceptor `ApiService` otomatis menambahkan header Authorization jika token ada.

## 🛠 Contoh Penggunaan Cepat

```dart
final api = ApiService();

// Login
await api.login('user@example.com', 'password123');

// Ambil role
final roles = await api.fetchRoles();

// Clock in shift "Siang"
final absensi = await api.clockIn('Siang');

// Total pemasukan bulan ini
final total = await api.fetchTotalIncome(startDate: '2025-11-01', endDate: '2025-11-30');
```

## 🎨 UI & Tema

- Splash & Auth menggunakan gradient gelap (`#0F1115 → #111827`) + glow biru/hijau.
- Komponen form: Card transparansi + input dengan `fillColor` gelap.
- TODO: Global dark theme (`app_theme.dart`) + konsolidasi text styles.

## 📦 Dependency Utama

| Package                | Fungsi                          |
| ---------------------- | ------------------------------- |
| dio                    | HTTP client + interceptor token |
| get                    | State management & routing      |
| flutter_secure_storage | Simpan token JWT aman           |
| flutter_animate        | Animasi splash/auth             |

## 🔄 State Management

- GetX digunakan untuk controller per fitur (AuthController, dsb.).
- Observables (`Rx<T>`) untuk memantau loading & data list.

## 📋 TODO / Roadmap (Singkat)

- [ ] Global dark theme file & apply di `main.dart`.
- [ ] Redesign Dashboard & AdminPanel dengan metric cards.
- [ ] Integrasi nyata Manage Users dengan endpoint backend user (belum ditambahkan di ApiService karena path belum tersedia di daftar route).
- [ ] Implement controller untuk setiap modul memanggil ApiService baru.
- [ ] Penanganan refresh token (jika backend menambah).
- [ ] Unit test parsing model (opsional).

## 🧪 Testing (Rencana)

- Tambah test untuk: decode JWT, parsing Role/User, error handling ApiService (mock Dio). Belum dibuat.

## 🚀 Menjalankan Aplikasi

```powershell
flutter pub get
flutter run --dart-define=BASE_URL=http://localhost:3000
```

## 🔐 Keamanan

- Jangan commit token / rahasia env.
- Pastikan backend mengatur `JWT_SECRET` dengan aman.

## 🧩 Ekstensi Mendatang

- Notifikasi realtime (opsional, websocket—saat ini dihapus atas preferensi sederhana).
- Pagination & meta (bila API menambah `page`, `limit`).
- Filter dinamis untuk laporan & pemasukkan.

## 🗂 Pola Naming

- JSON backend menggunakan campuran bahasa Indonesia (nama, gajiPerJam, jumlahPemasukan) → Model mempertahankan naming agar seragam.
- Field opsional dijaga nullable di Dart (`String?`).

## ❓ FAQ Singkat

**Kenapa tidak pakai freezed/json_serializable?** Disederhanakan agar cepat iterasi manual & mengurangi overhead build runner.

**Kenapa jadwal belum dihubungkan?** Endpoint belum terlihat di daftar route; metode dibuat dengan asumsi untuk memudahkan nanti.

**Bisakah tambah refresh token?** Ya, tinggal menambah penyimpanan & endpoint di backend lalu interceptor refresh.

## 🧾 Lisensi

Internal/Private (sesuaikan jika ingin open-source).

---

Dokumen ini akan diperbarui seiring fitur ditambahkan. Minta perubahan? Cukup jelaskan bagian yang ingin dirinci.
