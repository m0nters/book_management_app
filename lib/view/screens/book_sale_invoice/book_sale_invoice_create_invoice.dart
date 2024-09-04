import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tuple/tuple.dart';
import '../../../controller/book_order_controller.dart';
import '../../../controller/rule_controller.dart';
import '../../../model/book.dart';
import '../../../model/book_order.dart';
import '../../../model/customer.dart';
import '../../../repository/book_order_repository.dart';
import '../../../repository/book_repository.dart';
import '../../../repository/customer_repository.dart';
import '../../../repository/rule_repository.dart';
import '../mutual_widgets.dart';
import 'book_sale_invoice_widgets.dart';
import '../setting/setting.dart';

late DateTime serverUploadedDateInputData;
late String serverUploadedCustomerName;
late String serverUploadedPhoneNumber;
List<InvoiceData> serverUploadedBookSaleInvoicesData = [];

class BookSaleInvoiceCreateInvoice extends StatefulWidget {
  final VoidCallback backContextSwitcher;

  const BookSaleInvoiceCreateInvoice(
      {super.key, required this.backContextSwitcher});

  @override
  State<BookSaleInvoiceCreateInvoice> createState() =>
      _BookSaleInvoiceCreateInvoiceState();
}

class _BookSaleInvoiceCreateInvoiceState
    extends State<BookSaleInvoiceCreateInvoice> {
  final List<Widget> _formWidgets = []; // Dynamic list of form widgets
  final List<GlobalKey<BookSaleInvoiceInputFormState>> _formKeys =
      []; // Corresponding keys
  final ScrollController _scrollController =
      ScrollController(); // Scroll controller

  final TextEditingController _customerNameController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();
  final FocusNode _customerNameFocusNode = FocusNode();
  final FocusNode _phoneNumberFocusNode = FocusNode();
  bool _becauseOfSubmissionCustomerName = false;
  bool _becauseOfSubmissionPhoneNumber = false;

  bool _isShowingSnackBar = false; // Track snack bar state
  bool _customerInfoIsValidToSave = false;
  Customer? targetCustomer;

  @override
  void dispose() {
    serverUploadedBookSaleInvoicesData.clear();
    _customerNameController.dispose();
    _phoneNumberController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);

    _addForm(); // Add one form initially
    BookSaleInvoiceInputFormState.existedNames.clear();

    _customerNameFocusNode.addListener(() {
      if (!_customerNameFocusNode.hasFocus &&
          !_becauseOfSubmissionCustomerName) {
        getTargetCustomer();
      }
    });

    _phoneNumberFocusNode.addListener(() {
      if (!_phoneNumberFocusNode.hasFocus && !_becauseOfSubmissionPhoneNumber) {
        getTargetCustomer();
      }
    });
  }

  void _addForm() {
    setState(() {
      final formKey = GlobalKey<BookSaleInvoiceInputFormState>();
      _formKeys.add(formKey); // Add the key to the list

      _formWidgets.add(
        BookSaleInvoiceInputForm(
          orderNum: _formWidgets.length + 1, // Dynamic order number
          key: formKey, // Assign the key
        ),
      );
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        // Check if the controller is attached
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> getTargetCustomer() async {
    _becauseOfSubmissionCustomerName = false;
    _becauseOfSubmissionPhoneNumber = false;

    _customerInfoIsValidToSave = false;
    targetCustomer = null;
    if (_customerNameController.text.isEmpty ||
        _phoneNumberController.text.isEmpty) {
      return;
    }

    final customerRepo = CustomerRepository();
    final customersByName = await customerRepo.getCustomersByName(
        removeRedundantSpaces(_customerNameController.text));
    final customersByPhoneNumber = await customerRepo.getCustomersByPhoneNumber(
        removeRedundantSpaces(_phoneNumberController.text));

    // Create a set of names from customersByName for faster lookups
    final nameSet = customersByName.map((c) => c.name).toSet();

    for (var customer in customersByPhoneNumber) {
      if (nameSet.contains(customer.name)) {
        targetCustomer = customer;
        break; // Exit the loop once a match is found
      }
    }

    if (targetCustomer == null) {
      _customerInfoIsValidToSave = false;
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            backgroundColor: const Color.fromRGBO(241, 248, 232, 1),
            title: const Text("Khách hàng không tồn tại",
                style: TextStyle(color: Color.fromRGBO(120, 171, 168, 1))),
            // Customize the title
            content: Text(
              "Không tồn tại khách hàng có thông tin như vậy. Thử xem lại họ tên khách hàng hoặc số điện thoại.\nVì do an toàn, hệ thống sẽ xóa đi toàn bộ thông tin đã nhập cũ, yêu cầu người dùng nhập lại cẩn thận.",
              style: TextStyle(color: Colors.grey[700]),
            ),
            // Customize the content
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Close the dialog
                },
                child: const Text("Đã hiểu",
                    style: TextStyle(color: Color.fromRGBO(239, 156, 102, 1))),
              ),
            ],
          );
        },
      );
      _customerNameController.clear();
      _phoneNumberController.clear();
      return;
    }

    final ruleController = RuleController(RuleRepository());
    int maxDebt = await ruleController.getCustomerMaxDebt();
    if (targetCustomer!.debt > maxDebt) {
      targetCustomer = null;
      _customerInfoIsValidToSave = false;
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            backgroundColor: const Color.fromRGBO(241, 248, 232, 1),
            title: const Text("Khách hàng không hợp lệ",
                style: TextStyle(color: Color.fromRGBO(120, 171, 168, 1))),
            // Customize the title
            content: Text(
              "Chỉ bán cho khách hàng nợ không quá $maxDebt.\nVì do an toàn, hệ thống sẽ xóa đi toàn bộ thông tin đã nhập cũ, yêu cầu người dùng nhập lại cẩn thận.",
              style: TextStyle(color: Colors.grey[700]),
            ),
            // Customize the content
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Close the dialog
                },
                child: const Text("Đã hiểu",
                    style: TextStyle(color: Color.fromRGBO(239, 156, 102, 1))),
              ),
            ],
          );
        },
      );
      _customerNameController.clear();
      _phoneNumberController.clear();
      return;
    }

    _customerInfoIsValidToSave = true;
  }

  Future<bool> uploadDataToDtb() async {
    final customerRepo = CustomerRepository();
    final bookRepo = BookRepository();
    List<Tuple2<Book, int>> bookList = [];

    int totalCost = 0;
    for (int i = 0; i < serverUploadedBookSaleInvoicesData.length; ++i) {
      var currentEntryObject = serverUploadedBookSaleInvoicesData[i];
      final targetList =
          await bookRepo.getBooksByTitle(currentEntryObject.bookName!);

      // if there exists a form with quantity = 0 or there's no book to upload
      if (currentEntryObject.quantity! == 0 || targetList.isEmpty) {
        _showSaveStatus(
            'Tồn tại thông tin sách bán không hợp lệ để tải lên cơ sở dữ liệu! Vui lòng kiểm tra lại tất cả các trường.',
            isError: true);
        return false;
      }

      Book targetBook = targetList[0];
      targetBook.stockQuantity -= currentEntryObject.quantity!;
      await bookRepo.updateBook(targetBook);
      bookList.add(Tuple2(targetBook, currentEntryObject.quantity!));
      totalCost += targetBook.price * currentEntryObject.quantity! as int;
    }

    targetCustomer?.debt += totalCost;
    await customerRepo.updateCustomer(targetCustomer!);

    if (bookList.isNotEmpty) {
      BookOrder currentInputEntryForm = BookOrder(
          orderID: '',
          customer: targetCustomer,
          orderDate: serverUploadedDateInputData,
          bookList: bookList,
          totalCost: totalCost);
      final bookOrderController = BookOrderController(BookOrderRepository());
      await bookOrderController.createBookOrder(currentInputEntryForm);
    } else {
      // there's no way we can get this error, but still put it in here for safety
      _showSaveStatus(
          'Lỗi không xác định, vui lòng sử dụng phần mềm đúng như những gì nó ngụ ý được thiết kế.',
          isError: true);
      return false;
    }

    return true;
  }

  void _onSavePressed() {
    if (!_customerInfoIsValidToSave) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            backgroundColor: const Color.fromRGBO(241, 248, 232, 1),
            title: const Text("Thiếu thông tin",
                style: TextStyle(color: Color.fromRGBO(120, 171, 168, 1))),
            // Customize the title
            content: Text(
              "Không thể lưu hóa đơn bán sách nếu thông tin khách hàng tương ứng không có hoặc không hợp lệ.",
              style: TextStyle(color: Colors.grey[700]),
            ),
            // Customize the content
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Close the dialog
                },
                child: const Text("Đã hiểu",
                    style: TextStyle(color: Color.fromRGBO(239, 156, 102, 1))),
              ),
            ],
          );
        },
      );
      return;
    }
    if (_isShowingSnackBar) return; // Prevent spamming button
    _isShowingSnackBar = true; // Set saving state to true

    String dateSaved = (serverUploadedDateInputData.year ==
                DateTime.now().year &&
            serverUploadedDateInputData.month == DateTime.now().month &&
            serverUploadedDateInputData.day == DateTime.now().day)
        ? "hôm nay"
        : "ngày ${serverUploadedDateInputData.day}/${serverUploadedDateInputData.month}/${serverUploadedDateInputData.year}";

    serverUploadedCustomerName = _customerNameController.text;
    serverUploadedPhoneNumber = _phoneNumberController.text;
    serverUploadedBookSaleInvoicesData = _formKeys
        .map((key) => key.currentState!.getBookSaleInvoiceData())
        .toList();

    // add the code to upload data to server here
    uploadDataToDtb().then((isValid) {
      if (isValid) {
        _showSaveStatus('Đã lưu các hóa đơn bán sách cho $dateSaved!');
        setState(() {
          _formWidgets.clear();
          _formKeys.clear();
          BookSaleInvoiceInputFormState.existedNames.clear();
          _addForm();
        });
      }
    });
  }

  void _showSaveStatus(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context)
        .showSnackBar(
          SnackBar(
            content: Text(message,
                style:
                    const TextStyle(color: Color.fromRGBO(215, 227, 234, 1))),
            backgroundColor:
                isError ? const Color.fromRGBO(239, 156, 102, 1) : Colors.green,
            duration: const Duration(seconds: 2),
          ),
        )
        .closed
        .then((reason) {
      _isShowingSnackBar =
          false; // Reset saving state after snack bar is closed
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(241, 248, 232, 1),
      appBar: AppBar(
        backgroundColor: const Color.fromRGBO(241, 248, 232, 1),
        foregroundColor: const Color.fromRGBO(120, 171, 168, 1),
        title: const Text(
          "Lập hóa đơn",
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
        actions: [
          IconButton(onPressed: _addForm, icon: const Icon(Icons.add_circle)),
          IconButton(
            onPressed: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    backgroundColor: const Color.fromRGBO(241, 248, 232, 1),
                    title: const Text("Lưu ý về ngày lập hóa đơn",
                        style:
                            TextStyle(color: Color.fromRGBO(120, 171, 168, 1))),
                    // Customize the title
                    content: Text(
                      "Ngày lập hóa đơn mặc định luôn là ngày hôm nay.",
                      style: TextStyle(color: Colors.grey[700]),
                    ),
                    // Customize the content
                    actions: <Widget>[
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop(); // Close the dialog
                        },
                        child: const Text("Đã hiểu",
                            style: TextStyle(
                                color: Color.fromRGBO(239, 156, 102, 1))),
                      ),
                    ],
                  );
                },
              );
            },
            icon: const Icon(Icons.info, size: 25),
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          children: [
            const SizedBox(
              height: 25,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                const Text(
                  "Ngày lập hoá đơn: ",
                  style: TextStyle(
                      fontSize: 16,
                      color: Color.fromRGBO(120, 171, 168, 1),
                      fontWeight: FontWeight.bold),
                ),
                DatePickerBox(
                  initialDate: DateTime.now(),
                  onDateChanged: (date) => serverUploadedDateInputData = date,
                  backgroundColor: const Color.fromRGBO(200, 207, 160, 1),
                  foregroundColor: const Color.fromRGBO(12, 24, 68, 1),
                )
              ],
            ),
            const SizedBox(
              height: 12,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                const Text(
                  "Họ tên khách hàng: ",
                  style: TextStyle(
                      fontSize: 16,
                      color: Color.fromRGBO(120, 171, 168, 1),
                      fontWeight: FontWeight.bold),
                ),
                Container(
                  width: 196,
                  decoration: BoxDecoration(
                    boxShadow: hasShadow
                        ? const [
                            BoxShadow(
                              offset: Offset(0, 4),
                              color: Colors.grey,
                              blurRadius: 4,
                            )
                          ]
                        : null,
                  ),
                  child: TextField(
                    focusNode: _customerNameFocusNode,
                    onSubmitted: (text) {
                      getTargetCustomer();
                      _becauseOfSubmissionCustomerName = true;
                    },
                    controller: _customerNameController,
                    decoration: InputDecoration(
                      isDense: true,
                      filled: true,
                      fillColor: const Color.fromRGBO(200, 207, 160, 1),
                      hintText: "Nhập họ tên khách hàng",
                      hintStyle: const TextStyle(
                          color: Color.fromRGBO(122, 122, 122, 1),
                          fontWeight: FontWeight.w400),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                      enabledBorder: const OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey, width: 1.0),
                      ),
                    ),
                    style: const TextStyle(
                        fontSize: 16, color: Color.fromRGBO(12, 24, 68, 1)),
                  ),
                )
              ],
            ),
            const SizedBox(
              height: 12,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                const Text(
                  "Số điện thoại: ",
                  style: TextStyle(
                      fontSize: 16,
                      color: Color.fromRGBO(120, 171, 168, 1),
                      fontWeight: FontWeight.bold),
                ),
                Container(
                  width: 196,
                  decoration: BoxDecoration(
                    boxShadow: hasShadow
                        ? const [
                            BoxShadow(
                              offset: Offset(0, 4),
                              color: Colors.grey,
                              blurRadius: 4,
                            )
                          ]
                        : null,
                  ),
                  child: TextField(
                    focusNode: _phoneNumberFocusNode,
                    onSubmitted: (text) {
                      getTargetCustomer();
                      _becauseOfSubmissionPhoneNumber = true;
                    },
                    controller: _phoneNumberController,
                    keyboardType: TextInputType.phone,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                    ],
                    decoration: InputDecoration(
                      isDense: true,
                      filled: true,
                      fillColor: const Color.fromRGBO(200, 207, 160, 1),
                      hintText: "Nhập số điện thoại",
                      hintStyle: const TextStyle(
                          color: Color.fromRGBO(122, 122, 122, 1),
                          fontWeight: FontWeight.w400),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                      enabledBorder: const OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey, width: 1.0),
                      ),
                    ),
                    style: const TextStyle(
                        fontSize: 16, color: Color.fromRGBO(12, 24, 68, 1)),
                  ),
                )
              ],
            ),
            const SizedBox(
              height: 20,
            ),
            CustomRoundedButton(
              backgroundColor: const Color.fromRGBO(239, 156, 102, 1),
              foregroundColor: const Color.fromRGBO(241, 248, 232, 1),
              title: "Lưu",
              onPressed: _onSavePressed,
              width: 108,
              fontSize: 24,
            ),
            const SizedBox(
              height: 20,
            ),
            Expanded(
              child: SingleChildScrollView(
                controller: _scrollController,
                child: Column(
                  children: _formWidgets.asMap().entries.map((entry) {
                    final index = entry.key;
                    final formWidget = entry.value;

                    return Column(
                      children: [
                        Dismissible(
                          key: UniqueKey(),
                          direction: DismissDirection.endToStart,
                          confirmDismiss: (direction) async {
                            final bool confirmDelete = await showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      backgroundColor: const Color.fromRGBO(
                                          241, 248, 232, 1),
                                      title: Text(
                                        _formWidgets.length != 1
                                            ? 'Xác nhận xóa'
                                            : "ĐÂY LÀ HÓA ĐƠN BÁN SÁCH CUỐI CÙNG!",
                                      ),
                                      content: const Text(
                                          "Bạn có chắc chắn muốn xóa hóa đơn bán sách này?"),
                                      actions: <Widget>[
                                        TextButton(
                                          onPressed: () {
                                            Navigator.of(context).pop(false);
                                          },
                                          child: const Text(
                                            "Không",
                                            style: TextStyle(
                                                color: Color.fromRGBO(
                                                    120, 171, 168, 1)),
                                          ),
                                        ),
                                        TextButton(
                                          onPressed: () {
                                            Navigator.of(context).pop(true);
                                          },
                                          style: TextButton.styleFrom(
                                            foregroundColor: Colors.red,
                                          ),
                                          child: const Text(
                                            'Xóa',
                                            style: TextStyle(
                                                color: Color.fromRGBO(
                                                    239, 156, 102, 1)),
                                          ),
                                        ),
                                      ],
                                    );
                                  },
                                ) ??
                                false;

                            if (confirmDelete) {
                              final bookName = _formKeys[index]
                                  .currentState
                                  ?.getBookSaleInvoiceData()
                                  .bookName;
                              BookSaleInvoiceInputFormState.existedNames
                                  .remove(bookName);

                              setState(() {
                                _formWidgets.removeAt(index);
                                _formKeys.removeAt(index);
                              });

                              if (_formWidgets.isNotEmpty) {
                                _showSaveStatus(
                                    'Đã xóa phiếu nhập sách ở STT ${index + 1}!',
                                    isError: true);
                              } else {
                                _showSaveStatus('Đã xóa toàn bộ phiếu hôm nay!',
                                    isError: true);
                              }

                              // Update order numbers after deletion
                              WidgetsBinding.instance.addPostFrameCallback((_) {
                                setState(() {
                                  for (int i = index;
                                      i < _formWidgets.length;
                                      i++) {
                                    _formKeys[i]
                                        .currentState!
                                        .updateOrderNumber(i + 1);
                                  }
                                });
                              });
                            }
                            return confirmDelete;
                          },
                          background: Container(
                            color: Colors.red,
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.only(right: 20.0),
                            child: const Icon(
                              Icons.delete,
                              color: Colors.white,
                            ),
                          ),
                          child: formWidget,
                        ),
                        const SizedBox(height: 30),
                      ],
                    );
                  }).toList(),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
