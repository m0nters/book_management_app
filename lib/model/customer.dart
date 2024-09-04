class Customer {
  String customerID;
  String name;
  String phoneNumber;
  String address;
  String email;
  int debt;

  Customer({
    required this.customerID,
    required this.name,
    required this.phoneNumber,
    required this.address,
    required this.email,
    required this.debt,
  });

  Map<String, dynamic> toFirestore() {
    return {
      'customerID': customerID,
      'name': name,
      'phoneNumber': phoneNumber,
      'address': address,
      'email': email,
      'debt': debt,
    };
  }

  factory Customer.fromFirestore(Map<String, dynamic> data) {
    return Customer(
      customerID: data['customerID'],
      name: data['name'] ?? '',
      phoneNumber: data['phoneNumber'] ?? '',
      address: data['address'] ?? '',
      email: data['email'] ?? '',
      debt: data['debt'] ?? 0,
    );
  }

}
