import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tuple/tuple.dart';
import '../../../controller/book_order_controller.dart';
import '../../../model/book.dart';
import '../../../repository/book_order_repository.dart';
import '../../../repository/book_repository.dart';
import '../../../repository/customer_repository.dart';
import '../mutual_widgets.dart';
import 'book_sale_invoice_widgets.dart';

bool disableButton = false;

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
    BookSaleInvoiceInputFormState.existedNames.clear();
  }

  Future<bool> uploadDataToDtb(InvoiceData editedItem, int index) async {
    final customerRepo = CustomerRepository();
    final bookOrderController = BookOrderController(BookOrderRepository());
    final order = await bookOrderController.readBookOrderByID(widget.editedItems[index].invoiceID!); // find the target book sale invoice

    final bookRepo = BookRepository();
    final newBookList = await bookRepo.getBooksByTitle(editedItem.bookName!); // returns the list of books that have the recently typed title
    final oldBookList = await bookRepo.getBooksByTitle(widget.editedItems[index]
        .bookName!); // returns the list of books that have the old title
    Book newBook = newBookList[0];
    Book oldBook = oldBookList[0];

    var oldQuantity = widget.editedItems[index].quantity ?? 0;
    var newQuantity = editedItem.quantity ?? 0;

    if (newQuantity == 0 || newBookList.isEmpty) {
      _showUpdateStatus('Thông tin chỉnh sửa không hợp lệ!', isError: true);
      return false;
    }

    if (oldBook.bookID == newBook.bookID) { // old book name = new book name
      // change stock quantity on server
      oldBook.stockQuantity -= (newQuantity - oldQuantity);
      await bookRepo.updateBook(oldBook);

      // change quantity that row
      for (Tuple2<Book,int> pair in order!.bookList) {
        if (pair.item1.bookID == oldBook.bookID) {
          order.bookList.remove(pair);
          break;
        }
      } // delete out the row

      order.totalCost -= oldBook.price * oldQuantity as int;
      order.customer?.debt -= oldBook.price * oldQuantity as int;
      order.totalCost += oldBook.price * newQuantity as int;
      order.customer?.debt += oldBook.price * newQuantity as int;
      order.bookList.add(Tuple2<Book, int>(oldBook, newQuantity));
      await customerRepo.updateCustomer(order.customer!);
      await bookOrderController.updateBookOrder(order);
    }
    else if (oldBook.bookID != newBook.bookID) {
      Tuple2<Book, int>? oldBookPair;
      Tuple2<Book, int>? newBookPair;
      int oldQuantityOfNewBook = 0;
      for (Tuple2<Book,int> pair in order!.bookList) {
        if (pair.item1.bookID == oldBook.bookID) {
          oldBookPair = pair;
        }
        if (pair.item1.bookID == newBook.bookID) {
          oldQuantityOfNewBook += pair.item2;
          newBookPair = pair;
        }
      }
      if (oldBookPair != null) {
        order.bookList.remove(oldBookPair);
      }
      if (newBookPair != null) {
        order.bookList.remove(newBookPair);
      }

      oldBook.stockQuantity += oldQuantity; // update the old book quantity
      order.totalCost -= oldBook.price * oldQuantity as int;
      order.customer?.debt -= oldBook.price * oldQuantity as int;
      await bookRepo.updateBook(oldBook);

      newBook.stockQuantity -= newQuantity; // update the new book quantity
      order.totalCost += newBook.price * newQuantity as int;
      order.customer?.debt += newBook.price * newQuantity as int;
      await bookRepo.updateBook(newBook);

      order.bookList.add(Tuple2<Book, int>(newBook, oldQuantityOfNewBook + newQuantity));
      await customerRepo.updateCustomer(order.customer!);
      await bookOrderController.updateBookOrder(order);
    }

    return true;
  }

  Future<void> _onUpdatePressed() async {
    if (_isShowingSnackBar) return; // Prevent spamming button

    _isShowingSnackBar = true; // Set saving state to true

    // Get the updated data from the form states
    serverUploadedBookSaleInvoicesData = _formStates
        .map((formState) => formState.getBookSaleInvoiceData())
        .toList();

    // Check if there is any change in the data
    bool hasChanges = false;

    for (int i = 0; i < widget.editedItems.length; ++i) {
      if (serverUploadedBookSaleInvoicesData[i].bookName !=
              widget.editedItems[i].bookName ||
          serverUploadedBookSaleInvoicesData[i].genres?.join(', ') !=
              widget.editedItems[i].genres?.join(', ') ||
          serverUploadedBookSaleInvoicesData[i].authors?.join(', ') !=
              widget.editedItems[i].authors?.join(', ') ||
          serverUploadedBookSaleInvoicesData[i].price !=
              widget.editedItems[i].price ||
          serverUploadedBookSaleInvoicesData[i].quantity !=
              widget.editedItems[i].quantity) {
        hasChanges = true;
        break; // Exit the loop early if any change is detected
      }
    }

    if (!hasChanges) {
      _showUpdateStatus('Không có dữ liệu gì thay đổi!', isError: true);
      return;
    }

    setState(() {
      disableButton = true;
    });

    _showUpdateStatus(
        'Vui lòng không rời màn hình này trong quá trình cập nhật\nSau khi cập nhật xong màn hình này sẽ tự động thoát ra!',
        isError: true,
        duration: 3000);

    // add the code to upload data to server here (backend)
    for (int i = 0; i < serverUploadedBookSaleInvoicesData.length; ++i) {
      await uploadDataToDtb(serverUploadedBookSaleInvoicesData[i], i);
      _showUpdateStatus('Đã cập nhật phiếu STT ${i + 1}', duration: 100);
    }
    await Future.delayed(const Duration(seconds: 3));
    if (widget.editedItems.length > 1) {
      _showUpdateStatus(
          'Đã cập nhật thông tin các hóa đơn bán sách liên quan trong ngày ${stdDateFormat.format(widget.editedDate)}');
    }
    else {
      _showUpdateStatus(
          'Đã cập nhật thông tin hóa đơn bán sách liên quan trong ngày ${stdDateFormat.format(widget.editedDate)}');
    }

    widget.backContextSwitcher();

    disableButton = false;
  }

  void _showUpdateStatus(String message, {bool isError = false, int duration = 2000}) {
    ScaffoldMessenger.of(context)
        .showSnackBar(
          SnackBar(
            content: Text(message,
                style:
                    const TextStyle(color: Color.fromRGBO(215, 227, 234, 1))),
            backgroundColor:
                isError ? const Color.fromRGBO(239, 156, 102, 1) : Colors.green,
            duration: Duration(milliseconds: duration),
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
                      fontSize: 16, color: Color.fromRGBO(120, 171, 168, 1), fontWeight: FontWeight.bold),
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
                      fontSize: 16, color: Color.fromRGBO(120, 171, 168, 1), fontWeight: FontWeight.bold),
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
                      fontSize: 16, color: Color.fromRGBO(120, 171, 168, 1), fontWeight: FontWeight.bold),
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
              isDisabled: disableButton,
            ),
            Expanded(
              child: disableButton
                  ? const Center(
                child: CircularProgressIndicator(
                    color: Color.fromRGBO(255, 105, 105, 1)),
              )
                  : Column(
                children: [
                  const SizedBox(
                    height: 46,
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        children: widget.editedItems.map((item) {
                          int index = widget.editedItems.indexOf(item);
                          return Column(
                            children: [
                              BookSaleInvoiceInputForm(
                                orderNum: index + 1,
                                reference: item,
                                key: GlobalKey(),
                                onStateCreated: (state) =>
                                    _formStates.add(state), // Save the form state
                                isEditingSearch: true,
                              ),
                              const SizedBox(
                                height: 16,
                              ),
                            ],
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
