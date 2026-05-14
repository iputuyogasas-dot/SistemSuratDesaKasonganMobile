// lib/controllers/informasi_controller.dart

import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/informasi_model.dart';

class InformasiController extends ChangeNotifier {
  // ─── state ───────────────────────────────────────────────────────────
  List<InformasiModel> _semua = [];
  bool _loading = false;

  // ─── key penyimpanan ─────────────────────────────────────────────────
  static const String _keyInformasi = 'daftar_informasi';
  static String _keyBookmark(String userId) => 'bookmarks_$userId';

  // ─── getter publik ────────────────────────────────────────────────────
  bool get loading => _loading;

  List<InformasiModel> get semuaInformasi {
    final list = List<InformasiModel>.from(_semua);
    list.sort((a, b) => b.tanggal.compareTo(a.tanggal));
    return list;
  }

  List<InformasiModel> get pengumuman {
    final list = _semua.where((i) => i.tipe == 'Pengumuman').toList();
    list.sort((a, b) => b.tanggal.compareTo(a.tanggal));
    return list;
  }

  List<InformasiModel> get berita {
    final list = _semua.where((i) => i.tipe == 'Berita').toList();
    list.sort((a, b) => b.tanggal.compareTo(a.tanggal));
    return list;
  }

  /// Ambil item yang sudah disematkan oleh userId tertentu
  Future<List<InformasiModel>> bookmarked(String userId) async {
    final ids = await _loadBookmarkIds(userId);
    final list = _semua.where((i) => ids.contains(i.id)).toList();
    list.sort((a, b) => b.tanggal.compareTo(a.tanggal));
    return list;
  }

  // ─── load data ────────────────────────────────────────────────────────
  Future<void> loadData() async {
    _loading = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_keyInformasi);
      if (raw != null) {
        final List decoded = jsonDecode(raw) as List;
        _semua = decoded
            .map((e) => InformasiModel.fromMap(Map<String, dynamic>.from(e as Map)))
            .toList();
      } else {
        // Seed data contoh agar halaman tidak kosong
        _semua = _seedData();
        await _simpanData(prefs);
      }
    } catch (_) {
      _semua = [];
    }

    _loading = false;
    notifyListeners();
  }

  // ─── tambah informasi (Admin/SuperAdmin) ──────────────────────────────
  Future<void> tambahInformasi(InformasiModel item) async {
    _semua.add(item);
    final prefs = await SharedPreferences.getInstance();
    await _simpanData(prefs);
    notifyListeners();
  }

  // ─── hapus informasi (Admin/SuperAdmin) ───────────────────────────────
  Future<void> hapusInformasi(String id) async {
    _semua.removeWhere((i) => i.id == id);
    final prefs = await SharedPreferences.getInstance();
    await _simpanData(prefs);
    notifyListeners();
  }

  // ─── bookmark personal user ───────────────────────────────────────────
  Future<void> toggleBookmark(String id, String userId) async {
    final prefs = await SharedPreferences.getInstance();
    final ids = await _loadBookmarkIds(userId);

    if (ids.contains(id)) {
      ids.remove(id);
    } else {
      ids.add(id);
    }

    await prefs.setStringList(_keyBookmark(userId), ids);
    notifyListeners();
  }

  Future<bool> isBookmarked(String id, String userId) async {
    final ids = await _loadBookmarkIds(userId);
    return ids.contains(id);
  }

  // ─── private helpers ──────────────────────────────────────────────────
  Future<List<String>> _loadBookmarkIds(String userId) async {
    if (userId.isEmpty) return [];
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_keyBookmark(userId)) ?? [];
  }

  Future<void> _simpanData(SharedPreferences prefs) async {
    final encoded = jsonEncode(_semua.map((i) => i.toMap()).toList());
    await prefs.setString(_keyInformasi, encoded);
  }

  // ─── seed data contoh ─────────────────────────────────────────────────
  List<InformasiModel> _seedData() {
    final now = DateTime.now();
    return [
      InformasiModel(
        id: 'info-001',
        judul: 'Jadwal Posyandu Bulan ${_bulan(now.month)}',
        isi:
            'Posyandu rutin akan dilaksanakan pada tanggal 15 ${_bulan(now.month)} ${now.year} di Balai Desa Kasongan pukul 08.00 – 12.00 WIB. Ibu-ibu diharapkan membawa buku KIA dan kartu posyandu. Layanan meliputi penimbangan balita, imunisasi, dan konsultasi gizi.',
        tipe: 'Pengumuman',
        kategori: 'Kesehatan',
        tanggal: now.subtract(const Duration(days: 1)),
        dibuatOleh: 'Administrator Desa',
      ),
      InformasiModel(
        id: 'info-002',
        judul: 'Gotong Royong Bersih Desa',
        isi:
            'Dalam rangka menjaga kebersihan dan keindahan desa, akan diadakan kegiatan Gotong Royong Bersih Desa pada hari Minggu, ${now.day + 3} ${_bulan(now.month)} ${now.year} pukul 07.00 WIB. Seluruh warga desa diharapkan berpartisipasi aktif. Alat kebersihan harap dibawa sendiri.',
        tipe: 'Pengumuman',
        kategori: 'Kegiatan',
        tanggal: now.subtract(const Duration(days: 2)),
        dibuatOleh: 'Administrator Desa',
      ),
      InformasiModel(
        id: 'info-003',
        judul: 'Festival Budaya Kasongan ${now.year}',
        isi:
            'Desa Kasongan kembali menggelar Festival Budaya tahunan yang menampilkan berbagai kesenian lokal Dayak Kalimantan Tengah. Acara akan berlangsung selama 3 hari pada akhir bulan ini di Lapangan Desa. Masyarakat umum dipersilakan hadir dan menikmati pertunjukan secara gratis.',
        tipe: 'Berita',
        kategori: 'Kegiatan',
        tanggal: now.subtract(const Duration(days: 3)),
        dibuatOleh: 'Administrator Desa',
      ),
      InformasiModel(
        id: 'info-004',
        judul: 'Pembukaan Layanan KTP & KK Online',
        isi:
            'Mulai bulan ini, warga Desa Kasongan dapat mengurus administrasi kependudukan (KTP, KK, Akte) secara online melalui aplikasi ini. Cukup ajukan permohonan dan tunggu konfirmasi dari petugas desa. Dokumen fisik dapat diambil di Kantor Desa pada hari kerja pukul 08.00–14.00.',
        tipe: 'Pengumuman',
        kategori: 'Administrasi',
        tanggal: now.subtract(const Duration(days: 5)),
        dibuatOleh: 'Administrator Desa',
      ),
      InformasiModel(
        id: 'info-005',
        judul: 'Waspada Demam Berdarah di Musim Hujan',
        isi:
            'Memasuki musim hujan, warga Desa Kasongan diimbau untuk menjaga kebersihan lingkungan guna mencegah perkembangbiakan nyamuk Aedes Aegypti. Lakukan 3M Plus: Menguras, Menutup, Mendaur ulang, serta menggunakan lotion anti nyamuk. Segera ke Puskesmas bila mengalami demam tinggi.',
        tipe: 'Berita',
        kategori: 'Kesehatan',
        tanggal: now.subtract(const Duration(days: 7)),
        dibuatOleh: 'Administrator Desa',
      ),
    ];
  }

  String _bulan(int m) {
    const bulan = [
      '', 'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
      'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
    ];
    return bulan[m];
  }
}
