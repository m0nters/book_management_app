import '../model/book.dart';
import '../model/goods_receipt.dart';
import '../network/goods_receipt_data_source.dart';

class GoodsReceiptRepository {
  final _dataSource = GoodsReceiptDataSource();

  Future<void> addGoodsReceipt (GoodsReceipt receipt) => _dataSource.createGoodsReceipt(receipt);

  Future<GoodsReceipt?> getGoodsReceiptByID (String receiptID) => _dataSource.readGoodsReceiptByID(receiptID);

  Future<List<GoodsReceipt>> getAllGoodsReceipts() => _dataSource.readAllGoodsReceipts();

  Future<List<GoodsReceipt>> getGoodsReceiptsByDate(DateTime date) => _dataSource.readGoodsReceiptsByDate(date);

  Future<DateTime?> getLatestBookReceiptDate (Book book) => _dataSource.readLatestBookReceiptDate(book);

  Future<List<GoodsReceipt>> getGoodsReceiptsBetweenDate (DateTime startDate, DateTime endDate) => _dataSource.readGoodsReceiptsBetweenDate(startDate, endDate);

  Future<int> getBookReceivedCurrentMonth(Book book) => _dataSource.readBookReceivedCurrentMonth(book);

  Future<int> getBookReceivedBetweenDate (Book book, DateTime startDate, DateTime endDate) => _dataSource.readBookReceivedBetweenDate(book, startDate, endDate);

  Future<void> updateGoodsReceipt (GoodsReceipt receipt) => _dataSource.updateGoodsReceipt(receipt);

  Future<void> deleteGoodsReceipt (String receiptID) => _dataSource.deleteGoodsReceipt(receiptID);

}