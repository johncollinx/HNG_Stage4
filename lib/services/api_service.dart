// lib/services/api_service.dart
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../models/coin_model.dart';
import '../models/price_point.dart';

class ApiService {
  static const String _baseUrl = 'https://api.coingecko.com/api/v3';

  /// CACHE UTILITIES 

  bool _isCacheValid(int? timestamp, int minutes) {
    if (timestamp == null) return false;
    final now = DateTime.now().millisecondsSinceEpoch;
    return (now - timestamp) < minutes * 60 * 1000;
  }

  ///FETCH COIN LIST

  Future<List<Coin>> fetchCoinList() async {
    final prefs = await SharedPreferences.getInstance();
    final cachedJson = prefs.getString('cached_coin_list');
    final cachedTime = prefs.getInt('cached_coin_list_time');

    //  Use cache if fresh (5 minutes)
    if (cachedJson != null && _isCacheValid(cachedTime, 5)) {
      try {
        final List data = jsonDecode(cachedJson);
        return data.map((item) => Coin.fromJson(item)).toList();
      } catch (e) {
        debugPrint("Cache decode error: $e");
      }
    }

    // Fetch from API
    try {
      final url = Uri.parse('$_baseUrl/coins/list');

      final response = await http.get(url);

      if (response.statusCode == 200) {
        // Store JSON in cache
        prefs.setString('cached_coin_list', response.body);
        prefs.setInt(
          'cached_coin_list_time',
          DateTime.now().millisecondsSinceEpoch,
        );

        final List data = jsonDecode(response.body);
        return data.map((item) => Coin.fromJson(item)).toList();
      }
    } catch (e) {
      debugPrint("Network fetch error: $e");
    }

    // Fallback to last known cache (if any)
    if (cachedJson != null) {
      final List data = jsonDecode(cachedJson);
      return data.map((item) => Coin.fromJson(item)).toList();
    }

    return [];
  }

  /// FETCH CHART DATA 

  Future<List<PricePoint>> fetchMarketChart(String coinId, String days) async {
    final prefs = await SharedPreferences.getInstance();

    final key = 'chart_${coinId}_$days';
    final timeKey = '${key}_time';

    final cachedJson = prefs.getString(key);
    final cachedTime = prefs.getInt(timeKey);

    // Cache duration per timeline
    final cacheMinutes = {
          '1': 2,
          '7': 10,
          '30': 30,
          '90': 60,
          '365': 1440, // 24 hours
        }[days] ??
        10;

    // Return cached values if fresh
    if (cachedJson != null && _isCacheValid(cachedTime, cacheMinutes)) {
      try {
        final List data = jsonDecode(cachedJson);
        return data
            .map((e) => PricePoint(
                  e['t'] as int,
                  (e['p'] as num).toDouble(),
                ))flutter run -d chrome

            .toList();
      } catch (e) {
        debugPrint("Chart cache decode error: $e");
      }
    }

    // Fetch from API
    try {
      final url = Uri.parse(
        '$_baseUrl/coins/$coinId/market_chart?vs_currency=usd&days=$days',
      );

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        final List<PricePoint> list = (data['prices'] as List)
            .map((row) => PricePoint(
                  (row[0] as num).toInt(),
                  (row[1] as num).toDouble(),
                ))
            .toList();

        // Store compact cache (much smaller JSON)
        final encoded = jsonEncode(
          list.map((p) => {"t": p.timestamp, "p": p.price}).toList(),
        );

        prefs.setString(key, encoded);
        prefs.setInt(
          timeKey,
          DateTime.now().millisecondsSinceEpoch,
        );

        return list;
      }
    } catch (e) {
      debugPrint(" Chart fetch error: $e");
    }

    //  Provide fallback cached chart
    if (cachedJson != null) {
      final List data = jsonDecode(cachedJson);
      return data
          .map((e) => PricePoint(
                e['t'] as int,
                (e['p'] as num).toDouble(),
              ))
          .toList();
    }

    return [];
  }
}
