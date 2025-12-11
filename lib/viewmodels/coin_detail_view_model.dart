// lib/viewmodels/coin_detail_view_model.dart
import 'package:flutter/material.dart';
import '../models/coin_model.dart';
import '../models/price_point.dart';
import '../services/api_service.dart';

enum ChartState { loading, loaded, error }

class CoinDetailViewModel extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  final Coin coin;

  ChartState _state = ChartState.loading;
  List<PricePoint> _chartData = [];
  String _selectedTimeline = '7'; // Default to 7 days
  String _errorMessage = ''; // Added error message field

  ChartState get state => _state;
  List<PricePoint> get chartData => _chartData;
  String get selectedTimeline => _selectedTimeline;
  String get errorMessage => _errorMessage; // Getter for the error message

  CoinDetailViewModel(this.coin) {
    // Start fetching data for the default timeline when the ViewModel is created
    fetchChartData(_selectedTimeline);
  }

  void setSelectedTimeline(String days) {
    if (_selectedTimeline != days) {
      _selectedTimeline = days;
      // Start the new fetch (fetchChartData handles setting state and notifying)
      fetchChartData(days);
    }
  }

  Future<void> fetchChartData(String days) async {
    _state = ChartState.loading;
    _errorMessage = ''; // Clear previous errors
    notifyListeners();

    try {
      _chartData = await _apiService.fetchMarketChart(coin.id, days);
      
      // Check if data was successfully received
      if (_chartData.isEmpty) {
         _state = ChartState.error;
         _errorMessage = 'No chart data available for this period.';
      } else {
         _state = ChartState.loaded;
      }
    } catch (e) {
      _state = ChartState.error;
      _errorMessage = 'Failed to load chart data: ${e.toString()}'; // Capture error details
      debugPrint('Chart fetch error: $e');
    } finally { // <-- FIX: Corrected syntax
      notifyListeners();
    }
  }
}
