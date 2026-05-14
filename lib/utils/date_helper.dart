// lib/utils/date_helper.dart

class DateHelper {
  DateHelper._();

  static final List<String> _bulan = [
    '', 'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
    'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember',
  ];

  /// Contoh: 09 Mei 2026
  static String formatPanjang(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')} '
        '${_bulan[date.month]} '
        '${date.year}';
  }

  /// Contoh: 09/05/2026
  static String formatPendek(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }

  /// Contoh: 09 Mei 2026, 14:30
  static String formatLengkap(DateTime date) {
    return '${formatPanjang(date)}, '
        '${date.hour.toString().padLeft(2, '0')}:'
        '${date.minute.toString().padLeft(2, '0')}';
  }

  /// Contoh: 001/DS-KSG/05/2026
  static String nomorSurat(int counter, DateTime date) {
    return '${counter.toString().padLeft(3, '0')}'
        '/DS-KSG/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }

  /// Contoh: Mei 2026
  static String formatBulanTahun(DateTime date) {
    return '${_bulan[date.month]} ${date.year}';
  }

  /// Contoh: Mei
  static String formatBulanSingkat(DateTime date) {
    return _bulan[date.month];
  }
}
