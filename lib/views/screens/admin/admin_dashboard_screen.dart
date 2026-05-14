// lib/views/screens/admin/admin_dashboard_screen.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../controllers/surat_controller.dart';
import '../../../utils/app_constants.dart';

class AdminDashboardScreen extends StatelessWidget {
  final SuratController suratController;

  const AdminDashboardScreen({super.key, required this.suratController});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: suratController,
      builder: (context, _) {
        final total = suratController.total;
        final menunggu = suratController.jumlahMenunggu;
        final diproses = suratController.jumlahDiproses;
        final selesai = suratController.jumlahSelesai;
        final perBulan = suratController.getSuratPerBulan();

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Header ──
              Text('Dashboard Statistik',
                  style: GoogleFonts.poppins(
                      color: AppConstants.textPrimary,
                      fontSize: 20,
                      fontWeight: FontWeight.bold)),
              Text('Ringkasan data surat desa',
                  style: GoogleFonts.poppins(
                      color: AppConstants.textSecondary, fontSize: 13)),
              const SizedBox(height: 20),

              // ── Stat Cards ──
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.9,
                children: [
                  _bigStatCard('Total Surat', total.toString(),
                      Icons.article_rounded, AppConstants.primaryColor),
                  _bigStatCard('Menunggu', menunggu.toString(),
                      Icons.hourglass_empty_rounded, AppConstants.accentColor),
                  _bigStatCard('Diproses', diproses.toString(),
                      Icons.sync_rounded, AppConstants.secondaryColor),
                  _bigStatCard('Selesai', selesai.toString(),
                      Icons.check_circle_rounded, AppConstants.successColor),
                ],
              ),
              const SizedBox(height: 24),

              // ── Pie Chart Status ──
              if (total > 0) ...[
                _sectionTitle('Distribusi Status Surat'),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppConstants.surfaceColor,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                        color: AppConstants.surfaceLight, width: 1),
                  ),
                  child: Column(
                    children: [
                      SizedBox(
                        height: 200,
                        child: PieChart(
                          PieChartData(
                            sectionsSpace: 3,
                            centerSpaceRadius: 50,
                            sections: [
                              if (menunggu > 0)
                                _pieSection(
                                    menunggu, total, AppConstants.accentColor,
                                    'Menunggu'),
                              if (diproses > 0)
                                _pieSection(diproses, total,
                                    AppConstants.secondaryColor, 'Diproses'),
                              if (selesai > 0)
                                _pieSection(selesai, total,
                                    AppConstants.successColor, 'Selesai'),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Legend
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _legendItem('Menunggu', AppConstants.accentColor,
                              menunggu),
                          const SizedBox(width: 16),
                          _legendItem(
                              'Diproses', AppConstants.secondaryColor, diproses),
                          const SizedBox(width: 16),
                          _legendItem(
                              'Selesai', AppConstants.successColor, selesai),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
              ],

              // ── Bar Chart per Bulan ──
              _sectionTitle('Surat per Bulan (6 Bulan Terakhir)'),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppConstants.surfaceColor,
                  borderRadius: BorderRadius.circular(20),
                  border:
                      Border.all(color: AppConstants.surfaceLight, width: 1),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      height: 200,
                      child: BarChart(
                        BarChartData(
                          alignment: BarChartAlignment.spaceAround,
                          maxY: _maxBarValue(perBulan) + 1,
                          barTouchData: BarTouchData(
                            touchTooltipData: BarTouchTooltipData(
                              getTooltipColor: (_) => AppConstants.surfaceLight,
                              getTooltipItem: (group, groupIdx, rod, rodIdx) {
                                final label =
                                    perBulan.keys.elementAt(group.x);
                                return BarTooltipItem(
                                  '$label\n${rod.toY.toInt()} surat',
                                  GoogleFonts.poppins(
                                      color: AppConstants.textPrimary,
                                      fontSize: 11),
                                );
                              },
                            ),
                          ),
                          titlesData: FlTitlesData(
                            show: true,
                            leftTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                reservedSize: 28,
                                getTitlesWidget: (val, meta) {
                                  if (val % 1 != 0) return const SizedBox();
                                  return Text(
                                    val.toInt().toString(),
                                    style: GoogleFonts.poppins(
                                        color: AppConstants.textSecondary,
                                        fontSize: 10),
                                  );
                                },
                              ),
                            ),
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                reservedSize: 32,
                                getTitlesWidget: (val, meta) {
                                  final idx = val.toInt();
                                  if (idx >= perBulan.length) {
                                    return const SizedBox();
                                  }
                                  final label =
                                      perBulan.keys.elementAt(idx);
                                  // Ambil 3 huruf pertama bulan
                                  final short = label.length > 3
                                      ? label.substring(0, 3)
                                      : label;
                                  return Padding(
                                    padding: const EdgeInsets.only(top: 6),
                                    child: Text(short,
                                        style: GoogleFonts.poppins(
                                            color: AppConstants.textSecondary,
                                            fontSize: 10)),
                                  );
                                },
                              ),
                            ),
                            topTitles: const AxisTitles(
                                sideTitles: SideTitles(showTitles: false)),
                            rightTitles: const AxisTitles(
                                sideTitles: SideTitles(showTitles: false)),
                          ),
                          gridData: FlGridData(
                            show: true,
                            drawVerticalLine: false,
                            getDrawingHorizontalLine: (_) => FlLine(
                              color: AppConstants.surfaceLight,
                              strokeWidth: 1,
                            ),
                          ),
                          borderData: FlBorderData(show: false),
                          barGroups: List.generate(
                            perBulan.length,
                            (i) => BarChartGroupData(
                              x: i,
                              barRods: [
                                BarChartRodData(
                                  toY: perBulan.values.elementAt(i).toDouble(),
                                  gradient: AppConstants.primaryGradient,
                                  width: 22,
                                  borderRadius: const BorderRadius.vertical(
                                      top: Radius.circular(6)),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // ── Info Summary ──
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppConstants.primaryColor.withValues(alpha: 0.15),
                      AppConstants.secondaryColor.withValues(alpha: 0.15),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                      color: AppConstants.primaryColor.withValues(alpha: 0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline_rounded,
                        color: AppConstants.primaryColor),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Tingkat Penyelesaian',
                              style: GoogleFonts.poppins(
                                  color: AppConstants.textPrimary,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13)),
                          Text(
                            total > 0
                                ? '${((selesai / total) * 100).toStringAsFixed(1)}% surat sudah selesai diproses'
                                : 'Belum ada data surat',
                            style: GoogleFonts.poppins(
                                color: AppConstants.textSecondary,
                                fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  Widget _sectionTitle(String title) => Text(
        title,
        style: GoogleFonts.poppins(
          color: AppConstants.textPrimary,
          fontSize: 15,
          fontWeight: FontWeight.w600,
        ),
      );

  Widget _bigStatCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(height: 6),
          Text(value,
              style: GoogleFonts.poppins(
                  color: color,
                  fontWeight: FontWeight.bold,
                  fontSize: 22)),
          Text(label,
              style: GoogleFonts.poppins(
                  color: AppConstants.textSecondary, fontSize: 10)),
        ],
      ),
    );
  }

  PieChartSectionData _pieSection(
      int value, int total, Color color, String title) {
    final pct = (value / total * 100).toStringAsFixed(1);
    return PieChartSectionData(
      color: color,
      value: value.toDouble(),
      title: '$pct%',
      radius: 60,
      titleStyle: GoogleFonts.poppins(
        color: AppConstants.surfaceColor,
        fontWeight: FontWeight.bold,
        fontSize: 11,
      ),
    );
  }

  Widget _legendItem(String label, Color color, int value) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration:
              BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text('$label ($value)',
            style: GoogleFonts.poppins(
                color: AppConstants.textSecondary, fontSize: 11)),
      ],
    );
  }

  double _maxBarValue(Map<String, int> data) {
    if (data.isEmpty) return 5;
    final max = data.values.reduce((a, b) => a > b ? a : b);
    return max < 5 ? 5 : max.toDouble();
  }
}
