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

  ChartState get state => _state;
  List<PricePoint> get chartData => _chartData;
  String get selectedTimeline => _selectedTimeline;

  CoinDetailViewModel(this.coin) {
    fetchChartData(_selectedTimeline);
  }

  void setSelectedTimeline(String days) {
    if (_selectedTimeline != days) {
      _selectedTimeline = days;
      fetchChartData(days);
    }
  }

  Future<void> fetchChartData(String days) async {
    _state = ChartState.loading;
    notifyListeners();

    try {
      _chartData = await _apiService.fetchMarketChart(coin.id, days);
      _state = ChartState.loaded;
    } catch (e) {
      _state = ChartState.error;
      debugPrint('Chart fetch error: $e');
    } finally {
      notifyListeners();
    }
  }
}
