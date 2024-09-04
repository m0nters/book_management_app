import 'package:cloud_firestore/cloud_firestore.dart';

class CloudFirestore {
  final _db = FirebaseFirestore.instance;
  FirebaseFirestore get instance => _db;

  // Create - C
  Future<DocumentReference<Map<String, dynamic>>> addDocument (String collectionPath, Map<String, dynamic> data) {
    return getCollectionReference(collectionPath).add(data);
  }

  // Read - R
  Future<DocumentSnapshot<Map<String, dynamic>>> readDocumentByID (String collectionPath, String documentId) {
    return getCollectionReference(collectionPath).doc(documentId).get();
  }

  Future<List<Map<String, dynamic>>> readAllDocuments (String collectionPath) async {
    try {
      final querySnapshot = await getCollectionReference(collectionPath).get();
      if (querySnapshot.docs.isNotEmpty) {
        return querySnapshot.docs.map((doc) => doc.data()).toList();
      } else {
        print('No documents found in the Firestore collection.');
        return [];
      }
    } catch (e) {
      print('Error retrieving documents: $e');
      return [];
    }
  }

  // Update - U
  Future<void> updateDocument (String collectionPath, String documentID, Map<String, dynamic> data) {
    return getCollectionReference(collectionPath).doc(documentID).update(data);
  }

  // Delete - D
  Future<void> deleteDocument (String collectionPath, String documentId) {
    return getCollectionReference(collectionPath).doc(documentId).delete();
  }

  // Utility
  CollectionReference<Map<String, dynamic>> getCollectionReference (String collectionPath) {
    return _db.collection(collectionPath).withConverter(
      fromFirestore: (snapshot, _) => snapshot.data()!,
      toFirestore: (value, _) => value,
    );
  }

  Future<int> getSizeOfCollection (String collection) async {
    final querySnapshot = await _db.collection(collection).get();
    return querySnapshot.size;
  }

}