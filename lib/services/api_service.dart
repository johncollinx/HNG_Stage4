// lib/services/api_service.dart
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../models/coin_model.dart';
import '../models/price_point.dart';

class ApiService {
  static const String _baseUrl = 'https://api.coingecko.com/api/v3';

  // --- COIN IDs TO SPECIFICALLY INCLUDE ---
  // Using the correct CoinGecko API IDs/slugs.
  static const List<String> _requiredCoinIds = [
    'ice-network',   // Confirmed ID for Ice Open Network
    'tron',          // ID for TRON (TRX)
    'binancecoin',   // ID for BNB
    'stacks',        // ID for STACKS (STX)
    'luno-coin',     // ASSUMED ID for LUNO (Adjust if error occurs)
  ];
  // ------------------------------------------

  /// CACHE UTILITIES 

  bool _isCacheValid(int? timestamp, int minutes) {
    if (timestamp == null) return false;
    final now = DateTime.now().millisecondsSinceEpoch;
    return (now - timestamp) < minutes * 60 * 1000;
  }

  /// STEP 1: FETCH TOP 50 MARKET COINS + REQUIRED COINS

  Future<List<Coin>> fetchCoinList() async {
    final prefs = await SharedPreferences.getInstance();
    final cachedJson = prefs.getString('cached_coin_list');
    final cachedTime = prefs.getInt('cached_coin_list_time');

    // Use cache if fresh (5 minutes)
    if (cachedJson != null && _isCacheValid(cachedTime, 5)) {
      try {
        final List data = jsonDecode(cachedJson);
        return data.map((item) => Coin.fromJson(item)).toList();
      } catch (e) {
        debugPrint("Cache decode error: $e");
      }
    }

    // List to hold the final merged coins
    List<Coin> mergedCoinList = [];

    try {
      // 1. FETCH THE TOP 50 COINS (Rich Market Data)
      final topNUrl = Uri.parse(
        '$_baseUrl/coins/markets?vs_currency=usd&order=market_cap_desc&per_page=50&page=1&sparkline=false',
      );

      final topNResponse = await http.get(topNUrl);

      if (topNResponse.statusCode == 200) {
        final List topNData = jsonDecode(topNResponse.body);
        mergedCoinList.addAll(topNData.map((item) => Coin.fromJson(item)).toList());
      } else {
         debugPrint("Error fetching Top 50: ${topNResponse.statusCode}");
      }

      // 2. FETCH THE SPECIFIC REQUIRED COINS
      final specificCoins = await _fetchSpecificCoins(_requiredCoinIds);

      // 3. MERGE AND CLEANUP
      // Identify IDs already present in the Top N list
      final topNIds = mergedCoinList.map((coin) => coin.id).toSet();
      
      // Add specific coins only if their ID is NOT in the Top N list
      for (var coin in specificCoins) {
        if (!topNIds.contains(coin.id)) {
          mergedCoinList.add(coin);
        }
      }
      
      // OPTIONAL: Sort the final list by rank again to ensure the newly added 
      // coins appear in order if they have valid marketCapRank (or are at the bottom).
      mergedCoinList.sort((a, b) => a.marketCapRank.compareTo(b.marketCapRank));

      // Store merged JSON in cache (Need Coin.toJson() for this)
      // Assuming your Coin model has a toJson() method:
      final finalEncodedBody = jsonEncode(mergedCoinList.map((c) => c.toJson()).toList());
      
      prefs.setString('cached_coin_list', finalEncodedBody);
      prefs.setInt(
        'cached_coin_list_time',
        DateTime.now().millisecondsSinceEpoch,
      );
      
      return mergedCoinList;

    } catch (e) {
      debugPrint("Network fetch/merge error: $e");
    }

    // Fallback to last known cache (if any)
    if (cachedJson != null) {
      final List data = jsonDecode(cachedJson);
      return data.map((item) => Coin.fromJson(item)).toList();
    }

    return [];
  }

  /// NEW HELPER: FETCH DATA FOR SPECIFIC COIN IDs

  Future<List<Coin>> _fetchSpecificCoins(List<String> coinIds) async {
    if (coinIds.isEmpty) return [];

    try {
      final idsParam = coinIds.join(',');
      
      // Filter the /markets endpoint by the 'ids' parameter
      final url = Uri.parse(
        '$_baseUrl/coins/markets?vs_currency=usd&ids=$idsParam&sparkline=false',
      );

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);
        return data.map((item) => Coin.fromJson(item)).toList();
      }
    } catch (e) {
      debugPrint("Specific coin fetch error: $e");
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
                ))
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
