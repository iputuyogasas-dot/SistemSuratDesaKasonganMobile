// lib/controllers/auth_controller.dart

import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import '../utils/app_constants.dart';

class AuthController extends ChangeNotifier {
  UserModel? _currentUser;
  bool _loading = false;

  UserModel? get currentUser => _currentUser;
  bool get loading => _loading;
  bool get isLoggedIn => _currentUser != null;
  String get role => _currentUser?.role ?? '';
  String get userId => _currentUser?.id ?? '';
  String get namaLengkap => _currentUser?.namaLengkap ?? '';
  bool get isUser => role == AppConstants.roleUser;
  bool get isAdmin => role == AppConstants.roleAdmin;
  bool get isSuperAdmin => role == AppConstants.roleSuperAdmin;


  // ── Inisialisasi akun default jika belum ada ───────────────────────────────
  Future<void> _ensureDefaultAccounts(SharedPreferences prefs) async {
    final raw = prefs.getString(AppConstants.keyDaftarUser);
    List<UserModel> users = [];

    if (raw != null) {
      final list = json.decode(raw) as List<dynamic>;
      users = list.map((e) => UserModel.fromMap(e as Map<String, dynamic>)).toList();
    }

    // Pastikan akun default selalu ada
    for (final def in AppConstants.defaultAccounts) {
      final exists = users.any((u) => u.id == def['id']);
      if (!exists) {
        users.add(UserModel.fromMap(def));
      }
    }

    await prefs.setString(
      AppConstants.keyDaftarUser,
      json.encode(users.map((u) => u.toMap()).toList()),
    );
  }

  // ── Cek session saat app dibuka ────────────────────────────────────────────
  Future<bool> checkSession() async {
    final prefs = await SharedPreferences.getInstance();
    await _ensureDefaultAccounts(prefs);

    final userId = prefs.getString(AppConstants.keySessionUserId);
    if (userId == null) return false;

    final raw = prefs.getString(AppConstants.keyDaftarUser);
    if (raw == null) return false;

    final list = json.decode(raw) as List<dynamic>;
    final users = list.map((e) => UserModel.fromMap(e as Map<String, dynamic>)).toList();

    try {
      _currentUser = users.firstWhere((u) => u.id == userId);
      notifyListeners();
      return true;
    } catch (_) {
      return false;
    }
  }

  // ── Login ──────────────────────────────────────────────────────────────────
  Future<String?> login(String username, String password) async {
    _loading = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      await _ensureDefaultAccounts(prefs);

      final raw = prefs.getString(AppConstants.keyDaftarUser);
      if (raw == null) {
        _loading = false;
        notifyListeners();
        return 'Data pengguna tidak ditemukan';
      }

      final list = json.decode(raw) as List<dynamic>;
      final users = list.map((e) => UserModel.fromMap(e as Map<String, dynamic>)).toList();

      try {
        final user = users.firstWhere(
          (u) => u.username.toLowerCase() == username.toLowerCase().trim() &&
              u.password == password,
        );
        _currentUser = user;
        await prefs.setString(AppConstants.keySessionUserId, user.id);
        _loading = false;
        notifyListeners();
        return null; // null = sukses
      } catch (_) {
        _loading = false;
        notifyListeners();
        return 'Username atau password salah';
      }
    } catch (e) {
      _loading = false;
      notifyListeners();
      return 'Terjadi kesalahan: $e';
    }
  }

  // ── Register ───────────────────────────────────────────────────────────────
  Future<String?> register({
    required String username,
    required String password,
    required String namaLengkap,
  }) async {
    _loading = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      await _ensureDefaultAccounts(prefs);

      final raw = prefs.getString(AppConstants.keyDaftarUser);
      List<UserModel> users = [];
      if (raw != null) {
        final list = json.decode(raw) as List<dynamic>;
        users = list.map((e) => UserModel.fromMap(e as Map<String, dynamic>)).toList();
      }

      // Cek username sudah ada
      final usernameExist = users.any(
        (u) => u.username.toLowerCase() == username.toLowerCase().trim(),
      );
      if (usernameExist) {
        _loading = false;
        notifyListeners();
        return 'Username sudah digunakan';
      }

      final newUser = UserModel(
        id: 'usr-${DateTime.now().millisecondsSinceEpoch}',
        username: username.trim(),
        password: password,
        role: AppConstants.roleUser,
        namaLengkap: namaLengkap.trim(),
      );

      users.add(newUser);
      await prefs.setString(
        AppConstants.keyDaftarUser,
        json.encode(users.map((u) => u.toMap()).toList()),
      );

      _loading = false;
      notifyListeners();
      return null; // null = sukses
    } catch (e) {
      _loading = false;
      notifyListeners();
      return 'Terjadi kesalahan: $e';
    }
  }

  // ── Logout ─────────────────────────────────────────────────────────────────
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(AppConstants.keySessionUserId);
    _currentUser = null;
    notifyListeners();
  }

  // ── Ambil semua user (untuk SuperAdmin) ────────────────────────────────────
  Future<List<UserModel>> getAllUsers() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(AppConstants.keyDaftarUser);
    if (raw == null) return [];
    final list = json.decode(raw) as List<dynamic>;
    return list.map((e) => UserModel.fromMap(e as Map<String, dynamic>)).toList();
  }

  // ── Hapus user (SuperAdmin only) ───────────────────────────────────────────
  Future<bool> hapusUser(String userId) async {
    // Akun default tidak bisa dihapus
    final isDefault = AppConstants.defaultAccounts.any((a) => a['id'] == userId);
    if (isDefault) return false;

    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(AppConstants.keyDaftarUser);
    if (raw == null) return false;

    final list = json.decode(raw) as List<dynamic>;
    var users = list.map((e) => UserModel.fromMap(e as Map<String, dynamic>)).toList();
    users.removeWhere((u) => u.id == userId);

    await prefs.setString(
      AppConstants.keyDaftarUser,
      json.encode(users.map((u) => u.toMap()).toList()),
    );
    notifyListeners();
    return true;
  }

  // ── Reset password user (SuperAdmin only) ─────────────────────────────────
  Future<bool> resetPassword(String userId, String newPassword) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(AppConstants.keyDaftarUser);
    if (raw == null) return false;

    final list = json.decode(raw) as List<dynamic>;
    var users = list.map((e) => UserModel.fromMap(e as Map<String, dynamic>)).toList();
    final idx = users.indexWhere((u) => u.id == userId);
    if (idx == -1) return false;

    users[idx] = users[idx].copyWith(password: newPassword);
    await prefs.setString(
      AppConstants.keyDaftarUser,
      json.encode(users.map((u) => u.toMap()).toList()),
    );
    notifyListeners();
    return true;
  }
}
