import '../model/book.dart';
import '../model/goods_receipt.dart';
import '../repository/goods_receipt_repository.dart';

class GoodsReceiptController {
  final GoodsReceiptRepository _goodsReceiptRepository;

  GoodsReceiptController(this._goodsReceiptRepository);

  Future<void> createGoodsReceipt(GoodsReceipt receipt) async {
    try {
      await _goodsReceiptRepository.addGoodsReceipt(receipt);
    } catch (e) {
      print('Error creating goods receipt: $e');
      // Handle error appropriately
    }
  }

  Future<GoodsReceipt?> readGoodsReceiptByID(String receiptID) async {
    try {
      return await _goodsReceiptRepository.getGoodsReceiptByID(receiptID);
    } catch (e) {
      print('Error reading goods receipt: $e');
      return null;
    }
  }

  Future<List<GoodsReceipt>> getAllGoodsReceipts() async {
    try {
      // Adjust this method if needed
      return await _goodsReceiptRepository.getAllGoodsReceipts(); // Make sure this method exists in the repository
    } catch (e) {
      print('Error retrieving all goods receipt: $e');
      return [];
    }
  }

  Future<List<GoodsReceipt>> getGoodsReceiptsByDate(DateTime date) async {
    try {
      // Adjust this method if needed
      return await _goodsReceiptRepository.getGoodsReceiptsByDate(date); // Make sure this method exists in the repository
    } catch (e) {
      print('Error retrieving goods receipt by date: $e');
      return [];
    }
  }

  Future<DateTime?> getLatestBookReceiptDate (Book book) async {
    try {
      // Adjust this method if needed
      return await _goodsReceiptRepository.getLatestBookReceiptDate(book); // Make sure this method exists in the repository
    } catch (e) {
      print('Error retrieving LatestBookReceiptDate: $e');
      return null;
    }
  }

  Future<int?> getBookReceivedCurrentMonth (Book book) async {
    try {
      // Adjust this method if needed
      return await _goodsReceiptRepository.getBookReceivedCurrentMonth(book); // Make sure this method exists in the repository
    } catch (e) {
      print('Error retrieving LatestBookReceiptDate: $e');
      return 0;
    }
  }

  Future<void> updateGoodsReceipt(GoodsReceipt receipt) async {
    try {
      await _goodsReceiptRepository.updateGoodsReceipt(receipt);
    } catch (e) {
      print('Error updating goods receipt: $e');
      // Handle error appropriately
    }
  }

  Future<void> deleteGoodsReceipt(String receiptID) async {
    try {
      await _goodsReceiptRepository.deleteGoodsReceipt(receiptID);
    } catch (e) {
      print('Error deleting goods receipt: $e');
      // Handle error appropriately
    }
  }
}
