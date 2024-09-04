import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tuple/tuple.dart';

import '../model/customer.dart';
import '../repository/book_order_repository.dart';
import '../repository/customer_repository.dart';
import '../repository/payment_receipt_repository.dart';

class CustomerController {
  final CustomerRepository _customerRepository;

  CustomerController(this._customerRepository);

  Future<void> createCustomer(Customer customer) async {
    try {
      await _customerRepository.addCustomer(customer);
    } catch (e) {
      print('Error creating customer: $e');
      // Handle error appropriately
    }
  }

  Future<Customer?> readCustomerByID(String customerID) async {
    try {
      return await _customerRepository.getCustomerByID(customerID);
    } catch (e) {
      print('Error reading customer: $e');
      return null;
    }
  }

  Future<List<Customer>> getAllCustomers() async {
    try {
      // Adjust this method if needed
      return await _customerRepository.getAllCustomers(); // Make sure this method exists in the repository
    } catch (e) {
      print('Error retrieving all customer: $e');
      return [];
    }
  }

  Future<void> updateCustomer(Customer customer) async {
    try {
      await _customerRepository.updateCustomer(customer);
    } catch (e) {
      print('Error updating customer: $e');
      // Handle error appropriately
    }
  }

  Future<void> deleteCustomer(String customerID) async {
    try {
      await _customerRepository.deleteCustomer(customerID);
    } catch (e) {
      print('Error deleting customer: $e');
      // Handle error appropriately
    }
  }

  Future<List<Customer>> searchCustomers(String query) async {
    List<Customer> byName = await _customerRepository.getCustomersByName(query);
    if (byName.isNotEmpty) {
      return byName;
    }
    List<Customer> byPhoneNumber = await _customerRepository.getCustomersByPhoneNumber(query);
    if (byPhoneNumber.isNotEmpty) {
      return byPhoneNumber;
    }
    List<Customer> byAddress = await _customerRepository.getCustomersByAddress(query);
    if (byAddress.isNotEmpty) {
      return byAddress;
    }
    List<Customer> byEmail = await _customerRepository.getCustomersByEmail(query);
    if (byEmail.isNotEmpty) {
      return byEmail;
    }

    return [];
  }

  Future<List<Tuple2<Customer, Tuple3<int, int, int>>>> getMonthlyDebtReport (List<Customer> customerList, DateTime date) async {
    final bookOrderRepository = BookOrderRepository();
    final paymentReceiptRepository = PaymentReceiptRepository();

    DateTime startOfMonth = DateTime(date.year, date.month, 1);
    DateTime endOfMonth = DateTime(date.year, date.month + 1, 0, 23, 59, 59);
    DateTime currentDate = DateTime.now();

    Map<String, List<int>> customerReport = {};
    for (var customer in customerList) {
      customerReport[customer.customerID] = [0,0,customer.debt]; //0: phat sinh ban 1: phat sinh thu 2: ton cuoi
    }

    final bookOrdersBetweenDate = await bookOrderRepository.getBookOrdersBetweenDate(startOfMonth, endOfMonth);
    final paymentReceiptsBetweenDate = await paymentReceiptRepository.getPaymentReceiptsBetweenDate(startOfMonth, endOfMonth);
    final bookOrdersNow2EndOfMonth = await bookOrderRepository.getBookOrdersBetweenDate(endOfMonth, currentDate);
    final paymentReceiptsNow2EndOfMonth = await paymentReceiptRepository.getPaymentReceiptsBetweenDate(endOfMonth, currentDate);

    for (var receipt in paymentReceiptsNow2EndOfMonth) {
      customerReport[receipt.customer?.customerID]?[2] += receipt.amount.toInt();
    }

    for (var order in bookOrdersNow2EndOfMonth) {
      customerReport[order.customer?.customerID]?[2] -= order.totalCost;
    }

    for (var receipt in paymentReceiptsBetweenDate) {
      customerReport[receipt.customer?.customerID]?[1] += receipt.amount.toInt();
    }

    for (var order in bookOrdersBetweenDate) {
      customerReport[order.customer?.customerID]?[0] += order.totalCost;
    }

    List<Tuple2<Customer, Tuple3<int, int, int>>> res = [];
    for (var customer in customerList) {
      final report = customerReport[customer.customerID];
      final fullReport = Tuple3<int, int, int>(report![2] - report![0] + report![1], report![0] - report![1], report![2]);
      res.add(Tuple2<Customer, Tuple3<int, int, int>>(customer, fullReport));
    }

    return res;
  }
}