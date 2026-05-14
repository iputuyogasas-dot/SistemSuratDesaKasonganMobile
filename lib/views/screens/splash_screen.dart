// lib/views/screens/splash_screen.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/surat_controller.dart';
import '../../controllers/informasi_controller.dart';
import '../../utils/app_constants.dart';
import 'auth/login_screen.dart';
import 'admin/admin_home_screen.dart';
import 'superadmin/superadmin_home_screen.dart';
import 'user/user_home_screen.dart';

class SplashScreen extends StatefulWidget {
  final AuthController authController;
  final SuratController suratController;
  final InformasiController informasiController;
  const SplashScreen({
    super.key,
    required this.authController,
    required this.suratController,
    required this.informasiController,
  });

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _anim;
  late final Animation<double> _fade;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _anim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..forward();

    _fade = CurvedAnimation(parent: _anim, curve: Curves.easeIn);
    _scale = Tween<double>(begin: 0.75, end: 1.0).animate(
      CurvedAnimation(parent: _anim, curve: Curves.elasticOut),
    );

    _init();
  }

  Future<void> _init() async {
    // Tunggu sedikit untuk efek visual
    await Future.delayed(const Duration(milliseconds: 2000));

    // Cek session login
    final isLoggedIn = await widget.authController.checkSession();

    // Jika login, sekalian load data surat
    if (isLoggedIn) {
      await widget.suratController.loadData();
    }

    if (!mounted) return;

    Widget nextScreen;
    if (isLoggedIn) {
      final role = widget.authController.role;
      if (role == AppConstants.roleSuperAdmin) {
        nextScreen = SuperAdminHomeScreen(
          authController: widget.authController,
          suratController: widget.suratController,
          informasiController: widget.informasiController,
        );
      } else if (role == AppConstants.roleAdmin) {
        nextScreen = AdminHomeScreen(
          authController: widget.authController,
          suratController: widget.suratController,
          informasiController: widget.informasiController,
        );
      } else {
        nextScreen = UserHomeScreen(
          authController: widget.authController,
          suratController: widget.suratController,
          informasiController: widget.informasiController,
        );
      }
    } else {
      nextScreen = LoginScreen(
        authController: widget.authController,
        suratController: widget.suratController,
        informasiController: widget.informasiController,
      );
    }

    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => nextScreen,
        transitionsBuilder: (_, anim, __, child) => FadeTransition(
          opacity: anim,
          child: child,
        ),
        transitionDuration: const Duration(milliseconds: 500),
      ),
    );
  }

  @override
  void dispose() {
    _anim.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppConstants.bgGradient,
        ),
        child: SafeArea(
          child: Center(
            child: FadeTransition(
              opacity: _fade,
              child: ScaleTransition(
                scale: _scale,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // logo
                    Image.asset(
                      'assets/images/logo_katingan.png',
                      width: 100,
                      height: 100,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) => const Icon(
                          Icons.account_balance,
                          size: 100,
                          color: AppConstants.primaryColor),
                    ),
                    const SizedBox(height: 28),
                    Text(
                      'DESA KASONGAN',
                      style: GoogleFonts.poppins(
                        color: AppConstants.primaryColor,
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 5),
                      decoration: BoxDecoration(
                        color: AppConstants.primaryColor.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color:
                              AppConstants.primaryColor.withValues(alpha: 0.5),
                        ),
                      ),
                      child: Text(
                        'Sistem Pengelolaan Surat',
                        style: GoogleFonts.poppins(
                          color: AppConstants.primaryColor,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Kec. Kasongan  •  Kab. Katingan\nKalimantan Tengah',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                          color: AppConstants.textSecondary, fontSize: 12),
                    ),
                    const SizedBox(height: 48),
                    const SizedBox(
                      width: 32,
                      height: 32,
                      child: CircularProgressIndicator(
                          color: AppConstants.primaryColor, strokeWidth: 2.5),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
