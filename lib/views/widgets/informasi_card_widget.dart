// lib/views/widgets/informasi_card_widget.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/informasi_model.dart';
import '../../utils/app_constants.dart';
import '../../utils/date_helper.dart';

class InformasiCardWidget extends StatelessWidget {
  final InformasiModel item;
  final bool isBookmarked;
  final bool isCompact; // untuk preview di home
  final VoidCallback? onTap;
  final VoidCallback? onBookmark;
  final VoidCallback? onDelete; // null = tidak tampil (bukan admin)

  const InformasiCardWidget({
    super.key,
    required this.item,
    required this.isBookmarked,
    this.isCompact = false,
    this.onTap,
    this.onBookmark,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final tipeColor = AppConstants.tipeColor(item.tipe);
    final katColor = AppConstants.kategoriColor(item.kategori);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.only(bottom: isCompact ? 0 : 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // ── Accent bar kiri ───────────────────────────────────
                Container(width: 4, color: tipeColor),

                // ── Konten ───────────────────────────────────────────
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(12, 11, 10, 11),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Baris badge + aksi
                        Row(
                          children: [
                            _BadgeChip(label: item.tipe, color: tipeColor),
                            const SizedBox(width: 6),
                            _BadgeChip(label: item.kategori, color: katColor),
                            const Spacer(),
                            if (onBookmark != null)
                              GestureDetector(
                                onTap: onBookmark,
                                child: Icon(
                                  isBookmarked
                                      ? Icons.bookmark_rounded
                                      : Icons.bookmark_border_rounded,
                                  color: isBookmarked
                                      ? const Color(0xFFF5A623)
                                      : AppConstants.textSecondary,
                                  size: 20,
                                ),
                              ),
                            if (onDelete != null) ...[
                              const SizedBox(width: 8),
                              GestureDetector(
                                onTap: onDelete,
                                child: Icon(
                                  Icons.delete_outline_rounded,
                                  color: AppConstants.errorColor,
                                  size: 20,
                                ),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 7),

                        // Judul
                        Text(
                          item.judul,
                          style: GoogleFonts.poppins(
                            fontSize: isCompact ? 13 : 14,
                            fontWeight: FontWeight.w600,
                            color: AppConstants.textPrimary,
                            height: 1.3,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 5),

                        // Isi preview
                        Text(
                          item.isi,
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: AppConstants.textSecondary,
                            height: 1.45,
                          ),
                          maxLines: isCompact ? 2 : 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 8),

                        // Meta: tanggal & pembuat
                        Row(
                          children: [
                            Icon(Icons.access_time_rounded,
                                size: 12, color: AppConstants.textSecondary),
                            const SizedBox(width: 4),
                            Text(
                              DateHelper.formatPanjang(item.tanggal),
                              style: GoogleFonts.poppins(
                                fontSize: 11,
                                color: AppConstants.textSecondary,
                              ),
                            ),
                            const Spacer(),
                            Icon(Icons.person_outline_rounded,
                                size: 12, color: AppConstants.textSecondary),
                            const SizedBox(width: 3),
                            Flexible(
                              child: Text(
                                item.dibuatOleh,
                                style: GoogleFonts.poppins(
                                  fontSize: 11,
                                  color: AppConstants.textSecondary,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
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
}

// ── Badge chip kecil ──────────────────────────────────────────────────────────
class _BadgeChip extends StatelessWidget {
  final String label;
  final Color color;

  const _BadgeChip({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.3), width: 0.8),
      ),
      child: Text(
        label,
        style: GoogleFonts.poppins(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}
