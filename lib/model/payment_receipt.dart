import '../repository/customer_repository.dart';
import 'customer.dart'; // Import the Customer class

class PaymentReceipt {
  String receiptID;
  Customer? customer;
  DateTime date;
  num amount;

  PaymentReceipt({
    required this.receiptID,
    required this.customer,
    required this.date,
    required this.amount,
  });

  // Convert a PaymentReceipt object to a Firestore document
  Map<String, dynamic> toFirestore() {
    return {
      'receiptID': receiptID,
      'customerID': customer?.customerID,
      'date': date.toIso8601String(),
      'amount': amount,
    };
  }

  // Create a PaymentReceipt object from a Firestore document
  static Future<PaymentReceipt?> fromFirestore(Map<String, dynamic> data) async {
    final customerRepo = CustomerRepository();

    // Fetch the customer
    Customer? customer = await customerRepo.getCustomerByID(data['customerID']);
    if (customer == null) {
      return null; // Customer not found
    }

    return PaymentReceipt(
      receiptID: data['receiptID'] ?? '',
      customer: customer, // Assume the customer data is within the same document
      date: DateTime.parse(data['date'] ?? DateTime.now().toIso8601String()).toLocal(),
      amount: data['amount'] ?? 0,
    );
  }
}
