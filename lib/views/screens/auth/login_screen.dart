// lib/views/screens/auth/login_screen.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../controllers/auth_controller.dart';
import '../../../controllers/surat_controller.dart';
import '../../../controllers/informasi_controller.dart';
import '../../../utils/app_constants.dart';
import 'register_screen.dart';
import '../admin/admin_home_screen.dart';
import '../superadmin/superadmin_home_screen.dart';
import '../user/user_home_screen.dart';

class LoginScreen extends StatefulWidget {
  final AuthController authController;
  final SuratController suratController;
  final InformasiController informasiController;

  const LoginScreen({
    super.key,
    required this.authController,
    required this.suratController,
    required this.informasiController,
  });

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _usernameCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _obscurePassword = true;
  String? _errorMsg;
  late AnimationController _animCtrl;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnim = CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animCtrl, curve: Curves.easeOutCubic));
    _animCtrl.forward();
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    _usernameCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _doLogin() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _errorMsg = null);

    final error = await widget.authController.login(
      _usernameCtrl.text,
      _passwordCtrl.text,
    );

    if (!mounted) return;

    if (error != null) {
      setState(() => _errorMsg = error);
      return;
    }

    await widget.suratController.loadData();
    if (!mounted) return;

    final role = widget.authController.role;
    Widget nextScreen;
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

    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => nextScreen,
        transitionsBuilder: (_, anim, __, child) => FadeTransition(
          opacity: anim,
          child: child,
        ),
        transitionDuration: const Duration(milliseconds: 400),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: AppConstants.backgroundColor,
      body: Stack(
        children: [
          // ── Background Image ──
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: size.height * 0.4, // Hanya memenuhi 40% layar atas
            child: Image.asset(
              'assets/images/login_bg.png',
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) =>
                  Container(color: AppConstants.primaryDark),
            ),
          ),
          // ── Overlay Gradient ──
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.black.withValues(alpha: 0.6),
                    Colors.black.withValues(alpha: 0.1),
                    Colors.transparent,
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ),

          // ── Logo & Welcome Text (Top Part) ──
          Positioned(
            top: size.height * 0.1,
            left: 0,
            right: 0,
            child: FadeTransition(
              opacity: _fadeAnim,
              child: Column(
                children: [
                  Container(
                    width: 90,
                    height: 90,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withValues(alpha: 0.2),
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Image.asset(
                        'assets/images/logo_katingan.png',
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) =>
                            const Icon(Icons.eco_rounded,
                                color: Colors.white, size: 36),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Welcome to Kasongan',
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Bottom Sheet Form ──
          Align(
            alignment: Alignment.bottomCenter,
            child: SlideTransition(
              position: _slideAnim,
              child: Container(
                width: double.infinity,
                height: size.height * 0.65,
                decoration: const BoxDecoration(
                  color: AppConstants.surfaceColor,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(36),
                    topRight: Radius.circular(36),
                  ),
                ),
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 16),
                          // Indicator pill
                          Center(
                            child: Container(
                              width: 40,
                              height: 4,
                              decoration: BoxDecoration(
                                color: const Color(0xFFE5E5EA),
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                          // Login Title
                          Text(
                            'Login',
                            style: GoogleFonts.poppins(
                              color: AppConstants.textPrimary,
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Silakan masuk untuk melanjutkan',
                            style: GoogleFonts.poppins(
                              color: AppConstants.textSecondary,
                              fontSize: 13,
                            ),
                          ),
                          const SizedBox(height: 32),

                          // Error Message
                          if (_errorMsg != null)
                            Container(
                              padding: const EdgeInsets.all(12),
                              margin: const EdgeInsets.only(bottom: 16),
                              decoration: BoxDecoration(
                                color: AppConstants.errorColor
                                    .withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                    color: AppConstants.errorColor
                                        .withValues(alpha: 0.3)),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.error_outline,
                                      color: AppConstants.errorColor, size: 20),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      _errorMsg!,
                                      style: GoogleFonts.poppins(
                                        color: AppConstants.errorColor,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                          // Username Field
                          Text(
                            'Email or Username',
                            style: GoogleFonts.poppins(
                              color: AppConstants.textPrimary,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _usernameCtrl,
                            style: GoogleFonts.poppins(
                                fontSize: 14, color: AppConstants.textPrimary),
                            decoration: _inputDecoration(
                                'Enter your email', Icons.mail_outline_rounded),
                            validator: (v) => v!.isEmpty
                                ? 'Username tidak boleh kosong'
                                : null,
                          ),
                          const SizedBox(height: 20),

                          // Password Field
                          Text(
                            'Password',
                            style: GoogleFonts.poppins(
                              color: AppConstants.textPrimary,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _passwordCtrl,
                            obscureText: _obscurePassword,
                            style: GoogleFonts.poppins(
                                fontSize: 14, color: AppConstants.textPrimary),
                            decoration: _inputDecoration('Enter your password',
                                    Icons.lock_outline_rounded)
                                .copyWith(
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscurePassword
                                      ? Icons.visibility_off_outlined
                                      : Icons.visibility_outlined,
                                  color: const Color(0xFFC7C7CC),
                                  size: 20,
                                ),
                                onPressed: () => setState(
                                    () => _obscurePassword = !_obscurePassword),
                              ),
                            ),
                            validator: (v) => v!.isEmpty
                                ? 'Password tidak boleh kosong'
                                : null,
                          ),
                          const SizedBox(height: 32),

                          // Sign In Button
                          SizedBox(
                            width: double.infinity,
                            height: 54,
                            child: ElevatedButton(
                              onPressed: widget.authController.loading
                                  ? null
                                  : _doLogin,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppConstants.primaryColor,
                                foregroundColor: Colors.white,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                              child: widget.authController.loading
                                  ? const SizedBox(
                                      width: 24,
                                      height: 24,
                                      child: CircularProgressIndicator(
                                          color: Colors.white, strokeWidth: 2))
                                  : Text(
                                      'Sign In',
                                      style: GoogleFonts.poppins(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Register Link
                          Center(
                            child: GestureDetector(
                              onTap: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => RegisterScreen(
                                      authController: widget.authController,
                                    ),
                                  ),
                                );
                              },
                              child: RichText(
                                text: TextSpan(
                                  text: 'Don\'t have an account? ',
                                  style: GoogleFonts.poppins(
                                      color: AppConstants.textSecondary,
                                      fontSize: 13),
                                  children: [
                                    TextSpan(
                                      text: 'Register',
                                      style: GoogleFonts.poppins(
                                        color: AppConstants.primaryColor,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 32),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  InputDecoration _inputDecoration(String hint, IconData icon) {
    return InputDecoration(
      hintText: hint,
      hintStyle:
          GoogleFonts.poppins(color: const Color(0xFFC7C7CC), fontSize: 13),
      prefixIcon: Icon(icon, color: const Color(0xFFC7C7CC), size: 20),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFE5E5EA), width: 1.5),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide:
            const BorderSide(color: AppConstants.primaryColor, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide:
            const BorderSide(color: AppConstants.errorColor, width: 1.5),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppConstants.errorColor, width: 2),
      ),
    );
  }
}
