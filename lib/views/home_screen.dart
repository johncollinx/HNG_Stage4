import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/coin_model.dart';
import '../viewmodels/coin_list_view_model.dart';
import 'detail_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  // Define consistent theme colors
  static const Color _primaryColor = Color(0xFF7B61FF);
  static const Color _positiveColor = Color(0xFF50AF95);
  static const Color _negativeColor = Color(0xFFEF5350);
  // Light Theme Colors
  static const Color _lightBackground =
      Color(0xFFF0F3F7); // Soft light gray background
  static const Color _cardColor =
      Color(0xFFFFFFFF); // Pure white cards/surfaces
  static const Color _darkTextColor =
      Color(0xFF1A1A1A); // Dark text for contrast
  static const Color _lightTextColor = Color(0xFF6B6B6B); // Gray secondary text

  // Helper to format currency
  String _formatCurrency(double amount) {
    return NumberFormat.currency(locale: 'en_US', symbol: '\$').format(amount);
  }

  // Helper to format large numbers like Market Cap
  String _formatLargeNumber(double number) {
    if (number >= 1e12) {
      return '${(number / 1e12).toStringAsFixed(2)}T';
    } else if (number >= 1e9) {
      return '${(number / 1e9).toStringAsFixed(2)}B';
    } else if (number >= 1e6) {
      return '${(number / 1e6).toStringAsFixed(2)}M';
    } else {
      return number.toStringAsFixed(0);
    }
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<CoinListViewModel>(context);

    return Scaffold(
      backgroundColor: _lightBackground,
      body: RefreshIndicator(
        onRefresh: viewModel.fetchCoins,
        color: _primaryColor,
        backgroundColor: _cardColor,
        child: Column(
          children: [
            _buildCustomHeader(),
            Expanded(
              child: _buildBody(viewModel),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNavBar(),
    );
  }

  Widget _buildCustomHeader() {
    return Container(
      padding: const EdgeInsets.only(top: 50, left: 20, right: 20, bottom: 20),
      decoration: const BoxDecoration(
        color: _cardColor, // White header background
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(25),
          bottomRight: Radius.circular(25),
        ),
        boxShadow: [
          BoxShadow(
            color: Color.fromRGBO(0, 0, 0, 0.05),
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // User Avatar Placeholder
              const CircleAvatar(
                radius: 24,
                backgroundColor: _primaryColor,
                child: Icon(Icons.person, color: Colors.white, size: 28),
              ),
              const Text(
                'Crypto Market',
                style: TextStyle(
                  color: _darkTextColor,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              // Icons (Heart and Notification Placeholder)
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.favorite_border,
                        color: _lightTextColor),
                    onPressed: () {},
                  ),
                  IconButton(
                    icon: const Icon(Icons.notifications_none,
                        color: _lightTextColor),
                    onPressed: () {},
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          // Search Bar
          TextField(
            style: const TextStyle(color: _darkTextColor),
            decoration: InputDecoration(
              hintText: 'Search Coin...',
              hintStyle: TextStyle(color: _lightTextColor),
              prefixIcon: const Icon(Icons.search, color: _lightTextColor),
              filled: true,
              fillColor: _lightBackground, // Light gray for the search bar fill
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(vertical: 0),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(CoinListViewModel viewModel) {
    switch (viewModel.state) {
      case CoinListState.loading:
        return const Center(
          child: CircularProgressIndicator(color: _primaryColor),
        );
      case CoinListState.error:
        return Center(
          child: Text(
            'Error: ${viewModel.errorMessage}',
            style: const TextStyle(color: _negativeColor),
            textAlign: TextAlign.center,
          ),
        );
      case CoinListState.loaded:
        return SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 24),
              _buildCompareCoinsSection(viewModel.coins),
              const SizedBox(height: 24),
              _buildAllCoinsHeader(),
              const SizedBox(height: 16),
              _buildCoinList(viewModel.coins),
              const SizedBox(height: 20), // Padding for the bottom
            ],
          ),
        );
      default:
        return Container();
    }
  }

  Widget _buildCompareCoinsSection(List<Coin> coins) {
    // Show only the top two coins for comparison cards
    final topCoins = coins.take(2).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Trending Market',
          style: TextStyle(
            color: _darkTextColor,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: topCoins.map((coin) => _buildCompareCard(coin)).toList(),
        ),
      ],
    );
  }

  Widget _buildCompareCard(Coin coin) {
    final bool isPositive = coin.priceChangePercentage24h >= 0;
    final Color changeColor = isPositive ? _positiveColor : _negativeColor;

    // Soft gradient effect using the light background
    final Color gradientStart = _cardColor;
    final Color gradientEnd = _lightBackground.withOpacity(0.5);

    return Expanded(
      child: Container(
        margin: const EdgeInsets.only(right: 10),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [gradientStart, gradientEnd],
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Image.network(coin.imageUrl, width: 32, height: 32),
                const SizedBox(width: 8),
                Text(
                  coin.symbol.toUpperCase(),
                  style: const TextStyle(
                    color: _darkTextColor,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              _formatCurrency(coin.currentPrice),
              style: const TextStyle(
                color: _darkTextColor,
                fontSize: 20,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(
                  isPositive ? Icons.arrow_upward : Icons.arrow_downward,
                  color: changeColor,
                  size: 16,
                ),
                const SizedBox(width: 4),
                Text(
                  '${coin.priceChangePercentage24h.toStringAsFixed(2)}%',
                  style: TextStyle(
                    color: changeColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'M.Cap: \$${_formatLargeNumber(coin.marketCap)}',
              style: const TextStyle(color: _lightTextColor, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAllCoinsHeader() {
    return const Text(
      'All Cryptocurrencies',
      style: TextStyle(
        color: _darkTextColor,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildCoinList(List<Coin> coins) {
    return ListView.builder(
      physics:
          const NeverScrollableScrollPhysics(), // Handled by parent ScrollView
      shrinkWrap: true,
      itemCount: coins.length,
      itemBuilder: (context, index) {
        final coin = coins[index];
        final bool isPositive = coin.priceChangePercentage24h >= 0;
        final Color changeColor = isPositive ? _positiveColor : _negativeColor;

        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => DetailScreen(coin: coin),
              ),
            );
          },
          child: Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            decoration: BoxDecoration(
              color: _cardColor,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 5,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                // Rank (Left-side label)
                Container(
                  width: 24,
                  alignment: Alignment.center,
                  child: Text(
                    '${coin.marketCapRank}',
                    style: TextStyle(
                      color: _lightTextColor,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // Coin Image and Name
                Image.network(coin.imageUrl, width: 36, height: 36),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        coin.name,
                        style: const TextStyle(
                            color: _darkTextColor,
                            fontSize: 16,
                            fontWeight: FontWeight.bold),
                      ),
                      Text(
                        coin.symbol.toUpperCase(),
                        style: const TextStyle(
                            color: _lightTextColor, fontSize: 14),
                      ),
                    ],
                  ),
                ),
                // Price and Change (Right Side)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      _formatCurrency(coin.currentPrice),
                      style: const TextStyle(
                        color: _darkTextColor,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Row(
                      children: [
                        Icon(
                          isPositive
                              ? Icons.arrow_drop_up
                              : Icons.arrow_drop_down,
                          color: changeColor,
                        ),
                        Text(
                          '${coin.priceChangePercentage24h.toStringAsFixed(2)}%',
                          style: TextStyle(
                            color: changeColor,
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildBottomNavBar() {
    return Container(
      decoration: BoxDecoration(
        color: _cardColor, // White for nav bar
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: BottomNavigationBar(
        backgroundColor: Colors.transparent, // Use Container color
        selectedItemColor: _primaryColor,
        unselectedItemColor: _lightTextColor,
        showSelectedLabels: true,
        showUnselectedLabels: false,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_filled),
            label: 'Market',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.show_chart),
            label: 'Trade',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_balance_wallet),
            label: 'Wallet',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
