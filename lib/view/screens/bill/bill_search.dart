import 'package:flutter/material.dart';
import 'package:dotted_line/dotted_line.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../../../repository/customer_repository.dart';
import '../mutual_widgets.dart';
import '/../repository/payment_receipt_repository.dart';
import '/../model/customer.dart';
import '/model/payment_receipt.dart';
import 'bill_edit.dart';



class BillSearch extends StatefulWidget {
  final VoidCallback backContextSwitcher;
  final Function(Widget) internalScreenContextSwitcher;

  const BillSearch({
    super.key,
    required this.backContextSwitcher,
    required this.internalScreenContextSwitcher
  });
  @override
  State<StatefulWidget> createState() => _BillSearchState();
}

class _BillSearchState extends State<BillSearch> {
  DateTime? _selectedDate;
  Customer? _selectedCustomer;
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  int? amountMoney;
  bool _isReadOnly = false; // Thêm biến này để điều khiển trạng thái chỉ đọc
  //Create object to query paymentReceipt
  PaymentReceiptRepository _paymentReceiptRepository = PaymentReceiptRepository();

  List <PaymentReceipt>? _alllistPaymentReceipt; //All the receipt of database
  List <PaymentReceipt>? _resultPaymentReceipt; //Receipt after filter

  @override
  void initState() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
    super.initState();
  }

  Future<void> _pickDate({
    required BuildContext context,
  }) async {
    final selected = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2004),
      lastDate: DateTime(2030),
    );
    if (selected != null) {
      setState(() {
        _selectedDate = selected;
      });

    }
  }

  Future<void> _onCustomerSelected(Customer customer) async {
    setState(() {
      _selectedCustomer = customer;
      _addressController.text = customer.address;
      _phoneNumberController.text = customer.phoneNumber;
      _emailController.text = customer.email;
      _isReadOnly = true; // Đặt các trường nhập liệu thành chỉ đọc
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      backgroundColor: const Color(0xFFEBF4F6),
      body: Padding(
          padding: const EdgeInsets.only(top: 10, left: 10, right: 10),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 10,),
                _buildHeader(),
                _buildForm(),
                const SizedBox(height: 20),
                _buildSearchButton(),
                const SizedBox(height: 20),
                _resultPaymentReceipt != null ?
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildFoundHeader(),
                    _buildFoundList(),
                  ],
                )
                    : _buildNotFound()
              ],
            ),
          )
      ),
    );
  }
  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: const Color(0xFFEBF4F6),
      foregroundColor: const Color.fromRGBO(8, 131, 149, 1),
      title: const Text(
        "Tìm kiếm phiếu thu tiền",
        style: TextStyle(
          fontWeight: FontWeight.bold,
        ),
      ),
      leading: IconButton(
        onPressed: () {
          widget.backContextSwitcher();
        },
        icon: const Icon(Icons.arrow_back),
      ),
    );
  }
  Widget _buildHeader() {
    return Container(
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.only(topLeft: Radius.circular(8), topRight: Radius.circular(8)),
        color: Color(0xFF088395),
      ),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.all(10.0),
            child: Text('Nhập thông tin', style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.w500),),
          )
        ],
      ),
    );
  }
  Widget _buildForm() {
    return Container(
      color: Color(0xFFFCFFEB),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
              padding: EdgeInsets.only(left: 15.0, top: 8.0),
              child: Text('Tên khách hàng', textAlign: TextAlign.left,)
          ),
          CustomerSearchScreen(onCustomerSelected: _onCustomerSelected,),
          SizedBox(height: 12.0,),
          Center(
            child: Text('Thông tin chi tiết', style: TextStyle(fontSize: 16),),
          ),
          SizedBox(height: 6.0,),
          const Padding(
            padding: EdgeInsets.only(left: 15),
            child: Row(
              children: [
                Expanded(child: Text('Địa chỉ')),
                Expanded(child: Text('Số điện thoại')),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.only(left: 15.0, right: 15.0),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.only(right: 10),
                    height: 35,
                    child: TextField(
                      controller: _addressController,
                      enabled: false,
                      textAlignVertical: TextAlignVertical.bottom,
                      decoration: InputDecoration(
                        hintText: '...',
                        hintStyle: TextStyle(color: Color(0xFFA3A3A3), fontWeight: FontWeight.w500),
                        disabledBorder: InputBorder.none,
                        filled: true,
                        fillColor:  Colors.grey[200]
                      ),
                      style: const TextStyle(
                          overflow: TextOverflow.ellipsis  // Thêm dấu ... nếu nội dung bị tràn khi ở trạng thái chỉ đọc
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Container(
                    height: 35,
                    child: TextField(
                      controller: _phoneNumberController,
                      enabled: false,
                      textAlignVertical: TextAlignVertical.bottom,
                      decoration: InputDecoration(
                        hintText: '...',
                        hintStyle: const TextStyle(color: Color(0xFFA3A3A3), fontWeight: FontWeight.w500),
                        disabledBorder: InputBorder.none,
                        filled: true,
                        fillColor: Colors.grey[200]
                      ),
                      style: const TextStyle(
                          overflow: TextOverflow.ellipsis // Thêm dấu ... nếu nội dung bị tràn khi ở trạng thái chỉ đọc
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          const Padding(
            padding: EdgeInsets.only(left: 15),
            child: Text('Email'),
          ),
          Container(
            height: 35,
            margin: const EdgeInsets.only(left: 15, right: 15),
            child: TextField(
              controller: _emailController,
              enabled: false,
              textAlignVertical: TextAlignVertical.bottom,
              decoration: InputDecoration(
                hintText: '...',
                hintStyle: const TextStyle(color: Color(0xFFA3A3A3), fontWeight: FontWeight.w500),
                disabledBorder: InputBorder.none,
                filled: true,
                fillColor: Colors.grey[200]
              ),
              style: const TextStyle(
                  overflow: TextOverflow.ellipsis
              ),
            ),
          ),
          const SizedBox(height: 10,),
          const Padding(
            padding: EdgeInsets.only(left: 15, right: 15),
            child: Row(
              children: [
                Expanded(child: Text('Ngày thu tiền')),
                Expanded(child: Text('Số tiền thu')),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 15.0, right: 15.0, bottom: 20.0),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 8.0),
                    height: 35,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    margin: EdgeInsets.only(right: 10.0),
                    child: TextButton(
                      onPressed: () async => _pickDate(context: context),
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero, // Để bỏ padding của TextButton
                        minimumSize: Size(double.infinity, double.infinity), // Để TextButton mở rộng toàn bộ Container
                      ),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Row(
                          mainAxisSize: MainAxisSize.min, // Để Row chỉ chiếm không gian cần thiết
                          children: [
                            Text(
                              _selectedDate != null
                                  ? '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}'
                                  : '../../..',
                              style: const TextStyle(fontSize: 16, color: Colors.grey, fontWeight: FontWeight.w500),
                            ),
                            Spacer(), // Thêm khoảng cách giữa văn bản và biểu tượng
                            const Icon(Icons.calendar_month, color: Colors.grey, size: 20,),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Container(
                    height: 35,
                    child: TextField(
                      keyboardType: TextInputType.number,
                      cursorColor: Colors.grey,
                      textAlignVertical: TextAlignVertical.bottom,
                      decoration: const InputDecoration(
                        hintText: 'Tiền thu',
                        hintStyle: TextStyle(color: Color(0xFFA3A3A3), fontWeight: FontWeight.w500),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.grey),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.grey),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                        suffixText: 'VNĐ',
                      ),
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly, // Chỉ cho phép nhập số
                        ThousandsSeparatorInputFormatter(),
                      ],
                      onChanged: (value) {
                        setState(() {
                          amountMoney = int.tryParse(value.replaceAll('.', '')); // Cập nhật giá trị amountMoney
                        });
                      },
                    ),
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
  Widget _buildSearchButton() {
    return Align(
      alignment: Alignment.center,
      child: Container(
        width: 120,
        child: TextButton(
          onPressed: () async {
            final selectedCustomer = _selectedCustomer;
            if (selectedCustomer != null) {
              // Lấy dữ liệu từ hàm getPaymentReceiptsByCustomerID một cách bất đồng bộ
              _alllistPaymentReceipt = await _paymentReceiptRepository.getAllPaymentReceipts();
              _resultPaymentReceipt = _alllistPaymentReceipt!.where((receipt) {
                return receipt.customer?.customerID == selectedCustomer.customerID &&  (_selectedDate == null ||
                    receipt.date == _selectedDate) && (amountMoney == null || amountMoney == receipt.amount );
              }).toList();

              // Sắp xếp danh sách theo ngày thu tiền (date) giảm dần (mới nhất trước)
              _resultPaymentReceipt?.sort((a, b) => b.date.compareTo(a.date));

              // Cập nhật lại trạng thái giao diện
              setState(() {});
            }
          },
          style: TextButton.styleFrom(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            backgroundColor: const Color(0xFF088395),
            elevation: 8,
            shadowColor: Colors.grey,
          ),
          child: const Text('Tìm kiếm', style: TextStyle(color: Colors.white)),
        ),
      ),
    );
  }

  Widget _buildNotFound() {
    return Container(
        alignment: Alignment.center,
        child: const Column(
          children: [
            Icon(Icons.search_off, color: Colors.grey, size: 170,),
            Text('Chưa có tìm kiếm nào được thực hiện', textAlign: TextAlign.center, style: TextStyle(color: Colors.grey))
          ],
        )
    );
  }
  Widget _buildFoundHeader() {
    return  Padding(
      padding: EdgeInsets.only(left: 8.0),
      child: Text('Đã tìm thấy ${_resultPaymentReceipt?.length} kết quả', style: TextStyle(fontSize: 20),),
    );
  }
  Widget _buildFoundList() {
    return Container(
      height: 300,
      child: ListView.builder(
          itemCount: _resultPaymentReceipt?.length ?? 0,
          itemBuilder: (context, index) {
            final paymentReceipt = _resultPaymentReceipt![index];

            final dateFormat = DateFormat('dd/MM/yyyy');
            final formattedDate = dateFormat.format(paymentReceipt.date);
            return Padding(
              padding: const EdgeInsets.only(left: 8.0, bottom: 20.0),
              child: GestureDetector(
                onTap: () {
                  widget.internalScreenContextSwitcher(
                    BillEdit(
                      backContextSwitcher: widget.backContextSwitcher,
                      paymentReceipt: paymentReceipt,
                    ),
                  );
                },
                child: Container(
                  padding: EdgeInsets.only(left: 15, right: 15),
                  height: 85,
                  width: 351,
                  decoration: const BoxDecoration(
                      image: DecorationImage(image: AssetImage('assets/images/book_entry_form_ticket.png'),fit: BoxFit.cover),
                      boxShadow: [
                        BoxShadow(
                            color: Colors.grey,
                            blurRadius: 3,
                            offset: Offset(0,3)
                        )
                      ]
                  ),
                  child: Column(
                    children: [
                      const Row(
                        children: [
                          Expanded(
                              child: Text('Mã phiếu')
                          ),
                          Expanded(
                              child: Text('Tên khách hàng', textAlign: TextAlign.right,)
                          )
                        ],
                      ),
                      Row(
                        children: [
                          Expanded(
                              child: Text( '${paymentReceipt.receiptID}', style: TextStyle(color: Color(0xFF858585), overflow: TextOverflow.ellipsis),)
                          ),
                          Expanded(
                              child: Text('${paymentReceipt.customer?.name}', textAlign: TextAlign.right,style: TextStyle(color: Color(0xFF858585), overflow: TextOverflow.ellipsis))
                          )
                        ],
                      ),
                      const DottedLine(
                        dashLength: 10,
                        dashGapLength: 10,
                      ),
                      const Row(
                        children: [
                          Expanded(
                              child: Text('Ngày thu tiền')
                          ),
                          Expanded(
                              child: Text('Số tiền thu', textAlign: TextAlign.right,)
                          )
                        ],
                      ),
                      Row(
                        children: [
                          Expanded(
                              child: Text(formattedDate, style: TextStyle(color: Color(0xFF858585)),)
                          ),
                          Expanded(
                              child: Text('${paymentReceipt.amount.toInt()} VNĐ', textAlign: TextAlign.right,style: TextStyle(color: Color(0xFF858585), overflow: TextOverflow.ellipsis))
                          )
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          }
      ),
    );
  }
}
class CustomerSearchScreen extends StatefulWidget {
  final Function(Customer) onCustomerSelected;

  const CustomerSearchScreen({
    super.key,
    required this.onCustomerSelected,
  });

  @override
  _CustomerSearchScreenState createState() => _CustomerSearchScreenState();
}

class _CustomerSearchScreenState extends State<CustomerSearchScreen> {
  final TextEditingController _nameController = TextEditingController();
  final CustomerRepository _customerRepository = CustomerRepository();
  List<Customer> _searchResults = [];
  Customer? _selectedCustomer;
  bool _isSearchLocked = false; // Biến để kiểm soát trạng thái tìm kiếm

  Future<void> _searchCustomers(String query) async {
    if (query.isNotEmpty && !_isSearchLocked) {
      final customers = await _customerRepository.getCustomersByName(query);
      setState(() {
        _searchResults = customers;
      });
    } else if (_isSearchLocked) {
      setState(() {
        _searchResults = [];
      });
    }
  }

  Future<void> _onCustomerSelected(Customer customer) async {
    setState(() {
      _selectedCustomer = customer;
      _nameController.text = customer.name; // Hiển thị tên khách hàng đã chọn trong TextField
      _nameController.selection = TextSelection.fromPosition(TextPosition(offset: _nameController.text.length)); // Đặt con trỏ vào cuối tên
      _searchResults.clear();
      _isSearchLocked = true; // Khóa tìm kiếm
    });
    widget.onCustomerSelected(customer);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 35,
            child: TextField(
              controller: _nameController,
              cursorColor: Colors.grey,
              textAlignVertical: TextAlignVertical.bottom,
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search, color: Color(0xFFA3A3A3),),
                hintText: 'Tìm kiếm khách hàng...',
                hintStyle: const TextStyle(
                  color: Color(0xFFA3A3A3),
                  fontWeight: FontWeight.w500,
                ),
                focusedBorder: _isSearchLocked
                    ? InputBorder.none
                    : const OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey),
                ),
                enabledBorder: _isSearchLocked
                    ? InputBorder.none
                    : const OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey),
                ),
                contentPadding: const EdgeInsets.all(8.0),
                errorBorder: InputBorder.none,
                disabledBorder: InputBorder.none,
                filled: true,
                fillColor: _isSearchLocked ? Colors.grey[200] : Colors.white,
              ),
              onChanged: _searchCustomers,
              enabled: !_isSearchLocked, // Khoá trường tìm kiếm nếu tìm kiếm đã bị khóa
            ),
          ),
          const SizedBox(height: 10),
          if (_searchResults.isEmpty &&
              _nameController.text.isNotEmpty &&
              !_isSearchLocked)
            const Center(
              child: Text(
                'Không tìm thấy khách hàng nào.',
                style: TextStyle(color: Colors.grey),
              ),
            ),
          if (_searchResults.isNotEmpty && !_isSearchLocked)
            Container(
              decoration: BoxDecoration(
                color: Color(0xFFFCFFEB),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: _searchResults.map((customer) {
                  return GestureDetector(
                    onTap: () => _onCustomerSelected(customer),
                    child: Container(
                      height: 35, // Chiều cao của từng mục
                      margin: const EdgeInsets.symmetric(vertical: 4), // Khoảng cách giữa các mục
                      padding: EdgeInsets.symmetric(horizontal: 8.0),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: Colors.grey),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                '${customer.name} (${customer.phoneNumber})',
                                style: const TextStyle(
                                  fontSize: 16, // Kích thước chữ
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
        ],
      ),
    );
  }
}