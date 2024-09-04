import '../model/book.dart';
import '../network/book_data_source.dart';

class BookRepository {
  final _dataSource = BookDataSource();

  Future<void> addBook (Book book) => _dataSource.createBook(book);

  Future<Book?> getBookByID (String bookID) => _dataSource.readBookByID(bookID);

  Future<List<Book>> getBooksByTitle (String title) => _dataSource.readBooksByTitle(title);

  Future<List<Book>> getBooksByAuthors (String authors) => _dataSource.readBooksByAuthors(authors);

  Future<List<Book>> getBooksByGenres (String genres) => _dataSource.readBooksByGenres(genres);

  Future<List<Book>> getBooksByISBN (String isbn) => _dataSource.readBooksByISBN(isbn);

  Future<List<Book>> getAllBooks() => _dataSource.readAllBooks();

  Future<void> updateBook (Book book) => _dataSource.updateBook(book);

  Future<void> deleteBook (String bookID) => _dataSource.deleteBook(bookID);


}