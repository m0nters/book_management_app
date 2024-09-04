import 'package:cloud_firestore/cloud_firestore.dart';

import '../model/customer.dart';
import '../model/payment_receipt.dart';
import '../repository/customer_repository.dart';
import 'cloud_firestore.dart';

class PaymentReceiptDataSource {
  final CloudFirestore _cloudFirestore = CloudFirestore();
  final String _collectionPath = 'payment_receipt';

  // Create - C
  Future<void> createPaymentReceipt(PaymentReceipt receipt) async {
    try {
      final receiptAsMap = receipt.toFirestore();

      // Add the payment receipt to Firestore and get the document reference
      DocumentReference<Map<String, dynamic>> docRef = await _cloudFirestore.addDocument(_collectionPath, receiptAsMap);
      receipt.receiptID = docRef.id;

      // Update the Firestore document with the receiptID
      await _cloudFirestore.updateDocument(_collectionPath, receipt.receiptID, {'receiptID': receipt.receiptID});
    } catch (e) {
      print('Error creating payment receipt: $e');
    }
  }

  // Read - R
  Future<PaymentReceipt?> readPaymentReceiptByID(String receiptID) async {
    try {
      DocumentSnapshot<Map<String, dynamic>> doc = await _cloudFirestore.readDocumentByID(_collectionPath, receiptID);

      if (doc.exists) {
        return PaymentReceipt.fromFirestore(doc.data()!);
      } else {
        return null;
      }
    } catch (e) {
      print('Error retrieving payment receipt: $e');
      return null;
    }
  }

  Future<List<PaymentReceipt>> readAllPaymentReceipts() async {
    try {
      QuerySnapshot<Map<String, dynamic>> querySnapshot = await _cloudFirestore.getCollectionReference(_collectionPath).get();

      if (querySnapshot.docs.isNotEmpty) {
        List<Future<PaymentReceipt?>> futures = querySnapshot.docs.map((doc) {
          return PaymentReceipt.fromFirestore(doc.data());
        }).toList();

        // Wait for all futures to complete
        List<PaymentReceipt?> paymentReceipts = await Future.wait(futures);

        // Filter out any null values
        List<PaymentReceipt> nonNullPaymentReceipts = paymentReceipts.where((receipt) => receipt != null).cast<PaymentReceipt>().toList();

        print('PaymentReceipt found: ${nonNullPaymentReceipts.length}');
        return nonNullPaymentReceipts;
      } else {
        print('No PaymentReceipt found in the Firestore collection.');
        return [];
      }
    } catch (e) {
      print('Error retrieving PaymentReceipt: $e');
      return [];
    }
  }

  Future<List<PaymentReceipt>> readPaymentReceiptsByCustomerName(String customerName) async {
    try {
      final customerRepo = CustomerRepository();
      final customerList = await customerRepo.getCustomersByName(customerName);

      if (customerList.isNotEmpty) {
        // Get a list of futures for all payment receipts related to each customer
        List<Future<List<PaymentReceipt?>>> futures = customerList.map((customer) async {
          try {
            QuerySnapshot<Map<String, dynamic>> querySnapshot = await _cloudFirestore
                .getCollectionReference(_collectionPath) // Replace _collectionPath with your actual collection path
                .where('customerID', isEqualTo: customer.customerID)
                .get();

            if (querySnapshot.docs.isNotEmpty) {
              // Await the asynchronous fromFirestore method and collect results
              List<PaymentReceipt?> receipts = await Future.wait(
                querySnapshot.docs.map((doc) async {
                  try {
                    final data = doc.data();
                    if (data != null) {
                      return await PaymentReceipt.fromFirestore(data);
                    } else {
                      return null;
                    }
                  } catch (e) {
                    print('Error converting document to PaymentReceipt: $e');
                    return null;
                  }
                }).toList(),
              );
              return receipts;
            } else {
              return <PaymentReceipt?>[]; // Return an empty list if no documents found
            }
          } catch (e) {
            print('Error retrieving receipts for customer ${customer.customerID}: $e');
            return <PaymentReceipt?>[];
          }
        }).toList();

        // Wait for all futures to complete
        List<List<PaymentReceipt?>> allReceipts = await Future.wait(futures);

        // Flatten the list of lists and filter out any null values
        List<PaymentReceipt> nonNullPaymentReceipts = allReceipts.expand((receipts) => receipts)
            .where((receipt) => receipt != null)
            .cast<PaymentReceipt>()
            .toList();

        print('PaymentReceipts found: ${nonNullPaymentReceipts.length}');
        return nonNullPaymentReceipts;
      } else {
        print('No customers found with the name: $customerName');
        return [];
      }
    } catch (e) {
      print('Error retrieving PaymentReceipts: $e');
      return [];
    }
  }

  Future<int> readCustomerPaymentsBetweenDate (Customer customer, DateTime startDate, DateTime endDate) async {
    try {
      QuerySnapshot<Map<String, dynamic>> querySnapshot = await _cloudFirestore
          .getCollectionReference(_collectionPath)
          .where('date', isGreaterThanOrEqualTo: startDate.toIso8601String())
          .where('date', isLessThanOrEqualTo: endDate.toIso8601String())
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        List<Future<PaymentReceipt?>> futures = querySnapshot.docs.map((doc) {
          return PaymentReceipt.fromFirestore(doc.data());
        }).toList();

        // Wait for all futures to complete
        List<PaymentReceipt?> paymentReceipts = await Future.wait(futures);

        // Filter out any null values
        List<PaymentReceipt> nonNullPaymentReceipts = paymentReceipts.where((receipt) => receipt != null).cast<PaymentReceipt>().toList();

        int count = 0;
        int res = 0;
        for (var receipt in nonNullPaymentReceipts) {
          if (receipt.customer?.customerID == customer.customerID) {
            res += (receipt.amount as int);
            count++;
          }
        }

        print('PaymentReceipts by ${customer.name} between date found: ${count}');
        return res;
      } else {
        print('No PaymentReceipts between date found in the Firestore collection.');
        return 0;
      }
    } catch (e) {
      print('Error retrieving PaymentReceipts between date: $e');
      return 0;
    }
  }

  Future<List<PaymentReceipt>> readPaymentReceiptsBetweenDate (DateTime startDate, DateTime endDate) async {
    try {
      QuerySnapshot<Map<String, dynamic>> querySnapshot = await _cloudFirestore
          .getCollectionReference(_collectionPath) // Replace with your actual collection name
          .where('date', isGreaterThanOrEqualTo: startDate.toIso8601String())
          .where('date', isLessThanOrEqualTo: endDate.toIso8601String())
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        List<Future<PaymentReceipt?>> futures = querySnapshot.docs.map((doc) {
          return PaymentReceipt.fromFirestore(doc.data());
        }).toList();

        // Wait for all futures to complete
        List<PaymentReceipt?> paymentReceipts = await Future.wait(futures);

        // Filter out any null values
        List<PaymentReceipt> nonNullPaymentReceipts = paymentReceipts.where((receipt) => receipt != null).cast<PaymentReceipt>().toList();

        print('PaymentReceipt found: ${nonNullPaymentReceipts.length}');
        return nonNullPaymentReceipts;
      } else {
        print('No PaymentReceipt found in the Firestore collection.');
        return [];
      }
    } catch (e) {
      print('Error reading PaymentReceipts between dates: $e');
      return [];
    }
  }

  // Update - U
  Future<void> updatePaymentReceipt(PaymentReceipt receipt) async {
    try {
      final receiptAsMap = receipt.toFirestore();

      // Update the Firestore document using the CloudFirestore service
      await _cloudFirestore.updateDocument(_collectionPath, receipt.receiptID, receiptAsMap);
    } catch (e) {
      print('Error updating payment receipt: $e');
    }
  }

  // Delete - D
  Future<void> deletePaymentReceipt(String receiptID) async {
    try {
      // Delete the Firestore document using the CloudFirestore service
      await _cloudFirestore.deleteDocument(_collectionPath, receiptID);
    } catch (e) {
      print('Error deleting payment receipt: $e');
    }
  }
}