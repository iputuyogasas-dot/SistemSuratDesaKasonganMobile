// lib/views/screens/home_screen.dart

import 'package:flutter/material.dart';
import '../../controllers/surat_controller.dart';
import '../../utils/app_constants.dart';
import '../widgets/stat_card_widget.dart';
import '../widgets/surat_card_widget.dart';
import 'tambah_surat_screen.dart';
import 'detail_surat_screen.dart';
import 'riwayat_screen.dart';

class HomeScreen extends StatefulWidget {
  final SuratController controller;
  final String userId;
  const HomeScreen({super.key, required this.controller, required this.userId});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _tabIdx = 0;

  SuratController get ctrl => widget.controller;

  // ── navigasi ───────────────────────────────────────────────────────────────
  Future<void> _bukaTambah() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
          builder: (_) => TambahSuratScreen(controller: ctrl, userId: widget.userId)),
    );
    setState(() {});
  }

  Future<void> _bukaDetail(String id) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
          builder: (_) =>
              DetailSuratScreen(controller: ctrl, suratId: id)),
    );
    setState(() {});
  }

  // ── hapus ──────────────────────────────────────────────────────────────────
  void _konfirmasiHapus(String id, String nama) {
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
        content: Text('Surat atas nama "$nama" akan dihapus permanen.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Batal')),
          ElevatedButton(
            style:
                ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              Navigator.pop(ctx);
              await ctrl.hapusSurat(id);
              if (mounted) {
                setState(() {});
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Surat berhasil dihapus'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
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
    return Scaffold(
      backgroundColor: AppConstants.backgroundColor,
      body: _tabIdx == 0 ? _buildBeranda() : _buildRiwayat(),
      floatingActionButton: _tabIdx == 0
          ? FloatingActionButton.extended(
              onPressed: _bukaTambah,
              backgroundColor: AppConstants.primaryColor,
              icon: const Icon(Icons.add, color: AppConstants.surfaceColor),
              label: const Text('Buat Surat',
                  style: TextStyle(
                      color: AppConstants.surfaceColor,
                      fontWeight: FontWeight.bold)),
            )
          : null,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _tabIdx,
        onDestinationSelected: (i) => setState(() => _tabIdx = i),
        backgroundColor: AppConstants.surfaceColor,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Beranda',
          ),
          NavigationDestination(
            icon: Icon(Icons.history_outlined),
            selectedIcon: Icon(Icons.history),
            label: 'Riwayat',
          ),
        ],
      ),
    );
  }

  // ── halaman beranda ────────────────────────────────────────────────────────
  Widget _buildBeranda() {
    final list = ctrl.daftarTampil();

    return NestedScrollView(
      headerSliverBuilder: (_, __) => [
        SliverAppBar(
          pinned: true,
          expandedHeight: 210,
          backgroundColor: AppConstants.primaryColor,
          flexibleSpace: FlexibleSpaceBar(
            background: _header(),
          ),
          title: const Text('Beranda',
              style: TextStyle(color: AppConstants.surfaceColor, fontSize: 16)),
        ),
      ],
      body: Column(
        children: [
          // search bar
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: TextField(
              onChanged: (v) {
                ctrl.setQuery(v);
                setState(() {});
              },
              decoration: InputDecoration(
                hintText:
                    'Cari nama, NIK, nomor, atau jenis surat…',
                hintStyle:
                    const TextStyle(fontSize: 13, color: Colors.grey),
                prefixIcon:
                    const Icon(Icons.search, size: 20, color: Colors.grey),
                filled: true,
                fillColor: AppConstants.surfaceColor,
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 10),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          // filter chips
          SizedBox(
            height: 42,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              children:
                  ['Semua', 'Menunggu', 'Diproses', 'Selesai'].map((s) {
                final selected = ctrl.filterStatus == s;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(s,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: selected
                              ? FontWeight.bold
                              : FontWeight.normal,
                          color: selected
                              ? AppConstants.primaryColor
                              : Colors.grey,
                        )),
                    selected: selected,
                    onSelected: (_) {
                      ctrl.setFilter(s);
                      setState(() {});
                    },
                    selectedColor:
                        AppConstants.primaryColor.withValues(alpha: 0.12),
                    checkmarkColor: AppConstants.primaryColor,
                    backgroundColor: AppConstants.surfaceColor,
                    side: BorderSide(
                      color: selected
                          ? AppConstants.primaryColor
                          : Colors.grey.shade300,
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          // jumlah hasil
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                '${list.length} surat ditemukan',
                style:
                    const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ),
          ),
          // list
          Expanded(
            child: ctrl.loading
                ? const Center(child: CircularProgressIndicator())
                : list.isEmpty
                    ? _kosong()
                    : ListView.builder(
                        padding: const EdgeInsets.only(bottom: 88),
                        itemCount: list.length,
                        itemBuilder: (_, i) {
                          final s = list[i];
                          return SuratCard(
                            surat: s,
                            onTap: () => _bukaDetail(s.id),
                            onHapus: () =>
                                _konfirmasiHapus(s.id, s.namaPemohon),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Widget _header() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF1A5276), Color(0xFF0D2B42)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 44, 20, 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppConstants.surfaceColor.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.account_balance,
                        color: AppConstants.surfaceColor, size: 24),
                  ),
                  const SizedBox(width: 12),
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'DESA KASONGAN',
                        style: TextStyle(
                            color: AppConstants.surfaceColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            letterSpacing: 1),
                      ),
                      Text(
                        'Sistem Pengelolaan Surat',
                        style:
                            TextStyle(color: AppConstants.textSecondary, fontSize: 11),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // 4 stat
              Row(
                children: [
                  Expanded(
                    child: StatCard(
                        label: 'Total',
                        value: ctrl.total,
                        icon: Icons.mail_outline_rounded,
                        color: AppConstants.surfaceColor),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: StatCard(
                        label: 'Menunggu',
                        value: ctrl.jumlahMenunggu,
                        icon: Icons.hourglass_empty_rounded,
                        color: Colors.orange),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: StatCard(
                        label: 'Diproses',
                        value: ctrl.jumlahDiproses,
                        icon: Icons.sync_rounded,
                        color: Colors.lightBlueAccent),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: StatCard(
                        label: 'Selesai',
                        value: ctrl.jumlahSelesai,
                        icon: Icons.check_circle_rounded,
                        color: Colors.greenAccent),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _kosong() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.inbox_outlined, size: 72, color: Colors.grey.shade300),
          const SizedBox(height: 14),
          const Text('Belum ada surat',
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey)),
          const SizedBox(height: 6),
          const Text(
            'Tekan "Buat Surat" untuk menambahkan',
            style: TextStyle(color: Colors.grey, fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _buildRiwayat() {
    return RiwayatScreen(controller: ctrl);
  }
}
