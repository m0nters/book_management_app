import 'package:cloud_firestore/cloud_firestore.dart';

import '../model/book.dart';
import '../model/goods_receipt.dart';
import 'cloud_firestore.dart';

class GoodsReceiptDataSource {
  final CloudFirestore _cloudFirestore = CloudFirestore();
  final String _collectionPath = 'goods_receipt';

  // Create - C
  Future<void> createGoodsReceipt (GoodsReceipt receipt) async {
    try {
      final receiptAsMap = receipt.toFirestore();
      // Add the goods receipt to Firestore and get the document reference
      DocumentReference<Map<String, dynamic>> docRef = await _cloudFirestore.addDocument(_collectionPath, receiptAsMap);

      // Update the goods receipt object with the generated document ID
      receipt.receiptID = docRef.id;

      // Update the Firestore document with the receiptID
      await _cloudFirestore.updateDocument(_collectionPath, receipt.receiptID, {'receiptID': receipt.receiptID});
    } catch (e) {
      print('Error adding goods receipt: $e');
    }
  }

  // Read - R
  Future<GoodsReceipt?> readGoodsReceiptByID (String receiptID) async {
    try {
      DocumentSnapshot<Map<String, dynamic>> doc = await _cloudFirestore.readDocumentByID(_collectionPath, receiptID);

      if (doc.exists) {
        return GoodsReceipt.fromFirestore(doc.data()!);
      } else {
        return null;
      }
    } catch (e) {
      print('Error retrieving goods receipt: $e');
      return null;
    }
  }

  Future<List<GoodsReceipt>> readAllGoodsReceipts() async {
    try {
      QuerySnapshot<Map<String, dynamic>> querySnapshot = await _cloudFirestore.getCollectionReference(_collectionPath).get();

      if (querySnapshot.docs.isNotEmpty) {
        List<Future<GoodsReceipt?>> futures = querySnapshot.docs.map((doc) {
          return GoodsReceipt.fromFirestore(doc.data());
        }).toList();

        // Wait for all futures to complete
        List<GoodsReceipt?> goodsReceipts = await Future.wait(futures);

        // Filter out any null values
        List<GoodsReceipt> nonNullGoodsReceipts = goodsReceipts.where((receipt) => receipt != null).cast<GoodsReceipt>().toList();

        print('GoodsReceipts found: ${nonNullGoodsReceipts.length}');
        return nonNullGoodsReceipts;
      } else {
        print('No GoodsReceipts found in the Firestore collection.');
        return [];
      }
    } catch (e) {
      print('Error retrieving GoodsReceipts: $e');
      return [];
    }
  }

  Future<List<GoodsReceipt>> readGoodsReceiptsByDate(DateTime date) async {
    DateTime startOfDay = DateTime(date.year, date.month, date.day);
    DateTime endOfDay = DateTime(date.year, date.month, date.day, 23, 59, 59);

    try {
      QuerySnapshot<Map<String, dynamic>> querySnapshot = await _cloudFirestore
          .getCollectionReference(_collectionPath)
          .where('date', isGreaterThanOrEqualTo: startOfDay.toIso8601String())
          .where('date', isLessThanOrEqualTo: endOfDay.toIso8601String())
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        List<Future<GoodsReceipt?>> futures = querySnapshot.docs.map((doc) {
          return GoodsReceipt.fromFirestore(doc.data());
        }).toList();

        // Wait for all futures to complete
        List<GoodsReceipt?> goodsReceipts = await Future.wait(futures);

        // Filter out any null values
        List<GoodsReceipt> nonNullGoodsReceipts = goodsReceipts.where((receipt) => receipt != null).cast<GoodsReceipt>().toList();

        print('GoodsReceipts by date found: ${nonNullGoodsReceipts.length}');
        return nonNullGoodsReceipts;
      } else {
        print('No GoodsReceipts by date found in the Firestore collection.');
        return [];
      }
    } catch (e) {
      print('Error retrieving GoodsReceipts by date: $e');
      return [];
    }
  }

  Future<List<GoodsReceipt>> readGoodsReceiptsBetweenDate(DateTime startDate, DateTime endDate) async {
    try {
      QuerySnapshot<Map<String, dynamic>> querySnapshot = await _cloudFirestore
          .getCollectionReference(_collectionPath) // Replace with your actual collection name
          .where('date', isGreaterThanOrEqualTo: startDate.toIso8601String())
          .where('date', isLessThanOrEqualTo: endDate.toIso8601String())
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        List<Future<GoodsReceipt?>> futures = querySnapshot.docs.map((doc) {
          return GoodsReceipt.fromFirestore(doc.data());
        }).toList();

        // Wait for all futures to complete
        List<GoodsReceipt?> goodsReceipts = await Future.wait(futures);

        // Filter out any null values
        List<GoodsReceipt> nonNullGoodsReceipts = goodsReceipts.where((receipt) => receipt != null).cast<GoodsReceipt>().toList();

        print('GoodsReceipts found: ${nonNullGoodsReceipts.length}');
        return nonNullGoodsReceipts;
      } else {
        print('No GoodsReceipts found in the Firestore collection.');
        return [];
      }
    } catch (e) {
      print('Error reading GoodsReceipts between dates: $e');
      return [];
    }
  }

  Future<int> readBookReceivedBetweenDate (Book book, DateTime startDate, DateTime endDate) async {
    try {
      QuerySnapshot<Map<String, dynamic>> querySnapshot = await _cloudFirestore
          .getCollectionReference(_collectionPath)
          .where('date', isGreaterThanOrEqualTo: startDate.toIso8601String())
          .where('date', isLessThanOrEqualTo: endDate.toIso8601String())
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        List<Future<GoodsReceipt?>> futures = querySnapshot.docs.map((doc) {
          return GoodsReceipt.fromFirestore(doc.data());
        }).toList();

        // Wait for all futures to complete
        List<GoodsReceipt?> goodsReceipts = await Future.wait(futures);

        // Filter out any null values
        List<GoodsReceipt> nonNullGoodsReceipts = goodsReceipts.where((receipt) => receipt != null).cast<GoodsReceipt>().toList();

        int count = 0;
        int res = 0;
        for (var receipt in nonNullGoodsReceipts) {
          for (var pair in receipt.bookList) {
            if (pair.item1.bookID == book.bookID) {
              res += pair.item2;
              count++;
            }
          }
        }

        print('GoodsReceipts that have ${book.title} between date found: ${count}');
        return res;
      } else {
        print('No GoodsReceipts between date found in the Firestore collection.');
        return 0;
      }
    } catch (e) {
      print('Error retrieving GoodsReceipts between date: $e');
      return 0;
    }
  }

  Future<DateTime?> readLatestBookReceiptDate(Book book) async {
    try {
      QuerySnapshot<Map<String, dynamic>> querySnapshot = await _cloudFirestore
          .getCollectionReference(_collectionPath)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        List<Future<GoodsReceipt?>> futures = querySnapshot.docs.map((doc) {
          return GoodsReceipt.fromFirestore(doc.data());
        }).toList();

        // Wait for all futures to complete
        List<GoodsReceipt?> goodsReceipts = await Future.wait(futures);

        // Filter out any null values
        List<GoodsReceipt> nonNullGoodsReceipts = goodsReceipts.where((
            receipt) => receipt != null).cast<GoodsReceipt>().toList();


        DateTime? latestDate;
        bool flag = false;

        for (var receipt in nonNullGoodsReceipts) {
          for (var pair in receipt.bookList) {
            if ((pair.item1.bookID == book.bookID)) {
              flag = true;
              if (latestDate == null || receipt.date.isAfter(latestDate)) {
                latestDate = receipt.date;
              }
            }
          }
        }

        if (!flag) {
          print('This book has never been received');
        }

        return latestDate;
      }
    } catch (e) {
      print('Error getting the latest receipt date: $e');
      return null;
    }
    return null;
  }

  Future<int> readBookReceivedCurrentMonth(Book book) async {
    try {
      // Get the current date
      DateTime now = DateTime.now();

      // Calculate the start and end dates of the current month
      DateTime startDate = DateTime(now.year, now.month, 1);
      DateTime endDate = DateTime(now.year, now.month + 1, 0, 23, 59, 59, 999);

      QuerySnapshot<Map<String, dynamic>> querySnapshot = await _cloudFirestore
          .getCollectionReference(_collectionPath)
          .where('date', isGreaterThanOrEqualTo: startDate.toIso8601String())
          .where('date', isLessThanOrEqualTo: endDate.toIso8601String())
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        List<Future<GoodsReceipt?>> futures = querySnapshot.docs.map((doc) {
          return GoodsReceipt.fromFirestore(doc.data());
        }).toList();

        // Wait for all futures to complete
        List<GoodsReceipt?> goodsReceipts = await Future.wait(futures);

        // Filter out any null values
        List<GoodsReceipt> nonNullGoodsReceipts = goodsReceipts.where((receipt) => receipt != null).cast<GoodsReceipt>().toList();

        int totalQuantity = 0;
        for (var receipt in nonNullGoodsReceipts) {
          for (var pair in receipt.bookList) {
            if (pair.item1.bookID == book.bookID) {
              totalQuantity += pair.item2;
            }
          }
        }

        print('Total quantity of ${book.title} received this month: $totalQuantity');
        return totalQuantity;
      } else {
        print('No GoodsReceipts found for the current month.');
        return 0;
      }
    } catch (e) {
      print('Error retrieving GoodsReceipts for the current month: $e');
      return 0;
    }
  }

  // Update - U
  Future<void> updateGoodsReceipt (GoodsReceipt receipt) async {
    try {
      final receiptAsMap = receipt.toFirestore();

      // Update the Firestore document using the CloudFirestore service
      await _cloudFirestore.updateDocument(_collectionPath, receipt.receiptID, receiptAsMap);
    } catch (e) {
      print('Error updating goods receipt: $e');
    }
  }

  // Delete - D
  Future<void> deleteGoodsReceipt (String receiptID) async {
    try {
      // Delete the Firestore document using the CloudFirestore service
      await _cloudFirestore.deleteDocument(_collectionPath, receiptID);
    } catch (e) {
      print('Error deleting goods receipt: $e');
    }
  }

}