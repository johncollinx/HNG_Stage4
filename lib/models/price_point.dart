// lib/models/price_point.dart

class PricePoint {
  // Timestamp is stored as an integer (milliseconds since epoch)
  final int timestamp;

  // Price is stored as a double to handle decimal values
  final double price;

  PricePoint(this.timestamp, this.price);

  // Helper method to convert PricePoint to a map for compact caching 
  // (used in ApiService for chart data)
  Map<String, dynamic> toJson() {
    return {
      // Use short keys for smaller cache size
      't': timestamp,
      'p': price,
    };
  }

  @override
  String toString() {
    return 'PricePoint(timestamp: $timestamp, price: $price)';
  }
}
