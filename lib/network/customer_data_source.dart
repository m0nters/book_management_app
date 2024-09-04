import 'package:cloud_firestore/cloud_firestore.dart';

import '../model/customer.dart';
import 'book_order_data_source.dart';
import 'payment_receipt_data_source.dart';
import 'cloud_firestore.dart';

class CustomerDataSource {
  final CloudFirestore _cloudFirestore = CloudFirestore();
  final String _collectionPath = 'customer';

  // Create - C
  Future<void> createCustomer (Customer customer) async {
    try {
      final customerAsMap = customer.toFirestore();

      // Add the customer to Firestore and get the document reference
      DocumentReference<Map<String, dynamic>> docRef = await _cloudFirestore.addDocument(_collectionPath, customerAsMap);

      // Update the customer object with the generated document ID
      customer.customerID = docRef.id;

      // Update the Firestore document with the customerID
      await _cloudFirestore.updateDocument(_collectionPath, customer.customerID, {'customerID': customer.customerID});
    } catch (e) {
      print('Error adding customer: $e');
    }
  }

  // Read - R
  Future<Customer?> readCustomerByID (String customerID) async {
    try {
      DocumentSnapshot<Map<String, dynamic>> doc = await _cloudFirestore.readDocumentByID(_collectionPath, customerID);

      if (doc.exists) {
        return Customer.fromFirestore(doc.data()!);
      } else {
        return null;
      }
    } catch (e) {
      print('Error retrieving customer: $e');
      return null;
    }
  }

  Future<List<Customer>> readCustomersByName (String name) async {
    try {
      // Query Firestore documents where the title field matches the provided title
      final QuerySnapshot<Map<String, dynamic>> querySnapshot = await _cloudFirestore
          .getCollectionReference(_collectionPath)
          .where('name', isEqualTo: name)
          .get();

      // Convert each document into a Book object and return the list
      return querySnapshot.docs.map((doc) => Customer.fromFirestore(doc.data())).toList();
    } catch (e) {
      print('Error retrieving customers by name: $e');
      return [];
    }
  }

  Future<List<Customer>> readCustomersByPhoneNumber (String phoneNumber) async {
    try {
      // Query Firestore documents where the title field matches the provided title
      final QuerySnapshot<Map<String, dynamic>> querySnapshot = await _cloudFirestore
          .getCollectionReference(_collectionPath)
          .where('phoneNumber', isEqualTo: phoneNumber)
          .get();

      // Convert each document into a Book object and return the list
      return querySnapshot.docs.map((doc) => Customer.fromFirestore(doc.data())).toList();
    } catch (e) {
      print('Error retrieving customers by phone number: $e');
      return [];
    }
  }

  Future<List<Customer>> readCustomersByAddress (String address) async {
    try {
      // Query Firestore documents where the title field matches the provided title
      final QuerySnapshot<Map<String, dynamic>> querySnapshot = await _cloudFirestore
          .getCollectionReference(_collectionPath)
          .where('address', arrayContains: address)
          .get();

      // Convert each document into a Book object and return the list
      return querySnapshot.docs.map((doc) => Customer.fromFirestore(doc.data())).toList();
    } catch (e) {
      print('Error retrieving customers by address: $e');
      return [];
    }
  }

  Future<List<Customer>> readCustomersByEmail (String email) async {
    try {
      // Query Firestore documents where the title field matches the provided title
      final QuerySnapshot<Map<String, dynamic>> querySnapshot = await _cloudFirestore
          .getCollectionReference(_collectionPath)
          .where('email', isEqualTo: email)
          .get();

      // Convert each document into a Book object and return the list
      return querySnapshot.docs.map((doc) => Customer.fromFirestore(doc.data())).toList();
    } catch (e) {
      print('Error retrieving customers by email: $e');
      return [];
    }
  }

  Future<List<Customer>> readAllCustomers() async {
    try {
      QuerySnapshot<Map<String, dynamic>> querySnapshot = await _cloudFirestore.getCollectionReference(_collectionPath).get();

      if (querySnapshot.docs.isNotEmpty) {
        List<Customer> customers = querySnapshot.docs.map((doc) {
          return Customer.fromFirestore(doc.data());
        }).toList();

        print('Customers found: ${customers.length}');
        return customers;
      } else {
        print('No customers found in the Firestore collection.');
        return [];
      }
    } catch (e) {
      print('Error retrieving customers: $e');
      return [];
    }
  }

  // Update - U
  Future<void> updateCustomer (Customer customer) async {
    try {
      final customerAsMap = customer.toFirestore();

      // Update the Firestore document using the CloudFirestore
      await _cloudFirestore.updateDocument(_collectionPath, customer.customerID, customerAsMap);
    } catch (e) {
      print('Error updating customer: $e');
    }
  }

  // Delete - D
  Future<void> deleteCustomer (String customerID) async {
    try {
      // Delete the Firestore document using the CloudFirestore
      await _cloudFirestore.deleteDocument(_collectionPath, customerID);
    } catch (e) {
      print('Error deleting customer: $e');
    }
  }
}