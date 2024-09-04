class Book {
  String bookID;
  String isbn;
  String title;
  String coverImageLink;
  List<String> genres;
  List<String> authors;
  int stockQuantity;
  num price;
  String publisher;
  DateTime publicationDate;

  Book({
    required this.bookID,
    required this.isbn,
    required this.title,
    required this.coverImageLink,
    required this.genres,
    required this.authors,
    required this.stockQuantity,
    required this.price,
    required this.publisher,
    required this.publicationDate,
  });

  // Convert a Book object to a Firestore document
  Map<String, dynamic> toFirestore() {
    return {
      'bookID': bookID,
      'ISBN': isbn,
      'Title': title,
      'Cover Image': coverImageLink,
      'Genre': genres,
      'Author': authors,
      'StockQuantity': stockQuantity,
      'Price': price,
      'Publisher': publisher,
      'PublicationDate': publicationDate.toIso8601String(),
    };
  }

  // Create a Book object from a Firestore document
  factory Book.fromFirestore(Map<String, dynamic> data) {
    return Book(
      bookID: data['bookID'] ?? '',
      isbn: data['ISBN'] ?? '',
      title: data['Title'] ?? '',
      coverImageLink: data['Cover Image'] ?? '',
      genres: List<String>.from(data['Genre'] ?? []),
      authors: List<String>.from(data['Author'] ?? []),
      stockQuantity: data['StockQuantity'] ?? 0,
      price: data['Price'] ?? 0,
      publisher: data['Publisher'] ?? '',
      publicationDate: DateTime.parse(data['PublicationDate'] ?? DateTime.now().toIso8601String()),
    );
  }
}
