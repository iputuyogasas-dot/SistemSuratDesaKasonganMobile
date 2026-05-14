// lib/views/screens/informasi/tambah_informasi_screen.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../controllers/informasi_controller.dart';
import '../../../models/informasi_model.dart';
import '../../../utils/app_constants.dart';

class TambahInformasiScreen extends StatefulWidget {
  final InformasiController informasiController;
  final String namaAdmin;

  const TambahInformasiScreen({
    super.key,
    required this.informasiController,
    required this.namaAdmin,
  });

  @override
  State<TambahInformasiScreen> createState() => _TambahInformasiScreenState();
}

class _TambahInformasiScreenState extends State<TambahInformasiScreen> {
  final _formKey = GlobalKey<FormState>();
  final _judulCtrl = TextEditingController();
  final _isiCtrl = TextEditingController();
  String _tipe = 'Pengumuman';
  String _kategori = 'Umum';
  bool _loading = false;

  @override
  void dispose() {
    _judulCtrl.dispose();
    _isiCtrl.dispose();
    super.dispose();
  }

  Future<void> _simpan() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);

    final item = InformasiModel(
      id: 'info-${DateTime.now().millisecondsSinceEpoch}',
      judul: _judulCtrl.text.trim(),
      isi: _isiCtrl.text.trim(),
      tipe: _tipe,
      kategori: _kategori,
      tanggal: DateTime.now(),
      dibuatOleh: widget.namaAdmin,
    );

    await widget.informasiController.tambahInformasi(item);
    setState(() => _loading = false);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '$_tipe berhasil ditambahkan!',
            style: GoogleFonts.poppins(color: Colors.white),
          ),
          backgroundColor: AppConstants.primaryColor,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstants.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppConstants.primaryColor,
        title: Text(
          'Tambah Informasi',
          style: GoogleFonts.poppins(
              color: Colors.white, fontWeight: FontWeight.bold, fontSize: 17),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Pilih Tipe ────────────────────────────────────────────
              _label('Tipe Informasi'),
              const SizedBox(height: 8),
              Row(
                children: AppConstants.tipeInformasiList.map((t) {
                  final selected = _tipe == t;
                  final color = AppConstants.tipeColor(t);
                  return Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _tipe = t),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        margin: const EdgeInsets.only(right: 10),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: selected ? color : Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: selected
                                ? color
                                : AppConstants.surfaceLight,
                            width: selected ? 2 : 1,
                          ),
                          boxShadow: selected
                              ? [
                                  BoxShadow(
                                    color: color.withValues(alpha: 0.3),
                                    blurRadius: 8,
                                    offset: const Offset(0, 3),
                                  )
                                ]
                              : [],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              AppConstants.tipeIcon(t),
                              color: selected ? Colors.white : color,
                              size: 18,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              t,
                              style: GoogleFonts.poppins(
                                color: selected ? Colors.white : AppConstants.textPrimary,
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),

              // ── Pilih Kategori ─────────────────────────────────────────
              _label('Kategori'),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: AppConstants.kategoriInformasiList.map((k) {
                  final selected = _kategori == k;
                  final color = AppConstants.kategoriColor(k);
                  return GestureDetector(
                    onTap: () => setState(() => _kategori = k),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: selected
                            ? color.withValues(alpha: 0.15)
                            : Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: selected ? color : AppConstants.surfaceLight,
                          width: selected ? 1.5 : 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(AppConstants.kategoriIcon(k),
                              size: 14, color: color),
                          const SizedBox(width: 5),
                          Text(
                            k,
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: selected
                                  ? color
                                  : AppConstants.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),

              // ── Judul ─────────────────────────────────────────────────
              _label('Judul'),
              const SizedBox(height: 8),
              TextFormField(
                controller: _judulCtrl,
                style: GoogleFonts.poppins(fontSize: 14),
                decoration: _inputDeco('Masukkan judul informasi...'),
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? 'Judul tidak boleh kosong'
                    : null,
              ),
              const SizedBox(height: 20),

              // ── Isi / Deskripsi ───────────────────────────────────────
              _label('Isi / Deskripsi'),
              const SizedBox(height: 8),
              TextFormField(
                controller: _isiCtrl,
                style: GoogleFonts.poppins(fontSize: 14),
                decoration: _inputDeco('Tulis isi informasi secara lengkap...'),
                maxLines: 6,
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? 'Isi tidak boleh kosong'
                    : null,
              ),
              const SizedBox(height: 32),

              // ── Tombol Simpan ─────────────────────────────────────────
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _loading ? null : _simpan,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppConstants.primaryColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                    elevation: 0,
                  ),
                  child: _loading
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2.5),
                        )
                      : Text(
                          'Simpan Informasi',
                          style: GoogleFonts.poppins(
                              fontWeight: FontWeight.bold, fontSize: 15),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _label(String text) => Text(
        text,
        style: GoogleFonts.poppins(
          fontWeight: FontWeight.w600,
          fontSize: 13,
          color: AppConstants.textPrimary,
        ),
      );

  InputDecoration _inputDeco(String hint) => InputDecoration(
        hintText: hint,
        hintStyle: GoogleFonts.poppins(
            color: AppConstants.textSecondary, fontSize: 13),
        filled: true,
        fillColor: Colors.white,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppConstants.surfaceLight),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppConstants.surfaceLight),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide:
              const BorderSide(color: AppConstants.primaryColor, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide:
              const BorderSide(color: AppConstants.errorColor, width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide:
              const BorderSide(color: AppConstants.errorColor, width: 1.5),
        ),
      );
}
