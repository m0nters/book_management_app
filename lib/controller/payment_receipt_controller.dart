import '../model/payment_receipt.dart';
import '../repository/payment_receipt_repository.dart';

class PaymentReceiptController {
  final PaymentReceiptRepository _paymentReceiptRepository;

  PaymentReceiptController(this._paymentReceiptRepository);

  Future<void> createPaymentReceipt(PaymentReceipt receipt) async {
    try {
      await _paymentReceiptRepository.addPaymentReceipt(receipt);
    } catch (e) {
      print('Error creating payment receipt: $e');
      // Handle error appropriately
    }
  }

  Future<PaymentReceipt?> readPaymentReceiptByID(String receiptID) async {
    try {
      return await _paymentReceiptRepository.getPaymentReceiptByID(receiptID);
    } catch (e) {
      print('Error reading payment receipt: $e');
      return null;
    }
  }

  Future<List<PaymentReceipt>> getAllPaymentReceipts() async {
    try {
      // Adjust this method if needed
      return await _paymentReceiptRepository.getAllPaymentReceipts(); // Make sure this method exists in the repository
    } catch (e) {
      print('Error retrieving all payment receipts: $e');
      return [];
    }
  }

  Future<List<PaymentReceipt>> getPaymentReceiptsByCustomerName(String customerName) async {
    try {
      // Adjust this method if needed
      return await _paymentReceiptRepository.getPaymentReceiptsByCustomerName(customerName); // Make sure this method exists in the repository
    } catch (e) {
      print('Error retrieving payment receipts by the customer\'s name: $e');
      return [];
    }
  }

  Future<List<PaymentReceipt>> searchPaymentReceipts(String query) async {
    return await _paymentReceiptRepository.getPaymentReceiptsByCustomerName(query);
  }

  Future<void> updatePaymentReceipt(PaymentReceipt receipt) async {
    try {
      await _paymentReceiptRepository.updatePaymentReceipt(receipt);
    } catch (e) {
      print('Error updating payment receipt: $e');
      // Handle error appropriately
    }
  }

  Future<void> deletePaymentReceipt(String receiptID) async {
    try {
      await _paymentReceiptRepository.deletePaymentReceipt(receiptID);
    } catch (e) {
      print('Error deleting payment receipt: $e');
      // Handle error appropriately
    }
  }
}
