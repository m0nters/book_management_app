import 'package:cloud_firestore/cloud_firestore.dart';

import 'cloud_firestore.dart';

class RuleDataSource {
  final CloudFirestore _cloudFirestore = CloudFirestore();
  final String _collectionPath = 'rule';
  final String _bookOrderDocumentPath = 'book_order';
  final String _goodsReceiptDocumentPath = 'goods_receipt';
  final String _paymentReceiptDocumentPath = 'payment_receipt';

  // Create - C

  // Read - R
  Future<int> readCustomerMaxDebt() async {
    try {
      DocumentSnapshot<Map<String, dynamic>> doc = await _cloudFirestore
          .readDocumentByID(_collectionPath, _bookOrderDocumentPath);

      if (doc.exists) {
        final data = doc.data()!;
        return data['max_debt'] ?? 0;
      } else {
        print('No document of ${_bookOrderDocumentPath}');
        return 0;
      }
    } catch (e) {
      print('Error retrieving maximum value a customer can be in debt: $e');
      return 0;
    }
  }

  Future<int> readMinStockPostOrder() async {
    try {
      DocumentSnapshot<Map<String, dynamic>> doc = await _cloudFirestore
          .readDocumentByID(_collectionPath, _bookOrderDocumentPath);

      if (doc.exists) {
        final data = doc.data()!;
        return data['min_stock_after'] ?? 0;
      } else {
        print('No document of ${_bookOrderDocumentPath}');
        return 0;
      }
    } catch (e) {
      print('Error retrieving minimum value of book stock after order: $e');
      return 0;
    }
  }

  Future<int> readMaxStockPreReceipt() async {
    try {
      DocumentSnapshot<Map<String, dynamic>> doc = await _cloudFirestore
          .readDocumentByID(_collectionPath, _goodsReceiptDocumentPath);

      if (doc.exists) {
        final data = doc.data()!;
        return data['max_stock_before'] ?? 0;
      } else {
        print('No document of ${_goodsReceiptDocumentPath}');
        return 0;
      }
    } catch (e) {
      print(
          'Error retrieving maximum value of book stock before receiving: $e');
      return 0;
    }
  }

  Future<int> readMinReceive() async {
    try {
      DocumentSnapshot<Map<String, dynamic>> doc = await _cloudFirestore
          .readDocumentByID(_collectionPath, _goodsReceiptDocumentPath);

      if (doc.exists) {
        final data = doc.data()!;
        return data['min_receive'] ?? 0;
      } else {
        print('No document of ${_goodsReceiptDocumentPath}');
        return 0;
      }
    } catch (e) {
      print('Error retrieving minimum number of book receiving: $e');
      return 0;
    }
  }

  Future<bool> readNegativeDebtRights() async {
    try {
      DocumentSnapshot<Map<String, dynamic>> doc = await _cloudFirestore
          .readDocumentByID(_collectionPath, _paymentReceiptDocumentPath);

      if (doc.exists) {
        final data = doc.data()!;
        return data['negative_debt'] ?? false;
      } else {
        print('No document of ${_paymentReceiptDocumentPath}');
        return false;
      }
    } catch (e) {
      print('Error retrieving customer negative debt rights: $e');
      return false;
    }
  }

  // Update - U
  Future<void> updateCustomerMaxDebt(int maxDebt) async {
    try {
      // Reference to the specific document in the collection
      DocumentReference documentRef = _cloudFirestore.getCollectionReference(_collectionPath).doc(_bookOrderDocumentPath);

      // Update the specific field in the document
      await documentRef.update({
        'max_debt': maxDebt,
      });

      print('Field max_debt updated successfully.');
    } catch (e) {
      print('Error updating field max_debt: $e');
    }
  }

  Future<void> updateMinStockPostOrder(int minStockPostOrder) async {
    try {
      // Reference to the specific document in the collection
      DocumentReference documentRef = _cloudFirestore.getCollectionReference(_collectionPath).doc(_bookOrderDocumentPath);

      // Update the specific field in the document
      await documentRef.update({
        'min_stock_after': minStockPostOrder,
      });

      print('Field min_stock_after updated successfully.');
    } catch (e) {
      print('Error updating field min_stock_after: $e');
    }
  }

  Future<void> updateMaxStockPreReceipt(int maxStockPreReceipt) async {
    try {
      // Reference to the specific document in the collection
      DocumentReference documentRef = _cloudFirestore.getCollectionReference(_collectionPath).doc(_goodsReceiptDocumentPath);

      // Update the specific field in the document
      await documentRef.update({
        'max_stock_before': maxStockPreReceipt,
      });

      print('Field max_stock_before updated successfully.');
    } catch (e) {
      print('Error updating field max_stock_before: $e');
    }
  }

  Future<void> updateMinReceive(int minReceive) async {
    try {
      // Reference to the specific document in the collection
      DocumentReference documentRef = _cloudFirestore.getCollectionReference(_collectionPath).doc(_goodsReceiptDocumentPath);

      // Update the specific field in the document
      await documentRef.update({
        'min_receive': minReceive,
      });

      print('Field min_receive updated successfully.');
    } catch (e) {
      print('Error updating field min_receive: $e');
    }
  }

  Future<void> updateNegativeDebtRights(bool negativeDebtRights) async {
    try {
      // Reference to the specific document in the collection
      DocumentReference documentRef = _cloudFirestore.getCollectionReference(_collectionPath).doc(_paymentReceiptDocumentPath);

      // Update the specific field in the document
      await documentRef.update({
        'negative_debt': negativeDebtRights,
      });

      print('Field negative_debt updated successfully.');
    } catch (e) {
      print('Error updating field negative_debt: $e');
    }
  }

// Delete - D
}