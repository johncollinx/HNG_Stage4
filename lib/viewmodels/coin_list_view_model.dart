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
    _errorMessage = ''; // Clear previous errors
    notifyListeners();

    try {
      _coins = await _apiService.fetchCoinList();
      _state = CoinListState.loaded;
    } catch (e) {
      // CRITICAL FIX: Catch the exception thrown by ApiService
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      _state = CoinListState.error;
      // Ensure the coin list is empty on error
      _coins = []; 
      print('VM Caught Error: $_errorMessage'); 
    }
    notifyListeners();
  }
}
