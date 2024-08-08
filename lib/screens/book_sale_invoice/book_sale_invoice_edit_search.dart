import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../mutual_widgets.dart';
import 'book_sale_invoice_widgets.dart';

List<InvoiceData> serverUploadedBookSaleInvoicesData = [];

class BookSaleInvoiceEditSearch extends StatefulWidget {
  final VoidCallback backContextSwitcher;
  final List<InvoiceData> editedItems;
  final DateTime editedDate;
  final String customerName;
  final String phoneNumber;

  const BookSaleInvoiceEditSearch({
    super.key,
    required this.editedItems,
    required this.backContextSwitcher,
    required this.editedDate,
    required this.customerName,
    required this.phoneNumber,
  });

  @override
  State<BookSaleInvoiceEditSearch> createState() =>
      _BookSaleInvoiceEditSearchState();
}

class _BookSaleInvoiceEditSearchState extends State<BookSaleInvoiceEditSearch> {
  final List<BookSaleInvoiceInputFormState> _formStates = [];
  bool _isShowingSnackBar = false;
  final TextEditingController _customerNameController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();

  @override
  void initState() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
    _customerNameController.text = widget.customerName;
    _phoneNumberController.text = widget.phoneNumber;
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    _customerNameController.dispose();
    _phoneNumberController.dispose();
  }

  void _onUpdatePressed() {
    if (_isShowingSnackBar) return; // Prevent spamming button

    _isShowingSnackBar = true; // Set saving state to true

    // Get the updated data from the form states
    serverUploadedBookSaleInvoicesData = _formStates
        .map((formState) => formState.getBookSaleInvoiceData())
        .toList();
    for (int i = 0; i < serverUploadedBookSaleInvoicesData.length; ++i) {
      print(serverUploadedBookSaleInvoicesData[i].bookName);
      print(serverUploadedBookSaleInvoicesData[i].genre);
      print(serverUploadedBookSaleInvoicesData[i].price);
      print(serverUploadedBookSaleInvoicesData[i].quantity);
    }

    // Check if there is any change in the data
    bool hasChanges = false;

    for (int i = 0; i < widget.editedItems.length; ++i) {
      if (serverUploadedBookSaleInvoicesData[i].bookName !=
              widget.editedItems[i].bookName ||
          serverUploadedBookSaleInvoicesData[i].genre !=
              widget.editedItems[i].genre ||
          serverUploadedBookSaleInvoicesData[i].price !=
              widget.editedItems[i].price ||
          serverUploadedBookSaleInvoicesData[i].quantity !=
              widget.editedItems[i].quantity) {
        hasChanges = true;
        break; // Exit the loop early if any change is detected
      }
    }

    if (!hasChanges) {
      _showSnackBar('Không có dữ liệu gì thay đổi!', isError: true);
      return;
    }

    // add the code to upload data to server here (backend)

    _showSnackBar(
        'Đã cập nhật thông tin các phiếu nhập ngày ${stdDateFormat.format(widget.editedDate)}');
    widget.backContextSwitcher();
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

  void explainWhyDisable(
      {required BuildContext context, required String errorString}) {
    if (_isShowingSnackBar) return; // Prevent spamming button

    _isShowingSnackBar = true; // Set saving state to true

    ScaffoldMessenger.of(context)
        .showSnackBar(
          SnackBar(
            content: Text(errorString),
            duration: const Duration(seconds: 2), // Adjust duration as needed
            behavior:
                SnackBarBehavior.floating, // Optional: make the Snackbar float
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
          "Chỉnh sửa",
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
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 0.0),
        child: Column(
          children: [
            const SizedBox(
              height: 25,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                const Text(
                  "Ngày đang chỉnh sửa: ",
                  style: TextStyle(
                      fontSize: 16, color: Color.fromRGBO(120, 171, 168, 1)),
                ),
                DatePickerBox(
                  initialDate: widget.editedDate,
                  backgroundColor: const Color.fromRGBO(200, 207, 160, 1),
                  foregroundColor: Colors.black,
                  isEnabled: false,
                  errorMessageWhenDisabled:
                      'Ngày chỉnh sửa đã bị vô hiệu hóa chỉnh sửa để đảm bảo tính toàn vẹn của dữ liệu',
                )
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                const Text(
                  "Họ tên khách hàng: ",
                  style: TextStyle(
                      fontSize: 16, color: Color.fromRGBO(120, 171, 168, 1)),
                ),
                const SizedBox(
                  height: 60,
                ),
                SizedBox(
                  width: 196,
                  child: GestureDetector(
                    onTap: () {
                      explainWhyDisable(
                          context: context,
                          errorString:
                              'Họ tên khách hàng đã bị vô hiệu hóa chỉnh sửa để đảm bảo tính toàn vẹn của dữ liệu');
                    },
                    child: TextField(
                      controller: _customerNameController,
                      enabled: false,
                      decoration: InputDecoration(
                        isDense: true,
                        filled: true,
                        fillColor: Colors.grey,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(4),
                        ),
                        enabledBorder: const OutlineInputBorder(
                          borderSide:
                              BorderSide(color: Colors.grey, width: 0.0),
                        ),
                      ),
                      style: const TextStyle(
                          fontSize: 16, color: Colors.black),
                    ),
                  ),
                )
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                const Text(
                  "Số điện thoại: ",
                  style: TextStyle(
                      fontSize: 16, color: Color.fromRGBO(120, 171, 168, 1)),
                ),
                const SizedBox(
                  height: 60,
                ),
                SizedBox(
                  width: 196,
                  child: GestureDetector(
                    onTap: () {
                      explainWhyDisable(
                          context: context,
                          errorString:
                              'Số điện thoại khách hàng đã bị vô hiệu hóa chỉnh sửa để đảm bảo tính toàn vẹn của dữ liệu');
                    },
                    child: TextField(
                      controller: _phoneNumberController,
                      enabled: false,
                      decoration: InputDecoration(
                        isDense: true,
                        filled: true,
                        fillColor: Colors.grey,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(4),
                        ),
                        enabledBorder: const OutlineInputBorder(
                          borderSide:
                              BorderSide(color: Colors.grey, width: 0.0),
                        ),
                      ),
                      style: const TextStyle(
                          fontSize: 16, color: Colors.black),
                    ),
                  ),
                )
              ],
            ),
            const SizedBox(
              height: 46,
            ),
            CustomRoundedButton(
              backgroundColor: const Color.fromRGBO(239, 156, 102, 1),
              foregroundColor: const Color.fromRGBO(255, 245, 225, 1),
              title: "Cập nhật",
              onPressed: _onUpdatePressed,
              width: 108,
              fontSize: 24,
            ),
            const SizedBox(
              height: 46,
            ),
            Expanded(
              child: ListView.builder(
                itemCount: widget.editedItems.length,
                itemBuilder: (context, index) {
                  return Column(
                    children: [
                      BookSaleInvoiceInputForm(
                        orderNum: index + 1,
                        reference: widget.editedItems[index],
                        key: GlobalKey(),
                        onStateCreated: (state) =>
                            _formStates.add(state), // Save the form state
                      ),
                      const SizedBox(
                        height: 16,
                      )
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
