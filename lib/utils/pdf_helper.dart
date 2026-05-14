// lib/utils/pdf_helper.dart

import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../models/surat_model.dart';

class PdfHelper {
  static const _bulanId = [
    '',
    'Januari',
    'Februari',
    'Maret',
    'April',
    'Mei',
    'Juni',
    'Juli',
    'Agustus',
    'September',
    'Oktober',
    'November',
    'Desember'
  ];

  static String _formatTanggal(DateTime dt) {
    return '${dt.day} ${_bulanId[dt.month]} ${dt.year}';
  }

  /// Generate dan download/print PDF surat
  static Future<void> downloadSurat(SuratModel surat) async {
    // Load logo from assets
    final logoBytes = await rootBundle.load('assets/images/logo_katingan.png');
    final logoImage = pw.MemoryImage(logoBytes.buffer.asUint8List());

    final pdf = pw.Document(
      theme: pw.ThemeData.withFont(
        base: await PdfGoogleFonts.notoSansRegular(),
        bold: await PdfGoogleFonts.notoSansBold(),
        italic: await PdfGoogleFonts.notoSansItalic(),
      ),
    );

    final tanggal = _formatTanggal(surat.tanggalPengajuan);
    final tanggalCetak = _formatTanggal(DateTime.now());

    // Colors
    final hitam = PdfColors.black;
    final abuGelap = PdfColor.fromHex('#333333');
    final abuMuda = PdfColor.fromHex('#888888');

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.symmetric(horizontal: 60, vertical: 48),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.stretch,
            children: [
              // ── KOP SURAT ─────────────────────────────────────────────────
              pw.Row(
                crossAxisAlignment: pw.CrossAxisAlignment.center,
                children: [
                  // Logo kiri
                  pw.Image(logoImage, width: 75, height: 75),
                  pw.SizedBox(width: 16),
                  // Teks kop tengah
                  pw.Expanded(
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.center,
                      children: [
                        pw.Text(
                          'PEMERINTAH KABUPATEN KATINGAN',
                          style: pw.TextStyle(
                            color: hitam,
                            fontSize: 11,
                            fontWeight: pw.FontWeight.normal,
                          ),
                          textAlign: pw.TextAlign.center,
                        ),
                        pw.Text(
                          'KECAMATAN KASONGAN',
                          style: pw.TextStyle(
                            color: hitam,
                            fontSize: 11,
                            fontWeight: pw.FontWeight.normal,
                          ),
                          textAlign: pw.TextAlign.center,
                        ),
                        pw.Text(
                          'DESA KASONGAN',
                          style: pw.TextStyle(
                            color: hitam,
                            fontSize: 17,
                            fontWeight: pw.FontWeight.bold,
                          ),
                          textAlign: pw.TextAlign.center,
                        ),
                        pw.SizedBox(height: 3),
                        pw.Text(
                          'Alamat : Jl. Pangeran Antasari, Kasongan, Kec. Kasongan',
                          style: pw.TextStyle(color: abuGelap, fontSize: 8),
                          textAlign: pw.TextAlign.center,
                        ),
                        pw.Text(
                          'Kab. Katingan, Kalimantan Tengah',
                          style: pw.TextStyle(color: abuGelap, fontSize: 8),
                          textAlign: pw.TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              // Garis tebal bawah kop
              pw.SizedBox(height: 6),
              pw.Container(height: 3, color: hitam),
              pw.Container(height: 1.5, color: PdfColors.white),
              pw.Container(height: 1, color: hitam),
              pw.SizedBox(height: 16),

              // ── JUDUL SURAT ───────────────────────────────────────────────
              pw.Center(
                child: pw.Column(
                  children: [
                    pw.Text(
                      surat.jenisSurat.toUpperCase(),
                      style: pw.TextStyle(
                        color: hitam,
                        fontSize: 13,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                    pw.Text(
                      'Nomor : ${surat.nomorSurat}',
                      style: pw.TextStyle(color: abuGelap, fontSize: 10),
                    ),
                  ],
                ),
              ),
              pw.SizedBox(height: 20),

              // ── PEMBUKA ───────────────────────────────────────────────────
              pw.Text(
                'Yang bertanda tangan di bawah ini menerangkan bahwa :',
                style: pw.TextStyle(color: hitam, fontSize: 11),
              ),
              pw.SizedBox(height: 14),

              // ── DATA PEMOHON (tabel dengan titik dua rata) ────────────────
              _dataRow('Nama', surat.namaPemohon,
                  bold: true, hitam: hitam, abu: abuMuda),
              _dataRow('NIK', surat.nik,
                  bold: true, hitam: hitam, abu: abuMuda),
              _dataRow('Keperluan', surat.keperluan,
                  hitam: hitam, abu: abuMuda),
              if (surat.keterangan.isNotEmpty)
                _dataRow('Keterangan', surat.keterangan,
                    hitam: hitam, abu: abuMuda),
              _dataRow('Tanggal Pengajuan', tanggal,
                  hitam: hitam, abu: abuMuda),
              pw.SizedBox(height: 20),

              // ── ISI SURAT ─────────────────────────────────────────────────
              pw.Text(
                'Dalam hal ini menerangkan bahwa yang bersangkutan tersebut di atas '
                'telah mengajukan permohonan ${surat.jenisSurat} kepada Pemerintah Desa Kasongan '
                'dan permohonan tersebut telah diproses serta telah diselesaikan '
                'sesuai dengan ketentuan yang berlaku.',
                style: pw.TextStyle(
                    color: hitam, fontSize: 11, lineSpacing: 4),
                textAlign: pw.TextAlign.justify,
              ),
              pw.SizedBox(height: 12),
              pw.Text(
                'Demikian surat keterangan ini dibuat dengan sebenar-benarnya untuk '
                'dapat dipergunakan sebagaimana mestinya.',
                style: pw.TextStyle(
                    color: hitam, fontSize: 11, lineSpacing: 4),
                textAlign: pw.TextAlign.justify,
              ),
              pw.SizedBox(height: 32),

              // ── TANDA TANGAN ──────────────────────────────────────────────
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.end,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.center,
                    children: [
                      pw.Text(
                        'Kasongan, $tanggalCetak',
                        style: pw.TextStyle(color: hitam, fontSize: 11),
                      ),
                      pw.SizedBox(height: 4),
                      pw.Text(
                        'Kepala Desa Kasongan,',
                        style: pw.TextStyle(color: hitam, fontSize: 11),
                      ),
                      pw.SizedBox(height: 70),
                      pw.Text(
                        '( ________________________________ )',
                        style: pw.TextStyle(color: hitam, fontSize: 10),
                      ),
                    ],
                  ),
                ],
              ),

              pw.Spacer(),

              // ── FOOTER ────────────────────────────────────────────────────
              pw.Container(height: 0.8, color: abuMuda),
              pw.SizedBox(height: 5),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(
                    'No: ${surat.nomorSurat}  •  Dicetak: $tanggalCetak',
                    style: pw.TextStyle(color: abuMuda, fontSize: 7.5),
                  ),
                  pw.Text(
                    'Sistem Pengelolaan Surat Desa Kasongan',
                    style: pw.TextStyle(color: abuMuda, fontSize: 7.5),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );

    // Buka dialog Print/Download di browser
    await Printing.layoutPdf(
      onLayout: (_) async => pdf.save(),
      name:
          'Surat_${surat.jenisSurat}_${surat.namaPemohon}.pdf'.replaceAll(' ', '_'),
    );
  }

  // Helper: baris data dengan kolom label + titik dua + nilai
  static pw.Widget _dataRow(
    String label,
    String value, {
    bool bold = false,
    required PdfColor hitam,
    required PdfColor abu,
  }) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 5),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.SizedBox(
            width: 120,
            child: pw.Text(
              label,
              style: pw.TextStyle(color: hitam, fontSize: 11),
            ),
          ),
          pw.Text(
            ':   ',
            style: pw.TextStyle(color: hitam, fontSize: 11),
          ),
          pw.Expanded(
            child: pw.Text(
              value,
              style: pw.TextStyle(
                color: hitam,
                fontSize: 11,
                fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
