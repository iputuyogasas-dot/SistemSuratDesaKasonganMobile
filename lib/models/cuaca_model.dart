// lib/models/cuaca_model.dart

class CuacaModel {
  final double suhu;         // °C
  final double kelembaban;   // %
  final int weatherCode;     // WMO code
  final double kecepatanAngin; // km/h
  final DateTime waktuUpdate;

  CuacaModel({
    required this.suhu,
    required this.kelembaban,
    required this.weatherCode,
    required this.kecepatanAngin,
    required this.waktuUpdate,
  });

  /// Deskripsi kondisi cuaca dari WMO weather code
  String get kondisi {
    if (weatherCode == 0) return 'Cerah';
    if (weatherCode <= 3) return 'Berawan';
    if (weatherCode <= 48) return 'Berkabut';
    if (weatherCode <= 55) return 'Gerimis';
    if (weatherCode <= 65) return 'Hujan';
    if (weatherCode <= 75) return 'Salju';
    if (weatherCode <= 82) return 'Hujan Lebat';
    if (weatherCode <= 86) return 'Hujan Es';
    if (weatherCode <= 99) return 'Badai Petir';
    return 'Tidak Diketahui';
  }

  /// Emoji icon dari kondisi cuaca
  String get emoji {
    if (weatherCode == 0) return '☀️';
    if (weatherCode <= 2) return '🌤️';
    if (weatherCode == 3) return '☁️';
    if (weatherCode <= 48) return '🌫️';
    if (weatherCode <= 55) return '🌦️';
    if (weatherCode <= 65) return '🌧️';
    if (weatherCode <= 82) return '⛈️';
    if (weatherCode <= 99) return '🌩️';
    return '🌡️';
  }

  factory CuacaModel.fromJson(Map<String, dynamic> json) {
    final current = json['current'] as Map<String, dynamic>;
    return CuacaModel(
      suhu: (current['temperature_2m'] as num).toDouble(),
      kelembaban: (current['relative_humidity_2m'] as num).toDouble(),
      weatherCode: (current['weather_code'] as num).toInt(),
      kecepatanAngin: (current['wind_speed_10m'] as num).toDouble(),
      waktuUpdate: DateTime.now(),
    );
  }
}
