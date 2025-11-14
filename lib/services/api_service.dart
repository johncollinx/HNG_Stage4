// lib/services/api_service.dart
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/coin_model.dart';
import '../models/price_point.dart';

class ApiService {
  static const String _baseUrl = 'https://api.coingecko.com/api/v3';

  /// Fetch the list of coins (basic info)
  Future<List<Coin>> fetchCoinList() async {
    try {
      final url = Uri.parse(
          '$_baseUrl/coins/markets?vs_currency=usd&order=market_cap_desc&per_page=50&page=1&sparkline=false');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => Coin.fromJson(json)).toList();
      } else {
        throw Exception('Failed to fetch coin list');
      }
    } catch (e) {
      debugPrint('Coin list fetch error: $e');
      return [];
    }
  }

  /// Fetch real-time historical market chart for a coin
  /// days: '1', '7', '30', '90', '365'
  Future<List<PricePoint>> fetchMarketChart(String coinId, String days) async {
    try {
      final url = Uri.parse(
          '$_baseUrl/coins/$coinId/market_chart?vs_currency=usd&days=$days');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // 'prices' is a List of [timestamp, price]
        final List<PricePoint> chartData = (data['prices'] as List)
            .map((item) => PricePoint(
                  item[0].toInt(),
                  (item[1] as num).toDouble(),
                ))
            .toList();

        return chartData;
      } else {
        throw Exception('Failed to load chart data');
      }
    } catch (e) {
      debugPrint('Chart fetch error: $e');
      return [];
    }
  }
}
