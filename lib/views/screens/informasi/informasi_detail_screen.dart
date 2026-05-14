// lib/views/screens/informasi/informasi_detail_screen.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../controllers/informasi_controller.dart';
import '../../../models/informasi_model.dart';
import '../../../utils/app_constants.dart';
import '../../../utils/date_helper.dart';

class InformasiDetailScreen extends StatefulWidget {
  final InformasiModel item;
  final InformasiController informasiController;
  final String userId;
  final bool isAdmin;

  const InformasiDetailScreen({
    super.key,
    required this.item,
    required this.informasiController,
    required this.userId,
    this.isAdmin = false,
  });

  @override
  State<InformasiDetailScreen> createState() => _InformasiDetailScreenState();
}

class _InformasiDetailScreenState extends State<InformasiDetailScreen> {
  bool _bookmarked = false;

  @override
  void initState() {
    super.initState();
    _loadBookmark();
  }

  Future<void> _loadBookmark() async {
    final v = await widget.informasiController.isBookmarked(
        widget.item.id, widget.userId);
    if (mounted) setState(() => _bookmarked = v);
  }

  Future<void> _toggleBookmark() async {
    await widget.informasiController.toggleBookmark(
        widget.item.id, widget.userId);
    if (mounted) setState(() => _bookmarked = !_bookmarked);

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          _bookmarked ? 'Disematkan!' : 'Sematan dihapus',
          style: GoogleFonts.poppins(color: Colors.white),
        ),
        backgroundColor: _bookmarked
            ? const Color(0xFFF5A623)
            : AppConstants.textSecondary,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 1),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final item = widget.item;
    final tipeColor = AppConstants.tipeColor(item.tipe);
    final katColor = AppConstants.kategoriColor(item.kategori);

    return Scaffold(
      backgroundColor: AppConstants.backgroundColor,
      body: CustomScrollView(
        slivers: [
          // ── App Bar ───────────────────────────────────────────────────
          SliverAppBar(
            expandedHeight: 160,
            pinned: true,
            backgroundColor: tipeColor,
            leading: IconButton(
              icon: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.arrow_back_ios_new_rounded,
                    color: Colors.white, size: 18),
              ),
              onPressed: () => Navigator.pop(context),
            ),
            actions: [
              if (!widget.isAdmin)
                IconButton(
                  onPressed: _toggleBookmark,
                  icon: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    child: Icon(
                      _bookmarked
                          ? Icons.bookmark_rounded
                          : Icons.bookmark_border_rounded,
                      key: ValueKey(_bookmarked),
                      color: _bookmarked
                          ? const Color(0xFFF5A623)
                          : Colors.white,
                      size: 26,
                    ),
                  ),
                ),
              if (widget.isAdmin)
                IconButton(
                  onPressed: () => _konfirmasiHapus(context),
                  icon: const Icon(Icons.delete_outline_rounded,
                      color: Colors.white),
                ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      tipeColor,
                      tipeColor.withOpacity(0.6),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding:
                        const EdgeInsets.fromLTRB(20, 56, 20, 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Row(
                          children: [
                            _badge(item.tipe, Colors.white.withOpacity(0.2),
                                Colors.white),
                            const SizedBox(width: 6),
                            _badge(item.kategori,
                                katColor.withOpacity(0.2), Colors.white),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          // ── Konten ────────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Judul
                  Text(
                    item.judul,
                    style: GoogleFonts.poppins(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppConstants.textPrimary,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Meta info
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: tipeColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                          color: tipeColor.withOpacity(0.2)),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.access_time_rounded,
                            size: 14, color: tipeColor),
                        const SizedBox(width: 6),
                        Text(
                          DateHelper.formatPanjang(item.tanggal),
                          style: GoogleFonts.poppins(
                              fontSize: 12, color: AppConstants.textSecondary),
                        ),
                        const SizedBox(width: 16),
                        Icon(Icons.person_outline_rounded,
                            size: 14, color: tipeColor),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            item.dibuatOleh,
                            style: GoogleFonts.poppins(
                                fontSize: 12,
                                color: AppConstants.textSecondary),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Divider
                  Container(
                    height: 2,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [tipeColor, tipeColor.withOpacity(0.3)],
                      ),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Isi
                  Text(
                    item.isi,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: AppConstants.textPrimary,
                      height: 1.7,
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Tombol sematkan (hanya user)
                  if (!widget.isAdmin)
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: OutlinedButton.icon(
                        onPressed: _toggleBookmark,
                        icon: Icon(
                          _bookmarked
                              ? Icons.bookmark_rounded
                              : Icons.bookmark_border_rounded,
                          color: _bookmarked
                              ? const Color(0xFFF5A623)
                              : AppConstants.primaryColor,
                        ),
                        label: Text(
                          _bookmarked ? 'Hapus Sematan' : 'Sematkan',
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w600,
                            color: _bookmarked
                                ? const Color(0xFFF5A623)
                                : AppConstants.primaryColor,
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(
                            color: _bookmarked
                                ? const Color(0xFFF5A623)
                                : AppConstants.primaryColor,
                            width: 1.5,
                          ),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _konfirmasiHapus(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.red),
            SizedBox(width: 8),
            Text('Hapus Informasi?'),
          ],
        ),
        content: Text(
            'Informasi "${widget.item.judul}" akan dihapus permanen.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Batal')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              Navigator.pop(ctx);
              await widget.informasiController.hapusInformasi(widget.item.id);
              if (mounted) Navigator.pop(context);
            },
            child: const Text('Hapus',
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _badge(String label, Color bg, Color textColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: GoogleFonts.poppins(
            fontSize: 11, fontWeight: FontWeight.w600, color: textColor),
      ),
    );
  }
}
