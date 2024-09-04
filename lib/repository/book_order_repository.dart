import '../model/book.dart';
import '../model/book_order.dart';
import '../model/customer.dart';
import '../network/book_order_data_source.dart';

class BookOrderRepository {
  final _dataSource = BookOrderDataSource();

  Future<void> addBookOrder (BookOrder order) => _dataSource.createBookOrder(order);

  Future<BookOrder?> getBookOrderByID (String orderID) => _dataSource.readBookOrderByID(orderID);

  Future<List<BookOrder>> getAllBookOrders() => _dataSource.readAllBookOrders();

  Future<int> getBookSoldCurrentMonth(Book book) => _dataSource.readBookSoldCurrentMonth(book);

  Future<int> getBookSoldBetweenDate(Book book, DateTime startDate, DateTime endDate) => _dataSource.readBookSoldBetweenDate(book, startDate, endDate);

  Future<List<BookOrder>> getBookOrdersBetweenDate(DateTime startDate, DateTime endDate) => _dataSource.readBookOrdersBetweenDate(startDate, endDate);

  Future<int> getCustomerCostBetweenDate(Customer customer, DateTime startDate, DateTime endDate) => _dataSource.readCustomerCostBetweenDate(customer, startDate, endDate);

  Future<List<BookOrder>> getBookOrdersByCustomer (String customerID) => _dataSource.readBookOrdersByCustomer(customerID);

  Future<void> updateBookOrder (BookOrder order) => _dataSource.updateBookOrder(order);

  Future<void> deleteBookOrder (String orderID) => _dataSource.deleteBookOrder(orderID);

}