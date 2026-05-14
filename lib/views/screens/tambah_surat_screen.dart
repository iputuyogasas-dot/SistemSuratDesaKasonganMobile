// lib/views/screens/tambah_surat_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../controllers/surat_controller.dart';
import '../../utils/app_constants.dart';

class TambahSuratScreen extends StatefulWidget {
  final SuratController controller;
  final String userId; // ← ID user yang sedang login
  const TambahSuratScreen({super.key, required this.controller, required this.userId});

  @override
  State<TambahSuratScreen> createState() => _TambahSuratScreenState();
}

class _TambahSuratScreenState extends State<TambahSuratScreen> {
  final _formKey = GlobalKey<FormState>();
  final _namaCtrl = TextEditingController();
  final _nikCtrl = TextEditingController();
  final _keperluanCtrl = TextEditingController();
  final _keteranganCtrl = TextEditingController();
  String? _jenisSurat;
  bool _saving = false;

  @override
  void dispose() {
    _namaCtrl.dispose();
    _nikCtrl.dispose();
    _keperluanCtrl.dispose();
    _keteranganCtrl.dispose();
    super.dispose();
  }

  Future<void> _simpan() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _saving = true);
    final ok = await widget.controller.tambahSurat(
      jenisSurat: _jenisSurat!,
      namaPemohon: _namaCtrl.text.trim(),
      nik: _nikCtrl.text.trim(),
      keperluan: _keperluanCtrl.text.trim(),
      keterangan: _keteranganCtrl.text.trim(),
      userId: widget.userId,
    );
    setState(() => _saving = false);

    if (!mounted) return;
    if (ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Surat berhasil diajukan!'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Gagal menyimpan, coba lagi.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // ── build ──────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstants.backgroundColor,
      appBar: AppBar(
        title: const Text('Pengajuan Surat Baru'),
        backgroundColor: AppConstants.primaryColor,
        foregroundColor: AppConstants.surfaceColor,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _card(
                title: 'Data Pemohon',
                icon: Icons.person_outline,
                children: [
                  _label('Nama Lengkap *'),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: _namaCtrl,
                    textCapitalization: TextCapitalization.words,
                    decoration: _dec(hint: 'Contoh: Budi Santoso', icon: Icons.person),
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) {
                        return 'Nama tidak boleh kosong';
                      }
                      if (v.trim().length < 3) return 'Minimal 3 karakter';
                      return null;
                    },
                  ),
                  const SizedBox(height: 14),
                  _label('NIK (16 digit) *'),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: _nikCtrl,
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(16),
                    ],
                    decoration: _dec(hint: '16 digit angka NIK', icon: Icons.badge),
                    validator: (v) {
                      if (v == null || v.isEmpty) return 'NIK tidak boleh kosong';
                      if (v.length != 16) return 'NIK harus 16 digit';
                      return null;
                    },
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _card(
                title: 'Detail Surat',
                icon: Icons.description_outlined,
                children: [
                  _label('Jenis Surat *'),
                  const SizedBox(height: 6),
                  DropdownButtonFormField<String>(
                    value: _jenisSurat,
                    isExpanded: true,
                    decoration:
                        _dec(hint: 'Pilih jenis surat', icon: Icons.list_alt),
                    items: AppConstants.jenisSuratList
                        .map((j) => DropdownMenuItem(
                            value: j,
                            child: Text(j,
                                style: const TextStyle(fontSize: 13))))
                        .toList(),
                    onChanged: (v) => setState(() => _jenisSurat = v),
                    validator: (v) =>
                        v == null ? 'Pilih jenis surat' : null,
                  ),
                  const SizedBox(height: 14),
                  _label('Keperluan / Tujuan *'),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: _keperluanCtrl,
                    maxLines: 3,
                    textCapitalization: TextCapitalization.sentences,
                    decoration: _dec(
                        hint: 'Jelaskan keperluan pembuatan surat…',
                        icon: Icons.edit_note),
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) {
                        return 'Keperluan tidak boleh kosong';
                      }
                      if (v.trim().length < 10) return 'Minimal 10 karakter';
                      return null;
                    },
                  ),
                  const SizedBox(height: 14),
                  _label('Keterangan Tambahan (opsional)'),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: _keteranganCtrl,
                    maxLines: 2,
                    textCapitalization: TextCapitalization.sentences,
                    decoration: _dec(
                        hint: 'Keterangan lain jika ada…',
                        icon: Icons.notes),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // info note
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.blue.shade100),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.blue, size: 16),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Nomor surat akan dibuat otomatis setelah pengajuan berhasil.',
                        style: TextStyle(fontSize: 11, color: Colors.blue),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              // tombol ajukan
              SizedBox(
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: _saving ? null : _simpan,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppConstants.primaryColor,
                    foregroundColor: AppConstants.surfaceColor,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  icon: _saving
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                              color: AppConstants.surfaceColor, strokeWidth: 2),
                        )
                      : const Icon(Icons.send),
                  label: Text(_saving ? 'Menyimpan…' : 'Ajukan Surat',
                      style: const TextStyle(
                          fontSize: 15, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 10),
              // tombol batal
              SizedBox(
                height: 46,
                child: OutlinedButton.icon(
                  onPressed: () => Navigator.pop(context),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.grey,
                    side: const BorderSide(color: Colors.grey),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  icon: const Icon(Icons.close),
                  label: const Text('Batal'),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  // ── helpers ────────────────────────────────────────────────────────────────
  Widget _card({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 18, color: AppConstants.primaryColor),
                const SizedBox(width: 8),
                Text(title,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: AppConstants.primaryColor)),
              ],
            ),
            const Divider(height: 16),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _label(String text) => Text(text,
      style: const TextStyle(
          fontSize: 13, fontWeight: FontWeight.w600, color: Colors.black87));

  InputDecoration _dec({required String hint, required IconData icon}) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(fontSize: 13, color: Colors.grey),
      prefixIcon: Icon(icon, size: 20, color: Colors.grey),
      filled: true,
      fillColor: Colors.grey.shade50,
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(
            color: AppConstants.primaryColor, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Colors.red),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide:
            const BorderSide(color: Colors.red, width: 1.5),
      ),
    );
  }
}
