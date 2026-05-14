// lib/models/waktu_model.dart

class WaktuModel {
  final DateTime dateTime;
  final String timezone;

  WaktuModel({
    required this.dateTime,
    required this.timezone,
  });

  /// Nama hari dalam Bahasa Indonesia
  String get namaHari {
    const hari = [
      'Minggu', 'Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu'
    ];
    return hari[dateTime.weekday % 7];
  }

  /// Nama bulan dalam Bahasa Indonesia
  String get namaBulan {
    const bulan = [
      '', 'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
      'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
    ];
    return bulan[dateTime.month];
  }

  /// Tanggal panjang: "Sabtu, 10 Mei 2026"
  String get tanggalPanjang {
    return '$namaHari, ${dateTime.day} $namaBulan ${dateTime.year}';
  }

  /// Format jam: "09:30"
  String get jamString {
    final h = dateTime.hour.toString().padLeft(2, '0');
    final m = dateTime.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  factory WaktuModel.fromJson(Map<String, dynamic> json) {
    // timeapi.io response format:
    // { "year":2026,"month":5,"day":10,"hour":9,"minute":30,"seconds":15,... }
    final dt = DateTime(
      json['year'] as int,
      json['month'] as int,
      json['day'] as int,
      json['hour'] as int,
      json['minute'] as int,
      json['seconds'] as int,
    );
    return WaktuModel(
      dateTime: dt,
      timezone: json['timeZone'] as String? ?? 'Asia/Jakarta',
    );
  }

  /// Fallback: gunakan waktu lokal device
  factory WaktuModel.fromLocal() {
    return WaktuModel(
      dateTime: DateTime.now(),
      timezone: 'Asia/Jakarta',
    );
  }
}
