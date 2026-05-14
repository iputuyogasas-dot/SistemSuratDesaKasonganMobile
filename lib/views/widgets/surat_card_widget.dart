// lib/views/widgets/surat_card_widget.dart

import 'package:flutter/material.dart';
import '../../models/surat_model.dart';
import '../../utils/app_constants.dart';
import '../../utils/date_helper.dart';

class SuratCard extends StatelessWidget {
  final SuratModel surat;
  final VoidCallback onTap;
  final VoidCallback onHapus;

  const SuratCard({
    super.key,
    required this.surat,
    required this.onTap,
    required this.onHapus,
  });

  @override
  Widget build(BuildContext context) {
    final color = AppConstants.statusColor(surat.status);
    final icon = AppConstants.statusIcon(surat.status);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // baris atas: nomor + status
              Row(
                children: [
                  Expanded(
                    child: Text(
                      surat.nomorSurat,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: AppConstants.primaryColor,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                      border:
                          Border.all(color: color.withValues(alpha: 0.4)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(icon, size: 11, color: color),
                        const SizedBox(width: 3),
                        Text(
                          surat.status,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: color,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              // jenis surat
              Text(
                surat.jenisSurat,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              // nama pemohon
              Row(
                children: [
                  const Icon(Icons.person_outline,
                      size: 13, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text(surat.namaPemohon,
                      style: const TextStyle(
                          fontSize: 12, color: Colors.black54)),
                ],
              ),
              const SizedBox(height: 2),
              // NIK
              Row(
                children: [
                  const Icon(Icons.badge_outlined,
                      size: 13, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text('NIK: ${surat.nik}',
                      style: const TextStyle(
                          fontSize: 12, color: Colors.black45)),
                ],
              ),
              const Divider(height: 14),
              // baris bawah: tanggal + hapus
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.calendar_today_outlined,
                          size: 12, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text(
                        DateHelper.formatPanjang(
                            surat.tanggalPengajuan),
                        style: const TextStyle(
                            fontSize: 11, color: Colors.grey),
                      ),
                    ],
                  ),
                  GestureDetector(
                    onTap: onHapus,
                    child: const Icon(Icons.delete_outline,
                        size: 20, color: Colors.redAccent),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
