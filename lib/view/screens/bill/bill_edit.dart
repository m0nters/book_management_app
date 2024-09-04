import '../../../controller/customer_controller.dart';
import '../../../controller/rule_controller.dart';
import '../../../repository/customer_repository.dart';
import '../../../repository/rule_repository.dart';
import '../mutual_widgets.dart';
import '/../model/payment_receipt.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '/../repository/payment_receipt_repository.dart';

class BillEdit extends StatefulWidget {
  final VoidCallback backContextSwitcher;
  final PaymentReceipt paymentReceipt;

  const BillEdit({super.key, required this.backContextSwitcher, required this.paymentReceipt});

  @override
  State<StatefulWidget> createState() => _BillEditState();
}

class _BillEditState extends State<BillEdit> {
  DateTime? _selectedDate;
  late final PaymentReceipt _paymentReceipt;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  late DateTime _dateController;
  final TextEditingController _amountController = TextEditingController();
  final PaymentReceiptRepository _paymentReceiptRepository = PaymentReceiptRepository();


  @override
  void initState() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
    super.initState();
    _paymentReceipt = widget.paymentReceipt;
    _nameController.text = _paymentReceipt.customer!.name;
    _addressController.text = _paymentReceipt.customer!.address;
    _phoneNumberController.text = _paymentReceipt.customer!.phoneNumber;
    _emailController.text = _paymentReceipt.customer!.email;
    _dateController = _paymentReceipt.date;

    String formattedValue = NumberFormat("#,###", "en_US").format(_paymentReceipt.amount);

    // Thay đổi dấu phân cách hàng nghìn từ dấu phẩy (,) thành dấu chấm (.)
    formattedValue = formattedValue.replaceAll(',', '.');

    _amountController.text = formattedValue;
  }
  @override
  void dispose() {
    // Dispose of the controllers when the widget is disposed
    _nameController.dispose();
    _addressController.dispose();
    _phoneNumberController.dispose();
    _emailController.dispose();
    _amountController.dispose();
    super.dispose();
  }
  Future<void> _deleteItem() async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Container(
            height: 80,
            width: 300,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  const Text(
                    'Bạn có chắc chắn muốn xoá phiếu thu tiền này?',
                    style: TextStyle(fontSize: 16),
                  ),
                  Row(
                    children: [
                      TextButton(
                        onPressed: () async {
                          Navigator.of(context).pop();
                        },
                        child: const Text('Không chấp nhận'),
                      ),
                      const SizedBox(width: 30,),
                      TextButton(
                        onPressed: () async {
                          _paymentReceipt.customer?.debt += _paymentReceipt.amount.toInt();
                          CustomerRepository customerRepository = CustomerRepository();
                          CustomerController customerController = CustomerController(customerRepository);
                          await customerController.updateCustomer(_paymentReceipt.customer!);
                          await _paymentReceiptRepository.deletePaymentReceipt(_paymentReceipt.receiptID);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Xoá thành công', style: TextStyle(color: Colors.white),),
                              backgroundColor: Colors.red,
                            ),
                          );
                          Navigator.of(context).pop();
                          // Quay lại màn hình trước đó
                          widget.backContextSwitcher();
                        },
                        child: const Text('Chấp nhận'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _saveData() async {
    // Kiểm tra các trường nhập liệu
    int? amountMoney = int.tryParse(_amountController.text.replaceAll('.', ''));
    if (amountMoney == null || amountMoney == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng nhập số tiền hợp lệ'),
        ),
      );
      return;
    }
    RuleRepository ruleRepository = RuleRepository();
    RuleController ruleController = RuleController(ruleRepository);
    bool negativeDebtRights = await ruleController.getNegativeDebtRights();
    if (!negativeDebtRights && amountMoney > (_paymentReceipt.customer!.debt + _paymentReceipt.amount.toInt()) ) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Cảnh báo ràng buộc: Thu không vượt nợ khách hàng'),
        ),
      );
      return;
    }
    if (_selectedDate != null && _selectedDate!.isAfter(DateTime.now())) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng chọn ngày hợp lệ'),
        ),
      );
      return;
    }
    // Cập nhật giá trị vào PaymentReceipt
    _paymentReceipt.customer!.name = _nameController.text;
    _paymentReceipt.customer!.address = _addressController.text;
    _paymentReceipt.customer!.phoneNumber = _phoneNumberController.text;
    _paymentReceipt.customer!.email = _emailController.text;
    _paymentReceipt.date = _dateController;
    //Cập nhật lại số tiền nợ
    _paymentReceipt.customer?.debt += (_paymentReceipt.amount.toInt() - amountMoney);

    _paymentReceipt.amount = amountMoney;

    CustomerRepository customerRepository = CustomerRepository();
    CustomerController customerController = CustomerController(customerRepository);
    await customerController.updateCustomer(_paymentReceipt.customer!);
    // Gọi hàm cập nhật
    await _paymentReceiptRepository.updatePaymentReceipt(_paymentReceipt);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Chỉnh sửa thành công', style: TextStyle(color: Colors.white),),
        backgroundColor: Colors.green,
      ),
    );
    // Quay lại màn hình trước đó
    widget.backContextSwitcher();
  }


  Future<void> _pickDate(BuildContext context) async {
    final DateTime initialDate = _selectedDate ?? DateTime.now();

    final DateTime? selected = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (selected != null && selected != _selectedDate) {
      setState(() {
        _selectedDate = selected;
        _dateController = selected; // Cập nhật _dateController
      });
    }
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      backgroundColor: const Color(0xFFEBF4F6),
      body: Padding(
          padding: const EdgeInsets.only(top: 10, right: 10, left: 10),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 10,),
                _buildHeader(),
                _buildForm(),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                        child: _buildDeleteButton()
                    ),
                    Expanded(
                        child: _buildSaveButton()
                    )
                  ],
                )
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
        "Chỉnh sửa phiếu thu tiền",
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
        borderRadius: BorderRadius.only(
            topLeft: Radius.circular(8),
            topRight: Radius.circular(8)),
        color: Color(0xFF088395),
      ),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.all(10.0),
            child: Text('Điền thông tin', style: TextStyle(
                fontSize: 18,
                color: Colors.white,
                fontWeight: FontWeight.w500),),
          )
        ],
      ),
    );
  }
  Widget _buildForm() {
    final DateFormat dateFormat = DateFormat('dd/MM/yyyy');
    final String formattedDate = dateFormat.format(_dateController);

    return Container(
      color: const Color(0xFFFCFFEB),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
              padding: EdgeInsets.only(left: 15.0, top: 8.0),
              child: Text(
                'Tên khách hàng', textAlign: TextAlign.left,)
          ),
          Container(
            height: 35,
            margin: const EdgeInsets.only(left: 15, right: 15),
            child: TextField(
              controller: _nameController,
              cursorColor: Colors.grey,
              readOnly: true,
              decoration: InputDecoration(
                hintText: 'Họ và tên...',
                hintStyle: const TextStyle(color: Color(0xFFA3A3A3),
                    fontWeight: FontWeight.w500),
                border: InputBorder.none,
                filled: true,
                fillColor: Colors.grey[200],
                contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              ),
            ),
          ),
          const SizedBox(height: 10,),
          const Padding(
            padding: EdgeInsets.only(left: 15, right: 15),
            child: Row(
              children: [
                Expanded(
                  child: Text('Địa chỉ'),
                ),
                Expanded(
                  child: Text('Số điện thoại'),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.only(left: 15.0, right: 15.0),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    height: 35,
                    margin: const EdgeInsets.only(right: 10),
                    child: TextField(
                      controller: _addressController,
                      cursorColor: Colors.grey,
                      readOnly: true,
                      textAlignVertical: TextAlignVertical.center,
                      decoration:  InputDecoration(
                        hintText: 'Nhập địa chỉ...',
                        hintStyle: const TextStyle(
                          color: Color(0xFFA3A3A3),
                          fontWeight: FontWeight.w500,
                        ),
                        border: InputBorder.none,
                        filled: true,
                        fillColor: Colors.grey[200],
                        contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                      ),
                    ),
                  ),
                ),

                Expanded(
                  child: Container(
                    height: 35,
                    child: TextField(
                      controller: _phoneNumberController,
                      keyboardType: TextInputType.number,
                      readOnly: true,
                      cursorColor: Colors.grey,
                      textAlignVertical: TextAlignVertical.center,
                      decoration:  InputDecoration(
                        hintText: 'Nhập số điện thoại...',
                        hintStyle: const TextStyle(
                            color: Color(0xFFA3A3A3),
                            fontWeight: FontWeight.w500),
                        border: InputBorder.none,
                        filled: true,
                        fillColor: Colors.grey[200],
                        contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
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
              cursorColor: Colors.grey,
              readOnly: true,
              textAlignVertical: TextAlignVertical.center,
              decoration: InputDecoration(
                hintText: 'Nhập email khách hàng...',
                hintStyle: TextStyle(color: Color(0xFFA3A3A3),
                    fontWeight: FontWeight.w500),
                border: InputBorder.none,
                filled: true,
                fillColor: Colors.grey[200],
                contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              ),
            ),
          ),
          const SizedBox(height: 10,),
          const Padding(
            padding: EdgeInsets.only(left: 15, right: 15),
            child: Row(
              children: [
                Expanded(
                  child: Text('Ngày thu tiền'),
                ),
                Expanded(
                  child: Text('Số tiền thu'),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(
                left: 15.0, right: 15.0, bottom: 20.0),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    height: 35,
                    decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(4)
                    ),
                    margin: const EdgeInsets.only(right: 10.0),
                    child: TextButton(
                      onPressed: () async {
                        _pickDate(context);
                        _dateController = _selectedDate!;
                      },
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 8), // Loại bỏ padding mặc định
                      ),
                      child: Row(
                        children: [
                          Text(
                            _selectedDate != null
                                ? dateFormat.format(_selectedDate!)
                                : formattedDate,
                            style: const TextStyle(fontSize: 16,
                              color: Colors.grey,
                              fontWeight: FontWeight.w500,),
                          ),
                          const Spacer(),
                          const Icon(Icons.calendar_month,
                            color: Colors.grey, size: 20,),
                        ],
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Container(
                    height: 35,
                    child: TextField(
                      controller: _amountController,
                      keyboardType: TextInputType.number,
                      cursorColor: Colors.grey,
                      textAlignVertical: TextAlignVertical.center,
                      decoration: const InputDecoration(
                        hintText: 'Tiền thu',
                        hintStyle: TextStyle(
                            color: Color(0xFFA3A3A3),
                            fontWeight: FontWeight.w500),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Colors.grey, // Màu xám cho border khi focus
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Colors.grey, // Màu xám cho border khi không focus
                          ),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: EdgeInsets.symmetric(horizontal: 8),
                        suffixText: 'VNĐ',
                      ),
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly, // Chỉ cho phép nhập số
                        ThousandsSeparatorInputFormatter(),
                      ],
                      onChanged: (value) {
                        setState(() {
                            String formattedValue = NumberFormat("#,###").format(value);
                            _amountController.text = formattedValue;
                          }
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDeleteButton() {
    return Container(
      padding: EdgeInsets.only(left: 70, right: 20),
      child: TextButton(
          onPressed: () {
            _deleteItem();
          },
          style: TextButton.styleFrom(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8)),
            backgroundColor: Colors.grey,
            elevation: 8,
            shadowColor: Colors.grey,
          ),
          child: const Text(
            'Xoá', style: TextStyle(color: Colors.white),)
      ),
    );
  }

  Widget _buildSaveButton() {
    return Container(
      padding: const EdgeInsets.only(left: 20, right: 70),
      child: TextButton(
          onPressed: () {
            _saveData();
          },
          style: TextButton.styleFrom(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8)),
            backgroundColor: const Color(0xFF088395),
            elevation: 8,
            shadowColor: Colors.grey,
          ),
          child: const Text(
            'Lưu', style: TextStyle(color: Colors.white),)
      ),
    );
  }
}