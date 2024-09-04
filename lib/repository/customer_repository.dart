import '../model/customer.dart';
import '../network/customer_data_source.dart';

class CustomerRepository {
  final CustomerDataSource _dataSource = CustomerDataSource();

  Future<void> addCustomer (Customer customer) => _dataSource.createCustomer(customer);

  Future<Customer?> getCustomerByID (String customerID) => _dataSource.readCustomerByID(customerID);

  Future<List<Customer>> getCustomersByName (String name) => _dataSource.readCustomersByName(name);

  Future<List<Customer>> getCustomersByPhoneNumber (String phoneNumber) => _dataSource.readCustomersByPhoneNumber(phoneNumber);

  Future<List<Customer>> getCustomersByAddress (String address) => _dataSource.readCustomersByAddress(address);

  Future<List<Customer>> getCustomersByEmail (String email) => _dataSource.readCustomersByEmail(email);

  Future<List<Customer>> getAllCustomers() => _dataSource.readAllCustomers();

  Future<void> updateCustomer (Customer customer) => _dataSource.updateCustomer(customer);

  Future<void> deleteCustomer (String customerID) => _dataSource.deleteCustomer(customerID);

}