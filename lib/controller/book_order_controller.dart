import '../model/book.dart';
import '../model/book_order.dart';
import '../repository/book_order_repository.dart';

class BookOrderController {
  final BookOrderRepository _bookOrderRepository;

  BookOrderController(this._bookOrderRepository);

  Future<void> createBookOrder(BookOrder order) async {
    try {
      await _bookOrderRepository.addBookOrder(order);
    } catch (e) {
      print('Error creating book order: $e');
      // Handle error appropriately
    }
  }

  Future<BookOrder?> readBookOrderByID(String orderID) async {
    try {
      return await _bookOrderRepository.getBookOrderByID(orderID);
    } catch (e) {
      print('Error reading book order: $e');
      return null;
    }
  }

  Future<List<BookOrder>> getAllBookOrders() async {
    try {
      // Adjust this method if needed
      return await _bookOrderRepository.getAllBookOrders(); // Make sure this method exists in the repository
    } catch (e) {
      print('Error retrieving all customer: $e');
      return [];
    }
  }

  Future<List<BookOrder>> getBookOrdersByCustomer(String customerID) async {
    try {
      // Adjust this method if needed
      return await _bookOrderRepository.getBookOrdersByCustomer(customerID); // Make sure this method exists in the repository
    } catch (e) {
      print('Error retrieving book orders of customer ${customerID}: $e');
      return [];
    }
  }

  Future<int> getBookSoldCurrentMonth(Book book) async {
    try {
      // Adjust this method if needed
      return await _bookOrderRepository.getBookSoldCurrentMonth(book); // Make sure this method exists in the repository
    } catch (e) {
      print('Error retrieving all customer: $e');
      return 0;
    }
  }

  Future<void> updateBookOrder(BookOrder order) async {
    try {
      await _bookOrderRepository.updateBookOrder(order);
    } catch (e) {
      print('Error updating book order: $e');
      // Handle error appropriately
    }
  }

  Future<void> deleteBookOrder(String orderID) async {
    try {
      await _bookOrderRepository.deleteBookOrder(orderID);
    } catch (e) {
      print('Error deleting book order: $e');
      // Handle error appropriately
    }
  }
}
