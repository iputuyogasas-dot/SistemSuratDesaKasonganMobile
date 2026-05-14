// lib/controllers/surat_controller.dart

import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/surat_model.dart';
import '../utils/app_constants.dart';
import '../utils/date_helper.dart';

class SuratController extends ChangeNotifier {
  // ── state ──────────────────────────────────────────────────────────────────
  List<SuratModel> _semua = [];
  bool _loading = false;
  String _query = '';
  String _filterStatus = 'Semua';

  // ── getter publik ──────────────────────────────────────────────────────────
  bool get loading => _loading;
  String get query => _query;
  String get filterStatus => _filterStatus;
  List<SuratModel> get semuaSurat => _semua;

  /// Daftar surat yang ditampilkan — bisa difilter by userId untuk role User
  List<SuratModel> daftarTampil({String? filterUserId}) {
    var hasil = List<SuratModel>.from(_semua);

    // Filter by user jika role = user
    if (filterUserId != null && filterUserId.isNotEmpty) {
      hasil = hasil.where((s) => s.userId == filterUserId).toList();
    }

    if (_filterStatus != 'Semua') {
      hasil = hasil.where((s) => s.status == _filterStatus).toList();
    }
    if (_query.isNotEmpty) {
      final q = _query.toLowerCase();
      hasil = hasil.where((s) {
        return s.namaPemohon.toLowerCase().contains(q) ||
            s.nomorSurat.toLowerCase().contains(q) ||
            s.jenisSurat.toLowerCase().contains(q) ||
            s.nik.contains(q);
      }).toList();
    }
    hasil.sort((a, b) => b.tanggalPengajuan.compareTo(a.tanggalPengajuan));
    return hasil;
  }

  // ── statistik (semua surat) ────────────────────────────────────────────────
  int get total => _semua.length;
  int get jumlahMenunggu => _semua.where((s) => s.status == 'Menunggu').length;
  int get jumlahDiproses => _semua.where((s) => s.status == 'Diproses').length;
  int get jumlahSelesai => _semua.where((s) => s.status == 'Selesai').length;

  // statistik per user
  int totalUser(String userId) => _semua.where((s) => s.userId == userId).length;
  int menungguUser(String userId) => _semua.where((s) => s.userId == userId && s.status == 'Menunggu').length;
  int diprosesUser(String userId) => _semua.where((s) => s.userId == userId && s.status == 'Diproses').length;
  int selesaiUser(String userId) => _semua.where((s) => s.userId == userId && s.status == 'Selesai').length;

  // Data untuk chart (per bulan, 6 bulan terakhir)
  Map<String, int> getSuratPerBulan() {
    final now = DateTime.now();
    final result = <String, int>{};
    for (int i = 5; i >= 0; i--) {
      final bulan = DateTime(now.year, now.month - i, 1);
      final label = DateHelper.formatBulanTahun(bulan);
      result[label] = _semua.where((s) =>
          s.tanggalPengajuan.month == bulan.month &&
          s.tanggalPengajuan.year == bulan.year).length;
    }
    return result;
  }

  // ── load ───────────────────────────────────────────────────────────────────
  Future<void> loadData() async {
    _loading = true;
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(AppConstants.keyDaftarSurat);
      if (raw != null) {
        final list = json.decode(raw) as List<dynamic>;
        _semua = list
            .map((e) => SuratModel.fromMap(e as Map<String, dynamic>))
            .toList();
      }
    } catch (e) {
      debugPrint('loadData error: $e');
    }
    _loading = false;
    notifyListeners();
  }

  // ── simpan ke SharedPreferences ────────────────────────────────────────────
  Future<void> _simpan() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      AppConstants.keyDaftarSurat,
      json.encode(_semua.map((s) => s.toMap()).toList()),
    );
  }

  // ── generate nomor surat ───────────────────────────────────────────────────
  Future<String> _buatNomor() async {
    final prefs = await SharedPreferences.getInstance();
    final counter = (prefs.getInt(AppConstants.keyCounter) ?? 0) + 1;
    await prefs.setInt(AppConstants.keyCounter, counter);
    return DateHelper.nomorSurat(counter, DateTime.now());
  }

  // ── CRUD ───────────────────────────────────────────────────────────────────
  Future<bool> tambahSurat({
    required String jenisSurat,
    required String namaPemohon,
    required String nik,
    required String keperluan,
    required String keterangan,
    required String userId,
  }) async {
    try {
      final nomor = await _buatNomor();
      final surat = SuratModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        nomorSurat: nomor,
        jenisSurat: jenisSurat,
        namaPemohon: namaPemohon,
        nik: nik,
        keperluan: keperluan,
        keterangan: keterangan,
        status: 'Menunggu',
        tanggalPengajuan: DateTime.now(),
        userId: userId,
      );
      _semua.add(surat);
      await _simpan();
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('tambahSurat error: $e');
      return false;
    }
  }

  Future<bool> editSurat({
    required String id,
    required String jenisSurat,
    required String keperluan,
    required String keterangan,
  }) async {
    try {
      final idx = _semua.indexWhere((s) => s.id == id);
      if (idx == -1) return false;
      _semua[idx] = _semua[idx].copyWith(
        jenisSurat: jenisSurat,
        keperluan: keperluan,
        keterangan: keterangan,
      );
      await _simpan();
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('editSurat error: $e');
      return false;
    }
  }

  Future<bool> updateStatus(String id, String statusBaru) async {
    try {
      final idx = _semua.indexWhere((s) => s.id == id);
      if (idx == -1) return false;
      _semua[idx] = _semua[idx].copyWith(status: statusBaru);
      await _simpan();
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('updateStatus error: $e');
      return false;
    }
  }

  Future<bool> hapusSurat(String id) async {
    try {
      _semua.removeWhere((s) => s.id == id);
      await _simpan();
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('hapusSurat error: $e');
      return false;
    }
  }

  SuratModel? cariById(String id) {
    try {
      return _semua.firstWhere((s) => s.id == id);
    } catch (_) {
      return null;
    }
  }

  // ── filter & search ────────────────────────────────────────────────────────
  void setQuery(String q) {
    _query = q;
    notifyListeners();
  }

  void setFilter(String status) {
    _filterStatus = status;
    notifyListeners();
  }

  void resetFilter() {
    _query = '';
    _filterStatus = 'Semua';
    notifyListeners();
  }
}
