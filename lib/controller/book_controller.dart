import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tuple/tuple.dart';

import '../model/book.dart';
import '../network/book_data_source.dart';
import '../repository/book_order_repository.dart';
import '../repository/book_repository.dart';
import '../repository/goods_receipt_repository.dart';

class BookController {
  final BookRepository _bookRepository;

  BookController(this._bookRepository);

  Future<void> createBook(Book book) async {
    try {
      await _bookRepository.addBook(book);
    } catch (e) {
      print('Error creating book: $e');
      // Handle error appropriately
    }
  }

  Future<Book?> readBookByID(String bookID) async {
    try {
      return await _bookRepository.getBookByID(bookID);
    } catch (e) {
      print('Error reading book: $e');
      return null;
    }
  }

  Future<void> updateBook(Book book) async {
    try {
      await _bookRepository.updateBook(book);
    } catch (e) {
      print('Error updating book: $e');
      // Handle error appropriately
    }
  }

  Future<void> deleteBook(String bookID) async {
    try {
      await _bookRepository.deleteBook(bookID);
    } catch (e) {
      print('Error deleting book: $e');
      // Handle error appropriately
    }
  }

  Future<List<Book>> searchBooks(String query) async {
    List<Book> byTitle = await _bookRepository.getBooksByTitle(query);
    if (byTitle.isNotEmpty)
      return byTitle;

    List<Book> byAuthor = await _bookRepository.getBooksByAuthors(query);
    if (byAuthor.isNotEmpty)
      return byAuthor;

    List<Book> byGenre = await _bookRepository.getBooksByGenres(query);
    if (byGenre.isNotEmpty)
      return byGenre;

    List<Book> byISBN = await _bookRepository.getBooksByISBN(query);
    if (byISBN.isNotEmpty)
      return byISBN;

    return [];
  }

  Future<List<Book>> getAllBooks() async {
    try {
      // Adjust this method if needed
      return await _bookRepository.getAllBooks(); // Make sure this method exists in the repository
    } catch (e) {
      print('Error retrieving all books: $e');
      return [];
    }
  }

  Future<List<Tuple2<Book, Tuple4<int, int, int, int>>>> getMonthlyStockReport (List<Book> bookList, DateTime date) async {
    final bookOrderRepository = BookOrderRepository();
    final goodsReceiptRepository = GoodsReceiptRepository();

    DateTime startOfMonth = DateTime(date.year, date.month, 1);
    DateTime endOfMonth = DateTime(date.year, date.month + 1, 0, 23, 59, 59);
    DateTime currentDate = DateTime.now();

    Map<String, List<int>> bookReport = {};
    for (var book in bookList) {
      bookReport[book.bookID] = [0,0,book.stockQuantity]; //0: phat sinh nhap 1: phat sinh xuat 2: ton cuoi
    }

    final bookOrdersBetweenDate = await bookOrderRepository.getBookOrdersBetweenDate(startOfMonth, endOfMonth);
    final goodsReceiptsBetweenDate = await goodsReceiptRepository.getGoodsReceiptsBetweenDate(startOfMonth, endOfMonth);
    final bookOrdersNow2EndOfMonth = await bookOrderRepository.getBookOrdersBetweenDate(endOfMonth, currentDate);
    final goodsReceiptsNow2EndOfMonth = await goodsReceiptRepository.getGoodsReceiptsBetweenDate(endOfMonth, currentDate);

    for (var receipt in goodsReceiptsNow2EndOfMonth) {
      for (var bookItem in receipt.bookList) {
        bookReport[bookItem.item1.bookID]?[2] -= bookItem.item2;
      }
    }

    for (var order in bookOrdersNow2EndOfMonth) {
      for (var bookItem in order.bookList) {
        bookReport[bookItem.item1.bookID]?[2] += bookItem.item2;
      }
    }

    for (var receipt in goodsReceiptsBetweenDate) {
      for (var bookItem in receipt.bookList) {
        bookReport[bookItem.item1.bookID]?[0] += bookItem.item2;
      }
    }

    for (var order in bookOrdersBetweenDate) {
      for (var bookItem in order.bookList) {
        bookReport[bookItem.item1.bookID]?[1] += bookItem.item2;
      }
    }

    List<Tuple2<Book, Tuple4<int, int, int, int>>> res = [];
    for (var book in bookList) {
      final report = bookReport[book.bookID];
      final fullReport = Tuple4<int, int, int, int>(report![2] - report![0] + report![1], report![0], report![1], report![2]);
      res.add(Tuple2<Book, Tuple4<int, int, int, int>>(book, fullReport));
    }

    return res;
  }
}