import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
  bool _isShowingSnackBar = false; // Track snack bar state

  @override
  void dispose() {
    _scrollController.dispose();
    _customerNameController.dispose();
    _phoneNumberController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);

    _addForm(); // Add one form initially
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

  bool isValidForUpload({required String dateSaved}) {
    if (_formWidgets.isEmpty) {
      _showSnackBar('Không có dữ liệu gì để lưu cho $dateSaved!',
          isError: true);
      return false;
    }

    if (_customerNameController.text.isEmpty) {
      _showSnackBar('Hóa đơn không hợp lệ nếu không có tên khách hàng!',
          isError: true);
      return false;
    }

    return true;
  }

  void _onSavePressed() {
    if (_isShowingSnackBar) return; // Prevent spamming button

    _isShowingSnackBar = true; // Set saving state to true

    String dateSaved = (serverUploadedDateInputData.year ==
                DateTime.now().year &&
            serverUploadedDateInputData.month == DateTime.now().month &&
            serverUploadedDateInputData.day == DateTime.now().day)
        ? "hôm nay"
        : "ngày ${serverUploadedDateInputData.day}/${serverUploadedDateInputData.month}/${serverUploadedDateInputData.year}";

    if (isValidForUpload(dateSaved: dateSaved)) {
      serverUploadedCustomerName = _customerNameController.text;
      serverUploadedPhoneNumber = _phoneNumberController.text;
      serverUploadedBookSaleInvoicesData = _formKeys
          .map((key) => key.currentState!.getBookSaleInvoiceData())
          .toList();

      // add the code to upload data to server here

      _showSnackBar('Đã lưu các phiếu nhập sách cho $dateSaved!');
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
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
                    title: const Text("Lưu ý về nhập trùng dữ liệu",
                        style:
                            TextStyle(color: Color.fromRGBO(120, 171, 168, 1))),
                    // Customize the title
                    content: Text(
                      "Nếu có nhiều hơn 1 form nhập dưới đây có cùng thông tin về một cuốn sách nào đó, dữ liệu về số lượng nhập cho cuốn sách đó khi lưu lại sẽ được cộng gộp các form liên quan lại với nhau.",
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
                      fontSize: 16, color: Color.fromRGBO(120, 171, 168, 1),fontWeight: FontWeight.bold),
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
                      fontSize: 16, color: Color.fromRGBO(120, 171, 168, 1),fontWeight: FontWeight.bold),
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
                      fontSize: 16, color: Color.fromRGBO(120, 171, 168, 1),fontWeight: FontWeight.bold),
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
              // Make the forms scrollable
              child: ListView.builder(
                controller: _scrollController,
                itemCount: _formWidgets.length,
                itemBuilder: (context, index) {
                  return Column(
                    children: [
                      Dismissible(
                        key: UniqueKey(),
                        direction: DismissDirection.endToStart,
                        confirmDismiss: (direction) async {
                          return await showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                backgroundColor:
                                    const Color.fromRGBO(241, 248, 232, 1),
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
                                      Navigator.of(context).pop(
                                          false); // Dismisses the dialog and does not delete the form
                                    },
                                    child: const Text(
                                      "Không",
                                      style: TextStyle(
                                          color:
                                              Color.fromRGBO(120, 171, 168, 1)),
                                    ),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(context).pop(
                                          true); // Dismisses the dialog and confirms deletion
                                    },
                                    style: TextButton.styleFrom(
                                      foregroundColor:
                                          Colors.red, // Color for delete button
                                    ),
                                    child: const Text(
                                      'Xóa',
                                      style: TextStyle(
                                          color:
                                              Color.fromRGBO(239, 156, 102, 1)),
                                    ),
                                  ),
                                ],
                              );
                            },
                          );
                        },
                        // Swipe left to delete
                        onDismissed: (direction) {
                          setState(() {
                            _formWidgets.removeAt(index);
                            _formKeys.removeAt(index);
                          });
                          if (_formWidgets.isNotEmpty) {
                            _showSnackBar(
                                'Đã xóa phiếu nhập sách ở STT ${index + 1}!',
                                isError: true);
                          } else {
                            _showSnackBar('Đã xóa toàn bộ phiếu hôm nay!',
                                isError: true);
                          }
                          // Use addPostFrameCallback to update order numbers after the build is complete
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            setState(() {
                              for (int i = 0; i < _formWidgets.length; i++) {
                                _formKeys[i]
                                    .currentState!
                                    .updateOrderNumber(i + 1);
                              }
                            });
                          });
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
                        child: _formWidgets[index],
                      ),
                      const SizedBox(height: 30),
                    ],
                  );
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}
