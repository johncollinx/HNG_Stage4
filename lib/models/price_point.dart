// A simple model to hold price and timestamp for charting
class PricePoint {
  // Timestamp is stored as an integer (milliseconds since epoch)
  final int timestamp;

  // Price is stored as a double to handle decimal values
  final double price;

  PricePoint(this.timestamp, this.price);

  // A helper method that some charting libraries might use,
  // or for easy debugging.
  @override
  String toString() {
    return 'PricePoint(timestamp: $timestamp, price: $price)';
  }
}
