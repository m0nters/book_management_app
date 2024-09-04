import 'package:cloud_firestore/cloud_firestore.dart';

import '../model/book.dart';
import 'book_order_data_source.dart';
import 'cloud_firestore.dart';
import 'goods_receipt_data_source.dart';

class BookDataSource {
  final CloudFirestore _cloudFirestore = CloudFirestore();
  final String _collectionPath = 'book';

  // Create - C
  Future<void> createBook (Book book) async {
    try {
      final bookAsMap = book.toFirestore();

      // Add the book to Firestore and get the document reference
      DocumentReference docRef = await _cloudFirestore.addDocument(_collectionPath, bookAsMap);

      // Update the book object with the generated document ID
      book.bookID = docRef.id;

      // Update the Firestore document with the bookID
      await _cloudFirestore.updateDocument(_collectionPath, book.bookID, {'bookID': book.bookID});
    } catch (e) {
      print('Error adding book: $e');
    }
  }

  // Read - R
  Future<Book?> readBookByID (String bookID) async {
    try {
      DocumentSnapshot<Map<String, dynamic>> doc = await _cloudFirestore.readDocumentByID(_collectionPath, bookID);

      if (doc.exists) {
        return Book.fromFirestore(doc.data()!);
      } else {
        return null;
      }
    } catch (e) {
      print('Error retrieving book: $e');
      return null;
    }
  }

  Future<List<Book>> readAllBooks() async {
    try {
      final documents = await _cloudFirestore.readAllDocuments(_collectionPath);
      if (documents.isNotEmpty) {
        return documents.map((data) => Book.fromFirestore(data)).toList();
      } else {
        print('No books found in the Firestore collection.');
        return [];
      }
    } catch (e) {
      print('Error retrieving books: $e');
      return [];
    }
  }

  Future<List<Book>> readBooksByTitle(String title) async {
    try {
      // Query Firestore documents where the title field matches the provided title
      final QuerySnapshot<Map<String, dynamic>> querySnapshot = await _cloudFirestore
          .getCollectionReference(_collectionPath)
          .where('Title', isEqualTo: title)
          .get();

      // Convert each document into a Book object and return the list
      return querySnapshot.docs.map((doc) => Book.fromFirestore(doc.data())).toList();
    } catch (e) {
      print('Error retrieving books by title: $e');
      return [];
    }
  }

  Future<List<Book>> readBooksByAuthors(String authors) async {
    final authorList = authors.split(', ');
    try {
      // Query Firestore documents where the title field matches the provided title
      final QuerySnapshot<Map<String, dynamic>> querySnapshot = await _cloudFirestore
          .getCollectionReference(_collectionPath)
          .where('Author', arrayContainsAny: authorList)
          .get();

      // Convert each document into a Book object and return the list
      return querySnapshot.docs
          .map((doc) => Book.fromFirestore(doc.data()))
          .where((book) => authorList.every((author) => book.authors.contains(author)))
          .toList();
    } catch (e) {
      print('Error retrieving books by authors: $e');
      return [];
    }
  }

  Future<List<Book>> readBooksByGenres(String genres) async {
    final genreList = genres.split(', ');
    try {
      // Query Firestore documents where the title field matches the provided title
      final QuerySnapshot<Map<String, dynamic>> querySnapshot = await _cloudFirestore
          .getCollectionReference(_collectionPath)
          .where('Genre', arrayContainsAny: genreList)
          .get();

      // Convert each document into a Book object and return the list
      return querySnapshot.docs
          .map((doc) => Book.fromFirestore(doc.data()))
          .where((book) => genreList.every((genre) => book.genres.contains(genre)))
          .toList();
    } catch (e) {
      print('Error retrieving books by genres: $e');
      return [];
    }
  }

  Future<List<Book>> readBooksByISBN(String isbn) async {
    try {
      // Query Firestore documents where the title field matches the provided title
      final QuerySnapshot<Map<String, dynamic>> querySnapshot = await _cloudFirestore
          .getCollectionReference(_collectionPath)
          .where('ISBN', isEqualTo: isbn)
          .get();

      // Convert each document into a Book object and return the list
      return querySnapshot.docs.map((doc) => Book.fromFirestore(doc.data())).toList();
    } catch (e) {
      print('Error retrieving books by isbn: $e');
      return [];
    }
  }

  // Update - U
  Future<void> updateBook (Book book) async {
    try {
      final bookAsMap = book.toFirestore();

      // Update the Firestore document using the CloudFirestore
      await _cloudFirestore.updateDocument(_collectionPath, book.bookID, bookAsMap);
    } catch (e) {
      print('Error updating book: $e');
    }
  }

  // Delete - D
  Future<void> deleteBook(String bookID) async {
    try {
      // Delete the Firestore document using the CloudFirestore
      await _cloudFirestore.deleteDocument(_collectionPath, bookID);
    } catch (e) {
      print('Error deleting book: $e');
    }
  }

}