// lib/models/coin_model.dart

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
  
  // Description is not available in the /coins/markets endpoint, 
  // so it defaults to a placeholder.
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
    // Provide a safe default value for the description
    this.description = 'No detailed description available.',
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
      
      // The description field is included here but will only be populated 
      // if the JSON map came from the full detail endpoint.
      description: json['description'] as String? ?? 'No detailed description available.',
    );
  }

  // Helper method to convert Coin to a map for SharedPreferences caching 
  // (used in ApiService for the coin list)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'symbol': symbol,
      'image': imageUrl,
      'current_price': currentPrice,
      'price_change_percentage_24h': priceChangePercentage24h,
      'market_cap_rank': marketCapRank,
      'market_cap': marketCap,
      'high_24h': high24h,
      'low_24h': low24h,
      'total_volume': totalVolume,
      'circulating_supply': circulatingSupply,
      'description': description,
    };
  }
}
