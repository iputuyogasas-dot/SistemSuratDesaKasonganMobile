// lib/views/screens/superadmin/superadmin_home_screen.dart

import 'package:flutter/material.dart';
import '../../../controllers/auth_controller.dart';
import '../../../controllers/surat_controller.dart';
import '../../../controllers/informasi_controller.dart';
import '../admin/admin_home_screen.dart';

/// SuperAdmin menggunakan tampilan yang sama dengan Admin
/// tapi dengan akses tab Kelola User.
/// Cukup redirect ke AdminHomeScreen karena sudah handle isSuperAdmin.
class SuperAdminHomeScreen extends StatelessWidget {
  final AuthController authController;
  final SuratController suratController;
  final InformasiController informasiController;

  const SuperAdminHomeScreen({
    super.key,
    required this.authController,
    required this.suratController,
    required this.informasiController,
  });

  @override
  Widget build(BuildContext context) {
    return AdminHomeScreen(
      authController: authController,
      suratController: suratController,
      informasiController: informasiController,
    );
  }
}

