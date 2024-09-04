import 'package:tuple/tuple.dart';
import '../repository/book_repository.dart';
import '../repository/customer_repository.dart';
import 'book.dart'; // Import the Book class
import 'customer.dart'; // Import the Customer class

class BookOrder {
  String orderID;
  Customer? customer;
  DateTime? orderDate;
  List<Tuple2<Book, int>> bookList;
  int totalCost;

  BookOrder({
    required this.orderID,
    required this.customer,
    required this.orderDate,
    required this.bookList,
    required this.totalCost,
  });

  Map<String, dynamic> toFirestore() {
    return {
      'orderID': orderID,
      'customer': customer?.customerID, // Store only the customerID
      'orderDate': orderDate?.toIso8601String(),
      'bookList': bookList
          .map((tuple) => {
                'bookID': tuple.item1.bookID, // Store only the bookID
                'quantity': tuple.item2,
              })
          .toList(),
      'totalCost': totalCost,
    };
  }

  static Future<BookOrder?> fromFirestore(Map<String, dynamic> data) async {
    final bookRepo = BookRepository();
    final customerRepo = CustomerRepository();

    // Fetch the customer
    Customer? customer = await customerRepo.getCustomerByID(data['customer']);
    if (customer == null) {
      return null; // Customer not found
    }

    // Parse the date
    DateTime orderDate = DateTime.parse(data['orderDate'] ?? DateTime.now().toIso8601String()).toLocal();

    // Fetch the book list
    List<Tuple2<Book, int>> bookList = [];
    for (var item in data['bookList']) {
      Book? book = await bookRepo.getBookByID(item['bookID']);
      if (book != null) {
        int quantity = item['quantity'];
        bookList.add(Tuple2(book, quantity));
      }
    }

    return BookOrder(
      orderID: data['orderID'] ?? '',
      customer: customer,
      orderDate: orderDate,
      bookList: bookList,
      totalCost: data['totalCost'] ?? 0,
    );
  }

  @override
  String toString() {
    return 'Order{orderID: $orderID, customer: $customer, orderDate: $orderDate, bookList: $bookList}';
  }
}
