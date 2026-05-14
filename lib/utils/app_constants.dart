// lib/utils/app_constants.dart

import 'package:flutter/material.dart';

class AppConstants {
  AppConstants._();

  static const String appName = 'Surat Desa Kasongan';
  static const String namaDesa = 'Desa Kasongan';
  static const String kecamatan = 'Kec. Kasongan • Kab. Katingan';
  static const String provinsi = 'Kalimantan Tengah';

  // ── SharedPreferences Keys ─────────────────────────────────────────────────
  static const String keyDaftarSurat = 'daftar_surat';
  static const String keyCounter = 'nomor_counter';
  static const String keyDaftarUser = 'daftar_user';
  static const String keySessionUserId = 'session_user_id';
  static const String keyDaftarInformasi = 'daftar_informasi';

  // 📢 Tipe & Kategori Informasi
  static const List<String> tipeInformasiList = ['Pengumuman', 'Berita'];
  static const List<String> kategoriInformasiList = [
    'Penting',
    'Kesehatan',
    'Kegiatan',
    'Administrasi',
    'Umum',
  ];

  // ── Everglo Light Theme Color Palette ──────────────────────────────────────
  static const Color backgroundColor = Color(0xFFF6F8F9);       // background utama
  static const Color surfaceColor = Color(0xFFFFFFFF);  // card / surface
  static const Color surfaceLight = Color(0xFFF4F6F6); // card terang
  static const Color primaryColor = Color(0xFF5DB075); // hijau aksen
  static const Color primaryDark = Color(0xFF48955F);  // hijau gelap gradient
  static const Color secondaryColor = Color(0xFFE8F5E9); // aksen sekunder
  static const Color accentColor = Color(0xFFF5A623);  // amber warning
  static const Color successColor = Color(0xFF5DB075); // hijau selesai
  static const Color errorColor = Color(0xFFFF6B6B);   // merah error
  static const Color textPrimary = Color(0xFF212121);  // teks utama
  static const Color textSecondary = Color(0xFF8E8E93); // teks sekunder

  // Legacy (untuk kompatibilitas)
  static const Color secondaryColorLegacy = primaryColor;

  // ── Gradients ──────────────────────────────────────────────────────────────
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primaryColor, primaryDark],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient bgGradient = LinearGradient(
    colors: [backgroundColor, Color(0xFFE8F0F2)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  // ── Role ───────────────────────────────────────────────────────────────────
  static const String roleUser = 'user';
  static const String roleAdmin = 'admin';
  static const String roleSuperAdmin = 'superadmin';

  // ── Akun Default SuperAdmin & Admin (preset, tidak bisa dihapus) ───────────
  static const List<Map<String, String>> defaultAccounts = [
    {
      'id': 'sa-001',
      'username': 'superadmin',
      'password': 'super123',
      'role': roleSuperAdmin,
      'namaLengkap': 'Super Administrator',
    },
    {
      'id': 'ad-001',
      'username': 'admin',
      'password': 'admin123',
      'role': roleAdmin,
      'namaLengkap': 'Administrator Desa',
    },
  ];

  // ── Jenis Surat ────────────────────────────────────────────────────────────
  static const List<String> jenisSuratList = [
    'Surat Keterangan Domisili',
    'Surat Keterangan Tidak Mampu',
    'Surat Keterangan Usaha',
    'Surat Keterangan Kelahiran',
    'Surat Keterangan Kematian',
    'Surat Pengantar KTP',
    'Surat Pengantar KK',
    'Surat Keterangan Beda Nama',
    'Surat Keterangan Belum Menikah',
    'Surat Izin Keramaian',
  ];

  static const List<String> statusList = [
    'Menunggu',
    'Diproses',
    'Selesai',
  ];

  // ── Helper Warna Status ────────────────────────────────────────────────────
  static Color statusColor(String status) {
    switch (status) {
      case 'Menunggu':
        return accentColor;
      case 'Diproses':
        return primaryColor;
      case 'Selesai':
        return successColor;
      default:
        return textSecondary;
    }
  }

  static IconData statusIcon(String status) {
    switch (status) {
      case 'Menunggu':
        return Icons.hourglass_empty_rounded;
      case 'Diproses':
        return Icons.sync_rounded;
      case 'Selesai':
        return Icons.check_circle_rounded;
      default:
        return Icons.help_outline;
    }
  }

  // ── Helper Warna & Icon Role ───────────────────────────────────────────────
  static Color roleColor(String role) {
    switch (role) {
      case roleSuperAdmin:
        return secondaryColor;
      case roleAdmin:
        return primaryColor;
      default:
        return successColor;
    }
  }

  static String roleLabel(String role) {
    switch (role) {
      case roleSuperAdmin:
        return 'Super Admin';
      case roleAdmin:
        return 'Admin';
      default:
        return 'User';
    }
  }

  static IconData roleIcon(String role) {
    switch (role) {
      case roleSuperAdmin:
        return Icons.shield_rounded;
      case roleAdmin:
        return Icons.admin_panel_settings_rounded;
      default:
        return Icons.person_rounded;
    }
  }

  // 📢 Helper Warna & Icon Tipe Informasi
  static Color tipeColor(String tipe) {
    switch (tipe) {
      case 'Berita':
        return const Color(0xFF0288D1); // biru teal
      default: // Pengumuman
        return const Color(0xFF7B61FF); // ungu
    }
  }

  static IconData tipeIcon(String tipe) {
    switch (tipe) {
      case 'Berita':
        return Icons.article_rounded;
      default:
        return Icons.campaign_rounded;
    }
  }

  // 📢 Helper Warna & Icon Kategori Informasi
  static Color kategoriColor(String kategori) {
    switch (kategori) {
      case 'Penting':
        return const Color(0xFFFF6B6B);    // merah
      case 'Kesehatan':
        return const Color(0xFF5DB075);    // hijau
      case 'Kegiatan':
        return const Color(0xFF0288D1);    // biru
      case 'Administrasi':
        return const Color(0xFFF5A623);    // amber
      default: // Umum
        return const Color(0xFF8E8E93);    // abu
    }
  }

  static IconData kategoriIcon(String kategori) {
    switch (kategori) {
      case 'Penting':
        return Icons.priority_high_rounded;
      case 'Kesehatan':
        return Icons.favorite_rounded;
      case 'Kegiatan':
        return Icons.celebration_rounded;
      case 'Administrasi':
        return Icons.assignment_rounded;
      default:
        return Icons.info_outline_rounded;
    }
  }
}
