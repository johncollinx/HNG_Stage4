// lib/viewmodels/coin_list_view_model.dart
import 'package:flutter/material.dart';
import '../models/coin_model.dart';
import '../services/api_service.dart';

// Defines the possible states of the data fetching process
enum CoinListState { initial, loading, loaded, error }

class CoinListViewModel extends ChangeNotifier {
  // Instance of the API service to fetch data
  final ApiService _apiService = ApiService();

  // Private state variables
  List<Coin> _coins = [];
  CoinListState _state = CoinListState.initial;
  String _errorMessage = '';

  // Public getters to expose the state to the UI
  List<Coin> get coins => _coins;
  CoinListState get state => _state;
  String get errorMessage => _errorMessage;

  // Constructor: Starts fetching data immediately when the ViewModel is created
  CoinListViewModel() {
    fetchCoins();
  }

  // Primary method to fetch the coin data
  Future<void> fetchCoins() async {
    // 1. Set state to loading and notify listeners (to show loading indicator)
    _state = CoinListState.loading;
    _errorMessage = '';
    notifyListeners();

    try {
      // 2. Await the fetch, which now includes the dual-fetch and merge logic
      _coins = await _apiService.fetchCoinList();

      // 3. Check results and set final state
      if (_coins.isEmpty) {
        _state = CoinListState.error;
        _errorMessage = "No data available (network issue or API returned empty)";
      } else {
        _state = CoinListState.loaded;
      }
    } catch (e) {
      // 4. Handle any exceptions during the fetch process
      _state = CoinListState.error;
      _errorMessage = e.toString();
      _coins = []; // Clear coins on critical error
    }

    // 5. Notify listeners one final time with the loaded or error state
    notifyListeners();
  }
}
