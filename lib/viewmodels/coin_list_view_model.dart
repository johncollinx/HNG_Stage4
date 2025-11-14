// lib/viewmodels/coin_list_view_model.dart
import 'package:flutter/material.dart';
import '../models/coin_model.dart';
import '../services/api_service.dart';

enum CoinListState { initial, loading, loaded, error }

class CoinListViewModel extends ChangeNotifier {
  final ApiService _apiService = ApiService();

  List<Coin> _coins = [];
  CoinListState _state = CoinListState.initial;
  String _errorMessage = '';

  List<Coin> get coins => _coins;
  CoinListState get state => _state;
  String get errorMessage => _errorMessage;

  CoinListViewModel() {
    fetchCoins();
  }

  Future<void> fetchCoins() async {
    _state = CoinListState.loading;
    _errorMessage = '';
    notifyListeners();

    try {
      // SINGLE unified method (auto-caches + fallback built in)
      _coins = await _apiService.fetchCoinList();

      if (_coins.isEmpty) {
        _state = CoinListState.error;
        _errorMessage = "No data available (network offline + no cache)";
      } else {
        _state = CoinListState.loaded;
      }
    } catch (e) {
      _state = CoinListState.error;
      _errorMessage = e.toString();
      _coins = [];
    }

    notifyListeners();
  }
}
