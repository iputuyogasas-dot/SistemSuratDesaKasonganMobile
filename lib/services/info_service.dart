// lib/services/info_service.dart

import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/cuaca_model.dart';
import '../models/waktu_model.dart';

class InfoService {
  InfoService._();

  // ── Koordinat Kasongan, Kab. Katingan, Kalteng ─────────────────────────────
  static const double _lat = -1.883;
  static const double _lon = 113.600;

  // ── URL API ────────────────────────────────────────────────────────────────
  static final Uri _cuacaUrl = Uri.parse(
    'https://api.open-meteo.com/v1/forecast'
    '?latitude=$_lat'
    '&longitude=$_lon'
    '&current=temperature_2m,relative_humidity_2m,weather_code,wind_speed_10m'
    '&timezone=Asia%2FBangkok'
    '&wind_speed_unit=kmh',
  );

  static final Uri _waktuUrl = Uri.parse(
    'https://timeapi.io/api/time/current/zone?timeZone=Asia%2FJakarta',
  );

  // ── Fetch Cuaca ────────────────────────────────────────────────────────────
  static Future<CuacaModel?> fetchCuaca() async {
    try {
      final response = await http
          .get(_cuacaUrl)
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        return CuacaModel.fromJson(json);
      }
    } catch (e) {
      debugPrint('fetchCuaca error: $e');
    }
    return null;
  }

  // ── Fetch Waktu ────────────────────────────────────────────────────────────
  static Future<WaktuModel> fetchWaktu() async {
    try {
      final response = await http
          .get(_waktuUrl)
          .timeout(const Duration(seconds: 8));

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        return WaktuModel.fromJson(json);
      }
    } catch (e) {
      debugPrint('fetchWaktu error: $e');
    }
    // Fallback ke waktu lokal device
    return WaktuModel.fromLocal();
  }

  // ── Fetch Keduanya Sekaligus ───────────────────────────────────────────────
  static Future<(CuacaModel?, WaktuModel)> fetchAll() async {
    final results = await Future.wait([
      fetchCuaca(),
      fetchWaktu(),
    ]);
    return (results[0] as CuacaModel?, results[1] as WaktuModel);
  }
}
