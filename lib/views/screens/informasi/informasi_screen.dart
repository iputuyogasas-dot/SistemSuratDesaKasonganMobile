// lib/views/screens/informasi/informasi_screen.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../controllers/auth_controller.dart';
import '../../../controllers/informasi_controller.dart';
import '../../../models/informasi_model.dart';
import '../../../utils/app_constants.dart';
import '../../widgets/informasi_card_widget.dart';
import 'informasi_detail_screen.dart';
import 'tambah_informasi_screen.dart';

class InformasiScreen extends StatefulWidget {
  final AuthController authController;
  final InformasiController informasiController;
  final int initialTabIndex;
  final bool showAppBar;

  const InformasiScreen({
    super.key,
    required this.authController,
    required this.informasiController,
    this.initialTabIndex = 0,
    this.showAppBar = true,
  });

  @override
  State<InformasiScreen> createState() => _InformasiScreenState();
}

class _InformasiScreenState extends State<InformasiScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final List<String> _tabs = ['Semua', 'Pengumuman', 'Berita', 'Disematkan'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: _tabs.length,
      vsync: this,
      initialIndex: widget.initialTabIndex,
    );
    widget.informasiController.loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  bool get _isAdmin =>
      widget.authController.role == AppConstants.roleAdmin ||
      widget.authController.role == AppConstants.roleSuperAdmin;

  String get _userId => widget.authController.userId;

  @override
  Widget build(BuildContext context) {
    final bool asTab = !widget.showAppBar;

    return Scaffold(
      backgroundColor: AppConstants.backgroundColor,
      resizeToAvoidBottomInset: false,
      extendBody: true,
      appBar: asTab
          ? null
          : AppBar(
              backgroundColor: AppConstants.primaryColor,
              elevation: 0,
              title: Text(
                'Informasi Desa',
                style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18),
              ),
              leading: IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded,
                    color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
              bottom: _tabBar(),
            ),
      body: Column(
        children: [
          // Header + tabbar when used inside TabBarView
          if (asTab) ...[
            Container(
              color: AppConstants.primaryColor,
              child: SafeArea(
                bottom: false,
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
                      child: Row(
                        children: [
                          Icon(Icons.info_outline_rounded,
                              color: Colors.white.withOpacity(0.9), size: 20),
                          const SizedBox(width: 8),
                          Text(
                            'Informasi Desa',
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const Spacer(),
                          if (_isAdmin)
                            TextButton.icon(
                              onPressed: _bukaFormTambah,
                              icon: const Icon(Icons.add_circle_rounded,
                                  color: Colors.white, size: 18),
                              label: Text('Tambah',
                                  style: GoogleFonts.poppins(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 13)),
                            ),
                        ],
                      ),
                    ),
                    TabBar(
                      controller: _tabController,
                      isScrollable: false,
                      indicatorColor: Colors.white,
                      indicatorWeight: 3,
                      labelColor: Colors.white,
                      unselectedLabelColor: Colors.white.withOpacity(0.65),
                      labelStyle: GoogleFonts.poppins(
                          fontWeight: FontWeight.bold, fontSize: 11),
                      unselectedLabelStyle: GoogleFonts.poppins(
                          fontWeight: FontWeight.w500, fontSize: 11),
                      labelPadding: EdgeInsets.zero,
                      tabs: _tabList(),
                    ),
                  ],
                ),
              ),
            ),
          ],
          Expanded(
            child: ListenableBuilder(
              listenable: widget.informasiController,
              builder: (context, _) {
                if (widget.informasiController.loading) {
                  return const Center(
                    child: CircularProgressIndicator(
                        color: AppConstants.primaryColor),
                  );
                }
                return TabBarView(
                  controller: _tabController,
                  children: [
                    _buildList(widget.informasiController.semuaInformasi),
                    _buildList(widget.informasiController.pengumuman),
                    _buildList(widget.informasiController.berita),
                    FutureBuilder<List<InformasiModel>>(
                      future: widget.informasiController.bookmarked(_userId),
                      builder: (ctx, snap) =>
                          _buildList(snap.data ?? [], isBookmarkTab: true),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: (!asTab && _isAdmin)
          ? FloatingActionButton(
              onPressed: _bukaFormTambah,
              backgroundColor: AppConstants.primaryColor,
              child: const Icon(Icons.add_rounded, color: Colors.white),
            )
          : null,
    );
  }

  PreferredSizeWidget _tabBar() => TabBar(
        controller: _tabController,
        isScrollable: false,
        indicatorColor: Colors.white,
        indicatorWeight: 3,
        labelColor: Colors.white,
        unselectedLabelColor: Colors.white.withOpacity(0.65),
        labelStyle:
            GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 11),
        unselectedLabelStyle:
            GoogleFonts.poppins(fontWeight: FontWeight.w500, fontSize: 11),
        labelPadding: EdgeInsets.zero,
        tabs: _tabList(),
      );

  List<Widget> _tabList() => [
        const Tab(text: 'Semua'),
        const Tab(text: 'Pengumuman'),
        const Tab(text: 'Berita'),
        const Tab(text: 'Disematkan'),
      ];

  void _bukaFormTambah() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => TambahInformasiScreen(
          informasiController: widget.informasiController,
          namaAdmin: widget.authController.namaLengkap,
        ),
      ),
    );
  }

  Widget _buildList(List<InformasiModel> items, {bool isBookmarkTab = false}) {
    if (items.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isBookmarkTab
                  ? Icons.bookmark_border_rounded
                  : Icons.info_outline_rounded,
              size: 64,
              color: AppConstants.textSecondary.withOpacity(0.4),
            ),
            const SizedBox(height: 16),
            Text(
              isBookmarkTab
                  ? 'Belum ada yang disematkan'
                  : 'Tidak ada informasi',
              style: GoogleFonts.poppins(
                color: AppConstants.textSecondary,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            if (isBookmarkTab) ...[
              const SizedBox(height: 8),
              Text(
                'Tap ikon 🔖 pada kartu untuk menyematkan',
                style: GoogleFonts.poppins(
                    color: AppConstants.textSecondary, fontSize: 12),
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
      itemCount: items.length,
      itemBuilder: (context, i) {
        final item = items[i];
        return FutureBuilder<bool>(
          future: widget.informasiController.isBookmarked(item.id, _userId),
          builder: (context, snapshot) {
            final isBookmarked = snapshot.data ?? false;
            return InformasiCardWidget(
              item: item,
              isBookmarked: isBookmarked,
              onTap: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => InformasiDetailScreen(
                      item: item,
                      informasiController: widget.informasiController,
                      userId: _userId,
                      isAdmin: _isAdmin,
                    ),
                  ),
                );
                setState(() {}); // refresh bookmarks
              },
              onBookmark: _isAdmin
                  ? null
                  : () => widget.informasiController
                      .toggleBookmark(item.id, _userId),
              onDelete: _isAdmin ? () => _konfirmasiHapus(item) : null,
            );
          },
        );
      },
    );
  }

  void _konfirmasiHapus(InformasiModel item) {
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
        content: Text('Informasi "${item.judul}" akan dihapus permanen.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx), child: const Text('Batal')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              Navigator.pop(ctx);
              await widget.informasiController.hapusInformasi(item.id);
            },
            child: const Text('Hapus', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
