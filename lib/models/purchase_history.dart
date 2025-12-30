class PurchaseHistory {
  final String orderId;
  final DateTime date;
  final double total;
  final String status;
  
  PurchaseHistory({
    required this.orderId,
    required this.date,
    required this.total,
    required this.status,
  });
}