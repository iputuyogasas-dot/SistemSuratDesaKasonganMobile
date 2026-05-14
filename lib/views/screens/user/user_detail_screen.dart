// lib/views/screens/user/user_detail_screen.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../controllers/surat_controller.dart';
import '../../../models/surat_model.dart';
import '../../../utils/app_constants.dart';
import '../../../utils/date_helper.dart';
import '../../../utils/pdf_helper.dart';

class UserDetailScreen extends StatelessWidget {
  final SuratModel surat;
  final SuratController suratController;
  final bool isAdmin;

  const UserDetailScreen({
    super.key,
    required this.surat,
    required this.suratController,
    this.isAdmin = false,
  });

  @override
  Widget build(BuildContext context) {
    final statusColor = AppConstants.statusColor(surat.status);
    final statusList = AppConstants.statusList;
    final currentIdx = statusList.indexOf(surat.status);

    return Scaffold(
      backgroundColor: AppConstants.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppConstants.primaryDark,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: AppConstants.surfaceColor, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text('Detail Surat',
            style: GoogleFonts.poppins(
                color: AppConstants.surfaceColor, fontWeight: FontWeight.w600)),
        flexibleSpace: Container(
          decoration: const BoxDecoration(gradient: AppConstants.primaryGradient),
        ),
        actions: isAdmin
            ? [
                IconButton(
                  icon: const Icon(Icons.delete_outline_rounded,
                      color: AppConstants.textSecondary),
                  onPressed: () => _confirmHapus(context),
                ),
              ]
            : null,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header Card ──
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: AppConstants.primaryGradient,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: AppConstants.primaryColor.withValues(alpha: 0.3),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.article_rounded,
                          color: AppConstants.textSecondary, size: 16),
                      const SizedBox(width: 6),
                      Text(surat.nomorSurat,
                          style: GoogleFonts.poppins(
                              color: AppConstants.textSecondary, fontSize: 12)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    surat.jenisSurat,
                    style: GoogleFonts.poppins(
                      color: AppConstants.surfaceColor,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(20),
                      border:
                          Border.all(color: statusColor.withValues(alpha: 0.5)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(AppConstants.statusIcon(surat.status),
                            color: statusColor, size: 14),
                        const SizedBox(width: 6),
                        Text(surat.status,
                            style: GoogleFonts.poppins(
                                color: statusColor,
                                fontWeight: FontWeight.w600,
                                fontSize: 13)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // ── Timeline ──
            _infoCard(
              title: 'Progress Status',
              child: _buildTimeline(currentIdx),
            ),
            const SizedBox(height: 16),

            // ── Info Pemohon ──
            _infoCard(
              title: 'Informasi Pemohon',
              child: Column(
                children: [
                  _infoRow(Icons.person_rounded, 'Nama Lengkap',
                      surat.namaPemohon),
                  _divider(),
                  _infoRow(Icons.badge_rounded, 'NIK', surat.nik),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // ── Detail Surat ──
            _infoCard(
              title: 'Detail Pengajuan',
              child: Column(
                children: [
                  _infoRow(Icons.description_rounded, 'Jenis Surat',
                      surat.jenisSurat),
                  _divider(),
                  _infoRow(Icons.text_snippet_rounded, 'Keperluan',
                      surat.keperluan),
                  if (surat.keterangan.isNotEmpty) ...[
                    _divider(),
                    _infoRow(Icons.notes_rounded, 'Keterangan',
                        surat.keterangan),
                  ],
                  _divider(),
                  _infoRow(Icons.calendar_today_rounded, 'Tanggal',
                      DateHelper.formatLengkap(surat.tanggalPengajuan)),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Tombol Update Status (hanya admin)
            if (isAdmin)
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
                  child: ElevatedButton.icon(
                    onPressed: () => _showUpdateStatus(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                    ),
                    icon: const Icon(Icons.update_rounded, color: AppConstants.surfaceColor),
                    label: Text('Update Status',
                        style: GoogleFonts.poppins(
                            color: AppConstants.surfaceColor,
                            fontWeight: FontWeight.w600,
                            fontSize: 16)),
                  ),
                ),
              ),

            // Tombol Download PDF (user & admin, hanya jika status Selesai)
            if (surat.status == 'Selesai') ...[
              const SizedBox(height: 12),
              _DownloadPdfButton(surat: surat),
            ],
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _infoCard({required String title, required Widget child}) {
    return Container(
      decoration: BoxDecoration(
        color: AppConstants.surfaceColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppConstants.surfaceLight, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
            child: Text(
              title,
              style: GoogleFonts.poppins(
                color: AppConstants.textSecondary,
                fontSize: 12,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
            ),
          ),
          Divider(height: 1, color: AppConstants.surfaceLight),
          Padding(
            padding: const EdgeInsets.all(16),
            child: child,
          ),
        ],
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: AppConstants.primaryColor, size: 18),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: GoogleFonts.poppins(
                      color: AppConstants.textSecondary, fontSize: 11)),
              const SizedBox(height: 2),
              Text(value,
                  style: GoogleFonts.poppins(
                      color: AppConstants.textPrimary,
                      fontSize: 14,
                      fontWeight: FontWeight.w500)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _divider() => Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Divider(height: 1, color: AppConstants.surfaceLight),
      );

  Widget _buildTimeline(int currentIdx) {
    final steps = ['Menunggu', 'Diproses', 'Selesai'];
    return Row(
      children: List.generate(steps.length * 2 - 1, (i) {
        if (i.isOdd) {
          // connector
          final stepIdx = (i - 1) ~/ 2;
          final passed = stepIdx < currentIdx;
          return Expanded(
            child: Container(
              height: 3,
              decoration: BoxDecoration(
                gradient: passed
                    ? AppConstants.primaryGradient
                    : null,
                color: passed ? null : AppConstants.surfaceLight,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          );
        }
        final stepIdx = i ~/ 2;
        final reached = stepIdx <= currentIdx;
        final isCurrent = stepIdx == currentIdx;
        return Column(
          children: [
            Container(
              width: isCurrent ? 36 : 28,
              height: isCurrent ? 36 : 28,
              decoration: BoxDecoration(
                gradient: reached ? AppConstants.primaryGradient : null,
                color: reached ? null : AppConstants.surfaceLight,
                shape: BoxShape.circle,
                boxShadow: isCurrent
                    ? [
                        BoxShadow(
                          color: AppConstants.primaryColor.withValues(alpha: 0.4),
                          blurRadius: 8,
                        )
                      ]
                    : null,
              ),
              child: Icon(
                reached
                    ? Icons.check_rounded
                    : Icons.circle_outlined,
                color: reached ? AppConstants.surfaceColor : AppConstants.textSecondary,
                size: isCurrent ? 18 : 14,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              steps[stepIdx],
              style: GoogleFonts.poppins(
                color: reached
                    ? AppConstants.textPrimary
                    : AppConstants.textSecondary,
                fontSize: 10,
                fontWeight:
                    isCurrent ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        );
      }),
    );
  }

  void _showUpdateStatus(BuildContext context) {
    String selected = surat.status;
    showModalBottomSheet(
      context: context,
      backgroundColor: AppConstants.surfaceColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => StatefulBuilder(
        builder: (ctx, setModalState) => Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Update Status Surat',
                  style: GoogleFonts.poppins(
                      color: AppConstants.textPrimary,
                      fontWeight: FontWeight.bold,
                      fontSize: 18)),
              const SizedBox(height: 16),
              ...AppConstants.statusList.map((s) {
                final color = AppConstants.statusColor(s);
                return GestureDetector(
                  onTap: () => setModalState(() => selected = s),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: selected == s
                          ? color.withValues(alpha: 0.15)
                          : AppConstants.surfaceLight.withValues(alpha: 0.4),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: selected == s
                            ? color
                            : Colors.transparent,
                        width: 1.5,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(AppConstants.statusIcon(s), color: color, size: 20),
                        const SizedBox(width: 12),
                        Text(s,
                            style: GoogleFonts.poppins(
                                color: AppConstants.textPrimary,
                                fontWeight: FontWeight.w500)),
                        const Spacer(),
                        if (selected == s)
                          Icon(Icons.check_circle_rounded, color: color, size: 20),
                      ],
                    ),
                  ),
                );
              }),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: AppConstants.primaryGradient,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ElevatedButton(
                    onPressed: () async {
                      Navigator.pop(ctx);
                      await suratController.updateStatus(surat.id, selected);
                      if (context.mounted) Navigator.of(context).pop();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Text('Simpan',
                        style: GoogleFonts.poppins(
                            color: AppConstants.surfaceColor,
                            fontWeight: FontWeight.w600)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _confirmHapus(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppConstants.surfaceColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Hapus Surat?',
            style: GoogleFonts.poppins(
                color: AppConstants.textPrimary, fontWeight: FontWeight.bold)),
        content: Text('Surat ini akan dihapus permanen.',
            style: GoogleFonts.poppins(color: AppConstants.textSecondary)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Batal',
                style: GoogleFonts.poppins(color: AppConstants.textSecondary)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppConstants.errorColor,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () async {
              Navigator.pop(context);
              await suratController.hapusSurat(surat.id);
              if (context.mounted) Navigator.of(context).pop();
            },
            child: Text('Hapus',
                style: GoogleFonts.poppins(color: AppConstants.surfaceColor)),
          ),
        ],
      ),
    );
  }
}

// ── Download PDF Button ────────────────────────────────────────────────────────

class _DownloadPdfButton extends StatefulWidget {
  final SuratModel surat;
  const _DownloadPdfButton({required this.surat});

  @override
  State<_DownloadPdfButton> createState() => _DownloadPdfButtonState();
}

class _DownloadPdfButtonState extends State<_DownloadPdfButton> {
  bool _loading = false;

  Future<void> _onDownload() async {
    setState(() => _loading = true);
    try {
      await PdfHelper.downloadSurat(widget.surat);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal membuat PDF: $e',
                style: GoogleFonts.poppins(fontSize: 13)),
            backgroundColor: AppConstants.errorColor,
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: OutlinedButton.icon(
        onPressed: _loading ? null : _onDownload,
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: AppConstants.primaryColor, width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          backgroundColor: AppConstants.primaryColor.withValues(alpha: 0.06),
        ),
        icon: _loading
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                    color: AppConstants.primaryColor, strokeWidth: 2),
              )
            : const Icon(Icons.download_rounded,
                color: AppConstants.primaryColor, size: 20),
        label: Text(
          _loading ? 'Menyiapkan PDF...' : 'Download Surat PDF',
          style: GoogleFonts.poppins(
            color: AppConstants.primaryColor,
            fontWeight: FontWeight.w600,
            fontSize: 15,
          ),
        ),
      ),
    );
  }
}

