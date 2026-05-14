# 📱 Penjelasan Aplikasi Surat Desa Kasongan
### Dokumen Presentasi UAS – Pemrograman Mobile (Flutter)

---

## 🎯 Kesesuaian dengan Spesifikasi UAS

| Ketentuan UAS | Status | Implementasi |
|---|---|---|
| Minimal 3 halaman (multi screen) | ✅ **LEBIH dari cukup** | 12+ halaman |
| Tambah data | ✅ | Form tambah surat & informasi |
| Tampilkan data | ✅ | ListView surat, kartu informasi |
| Hapus data | ✅ | Hapus surat (admin) & hapus informasi |
| Form input (TextField) + validasi | ✅ | Validasi nama, alamat, form surat |
| Layout Column, Row, ListView | ✅ | Digunakan di semua halaman |
| Interaksi tombol yang berfungsi | ✅ | Navigation, CRUD, bookmark |
| Penyimpanan lokal (nilai tambah) | ✅ **BONUS** | SharedPreferences |
| UI menarik (nilai tambah) | ✅ **BONUS** | Glassmorphism, animasi, dark header |
| Bahasa Dart + Framework Flutter | ✅ | 100% Flutter/Dart |

---

## 📂 Struktur Proyek

```
lib/
├── main.dart                    → Entry point aplikasi
├── controllers/
│   ├── auth_controller.dart     → Login, register, manajemen sesi
│   ├── surat_controller.dart    → CRUD pengajuan surat
│   └── informasi_controller.dart→ CRUD informasi + bookmark
├── models/
│   ├── user_model.dart          → Struktur data pengguna
│   ├── surat_model.dart         → Struktur data surat
│   └── informasi_model.dart     → Struktur data informasi desa
├── views/screens/
│   ├── splash_screen.dart       → Loading awal
│   ├── auth/login_screen.dart   → Login
│   ├── auth/register_screen.dart→ Daftar akun baru
│   ├── user/
│   │   ├── user_home_screen.dart    → Dashboard pengguna
│   │   ├── user_tambah_screen.dart  → Form ajukan surat
│   │   └── user_detail_screen.dart  → Detail & tracking surat
│   ├── admin/
│   │   ├── admin_home_screen.dart   → Dashboard admin
│   │   └── admin_dashboard_screen.dart → Statistik admin
│   └── informasi/
│       ├── informasi_screen.dart       → Daftar informasi desa
│       ├── informasi_detail_screen.dart→ Detail informasi
│       └── tambah_informasi_screen.dart→ Form tambah informasi
└── views/widgets/
    ├── informasi_card_widget.dart   → Kartu informasi reusable
    └── info_banner_widget.dart      → Banner cuaca/waktu
```

---

## 🔑 FITUR 1 – Autentikasi Multi-Role

**File utama:** `lib/controllers/auth_controller.dart`

### Cara Kerja:
```dart
// Login: cek username + password di SharedPreferences
Future<bool> login(String username, String password) async {
  final prefs = await SharedPreferences.getInstance();
  final usersJson = prefs.getStringList('users') ?? [];
  // Cari user yang cocok
  for (final json in usersJson) {
    final user = UserModel.fromJson(jsonDecode(json));
    if (user.username == username && user.password == password) {
      await prefs.setString('currentUser', jsonEncode(user.toJson()));
      _currentUser = user;
      notifyListeners();
      return true;
    }
  }
  return false;
}
```

### 3 Peran (Role):
- **User** → hanya bisa lihat & ajukan surat milik sendiri
- **Admin** → kelola semua surat, tambah/hapus informasi  
- **SuperAdmin** → akses penuh + manajemen pengguna

### Alur Navigasi Login:
```
SplashScreen → LoginScreen
                    ↓ (cek role)
         ┌──────────┼──────────┐
       User        Admin    SuperAdmin
         ↓           ↓          ↓
  UserHomeScreen  AdminHome  SuperAdminHome
```

---

## 📝 FITUR 2 – Pengajuan Surat (CRUD)

**File utama:** `lib/controllers/surat_controller.dart`  
**Form:** `lib/views/screens/user/user_tambah_screen.dart`

### Tambah Surat (Create):
```dart
// user_tambah_screen.dart – validasi form sebelum simpan
final _formKey = GlobalKey<FormState>();

TextFormField(
  validator: (v) => v == null || v.isEmpty 
    ? 'Nama tidak boleh kosong' 
    : null,
  // ...
)

// Simpan ke controller
widget.suratController.tambahSurat(
  jenisSurat: _selectedJenis!,
  namaLengkap: _namaController.text,
  nik: _nikController.text,
  // ...
);
```

### Tampilkan Surat (Read):
```dart
// user_home_screen.dart – filter berdasarkan userId & status
final surat = widget.suratController.daftarTampil(
  filterUserId: user.id,  // hanya surat milik user ini
);

// Ditampilkan dalam ListView
ListView.builder(
  itemCount: surat.length,
  itemBuilder: (_, i) => _suratCard(surat[i]),
)
```

### Update Status Surat (Admin):
```dart
// admin_home_screen.dart
widget.suratController.updateStatus(surat.id, statusBaru);
// Status: Menunggu → Diproses → Selesai / Ditolak
```

### Hapus Surat (Delete):
```dart
// Konfirmasi dulu, lalu hapus
widget.suratController.hapusSurat(surat.id);
```

### Penyimpanan Lokal:
```dart
// surat_controller.dart – data disimpan di SharedPreferences
Future<void> _saveData() async {
  final prefs = await SharedPreferences.getInstance();
  final list = _daftarSurat.map((s) => jsonEncode(s.toJson())).toList();
  await prefs.setStringList('surat', list);
}
```

---

## 📢 FITUR 3 – Informasi Desa

**File utama:** `lib/controllers/informasi_controller.dart`  
**Layar:** `lib/views/screens/informasi/informasi_screen.dart`

### Model Data:
```dart
// informasi_model.dart
class InformasiModel {
  final String id;
  final String judul;       // Judul pengumuman/berita
  final String isi;         // Isi lengkap
  final String tipe;        // 'Pengumuman' atau 'Berita'
  final String kategori;    // 'Kesehatan', 'Pendidikan', dll
  final DateTime tanggal;
  final String dibuatOleh;
}
```

### Tambah Informasi (Admin only):
```dart
// tambah_informasi_screen.dart
await widget.informasiController.tambahInformasi(
  judul: _judulController.text,
  isi: _isiController.text,
  tipe: _selectedTipe!,
  kategori: _selectedKategori!,
  namaAdmin: widget.namaAdmin,
);
```

### Tampilkan berdasarkan Kategori (Tab):
```dart
// informasi_screen.dart – 4 tab filter
TabBarView(
  children: [
    _buildList(controller.semuaInformasi),    // Semua
    _buildList(controller.pengumuman),         // Pengumuman saja
    _buildList(controller.berita),             // Berita saja
    _buildList(await controller.bookmarked()), // Disematkan user
  ],
)
```

### Bookmark / Sematkan:
```dart
// informasi_controller.dart – simpan bookmark per user
Future<void> toggleBookmark(String informasiId, String userId) async {
  final prefs = await SharedPreferences.getInstance();
  final key = 'bookmark_${userId}';
  final list = prefs.getStringList(key) ?? [];
  
  if (list.contains(informasiId)) {
    list.remove(informasiId); // hapus bookmark
  } else {
    list.add(informasiId);    // tambah bookmark
  }
  await prefs.setStringList(key, list);
  notifyListeners();
}
```

---

## 🧭 FITUR 4 – Navigasi Floating (Pill Navigation Bar)

**File:** `lib/views/screens/user/user_home_screen.dart`

### Konsep IndexedStack:
```dart
// IndexedStack menyimpan state semua tab, tidak rebuild saat pindah
IndexedStack(
  index: _currentTab,   // 0=Home, 1=Informasi, 2=Disematkan
  children: [
    _buildHomeContent(),
    InformasiScreen(showAppBar: false),  // tab mode
    InformasiScreen(initialTabIndex: 3, showAppBar: false),
  ],
)
```

### Floating Nav dengan Glassmorphism:
```dart
// Pill-shaped floating bottom bar
Container(
  decoration: BoxDecoration(
    color: Colors.white.withOpacity(0.85),  // transparan
    borderRadius: BorderRadius.circular(40), // pill shape
    boxShadow: [BoxShadow(blurRadius: 20)],
  ),
  child: Row(
    children: [
      _navTab(0, Icons.home_rounded, 'Home'),
      _navTab(1, Icons.info_outline_rounded, 'Info'),
      _navTab(2, Icons.bookmark_outline_rounded, 'Saved'),
      _navAction(Icons.add_box_rounded),  // ajukan surat
    ],
  ),
)
```

### Animasi Tab Aktif:
```dart
// Tab aktif melebar dengan animasi
AnimatedContainer(
  duration: Duration(milliseconds: 220),
  padding: EdgeInsets.symmetric(
    horizontal: isActive ? 18 : 12,  // melebar saat aktif
    vertical: 10,
  ),
  decoration: BoxDecoration(
    color: isActive ? AppConstants.primaryColor : Colors.transparent,
    borderRadius: BorderRadius.circular(30),
  ),
)
```

---

## 👥 FITUR 5 – Dashboard Statistik (Admin)

**File:** `lib/views/screens/admin/admin_home_screen.dart`

### Statistik Real-time:
```dart
// Hitung total, menunggu, selesai secara otomatis
ListenableBuilder(
  listenable: widget.suratController,
  builder: (context, _) {
    final total = controller.daftarSurat.length;
    final menunggu = controller.daftarSurat
        .where((s) => s.status == 'Menunggu').length;
    final selesai = controller.daftarSurat
        .where((s) => s.status == 'Selesai').length;
    // Tampilkan di stat card
  }
)
```

---

## 💾 FITUR 6 – Penyimpanan Lokal (SharedPreferences)

Semua data disimpan lokal tanpa memerlukan internet:

| Data | Key SharedPreferences |
|------|-----------------------|
| Daftar pengguna | `'users'` |
| Sesi login aktif | `'currentUser'` |
| Daftar surat | `'surat'` |
| Daftar informasi | `'informasi'` |
| Bookmark per user | `'bookmark_{userId}'` |

```dart
// Contoh simpan data
final prefs = await SharedPreferences.getInstance();
await prefs.setStringList('surat', listJson);

// Contoh baca data
final listJson = prefs.getStringList('surat') ?? [];
final daftar = listJson.map((j) => SuratModel.fromJson(jsonDecode(j))).toList();
```

---

## 🎨 Teknik UI yang Digunakan

| Teknik | Lokasi | Fungsi |
|--------|--------|--------|
| **Glassmorphism** | Floating nav bar | Tampilan transparan modern |
| **AnimatedContainer** | Tab aktif di nav | Animasi expand/collapse halus |
| **AnimatedSwitcher** | List surat | Transisi fade+slide antar filter |
| **CustomClipper** | Header user dashboard | Bentuk gelombang dekoratif |
| **NestedScrollView** | Home user | Header collapse saat scroll |
| **FutureBuilder** | Status bookmark | Load async data bookmark |
| **ListenableBuilder** | Semua list | Reactive update tanpa setState |
| **PageRouteBuilder** | Navigasi | Transisi slide/fade kustom |
| **IndexedStack** | Bottom nav | Preserve state antar tab |

---

## 🗺️ Daftar Semua Halaman (12 Halaman)

| No | Halaman | File | Role |
|----|---------|------|------|
| 1 | Splash Screen | `splash_screen.dart` | Semua |
| 2 | Login | `auth/login_screen.dart` | Semua |
| 3 | Register | `auth/register_screen.dart` | Semua |
| 4 | Dashboard User | `user/user_home_screen.dart` | User |
| 5 | Ajukan Surat | `user/user_tambah_screen.dart` | User |
| 6 | Detail Surat User | `user/user_detail_screen.dart` | User |
| 7 | Dashboard Admin | `admin/admin_home_screen.dart` | Admin |
| 8 | Statistik Admin | `admin/admin_dashboard_screen.dart` | Admin |
| 9 | Daftar Informasi | `informasi/informasi_screen.dart` | Semua |
| 10 | Detail Informasi | `informasi/informasi_detail_screen.dart` | Semua |
| 11 | Tambah Informasi | `informasi/tambah_informasi_screen.dart` | Admin |
| 12 | SuperAdmin Panel | `superadmin/` | SuperAdmin |

---

## ✅ Ringkasan untuk Presentasi

> **Aplikasi Surat Desa Kasongan** adalah aplikasi mobile Flutter untuk mengelola pengajuan surat keterangan warga dan informasi desa.

**Yang membuat aplikasi ini menonjol:**
1. 🔐 **Sistem login multi-role** (User, Admin, SuperAdmin)
2. 📋 **CRUD lengkap** untuk surat dan informasi desa
3. 💾 **Data tersimpan lokal** menggunakan SharedPreferences — tidak perlu internet
4. 🎨 **UI modern premium** dengan animasi, glassmorphism, dan gradasi
5. 🔖 **Fitur bookmark** per-pengguna yang persisten
6. 📱 **12+ halaman** dengan navigasi yang halus dan intuitif
7. ✅ **Validasi form** pada setiap input pengguna

**Teknologi:**
- Flutter (Dart)
- SharedPreferences (penyimpanan lokal)
- Google Fonts (tipografi)
- CustomClipper, AnimatedContainer, IndexedStack (UI advanced)
