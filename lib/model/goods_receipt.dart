import 'package:tuple/tuple.dart';

import '../repository/book_repository.dart';
import 'book.dart';

class GoodsReceipt {
  String receiptID;
  DateTime date;
  List<Tuple2<Book, int>> bookList; // Books and number of them being received

  GoodsReceipt({
    required this.receiptID,
    required this.date,
    required this.bookList,
  });

  Map<String, dynamic> toFirestore() {
    return {
      'receiptID': receiptID,
      'date': date.toIso8601String(),
      'bookList': bookList
          .map((tuple) => {
                'book': tuple.item1.bookID,
                'quantity': tuple.item2,
              })
          .toList(),
    };
  }

  static Future<GoodsReceipt?> fromFirestore(Map<String, dynamic> data) async {
    final bookRepo = BookRepository();

    List<Tuple2<Book, int>> bookList = [];
    for (var item in data['bookList']) {
      Book? book = await bookRepo.getBookByID(item['book']);
      if (book != null) {
        int quantity = item['quantity'];
        bookList.add(Tuple2(book, quantity));
      }
    }

    return GoodsReceipt(
      receiptID: data['receiptID'] ?? '',
      date: DateTime.parse(data['date'] ?? DateTime.now().toIso8601String()).toLocal(),
      bookList: bookList,
    );
  }

  @override
  String toString() {
    return 'GoodsReceipt{receiptID: $receiptID, date: $date, bookList: $bookList}';
  }
}
