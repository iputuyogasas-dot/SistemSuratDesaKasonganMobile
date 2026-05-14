// lib/views/screens/user/user_tambah_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../controllers/surat_controller.dart';
import '../../../utils/app_constants.dart';

class UserTambahScreen extends StatefulWidget {
  final SuratController suratController;
  final String userId;

  const UserTambahScreen({
    super.key,
    required this.suratController,
    required this.userId,
  });

  @override
  State<UserTambahScreen> createState() => _UserTambahScreenState();
}

class _UserTambahScreenState extends State<UserTambahScreen> {
  final _formKey = GlobalKey<FormState>();
  final _namaCtrl = TextEditingController();
  final _nikCtrl = TextEditingController();
  final _keperluanCtrl = TextEditingController();
  final _keteranganCtrl = TextEditingController();
  String? _jenisSurat;
  bool _loading = false;

  @override
  void dispose() {
    _namaCtrl.dispose();
    _nikCtrl.dispose();
    _keperluanCtrl.dispose();
    _keteranganCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);

    final ok = await widget.suratController.tambahSurat(
      jenisSurat: _jenisSurat!,
      namaPemohon: _namaCtrl.text.trim(),
      nik: _nikCtrl.text.trim(),
      keperluan: _keperluanCtrl.text.trim(),
      keterangan: _keteranganCtrl.text.trim(),
      userId: widget.userId,
    );

    if (!mounted) return;
    setState(() => _loading = false);

    if (ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle_rounded, color: AppConstants.surfaceColor),
              const SizedBox(width: 8),
              Text('Surat berhasil diajukan!',
                  style: GoogleFonts.poppins(color: AppConstants.surfaceColor)),
            ],
          ),
          backgroundColor: AppConstants.successColor,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      Navigator.of(context).pop();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal mengajukan surat',
              style: GoogleFonts.poppins(color: AppConstants.surfaceColor)),
          backgroundColor: AppConstants.errorColor,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstants.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppConstants.primaryDark,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close_rounded, color: AppConstants.surfaceColor),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text('Ajukan Surat',
            style: GoogleFonts.poppins(
                color: AppConstants.surfaceColor, fontWeight: FontWeight.w600)),
        flexibleSpace: Container(
          decoration: const BoxDecoration(gradient: AppConstants.primaryGradient),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _section('Informasi Pemohon'),
              const SizedBox(height: 12),
              _field(
                label: 'Nama Lengkap',
                controller: _namaCtrl,
                hint: 'Masukkan nama lengkap',
                icon: Icons.person_outline_rounded,
                validator: (v) {
                  if (v == null || v.trim().length < 3) {
                    return 'Nama minimal 3 karakter';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 14),
              _field(
                label: 'NIK',
                controller: _nikCtrl,
                hint: '16 digit NIK',
                icon: Icons.badge_outlined,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                validator: (v) {
                  if (v == null || v.length != 16) {
                    return 'NIK harus 16 digit';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),

              _section('Detail Surat'),
              const SizedBox(height: 12),

              // Jenis Surat dropdown
              _buildLabel('Jenis Surat'),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _jenisSurat,
                dropdownColor: AppConstants.surfaceColor,
                style: GoogleFonts.poppins(
                    color: AppConstants.textPrimary, fontSize: 14),
                icon: const Icon(Icons.keyboard_arrow_down_rounded,
                    color: AppConstants.textSecondary),
                decoration: InputDecoration(
                  hintText: 'Pilih jenis surat',
                  hintStyle: GoogleFonts.poppins(
                      color: AppConstants.textSecondary.withValues(alpha: 0.6),
                      fontSize: 14),
                  prefixIcon: const Icon(Icons.description_outlined,
                      color: AppConstants.textSecondary, size: 20),
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
                    borderSide:
                        BorderSide(color: AppConstants.primaryColor, width: 1.5),
                  ),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                ),
                items: AppConstants.jenisSuratList
                    .map((j) => DropdownMenuItem(
                          value: j,
                          child: Text(j,
                              style: GoogleFonts.poppins(
                                  color: AppConstants.textPrimary,
                                  fontSize: 13)),
                        ))
                    .toList(),
                onChanged: (v) => setState(() => _jenisSurat = v),
                validator: (v) =>
                    v == null ? 'Pilih jenis surat terlebih dahulu' : null,
              ),
              const SizedBox(height: 14),

              _field(
                label: 'Keperluan',
                controller: _keperluanCtrl,
                hint: 'Jelaskan keperluan surat (min. 10 karakter)',
                icon: Icons.article_outlined,
                maxLines: 3,
                validator: (v) {
                  if (v == null || v.trim().length < 10) {
                    return 'Keperluan minimal 10 karakter';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 14),

              _field(
                label: 'Keterangan (Opsional)',
                controller: _keteranganCtrl,
                hint: 'Tambahan keterangan jika diperlukan',
                icon: Icons.notes_rounded,
                maxLines: 2,
              ),
              const SizedBox(height: 32),

              // Tombol Submit
              SizedBox(
                width: double.infinity,
                height: 52,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: AppConstants.primaryGradient,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: AppConstants.primaryColor.withValues(alpha: 0.4),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ElevatedButton(
                    onPressed: _loading ? null : _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                    ),
                    child: _loading
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                                color: AppConstants.surfaceColor, strokeWidth: 2.5),
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.send_rounded,
                                  color: AppConstants.surfaceColor, size: 18),
                              const SizedBox(width: 8),
                              Text('Ajukan Surat',
                                  style: GoogleFonts.poppins(
                                      color: AppConstants.surfaceColor,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 16)),
                            ],
                          ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _section(String title) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 18,
          decoration: BoxDecoration(
            gradient: AppConstants.primaryGradient,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 10),
        Text(title,
            style: GoogleFonts.poppins(
              color: AppConstants.textPrimary,
              fontWeight: FontWeight.w600,
              fontSize: 15,
            )),
      ],
    );
  }

  Widget _buildLabel(String text) => Text(
        text,
        style: GoogleFonts.poppins(
          color: AppConstants.textSecondary,
          fontSize: 13,
          fontWeight: FontWeight.w500,
        ),
      );

  Widget _field({
    required String label,
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    int maxLines = 1,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel(label),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          style: GoogleFonts.poppins(
              color: AppConstants.textPrimary, fontSize: 14),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: GoogleFonts.poppins(
                color: AppConstants.textSecondary.withValues(alpha: 0.6),
                fontSize: 13),
            prefixIcon: Icon(icon,
                color: AppConstants.textSecondary, size: 20),
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
              borderSide:
                  BorderSide(color: AppConstants.primaryColor, width: 1.5),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppConstants.errorColor),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide:
                  BorderSide(color: AppConstants.errorColor, width: 1.5),
            ),
            errorStyle: GoogleFonts.poppins(
                color: AppConstants.errorColor, fontSize: 12),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
          validator: validator,
        ),
      ],
    );
  }
}
