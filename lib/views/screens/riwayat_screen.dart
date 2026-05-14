// lib/views/screens/riwayat_screen.dart

import 'package:flutter/material.dart';
import '../../controllers/surat_controller.dart';
import '../../models/surat_model.dart';
import '../../utils/app_constants.dart';
import '../../utils/date_helper.dart';
import 'detail_surat_screen.dart';

class RiwayatScreen extends StatefulWidget {
  final SuratController controller;
  const RiwayatScreen({super.key, required this.controller});

  @override
  State<RiwayatScreen> createState() => _RiwayatScreenState();
}

class _RiwayatScreenState extends State<RiwayatScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tab;

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }

  List<SuratModel> _byStatus(String status) {
    // ambil langsung dari controller tanpa filter/search agar riwayat lengkap
    return widget.controller.daftarTampil()
        .where((s) => s.status == status)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstants.backgroundColor,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: AppConstants.primaryColor,
        foregroundColor: AppConstants.surfaceColor,
        title: const Text('Riwayat Surat'),
        bottom: TabBar(
          controller: _tab,
          indicatorColor: AppConstants.accentColor,
          labelColor: AppConstants.surfaceColor,
          unselectedLabelColor: AppConstants.textSecondary,
          labelStyle: const TextStyle(
              fontWeight: FontWeight.bold, fontSize: 12),
          tabs: [
            Tab(text: 'Menunggu (${_byStatus('Menunggu').length})'),
            Tab(text: 'Diproses (${_byStatus('Diproses').length})'),
            Tab(text: 'Selesai (${_byStatus('Selesai').length})'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tab,
        children: [
          _listByStatus('Menunggu'),
          _listByStatus('Diproses'),
          _listByStatus('Selesai'),
        ],
      ),
    );
  }

  Widget _listByStatus(String status) {
    final list = _byStatus(status);
    final color = AppConstants.statusColor(status);

    if (list.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(AppConstants.statusIcon(status),
                size: 60, color: Colors.grey.shade300),
            const SizedBox(height: 12),
            Text('Tidak ada surat "$status"',
                style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey)),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 10),
      itemCount: list.length,
      itemBuilder: (_, i) => _itemCard(list[i], color),
    );
  }

  Widget _itemCard(SuratModel surat, Color color) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
      shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => DetailSuratScreen(
                  controller: widget.controller,
                  suratId: surat.id),
            ),
          );
          setState(() {});
        },
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(AppConstants.statusIcon(surat.status),
                    color: color, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(surat.jenisSurat,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13)),
                    const SizedBox(height: 2),
                    Text(surat.namaPemohon,
                        style: const TextStyle(
                            fontSize: 12, color: Colors.black54)),
                    const SizedBox(height: 2),
                    Text(surat.nomorSurat,
                        style: TextStyle(
                            fontSize: 11,
                            color: AppConstants.primaryColor
                                .withValues(alpha: 0.8),
                            fontWeight: FontWeight.w500)),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    DateHelper.formatPendek(surat.tanggalPengajuan),
                    style:
                        const TextStyle(fontSize: 11, color: Colors.grey),
                  ),
                  const SizedBox(height: 4),
                  const Icon(Icons.chevron_right,
                      color: Colors.grey, size: 18),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
