import 'package:cloud_firestore/cloud_firestore.dart';

import '../model/book.dart';
import '../model/book_order.dart';
import '../model/customer.dart';
import 'cloud_firestore.dart';

class BookOrderDataSource {
  final CloudFirestore _cloudFirestore = CloudFirestore();
  final String _collectionPath = 'book_order';

  // Create - C
  Future<void> createBookOrder (BookOrder order) async {
    try {
      final orderAsMap = order.toFirestore();

      // Add the book order to Firestore and get the document reference
      DocumentReference docRef = await _cloudFirestore.addDocument(_collectionPath, orderAsMap);

      // Update the book order object with the generated document ID
      order.orderID = docRef.id;

      // Update the Firestore document with the orderID
      await _cloudFirestore.updateDocument(_collectionPath, order.orderID, {'orderID': order.orderID});
    } catch (e) {
      print('Error adding book: $e');
    }
  }

  // Read - R
  Future<BookOrder?> readBookOrderByID (String orderID) async {
    try {
      DocumentSnapshot<Map<String, dynamic>> doc = await _cloudFirestore.readDocumentByID(_collectionPath, orderID);

      if (doc.exists) {
        return BookOrder.fromFirestore(doc.data()!);
      } else {
        return null;
      }
    } catch (e) {
      print('Error retrieving book order: $e');
      return null;
    }
  }

  Future<List<BookOrder>> readAllBookOrders() async {
    try {
      QuerySnapshot<Map<String, dynamic>> querySnapshot = await _cloudFirestore.getCollectionReference(_collectionPath).get();

      if (querySnapshot.docs.isNotEmpty) {
        List<Future<BookOrder?>> futures = querySnapshot.docs.map((doc) {
          return BookOrder.fromFirestore(doc.data());
        }).toList();

        // Wait for all futures to complete
        List<BookOrder?> bookOrders = await Future.wait(futures);

        // Filter out any null values
        List<BookOrder> nonNullBookOrders = bookOrders.where((receipt) => receipt != null).cast<BookOrder>().toList();

        print('Book orders found: ${nonNullBookOrders.length}');
        return nonNullBookOrders;
      } else {
        print('No BookOrder found in the Firestore collection.');
        return [];
      }
    } catch (e) {
      print('Error retrieving BookOrder: $e');
      return [];
    }
  }

  Future<int> readBookSoldBetweenDate(Book book, DateTime startDate, DateTime endDate) async {
    try {
      QuerySnapshot<Map<String, dynamic>> querySnapshot = await _cloudFirestore
          .getCollectionReference(_collectionPath)
          .where('orderDate', isGreaterThanOrEqualTo: startDate.toIso8601String())
          .where('orderDate', isLessThanOrEqualTo: endDate.toIso8601String())
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        List<Future<BookOrder?>> futures = querySnapshot.docs.map((doc) {
          return BookOrder.fromFirestore(doc.data());
        }).toList();

        // Wait for all futures to complete
        List<BookOrder?> bookOrders = await Future.wait(futures);

        // Filter out any null values
        List<BookOrder> nonNullBookOrders = bookOrders.where((receipt) => receipt != null).cast<BookOrder>().toList();

        int count = 0;
        int res = 0;
        for (var order in nonNullBookOrders) {
          for (var pair in order.bookList) {
            if (pair.item1.bookID == book.bookID) {
              res += pair.item2;
              count++;
            }
          }
        }

        print('Book orders that have ${book.title} found between dates: ${count}');
        return res;
      } else {
        print('No BookOrder between date found in the Firestore collection.');
        return 0;
      }
    } catch (e) {
      print('Error retrieving BookOrder between date: $e');
      return 0;
    }
  }

  Future<List<BookOrder>> readBookOrdersBetweenDate (DateTime startDate, DateTime endDate) async {
    try {
      QuerySnapshot<Map<String, dynamic>> querySnapshot = await _cloudFirestore
          .getCollectionReference(_collectionPath) // Replace with your actual collection name
          .where('orderDate', isGreaterThanOrEqualTo: startDate.toIso8601String())
          .where('orderDate', isLessThanOrEqualTo: endDate.toIso8601String())
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        List<Future<BookOrder?>> futures = querySnapshot.docs.map((doc) {
          return BookOrder.fromFirestore(doc.data());
        }).toList();

        // Wait for all futures to complete
        List<BookOrder?> bookOrders = await Future.wait(futures);

        // Filter out any null values
        List<BookOrder> nonNullBookOrders = bookOrders.where((receipt) => receipt != null).cast<BookOrder>().toList();

        print('Book orders found: ${nonNullBookOrders.length}');
        return nonNullBookOrders;
      } else {
        print('No BookOrder found in the Firestore collection.');
        return [];
      }
    } catch (e) {
      print('Error reading book orders between dates: $e');
      return [];
    }
  }

  Future<int> readCustomerCostBetweenDate(Customer customer, DateTime startDate, DateTime endDate) async {
    try {
      QuerySnapshot<Map<String, dynamic>> querySnapshot = await _cloudFirestore
          .getCollectionReference(_collectionPath)
          .where('orderDate', isGreaterThanOrEqualTo: startDate.toIso8601String())
          .where('orderDate', isLessThanOrEqualTo: endDate.toIso8601String())
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        List<Future<BookOrder?>> futures = querySnapshot.docs.map((doc) {
          return BookOrder.fromFirestore(doc.data());
        }).toList();

        // Wait for all futures to complete
        List<BookOrder?> bookOrders = await Future.wait(futures);

        // Filter out any null values
        List<BookOrder> nonNullBookOrders = bookOrders.where((receipt) => receipt != null).cast<BookOrder>().toList();

        int count = 0;
        int res = 0;
        for (var order in nonNullBookOrders) {
          if (order.customer?.customerID == customer.customerID) {
            res += order.totalCost;
            count++;
          }
        }

        print('Book orders by ${customer.name} found between dates: ${count}');
        return res;
      } else {
        print('No BookOrder between date found in the Firestore collection.');
        return 0;
      }
    } catch (e) {
      print('Error retrieving BookOrder between date: $e');
      return 0;
    }
  }

  Future<int> readBookSoldCurrentMonth(Book book) async {
    DateTime now = DateTime.now();

    // Calculate the start and end dates of the current month
    DateTime startDate = DateTime(now.year, now.month, 1);
    DateTime endDate = DateTime(now.year, now.month + 1, 0, 23, 59, 59, 999);

    try {
      QuerySnapshot<Map<String, dynamic>> querySnapshot = await _cloudFirestore
          .getCollectionReference(_collectionPath)
          .where('orderDate', isGreaterThanOrEqualTo: startDate.toIso8601String())
          .where('orderDate', isLessThanOrEqualTo: endDate.toIso8601String())
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        List<Future<BookOrder?>> futures = querySnapshot.docs.map((doc) {
          return BookOrder.fromFirestore(doc.data());
        }).toList();

        // Wait for all futures to complete
        List<BookOrder?> bookOrders = await Future.wait(futures);

        // Filter out any null values
        List<BookOrder> nonNullBookOrders = bookOrders.where((receipt) => receipt != null).cast<BookOrder>().toList();

        int count = 0;
        int res = 0;
        for (var order in nonNullBookOrders) {
          for (var pair in order.bookList) {
            if (pair.item1.bookID == book.bookID) {
              res += pair.item2;
              count++;
            }
          }
        }

        print('Book orders that have ${book.title} found in this month: ${count}');
        return res;
      } else {
        print('No BookOrder in this month that has ${book.title} found in the Firestore collection.');
        return 0;
      }
    } catch (e) {
      print('Error retrieving BookOrder this month: $e');
      return 0;
    }
  }

  Future<List<BookOrder>> readBookOrdersByCustomer (String customerID) async {
    try {
      // Query Firestore to get book orders by customer ID
      QuerySnapshot<Map<String, dynamic>> querySnapshot = await _cloudFirestore
          .getCollectionReference(_collectionPath)
          .where('customer', isEqualTo: customerID)
          .get();

      // Convert each document into a BookOrder object
      List<Future<BookOrder?>> futures = querySnapshot.docs.map((doc) {
        return BookOrder.fromFirestore(doc.data());
      }).toList();

      // Wait for all futures to complete
      List<BookOrder?> bookOrders = await Future.wait(futures);

      // Filter out any null values
      List<BookOrder> nonNullBookOrders = bookOrders.where((order) => order != null).cast<BookOrder>().toList();

      return nonNullBookOrders;
    } catch (e) {
      print('Error retrieving book orders for customer: $e');
      return [];
    }
  }

  // Update - U
  Future<void> updateBookOrder (BookOrder order) async {
    try {
      final orderAsMap = order.toFirestore();

      // Update the Firestore document using the CloudFirestore service
      await _cloudFirestore.updateDocument(_collectionPath, order.orderID, orderAsMap);
    } catch (e) {
      print('Error updating book order: $e');
    }
  }

  // Delete - D
  Future<void> deleteBookOrder (String orderID) async {
    try {
      // Delete the Firestore document using the CloudFirestore service
      await _cloudFirestore.deleteDocument(_collectionPath, orderID);
    } catch (e) {
      print('Error deleting book order: $e');
    }
  }

}