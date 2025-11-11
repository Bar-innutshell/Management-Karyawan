# TROUBLESHOOTING GAJI - PERBAIKAN MODEL

## Masalah yang Ditemukan

Error 500 dari backend endpoint `/gaji/all` karena struktur respons tidak sesuai dengan model Flutter.

## Struktur Respons Backend (Actual)

Berdasarkan `gajiController.js -> getAllUserGaji()`:

```json
{
  "message": "Daftar gaji semua user berhasil diambil",
  "data": [
    {
      "id": 1,
      "nama": "John Doe",
      "email": "john@example.com",
      "gajiPerJam": 15000,
      "role": {
        "nama": "Kasir",
        "gajiPokok": 5000000
      },
      "gajiBulanan": 1800000
    }
  ]
}
```

**Catatan:** Backend mengirim `id` (bukan `userId`), `role` sebagai nested object, dan `gajiBulanan` langsung (bukan `gajiBulananPerRole`).

## Perubahan yang Dilakukan

### 1. Model `UserGajiListItem` (gaji.dart)

**Sebelum:**

```dart
final int? userId;
final String? nama;
final String? email;
final double? gajiPerJam;
final double? gajiBulananPerRole;
```

**Sesudah:**

```dart
final int? userId;
final String? nama;
final String? email;
final String? roleName;  // ← TAMBAH
final double? gajiPerJam;
final double? gajiBulanan;  // ← RENAME dari gajiBulananPerRole
```

**fromJson:**

```dart
factory UserGajiListItem.fromJson(Map<String, dynamic> json) {
  final role = json['role'];
  return UserGajiListItem(
    userId: _parseInt(json['id']),  // ← backend kirim 'id'
    nama: json['nama']?.toString(),
    email: json['email']?.toString(),
    roleName: role is Map ? role['nama']?.toString() : null,  // ← parse nested
    gajiPerJam: _parseDouble(json['gajiPerJam']),
    gajiBulanan: _parseDouble(json['gajiBulanan']),  // ← field sesuai backend
  );
}
```

### 2. Controller (salary_info_controller.dart)

Menambah helper untuk hitung gaji bulanan jika backend tidak kirim:

```dart
double calculateMonthlyFromHourly(double? gajiPerJam) {
  if (gajiPerJam == null || gajiPerJam == 0) return 0;
  return gajiPerJam * 6 * 20;  // Formula: per jam × 6 jam × 20 hari
}
```

Format currency menggunakan pemisah titik (Rp 1.000.000):

```dart
String formatCurrency(double? amount) {
  if (amount == null || amount == 0) return 'Rp 0';
  final formatted = amount.toStringAsFixed(0).replaceAllMapped(
    RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
    (m) => '${m[1]}.',  // ← gunakan titik
  );
  return 'Rp $formatted';
}
```

### 3. UI (salary_info_screen.dart)

Menampilkan role name di card:

```dart
_SalaryCard(
  nama: item.nama ?? 'N/A',
  roleName: item.roleName ?? '-',  // ← tampilkan role
  rateGaji: controller.formatCurrency(item.gajiPerJam),
  total: controller.formatCurrency(
    item.gajiBulanan ?? controller.calculateMonthlyFromHourly(item.gajiPerJam),
  ),
)
```

## Kesimpulan

Model sekarang sudah selaras dengan backend:

- ✅ Parsing `id` dari backend → `userId`
- ✅ Parsing nested `role.nama` → `roleName`
- ✅ Field `gajiBulanan` sesuai respons backend
- ✅ Fallback calculation jika backend tidak kirim gajiBulanan
- ✅ Format currency Indonesia (titik sebagai pemisah ribuan)
