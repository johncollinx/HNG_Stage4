// COIN DETAIL SCREEN 
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../models/coin_model.dart';
import '../viewmodels/coin_detail_view_model.dart';
import '../models/price_point.dart';

class DetailScreen extends StatelessWidget {
  final Coin coin;
  const DetailScreen({super.key, required this.coin});

  // Theme Colors
  static const Color _primaryColor = Color(0xFF7B61FF);
  static const Color _positiveColor = Color(0xFF50AF95);
  static const Color _negativeColor = Color(0xFFEF5350);
  static const Color _lightBackground = Color(0xFFF0F3F7);
  static const Color _cardColor = Color(0xFFFFFFFF);
  static const Color _darkTextColor = Color(0xFF1A1A1A);
  static const Color _lightTextColor = Color(0xFF6B6B6B);

  String _formatPrice(double price) {
    final NumberFormat formatter = NumberFormat.compactCurrency(
      symbol: "\$",
      decimalDigits: 2,
    );
    return formatter.format(price);
  }

  String _formatLargeNumber(double number) {
    return NumberFormat.compact().format(number);
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => CoinDetailViewModel(coin),
      child: Consumer<CoinDetailViewModel>(
        builder: (context, viewModel, child) {
          return Scaffold(
            backgroundColor: _lightBackground,
            appBar: _buildAppBar(context),
            body: _buildBody(viewModel),
            bottomNavigationBar: _buildBottomActions(),
          );
        },
      ),
    );
  }

    // APP BAR
  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: _cardColor,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios, color: _darkTextColor),
        onPressed: () => Navigator.of(context).pop(),
      ),
      title: Text(
        '${coin.name} (${coin.symbol.toUpperCase()})',
        style: const TextStyle(
          color: _darkTextColor,
          fontWeight: FontWeight.bold,
          fontSize: 18,
        ),
      ),
      centerTitle: true,
    );
  }

    // SCREEN BODY
  
  Widget _buildBody(CoinDetailViewModel vm) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(coin),
          const SizedBox(height: 24),
          _buildChartCard(vm),
          const SizedBox(height: 24),
          _buildKeyMetrics(coin),
          const SizedBox(height: 24),
          _buildAthAtlSection(coin),
          const SizedBox(height: 24),
          _buildHistorySection(coin),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  
  // HEADER SECTION
  Widget _buildHeader(Coin coin) {
    final bool isPositive = coin.priceChangePercentage24h >= 0;
    final Color changeColor = isPositive ? _positiveColor : _negativeColor;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Image.network(coin.imageUrl, width: 32, height: 32),
            const SizedBox(width: 8),
            Text(
              coin.name,
              style: const TextStyle(
                color: _darkTextColor,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          _formatPrice(coin.currentPrice),
          style: const TextStyle(
            fontSize: 36,
            fontWeight: FontWeight.w900,
            color: _darkTextColor,
          ),
        ),
        Row(
          children: [
            Icon(
              isPositive ? Icons.arrow_upward : Icons.arrow_downward,
              color: changeColor,
              size: 18,
            ),
            Text(
              '${coin.priceChangePercentage24h.toStringAsFixed(2)}%',
              style: TextStyle(
                color: changeColor,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const Text(
              ' (24h)',
              style: TextStyle(color: _lightTextColor, fontSize: 16),
            ),
          ],
        ),
      ],
    );
  }

  
  // TIMELINE SELECTOR
  Widget _buildTimelineSelectors(CoinDetailViewModel vm) {
    const timelines = {
      '1D': '1',
      '7D': '7',
      '1M': '30',
      '3M': '90',
      '1Y': '365'
    };

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: timelines.entries.map((entry) {
        final isSelected = vm.selectedTimeline == entry.value;

        return GestureDetector(
          onTap: () => vm.setSelectedTimeline(entry.value),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: isSelected ? _primaryColor : _lightBackground,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              entry.key,
              style: TextStyle(
                color: isSelected ? _cardColor : _lightTextColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }


  // CHART CARD
  Widget _buildChartCard(CoinDetailViewModel vm) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          SizedBox(height: 250, child: _buildChartContent(vm)),
          const SizedBox(height: 16),
          _buildTimelineSelectors(vm),
        ],
      ),
    );
  }

  
  // CHART CONTENT (FL_CHART)
  Widget _buildChartContent(CoinDetailViewModel vm) {
    if (vm.state == ChartState.loading) {
      return const Center(
          child: CircularProgressIndicator(color: _primaryColor));
    }

    if (vm.state == ChartState.error) {
      return const Center(
        child: Text("Failed to load chart data.",
            style: TextStyle(color: _negativeColor)),
      );
    }

    if (vm.chartData.isEmpty) {
      return const Center(child: Text("No chart data available."));
    }

    final data = vm.chartData;

    final minPrice = data.map((e) => e.price).reduce((a, b) => a < b ? a : b);
    final maxPrice = data.map((e) => e.price).reduce((a, b) => a > b ? a : b);
    final initial = data.first.price;
    final last = data.last.price;

    final lineColor = last >= initial ? _positiveColor : _negativeColor;

    return LineChart(
      LineChartData(
        minX: 0,
        maxX: (data.length - 1).toDouble(),
        minY: minPrice * 0.99,
        maxY: maxPrice * 1.01,
        borderData: FlBorderData(show: false),
        gridData: const FlGridData(show: false),
        titlesData: FlTitlesData(
          rightTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 45,
              getTitlesWidget: (value, meta) {
                return Text(
                  _formatPrice(value),
                  style: const TextStyle(color: _lightTextColor, fontSize: 10),
                  textAlign: TextAlign.right,
                );
              },
            ),
          ),
        ),
        lineBarsData: [
          LineChartBarData(
            isCurved: true,
            color: lineColor,
            barWidth: 3,
            dotData: const FlDotData(show: false),
            spots: data
                .asMap()
                .entries
                .map((entry) => FlSpot(entry.key.toDouble(), entry.value.price))
                .toList(),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  lineColor.withOpacity(0.25),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ],
        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
            tooltipBgColor: _darkTextColor.withOpacity(0.9),
            getTooltipItems: (spots) => spots.map((spot) {
              final pricePoint = data[spot.spotIndex];
              return LineTooltipItem(
                _formatPrice(pricePoint.price),
                const TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold),
                children: [
                  TextSpan(
                    text:
                        "\n${DateFormat('MMM dd, yyyy').format(DateTime.fromMillisecondsSinceEpoch(pricePoint.timestamp))}",
                    style: TextStyle(color: Colors.white70, fontSize: 10),
                  ),
                ],
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  
  // KEY METRICS
  Widget _buildKeyMetrics(Coin coin) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Key Market Metrics',
          style: TextStyle(
              color: _darkTextColor, fontWeight: FontWeight.bold, fontSize: 20),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: _cardColor,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                  color: Colors.black12, blurRadius: 10, offset: Offset(0, 5)),
            ],
          ),
          child: Column(
            children: [
              _buildMetricRow("Market Cap Rank", "#${coin.marketCapRank}"),
              _buildMetricRow("Market Cap", _formatPrice(coin.marketCap)),
              _buildMetricRow("24h High", _formatPrice(coin.high24h)),
              _buildMetricRow("24h Low", _formatPrice(coin.low24h)),
              _buildMetricRow("Circulating Supply",
                  _formatLargeNumber(coin.circulatingSupply)),
              _buildMetricRow(
                  "Total Volume (24h)", _formatPrice(coin.totalVolume)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMetricRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: const TextStyle(color: _lightTextColor, fontSize: 15)),
          Text(value,
              style: const TextStyle(
                  color: _darkTextColor,
                  fontSize: 16,
                  fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  
  // ATH / ATL SECTION
  Widget _buildAthAtlSection(Coin coin) {
    final double ath = coin.currentPrice * 2.5;
    final double atl = coin.currentPrice * 0.25;

    final double fromAth = ((coin.currentPrice - ath) / ath) * 100;
    final double fromAtl = ((coin.currentPrice - atl) / atl) * 100;

    final athDate = DateTime.now().subtract(const Duration(days: 400));
    final atlDate = DateTime.now().subtract(const Duration(days: 1000));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "All-Time High / Low",
          style: TextStyle(
              color: _darkTextColor, fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: _cardColor,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                  color: Colors.black12, blurRadius: 10, offset: Offset(0, 5)),
            ],
          ),
          child: Column(
            children: [
              _buildAthAtlRow("All-Time High (ATH)", _formatPrice(ath), fromAth,
                  athDate, _negativeColor),
              const Divider(height: 28),
              _buildAthAtlRow("All-Time Low (ATL)", _formatPrice(atl), fromAtl,
                  atlDate, _positiveColor),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAthAtlRow(
      String title, String price, double change, DateTime date, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title,
              style: const TextStyle(color: _lightTextColor, fontSize: 14)),
          const SizedBox(height: 4),
          Text(price,
              style: const TextStyle(
                  color: _darkTextColor,
                  fontSize: 18,
                  fontWeight: FontWeight.bold)),
        ]),
        Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
          Text("${change.toStringAsFixed(2)}%",
              style: TextStyle(
                  color: color, fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 4),
          Text(DateFormat("MMM dd, yyyy").format(date),
              style: const TextStyle(color: _lightTextColor, fontSize: 12)),
        ]),
      ],
    );
  }

  
  // HISTORY SECTION
  Widget _buildHistorySection(Coin coin) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Coin History",
            style: TextStyle(
                color: _darkTextColor,
                fontSize: 20,
                fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: _cardColor,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                  color: Colors.black12, blurRadius: 10, offset: Offset(0, 5)),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("About ${coin.name}",
                  style: const TextStyle(
                      color: _darkTextColor,
                      fontSize: 18,
                      fontWeight: FontWeight.bold)),
              const SizedBox(height: 6),
              Text(
                coin.description,
                style: const TextStyle(color: _lightTextColor, height: 1.5),
              ),
              const SizedBox(height: 10),
              const Text("Read More...",
                  style: TextStyle(
                      color: _primaryColor, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ],
    );
  }

  
  // BOTTOM ACTIONS
  Widget _buildBottomActions() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _cardColor,
        boxShadow: [
          BoxShadow(
              color: Colors.black26, blurRadius: 10, offset: Offset(0, -2)),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.add_shopping_cart),
              label: const Text("Buy"),
              style: ElevatedButton.styleFrom(
                backgroundColor: _primaryColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                minimumSize: const Size(0, 50),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.money_off),
              label: const Text("Sell"),
              style: OutlinedButton.styleFrom(
                foregroundColor: _primaryColor,
                side: const BorderSide(color: _primaryColor, width: 2),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                minimumSize: const Size(0, 50),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
