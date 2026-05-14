// lib/views/screens/auth/register_screen.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../controllers/auth_controller.dart';
import '../../../utils/app_constants.dart';

class RegisterScreen extends StatefulWidget {
  final AuthController authController;

  const RegisterScreen({super.key, required this.authController});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _namaCtrl = TextEditingController();
  final _usernameCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _konfirmasiCtrl = TextEditingController();
  bool _obscurePass = true;
  bool _obscureKonfirmasi = true;
  String? _errorMsg;

  late AnimationController _animCtrl;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnim = CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animCtrl, curve: Curves.easeOutCubic));
    _animCtrl.forward();
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    _namaCtrl.dispose();
    _usernameCtrl.dispose();
    _passwordCtrl.dispose();
    _konfirmasiCtrl.dispose();
    super.dispose();
  }

  Future<void> _doRegister() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _errorMsg = null);

    final error = await widget.authController.register(
      username: _usernameCtrl.text,
      password: _passwordCtrl.text,
      namaLengkap: _namaCtrl.text,
    );

    if (!mounted) return;

    if (error != null) {
      setState(() => _errorMsg = error);
      return;
    }

    // Sukses → kembali ke login dengan notifikasi
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_rounded,
                color: AppConstants.surfaceColor),
            const SizedBox(width: 8),
            Text(
              'Akun berhasil dibuat! Silakan login.',
              style: GoogleFonts.poppins(color: AppConstants.surfaceColor),
            ),
          ],
        ),
        backgroundColor: AppConstants.successColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstants.backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: AppConstants.textPrimary, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Buat Akun',
          style: GoogleFonts.poppins(
              color: AppConstants.textPrimary, fontWeight: FontWeight.w600),
        ),
      ),
      body: FadeTransition(
        opacity: _fadeAnim,
        child: SlideTransition(
          position: _slideAnim,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                // Info banner
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppConstants.primaryColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                        color:
                            AppConstants.primaryColor.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline_rounded,
                          color: AppConstants.primaryColor, size: 18),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Akun yang dibuat memiliki akses sebagai Warga (User)',
                          style: GoogleFonts.poppins(
                            color: AppConstants.primaryColor,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Form Card
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: AppConstants.surfaceColor,
                    borderRadius: BorderRadius.circular(20),
                    border:
                        Border.all(color: AppConstants.surfaceLight, width: 1),
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildLabel('Nama Lengkap'),
                        const SizedBox(height: 8),
                        _buildTextField(
                          controller: _namaCtrl,
                          hint: 'Masukkan nama lengkap',
                          icon: Icons.badge_outlined,
                          validator: (v) {
                            if (v == null || v.trim().length < 3) {
                              return 'Nama minimal 3 karakter';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        _buildLabel('Username'),
                        const SizedBox(height: 8),
                        _buildTextField(
                          controller: _usernameCtrl,
                          hint: 'Buat username unik',
                          icon: Icons.person_outline_rounded,
                          validator: (v) {
                            if (v == null || v.trim().length < 4) {
                              return 'Username minimal 4 karakter';
                            }
                            if (v.contains(' ')) {
                              return 'Username tidak boleh mengandung spasi';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        _buildLabel('Password'),
                        const SizedBox(height: 8),
                        _buildTextField(
                          controller: _passwordCtrl,
                          hint: 'Buat password (min. 6 karakter)',
                          icon: Icons.lock_outline_rounded,
                          obscure: _obscurePass,
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePass
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off_outlined,
                              color: AppConstants.textSecondary,
                              size: 20,
                            ),
                            onPressed: () =>
                                setState(() => _obscurePass = !_obscurePass),
                          ),
                          validator: (v) {
                            if (v == null || v.length < 6) {
                              return 'Password minimal 6 karakter';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        _buildLabel('Konfirmasi Password'),
                        const SizedBox(height: 8),
                        _buildTextField(
                          controller: _konfirmasiCtrl,
                          hint: 'Ulangi password',
                          icon: Icons.lock_reset_outlined,
                          obscure: _obscureKonfirmasi,
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscureKonfirmasi
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off_outlined,
                              color: AppConstants.textSecondary,
                              size: 20,
                            ),
                            onPressed: () => setState(
                                () => _obscureKonfirmasi = !_obscureKonfirmasi),
                          ),
                          validator: (v) {
                            if (v != _passwordCtrl.text) {
                              return 'Password tidak cocok';
                            }
                            return null;
                          },
                        ),
                        if (_errorMsg != null) ...[
                          const SizedBox(height: 16),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppConstants.errorColor
                                  .withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                  color: AppConstants.errorColor
                                      .withValues(alpha: 0.4)),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.error_outline,
                                    color: AppConstants.errorColor, size: 18),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    _errorMsg!,
                                    style: GoogleFonts.poppins(
                                      color: AppConstants.errorColor,
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                        const SizedBox(height: 24),
                        ListenableBuilder(
                          listenable: widget.authController,
                          builder: (_, __) => SizedBox(
                            width: double.infinity,
                            height: 52,
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                gradient: AppConstants.primaryGradient,
                                borderRadius: BorderRadius.circular(14),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppConstants.primaryColor
                                        .withValues(alpha: 0.4),
                                    blurRadius: 12,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: ElevatedButton(
                                onPressed: widget.authController.loading
                                    ? null
                                    : _doRegister,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.transparent,
                                  shadowColor: Colors.transparent,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                ),
                                child: widget.authController.loading
                                    ? const SizedBox(
                                        width: 22,
                                        height: 22,
                                        child: CircularProgressIndicator(
                                          color: AppConstants.surfaceColor,
                                          strokeWidth: 2.5,
                                        ),
                                      )
                                    : Text(
                                        'Buat Akun',
                                        style: GoogleFonts.poppins(
                                          color: AppConstants.surfaceColor,
                                          fontWeight: FontWeight.w600,
                                          fontSize: 16,
                                        ),
                                      ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) => Padding(
        padding: const EdgeInsets.only(bottom: 0),
        child: Text(
          text,
          style: GoogleFonts.poppins(
            color: AppConstants.textSecondary,
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
      );

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool obscure = false,
    Widget? suffixIcon,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      style: GoogleFonts.poppins(color: AppConstants.textPrimary, fontSize: 14),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: GoogleFonts.poppins(
            color: AppConstants.textSecondary.withValues(alpha: 0.6),
            fontSize: 13),
        prefixIcon: Icon(icon, color: AppConstants.textSecondary, size: 20),
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: AppConstants.surfaceLight.withValues(alpha: 0.5),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppConstants.surfaceLight),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppConstants.surfaceLight),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppConstants.primaryColor, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppConstants.errorColor),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppConstants.errorColor, width: 1.5),
        ),
        errorStyle:
            GoogleFonts.poppins(color: AppConstants.errorColor, fontSize: 12),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      validator: validator,
    );
  }
}
