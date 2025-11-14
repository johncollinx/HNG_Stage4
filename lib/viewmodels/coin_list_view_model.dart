// lib/viewmodels/coin_list_view_model.dart
import 'package:flutter/material.dart';
import '../models/coin_model.dart';
import '../services/api_service.dart';

enum CoinListState { initial, loading, loaded, cached, error }

class CoinListViewModel extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  
  List<Coin> _coins = [];
  CoinListState _state = CoinListState.initial;
  String _errorMessage = '';

  List<Coin> get coins => _coins;
  CoinListState get state => _state;
  String get errorMessage => _errorMessage;

  CoinListViewModel() {
    loadCoinList();
  }

  /// NEW → Loads cached first, then refreshes network
  Future<void> loadCoinList() async {
    _state = CoinListState.loading;
    notifyListeners();

    // 1️⃣ Load from cache first
    final cachedCoins = await _apiService.getCachedCoinList();

    if (cachedCoins.isNotEmpty) {
      _coins = cachedCoins;
      _state = CoinListState.cached; // UI shows old data immediately
      notifyListeners();
    }

    // 2️⃣ Then fetch fresh data
    await fetchCoins();
  }

  Future<void> fetchCoins() async {
    try {
      final freshData = await _apiService.fetchCoinListWithCache();

      if (freshData.isNotEmpty) {
        _coins = freshData;
        _state = CoinListState.loaded;
      } else {
        // If we already displayed cached data, avoid switching to error state.
        if (_state != CoinListState.cached) {
          _state = CoinListState.error;
          _errorMessage = "Unable to load latest data";
        }
      }
    } catch (e) {
      _errorMessage = e.toString();

      // Only show error if there was no cached data earlier
      if (_state != CoinListState.cached) {
        _coins = [];
        _state = CoinListState.error;
      }
    }

    notifyListeners();
  }
}
