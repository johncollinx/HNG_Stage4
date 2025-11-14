class Coin {
  final String id;
  final String name;
  final String symbol;
  final String imageUrl;
  final double currentPrice;
  final double priceChangePercentage24h;
  final int marketCapRank;
  final double marketCap;
  final double high24h;
  final double low24h;
  final double totalVolume;
  final double circulatingSupply;
  final String description; 

  Coin({
    required this.id,
    required this.name,
    required this.symbol,
    required this.imageUrl,
    required this.currentPrice,
    required this.priceChangePercentage24h,
    required this.marketCapRank,
    required this.marketCap,
    required this.high24h,
    required this.low24h,
    required this.totalVolume,
    required this.circulatingSupply,
    required this.description, 
  });

  // Factory constructor to create a Coin instance from JSON data.
  factory Coin.fromJson(Map<String, dynamic> json) {
    // Helper function to safely parse a dynamic value as a double, defaulting to 0.0
    double safeDouble(dynamic value) {
      if (value is num) return value.toDouble();
      if (value is String) return double.tryParse(value) ?? 0.0;
      return 0.0;
    }

    return Coin(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      symbol: json['symbol'] as String? ?? '',
      imageUrl: json['image'] as String? ?? '',
      currentPrice: safeDouble(json['current_price']),
      priceChangePercentage24h: safeDouble(json['price_change_percentage_24h']),
      marketCapRank: json['market_cap_rank'] as int? ?? 0,
      marketCap: safeDouble(json['market_cap']),
      high24h: safeDouble(json['high_24h']),
      low24h: safeDouble(json['low_24h']),
      totalVolume: safeDouble(json['total_volume']),
      circulatingSupply: safeDouble(json['circulating_supply']),
      description: json['description'] as String? ??
          'No detailed description available for this coin.', // <-- Populating description
    );
  }
}
