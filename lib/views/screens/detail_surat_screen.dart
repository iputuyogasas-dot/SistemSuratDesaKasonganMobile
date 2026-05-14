// lib/views/screens/detail_surat_screen.dart

import 'package:flutter/material.dart';
import '../../controllers/surat_controller.dart';
import '../../models/surat_model.dart';
import '../../utils/app_constants.dart';
import '../../utils/date_helper.dart';

class DetailSuratScreen extends StatefulWidget {
  final SuratController controller;
  final String suratId;

  const DetailSuratScreen({
    super.key,
    required this.controller,
    required this.suratId,
  });

  @override
  State<DetailSuratScreen> createState() => _DetailSuratScreenState();
}

class _DetailSuratScreenState extends State<DetailSuratScreen> {
  SuratModel? get _surat =>
      widget.controller.cariById(widget.suratId);

  // ── update status ──────────────────────────────────────────────────────────
  void _dialogUpdateStatus() {
    if (_surat == null) return;
    String pilihan = _surat!.status;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setD) => AlertDialog(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16)),
          title: const Row(
            children: [
              Icon(Icons.update, color: AppConstants.primaryColor),
              SizedBox(width: 8),
              Text('Update Status Surat'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: AppConstants.statusList
                .map((s) => RadioListTile<String>(
                      dense: true,
                      title: Row(
                        children: [
                          Icon(AppConstants.statusIcon(s),
                              size: 16,
                              color: AppConstants.statusColor(s)),
                          const SizedBox(width: 8),
                          Text(s),
                        ],
                      ),
                      value: s,
                      groupValue: pilihan,
                      activeColor: AppConstants.primaryColor,
                      onChanged: (v) => setD(() => pilihan = v!),
                    ))
                .toList(),
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Batal')),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                  backgroundColor: AppConstants.primaryColor),
              onPressed: () async {
                Navigator.pop(ctx);
                final ok = await widget.controller
                    .updateStatus(widget.suratId, pilihan);
                if (mounted) {
                  setState(() {});
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(ok
                          ? 'Status diperbarui menjadi "$pilihan"'
                          : 'Gagal memperbarui status'),
                      backgroundColor: ok ? Colors.green : Colors.red,
                    ),
                  );
                }
              },
              child: const Text('Simpan',
                  style: TextStyle(color: AppConstants.surfaceColor)),
            ),
          ],
        ),
      ),
    );
  }

  // ── hapus ──────────────────────────────────────────────────────────────────
  void _konfirmasiHapus() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.red),
            SizedBox(width: 8),
            Text('Hapus Surat?'),
          ],
        ),
        content:
            const Text('Surat ini akan dihapus secara permanen.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Batal')),
          ElevatedButton(
            style:
                ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              Navigator.pop(ctx);
              await widget.controller.hapusSurat(widget.suratId);
              if (mounted) Navigator.pop(context);
            },
            child: const Text('Hapus',
                style: TextStyle(color: AppConstants.surfaceColor)),
          ),
        ],
      ),
    );
  }

  // ── build ──────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final surat = _surat;
    if (surat == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Detail Surat')),
        body: const Center(child: Text('Data tidak ditemukan')),
      );
    }

    final statusColor = AppConstants.statusColor(surat.status);
    final statusIcon = AppConstants.statusIcon(surat.status);

    return Scaffold(
      backgroundColor: AppConstants.backgroundColor,
      appBar: AppBar(
        title: const Text('Detail Surat'),
        backgroundColor: AppConstants.primaryColor,
        foregroundColor: AppConstants.surfaceColor,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline),
            tooltip: 'Hapus',
            onPressed: _konfirmasiHapus,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // ── header card ────────────────────────────────────────────
            Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              elevation: 3,
              clipBehavior: Clip.antiAlias,
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF1A5276), Color(0xFF0D2B42)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppConstants.surfaceColor.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.description,
                          color: AppConstants.surfaceColor, size: 34),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      surat.nomorSurat,
                      style: const TextStyle(
                          color: AppConstants.surfaceColor,
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.8),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      surat.jenisSurat,
                      style: const TextStyle(
                          color: AppConstants.textSecondary, fontSize: 13),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 14),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 6),
                      decoration: BoxDecoration(
                        color: statusColor.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                            color: statusColor.withValues(alpha: 0.5),
                            width: 1.5),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(statusIcon,
                              color: statusColor, size: 14),
                          const SizedBox(width: 6),
                          Text(
                            surat.status,
                            style: TextStyle(
                                color: statusColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 13),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),

            // ── info pemohon ───────────────────────────────────────────
            _infoCard(
              title: 'Informasi Pemohon',
              icon: Icons.person_outline,
              rows: [
                _Row('Nama', surat.namaPemohon, Icons.person),
                _Row('NIK', surat.nik, Icons.badge),
              ],
            ),
            const SizedBox(height: 10),

            // ── detail surat ───────────────────────────────────────────
            _infoCard(
              title: 'Detail Surat',
              icon: Icons.description_outlined,
              rows: [
                _Row('Jenis', surat.jenisSurat, Icons.list_alt),
                _Row('Keperluan', surat.keperluan, Icons.edit_note,
                    multi: true),
                if (surat.keterangan.isNotEmpty)
                  _Row('Keterangan', surat.keterangan, Icons.notes,
                      multi: true),
                _Row(
                  'Tanggal',
                  DateHelper.formatLengkap(surat.tanggalPengajuan),
                  Icons.calendar_today,
                ),
              ],
            ),
            const SizedBox(height: 10),

            // ── timeline ───────────────────────────────────────────────
            _timelineCard(surat.status),
            const SizedBox(height: 20),

            // ── tombol update ──────────────────────────────────────────
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: _dialogUpdateStatus,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppConstants.secondaryColor,
                  foregroundColor: AppConstants.surfaceColor,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                icon: const Icon(Icons.update),
                label: const Text('Update Status Surat',
                    style: TextStyle(
                        fontSize: 15, fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  // ── helper widgets ─────────────────────────────────────────────────────────
  Widget _infoCard({
    required String title,
    required IconData icon,
    required List<_Row> rows,
  }) {
    return Card(
      shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Icon(icon, size: 18, color: AppConstants.primaryColor),
              const SizedBox(width: 8),
              Text(title,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: AppConstants.primaryColor)),
            ]),
            const Divider(height: 16),
            ...rows.map((r) => _buildRow(r)),
          ],
        ),
      ),
    );
  }

  Widget _buildRow(_Row r) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: r.multi
            ? CrossAxisAlignment.start
            : CrossAxisAlignment.center,
        children: [
          Icon(r.icon, size: 15, color: Colors.grey),
          const SizedBox(width: 8),
          SizedBox(
            width: 90,
            child: Text(r.label,
                style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 12,
                    fontWeight: FontWeight.w500)),
          ),
          const Text(': ',
              style: TextStyle(color: Colors.grey, fontSize: 12)),
          Expanded(
            child: Text(r.value,
                style: const TextStyle(
                    fontSize: 13, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  Widget _timelineCard(String currentStatus) {
    final steps = ['Menunggu', 'Diproses', 'Selesai'];
    final idx = steps.indexOf(currentStatus);

    return Card(
      shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.timeline,
                    size: 18, color: AppConstants.primaryColor),
                SizedBox(width: 8),
                Text('Timeline Status',
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: AppConstants.primaryColor)),
              ],
            ),
            const Divider(height: 16),
            Row(
              children: steps.asMap().entries.map((entry) {
                final i = entry.key;
                final step = entry.value;
                final done = i <= idx;
                final color = done
                    ? AppConstants.statusColor(step)
                    : Colors.grey.shade300;

                return Expanded(
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          children: [
                            Container(
                              width: 34,
                              height: 34,
                              decoration: BoxDecoration(
                                  color: color, shape: BoxShape.circle),
                              child: Icon(
                                  AppConstants.statusIcon(step),
                                  size: 16,
                                  color: AppConstants.surfaceColor),
                            ),
                            const SizedBox(height: 4),
                            Text(step,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: i == idx
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                    color: done
                                        ? Colors.black87
                                        : Colors.grey)),
                          ],
                        ),
                      ),
                      if (i < steps.length - 1)
                        Expanded(
                          child: Container(
                            height: 2,
                            color: i < idx
                                ? AppConstants.secondaryColor
                                : Colors.grey.shade300,
                          ),
                        ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}

// helper data class (private)
class _Row {
  final String label;
  final String value;
  final IconData icon;
  final bool multi;
  const _Row(this.label, this.value, this.icon, {this.multi = false});
}
