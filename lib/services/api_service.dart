// lib/services/api_service.dart
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../models/coin_model.dart';
import '../models/price_point.dart';

class ApiService {
  static const String _baseUrl = 'https://api.coingecko.com/api/v3';

  /// ---------------------- CACHE UTILITIES ----------------------

  bool _isCacheValid(int? timestamp, int minutes) {
    if (timestamp == null) return false;
    final now = DateTime.now().millisecondsSinceEpoch;
    return (now - timestamp) < minutes * 60 * 1000;
  }

  /// ---------------------- FETCH COIN LIST ----------------------

  Future<List<Coin>> fetchCoinList() async {
    final prefs = await SharedPreferences.getInstance();
    final cachedJson = prefs.getString('cached_coin_list');
    final cachedTime = prefs.getInt('cached_coin_list_time');

    // 1. Use cache if it's fresh (valid for 5 minutes)
    if (cachedJson != null && _isCacheValid(cachedTime, 5)) {
      try {
        final List<dynamic> cachedData = jsonDecode(cachedJson);
        return cachedData.map((json) => Coin.fromJson(json)).toList();
      } catch (_) {}
    }

    // 2. Fetch from network
    try {
      final url = Uri.parse(
          '$_baseUrl/coins/markets?vs_currency=usd&order=market_cap_desc&per_page=50&page=1&sparkline=false');

      final response = await http.get(url);

      if (response.statusCode == 200) {
        // Save fresh cache
        prefs.setString('cached_coin_list', response.body);
        prefs.setInt('cached_coin_list_time',
            DateTime.now().millisecondsSinceEpoch);

        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => Coin.fromJson(json)).toList();
      }
    } catch (e) {
      debugPrint('Coin list fetch error: $e');
    }

    // 3. If network fails, return last known cached data
    if (cachedJson != null) {
      final List<dynamic> fallback = jsonDecode(cachedJson);
      return fallback.map((json) => Coin.fromJson(json)).toList();
    }

    return [];
  }

  /// ---------------------- FETCH CHART DATA ----------------------

  Future<List<PricePoint>> fetchMarketChart(String coinId, String days) async {
    final prefs = await SharedPreferences.getInstance();

    final key = 'chart_${coinId}_$days';
    final timeKey = '${key}_time';

    final cachedJson = prefs.getString(key);
    final cachedTime = prefs.getInt(timeKey);

    // Cache duration varies by selected timeline
    int cacheMinutes = {
      '1': 2,     // 1D refresh often
      '7': 10,
      '30': 30,
      '90': 60,
      '365': 1440, // 24 hours
    }[days] ?? 10;

    // 1. Use cached chart data if valid
    if (cachedJson != null && _isCacheValid(cachedTime, cacheMinutes)) {
      try {
        final List data = jsonDecode(cachedJson);
        return data
            .map((e) => PricePoint(e['t'] as int, (e['p'] as num).toDouble()))
            .toList();
      } catch (_) {}
    }

    // 2. Fetch real-time data
    try {
      final url = Uri.parse(
          '$_baseUrl/coins/$coinId/market_chart?vs_currency=usd&days=$days');

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        final List<PricePoint> list = (data['prices'] as List)
            .map((e) =>
                PricePoint((e[0] as num).toInt(), (e[1] as num).toDouble()))
            .toList();

        // Save cache
        final encoded = jsonEncode(
          list
              .map((e) => {"t": e.timestamp, "p": e.price})
              .toList(),
        );

        prefs.setString(key, encoded);
        prefs.setInt(timeKey, DateTime.now().millisecondsSinceEpoch);

        return list;
      }
    } catch (e) {
      debugPrint('Chart fetch error: $e');
    }

    // 3. Return cached fallback if available
    if (cachedJson != null) {
      final List data = jsonDecode(cachedJson);
      return data
          .map((e) => PricePoint(e['t'] as int, (e['p'] as num).toDouble()))
          .toList();
    }

    return [];
  }
}
