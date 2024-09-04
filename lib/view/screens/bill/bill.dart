import 'package:untitled2/controller/customer_controller.dart';
import 'package:untitled2/repository/customer_repository.dart';
import '../../../controller/rule_controller.dart';
import '../../../model/payment_receipt.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../repository/rule_repository.dart';
import '../mutual_widgets.dart';
import 'bill_search.dart';
import '/../model/customer.dart';
import '/../repository/payment_receipt_repository.dart';



class Bill extends StatefulWidget {
  final VoidCallback backContextSwitcher;
  final VoidCallback reloadContext;
  final Function(Widget) internalScreenContextSwitcher;

  const Bill({
    super.key,
    required this.backContextSwitcher,
    required this.internalScreenContextSwitcher,
    required this.reloadContext,
  });

  @override
  State<StatefulWidget> createState() => _BillState();
}

class _BillState extends State<Bill> {
  DateTime? _selectedDate;
  Customer? _selectedCustomer;
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  int? amountMoney;
  final PaymentReceiptRepository _paymentReceiptRepository = PaymentReceiptRepository();

  @override
  void initState() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
    super.initState();
  }


  Future<void> _saveData() async {
    if (_selectedCustomer == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng chọn khách hàng'),
        ),
      );
      return;
    }
    if (_selectedDate == null || _selectedDate!.isAfter(DateTime.now())) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng chọn ngày hợp lệ'),
        ),
      );
      return;
    }
    if (amountMoney == null || amountMoney == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng nhập số tiền'),
        ),
      );
      return;
    }
    RuleRepository ruleRepository = RuleRepository();
    RuleController ruleController = RuleController(ruleRepository);
    bool negativeDebtRights = await ruleController.getNegativeDebtRights();
    if (!negativeDebtRights && amountMoney! > _selectedCustomer!.debt) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Cảnh báo ràng buộc: Thu không vượt nợ khách hàng'),
        ),
      );
      return;
    }

    final paymentReceipt = PaymentReceipt(
      receiptID: DateTime.now().toString(), // Use your own ID generation logic
      customer: _selectedCustomer!,
      date: _selectedDate!,
      amount: amountMoney!,
    );

    await _paymentReceiptRepository.addPaymentReceipt(paymentReceipt);
    _selectedCustomer?.debt -= amountMoney!;
    CustomerRepository customerRepository = CustomerRepository();
    CustomerController customerController = CustomerController(customerRepository);
    await customerController.updateCustomer(_selectedCustomer!);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Phiếu thu tiền đã được lưu thành công', style: TextStyle(color: Colors.white),),
        backgroundColor: Colors.green,
      ),
    );
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
              SizedBox(height: 10,),
              _buildHeader(),
              _buildForm(),
              const SizedBox(height: 20),
              _buildSaveButton(),
            ],
          ),
        ),
      ),
    );
  }
  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: const Color.fromRGBO(235, 244, 246, 1),
      foregroundColor: const Color.fromRGBO(8, 131, 149, 1),
      title: const Text(
        "Phiếu thu tiền",
        style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Color.fromRGBO(8, 131, 149, 1)),
      ),
      actions: [
        IconButton(
            onPressed: () {
              widget.internalScreenContextSwitcher(
                BillSearch(
                  backContextSwitcher:
                  widget.backContextSwitcher,
                  internalScreenContextSwitcher: widget.internalScreenContextSwitcher,
                ),
              );
            },
            icon: const Icon(
              Icons.search,
              size: 29,
            )
        ),
      ],
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
            child: Text('Tạo phiếu thu tiền', style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.w500),),
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
                      enabled: false, // Cho phép chỉnh sửa dựa trên trạng thái chỉ đọc
                      textAlignVertical: TextAlignVertical.bottom,
                      decoration: InputDecoration(
                        hintText: '...',
                        hintStyle: TextStyle(color: Color(0xFFA3A3A3), fontWeight: FontWeight.w500),
                        disabledBorder: InputBorder.none,
                        filled: true,
                        fillColor: Colors.grey[200] // Thay đổi màu nền dựa trên trạng thái chỉ đọc
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
                        hintStyle: TextStyle(color: Color(0xFFA3A3A3), fontWeight: FontWeight.w500),
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
                hintStyle: TextStyle(color: Color(0xFFA3A3A3), fontWeight: FontWeight.w500),
                errorBorder: InputBorder.none,
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
                        contentPadding:  EdgeInsets.symmetric(horizontal: 8, vertical: 8),
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
  Widget _buildSaveButton() {
    return Align(
      alignment: Alignment.center,
      child: Container(
        width: 90,
        child: TextButton(
          onPressed: () {
            _saveData();
          },
          style: TextButton.styleFrom(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            backgroundColor: const Color(0xFF088395),
            elevation: 8,
            shadowColor: Colors.grey,
          ),
          child: const Text('Lưu', style: TextStyle(color: Colors.white),),
        ),
      ),
    );
  }
}