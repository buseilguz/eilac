
class Order {
  final String id;
  final String userId;
  final List<String> items;
  final double totalAmount;
  final DateTime dateTime;
  final String address;

  Order({
    required this.id,
    required this.userId,
    required this.items,
    required this.totalAmount,
    required this.dateTime,
    required this.address
  });
}
