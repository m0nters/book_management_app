import '../model/customer.dart';
import '../model/payment_receipt.dart';
import '../network/payment_receipt_data_source.dart';

class PaymentReceiptRepository {
  final PaymentReceiptDataSource _dataSource = PaymentReceiptDataSource();

  Future<void> addPaymentReceipt (PaymentReceipt receipt) => _dataSource.createPaymentReceipt(receipt);

  Future<PaymentReceipt?> getPaymentReceiptByID (String receiptID) => _dataSource.readPaymentReceiptByID(receiptID);

  Future<List<PaymentReceipt>> getAllPaymentReceipts () => _dataSource.readAllPaymentReceipts();

  Future<List<PaymentReceipt>> getPaymentReceiptsByCustomerName (String customerName) => _dataSource.readPaymentReceiptsByCustomerName(customerName);

  Future<int> getCustomerPaymentsBetweenDate (Customer customer, DateTime startDate, DateTime endDate) => _dataSource.readCustomerPaymentsBetweenDate(customer, startDate, endDate);

  Future<List<PaymentReceipt>> getPaymentReceiptsBetweenDate (DateTime startDate, DateTime endDate) => _dataSource.readPaymentReceiptsBetweenDate(startDate, endDate);

  Future<void> updatePaymentReceipt (PaymentReceipt receipt) => _dataSource.updatePaymentReceipt(receipt);

  Future<void> deletePaymentReceipt (String receiptID) => _dataSource.deletePaymentReceipt(receiptID);

}