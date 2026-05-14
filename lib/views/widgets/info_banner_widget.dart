// lib/views/widgets/info_banner_widget.dart

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/cuaca_model.dart';
import '../../models/waktu_model.dart';
import '../../services/info_service.dart';
import '../../utils/app_constants.dart';

class InfoBannerWidget extends StatefulWidget {
  final Color? textColor;
  final Color? subTextColor;

  const InfoBannerWidget({
    super.key,
    this.textColor,
    this.subTextColor,
  });

  @override
  State<InfoBannerWidget> createState() => _InfoBannerWidgetState();
}

class _InfoBannerWidgetState extends State<InfoBannerWidget> {
  CuacaModel? _cuaca;
  WaktuModel? _waktu;
  bool _loading = true;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _loadData();
    // Auto refresh setiap menit untuk update jam
    _timer = Timer.periodic(const Duration(minutes: 1), (_) {
      _loadData();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _loadData() async {
    // Jika data sudah ada, tidak perlu loading spinner penuh
    if (_cuaca == null && _waktu == null) {
      if (mounted) setState(() => _loading = true);
    }
    
    final data = await InfoService.fetchAll();
    
    if (mounted) {
      setState(() {
        _cuaca = data.$1;
        _waktu = data.$2;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Container(
        height: 100,
        margin: const EdgeInsets.only(top: 16),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Center(
          child: CircularProgressIndicator(
            color: AppConstants.primaryColor,
            strokeWidth: 2,
          ),
        ),
      );
    }

    return Container(
      margin: const EdgeInsets.only(top: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.black.withValues(alpha: 0.1)),
      ),
      child: Row(
        children: [
          // ── Kiri: Cuaca ──
          Expanded(
            child: Row(
              children: [
                Text(
                  _cuaca?.emoji ?? '🌍',
                  style: const TextStyle(fontSize: 32),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _cuaca != null ? '${_cuaca!.suhu}°C' : '--°C',
                        style: GoogleFonts.poppins(
                          color: widget.textColor ?? AppConstants.textPrimary,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        _cuaca?.kondisi ?? 'Memuat Cuaca',
                        style: GoogleFonts.poppins(
                          color: widget.subTextColor ?? AppConstants.textSecondary,
                          fontSize: 12,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (_cuaca != null)
                        Text(
                          '💧 ${_cuaca!.kelembaban}%  💨 ${_cuaca!.kecepatanAngin} km/h',
                          style: GoogleFonts.poppins(
                            color: widget.subTextColor ?? AppConstants.textSecondary,
                            fontSize: 10,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          // Pembatas
          Container(
            width: 1,
            height: 50,
            color: Colors.black.withValues(alpha: 0.1),
            margin: const EdgeInsets.symmetric(horizontal: 16),
          ),
          
          // ── Kanan: Tanggal & Waktu ──
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  _waktu?.jamString ?? '--:--',
                  style: GoogleFonts.poppins(
                    color: widget.textColor ?? AppConstants.textPrimary,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                  ),
                ),
                Text(
                  _waktu?.namaHari ?? 'Hari ini',
                  style: GoogleFonts.poppins(
                    color: widget.subTextColor ?? AppConstants.textSecondary,
                    fontSize: 12,
                  ),
                ),
                Text(
                  _waktu?.tanggalPanjang ?? '-- -- ----',
                  style: GoogleFonts.poppins(
                    color: widget.subTextColor ?? AppConstants.textSecondary,
                    fontSize: 10,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
