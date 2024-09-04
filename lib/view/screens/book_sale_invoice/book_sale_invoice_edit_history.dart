import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:tuple/tuple.dart';
import '../../../controller/book_order_controller.dart';
import '../../../controller/rule_controller.dart';
import '../../../model/book.dart';
import '../../../repository/book_order_repository.dart';
import '../../../repository/book_repository.dart';
import '../../../repository/customer_repository.dart';
import '../../../repository/rule_repository.dart';
import '../setting/setting.dart';
import '../mutual_widgets.dart';
import 'book_sale_invoice_widgets.dart';
import 'package:flutter/services.dart'; // Import for FilteringTextInputFormatter

late InvoiceData serverUploadedBookEntryData;

class BookSaleInvoiceEditHistory extends StatefulWidget {
  final VoidCallback backContextSwitcher;
  final VoidCallback reloadContext;
  final InvoiceData editedItem;

  final Color titleBarColor;
  final Color titleColor;
  final Color contentAreaColor;
  final Color contentTitleColor;
  final Color contentInputColor;
  final Color contentInputFormFillColor;
  final Color textFieldBorderColor;

  const BookSaleInvoiceEditHistory({
    super.key,
    required this.backContextSwitcher,
    required this.reloadContext,
    required this.editedItem,
    this.titleBarColor = const Color.fromRGBO(252, 220, 148, 1),
    this.titleColor = const Color.fromRGBO(120, 171, 168, 1),
    this.contentAreaColor = const Color.fromRGBO(120, 171, 168, 1),
    this.contentTitleColor = const Color.fromRGBO(241, 248, 232, 1),
    this.contentInputColor = const Color.fromRGBO(12, 24, 68, 1),
    this.contentInputFormFillColor = const Color.fromRGBO(241, 248, 232, 1),
    this.textFieldBorderColor = Colors.grey,
  });

  @override
  State<BookSaleInvoiceEditHistory> createState() =>
      _BookSaleInvoiceEditHistoryState();
}

class _BookSaleInvoiceEditHistoryState
    extends State<BookSaleInvoiceEditHistory> {
  final TextEditingController _customerNameController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();
  final TextEditingController _bookNameController = TextEditingController();
  final TextEditingController _genresController = TextEditingController();
  final TextEditingController _authorsController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final FocusNode _bookNameFocusNode = FocusNode();
  final FocusNode _quantityFocusNode = FocusNode();
  String? _originalBookName;
  bool _becauseOfSubmissionBookName = false;
  bool _becauseOfSubmissionQuantity = false;
  bool _isShowingSnackBar = false;
  late TextStyle titleStyle;

  Book? _originalBookEntity;
  Book? _currentBookEntity;
  late int _minStockAfter;

  @override
  void initState() {
    super.initState();

    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);

    _customerNameController.text = widget.editedItem.customerName!;
    _phoneNumberController.text = widget.editedItem.phoneNumber!;
    _bookNameController.text = widget.editedItem.bookName!;
    _genresController.text = widget.editedItem.genres?.join(', ') ?? '';
    _authorsController.text = widget.editedItem.authors?.join(', ') ?? '';
    _quantityController.text =
        stdNumFormat.format(widget.editedItem.quantity).toString();
    _priceController.text =
        stdNumFormat.format(widget.editedItem.price).toString();

    getOriginalBookEntity();
    _currentBookEntity = _originalBookEntity;

    _bookNameFocusNode.addListener(() {
      if (!_bookNameFocusNode.hasFocus && !_becauseOfSubmissionBookName) {
        autoFill(_bookNameController.text);
      }
    });

    _quantityFocusNode.addListener(() {
      if (!_quantityFocusNode.hasFocus && !_becauseOfSubmissionQuantity) {
        checkQuantity(_quantityController.text);
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    _customerNameController.dispose();
    _phoneNumberController.dispose();
    _bookNameController.dispose();
    _authorsController.dispose();
    _genresController.dispose();
    _priceController.dispose();
    _quantityController.dispose();
  }

  Future<Book?> getBookEntity(String name) async {
    final bookRepo = BookRepository();
    final targetList = await bookRepo.getBooksByTitle(name);
    return targetList.isNotEmpty ? targetList[0] : null;
  }

  Future<void> getOriginalBookEntity() async {
    _originalBookEntity = await getBookEntity(widget.editedItem.bookName!);
    _currentBookEntity = _originalBookEntity;
  }

  Future<void> autoFill(String bookName) async {
    _becauseOfSubmissionBookName = false;

    bookName = removeRedundantSpaces(bookName);
    _currentBookEntity = await getBookEntity(bookName); // can be null

    if (!mounted) return;

    if (_currentBookEntity == null) {
      _currentBookEntity = _originalBookEntity;
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Nhập không thành công",
                style: TextStyle(color: widget.titleColor)),
            content: Text(
                "Không tồn tại sách nào có tên như vậy trong cơ sở dữ liệu!",
                style: TextStyle(color: Colors.grey[700])),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text("Đã hiểu",
                    style: TextStyle(color: Color.fromRGBO(239, 156, 102, 1))),
              ),
            ],
          );
        },
      );
      _bookNameController.text = _originalBookName!;
      return;
    }

    _bookNameController.text = bookName;
    _genresController.text = _currentBookEntity!.genres.join(', ');
    _authorsController.text = _currentBookEntity!.authors.join(', ');
    _priceController.text =
        stdNumFormat.format(_currentBookEntity!.price).toString();
  }

  Future<void> checkQuantity(String text) async {
    int sellQuantity = int.tryParse(text.replaceAll('.', '')) ?? 0;

    if (_currentBookEntity == null) {
      _quantityController.clear();
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            backgroundColor: const Color.fromRGBO(241, 248, 232, 1),
            title: const Text("Không thể nhập",
                style: TextStyle(color: Color.fromRGBO(120, 171, 168, 1))),
            // Customize the title
            content: Text(
              "Số lượng bán phụ thuộc vào số lượng tồn kho của đầu sách cụ thể, vui lòng nhập tên sách trước rồi mới nhập số lượng bán.",
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
    }

    final ruleController = RuleController(RuleRepository());
    _minStockAfter = await ruleController.getMinStockPostOrder();
    bool isErrorWhileEditingOnTheSameBook = false;
    bool isErrorWhileEditingOnDifferentBooks = false;

    // if working on the same book
    if (_currentBookEntity == _originalBookEntity &&
        _currentBookEntity!.stockQuantity +
                widget.editedItem.quantity! -
                sellQuantity <
            _minStockAfter) {
      isErrorWhileEditingOnTheSameBook = true;
    }

    // if working on different books
    else if (_currentBookEntity != _originalBookEntity &&
        _currentBookEntity!.stockQuantity - sellQuantity < _minStockAfter) {
      isErrorWhileEditingOnDifferentBooks = true;
    }

    if (isErrorWhileEditingOnTheSameBook) {
      _quantityController.clear();
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            backgroundColor: const Color.fromRGBO(241, 248, 232, 1),
            title: const Text("Không thể nhập",
                style: TextStyle(color: Color.fromRGBO(120, 171, 168, 1))),
            // Customize the title
            content: Text(
              "Đầu sách phải có lượng tồn tối thiểu sau khi bán là $_minStockAfter.\n"
                  "Hướng dẫn: Số lượng tồn kho hiện tại của cuốn \"${_currentBookEntity?.title}\" "
                  "đang là ${_currentBookEntity?.stockQuantity}, số lượng đang bán hiện tại "
                  "là ${widget.editedItem.quantity}, nếu hủy nó thì số lượng tồn kho của "
                  "\"${_currentBookEntity?.title}\" sẽ lại là ${widget.editedItem.quantity! + _currentBookEntity!.stockQuantity}, "
                  "do đó số lượng bán sau chỉnh sửa chỉ có thể tối đa là ${widget.editedItem.quantity! + _currentBookEntity!.stockQuantity - _minStockAfter}.",
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
    }
    if (isErrorWhileEditingOnDifferentBooks) {
      _quantityController.clear();
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            backgroundColor: const Color.fromRGBO(241, 248, 232, 1),
            title: const Text("Không thể nhập",
                style: TextStyle(color: Color.fromRGBO(120, 171, 168, 1))),
            // Customize the title
            content: Text(
              "Đầu sách phải có lượng tồn tối thiểu sau khi bán là $_minStockAfter. "
              "Số lượng tồn kho hiện tại của cuốn \"${_currentBookEntity!.title}\" "
              "đang là ${_currentBookEntity!.stockQuantity}, do đó số lượng bán tối đa "
              "cho cuốn này chỉ có thể là ${_currentBookEntity!.stockQuantity - _minStockAfter}.",
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
    }
  }

  Future<bool> uploadDataToDtb() async {
    final customerRepo = CustomerRepository();
    final bookOrderController = BookOrderController(BookOrderRepository());
    final order = await bookOrderController.readBookOrderByID(
        widget.editedItem.invoiceID!); // find the target book sale invoice

    final bookRepo = BookRepository();
    final newBookList = await bookRepo.getBooksByTitle(serverUploadedBookEntryData
        .bookName!); // returns the list of books that have the recently typed title
    final oldBookList = await bookRepo.getBooksByTitle(widget.editedItem
        .bookName!); // returns the list of books that have the old title
    var oldQuantity = widget.editedItem.quantity ?? 0;
    var newQuantity = serverUploadedBookEntryData.quantity ?? 0;

    if (newQuantity == 0 || newBookList.isEmpty) {
      _showUpdateStatus('Thông tin chỉnh sửa không hợp lệ!', isError: true);
      return false;
    }

    Book newBook = newBookList[0];
    Book oldBook = oldBookList[0];

    if (oldBook.bookID == newBook.bookID) {
      // old book name = new book name
      // change stock quantity on server
      oldBook.stockQuantity -= (newQuantity - oldQuantity);
      await bookRepo.updateBook(oldBook);

      // change quantity that row
      for (Tuple2<Book, int> pair in order!.bookList) {
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
    } else if (oldBook.bookID != newBook.bookID) {
      Tuple2<Book, int>? oldBookPair;
      Tuple2<Book, int>? newBookPair;
      int oldQuantityOfNewBook = 0;
      for (Tuple2<Book, int> pair in order!.bookList) {
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

      order.bookList
          .add(Tuple2<Book, int>(newBook, oldQuantityOfNewBook + newQuantity));
      await customerRepo.updateCustomer(order.customer!);
      await bookOrderController.updateBookOrder(order);
    }

    return true;
  }

  void _onUpdatePressed() {
    if (_isShowingSnackBar) return; // Prevent spamming button

    _isShowingSnackBar = true; // Set saving state to true

    serverUploadedBookEntryData = getBookSaleInvoiceData();

    if (serverUploadedBookEntryData.bookName == widget.editedItem.bookName &&
        listEquals(serverUploadedBookEntryData.genres?..sort(),
            widget.editedItem.genres?..sort()) &&
        listEquals(serverUploadedBookEntryData.authors?..sort(),
            widget.editedItem.authors?..sort()) &&
        serverUploadedBookEntryData.quantity == widget.editedItem.quantity &&
        serverUploadedBookEntryData.price == widget.editedItem.price) {
      _showUpdateStatus('Không có dữ liệu gì thay đổi!', isError: true);
      return;
    }

    // add the code to upload data to server here (backend)
    uploadDataToDtb().then((isValid) {
      if (isValid) {
        _showUpdateStatus(
            'Đã chỉnh sửa phiếu nhập sách số ${widget.editedItem.invoiceID}!');
        widget.reloadContext();
      }
    });
  }

  void _showUpdateStatus(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context)
        .showSnackBar(
          SnackBar(
            content: Text(message,
                style:
                    const TextStyle(color: Color.fromRGBO(215, 227, 234, 1))),
            backgroundColor:
                isError ? const Color.fromRGBO(255, 105, 105, 1) : Colors.green,
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

    setState(() {
      _isShowingSnackBar = true; // Set saving state to true
    });

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
      setState(() {
        _isShowingSnackBar =
            false; // Reset saving state after snack bar is closed
      });
    });
  }

  double _measureTextWidth(String text, TextStyle style) {
    final TextPainter textPainter = TextPainter(
      text: TextSpan(text: text, style: style),
      maxLines: 1,
      textDirection: TextDirection.ltr,
    )..layout(minWidth: 0, maxWidth: double.infinity);
    return textPainter.size.width;
  }

  String _formatText(String text, {required textStyle, int maxWidth = 120}) {
    // maxWidth in pixels
    double textWidth = _measureTextWidth(text, textStyle);
    if (textWidth > maxWidth) {
      String truncatedText = text;
      do {
        truncatedText = truncatedText.substring(0, truncatedText.length - 1);
        textWidth = _measureTextWidth('$truncatedText...', textStyle);
      } while (textWidth > maxWidth);
      return '$truncatedText...';
    }
    return text;
  }

  @override
  Widget build(BuildContext context) {
    titleStyle = TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.bold,
      color: widget.titleColor,
    );
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
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 0.0),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(
                    height: 12,
                  ),
                  CustomRoundedButton(
                    backgroundColor: const Color.fromRGBO(239, 156, 102, 1),
                    foregroundColor: const Color.fromRGBO(241, 248, 232, 1),
                    title: "Cập nhật",
                    onPressed: () {
                      _onUpdatePressed();
                    },
                    width: 108,
                    fontSize: 24,
                  ),
                  const SizedBox(
                    height: 32,
                  ),
                  Container(
                    // title bar
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8.0, vertical: 8.0),
                    decoration: BoxDecoration(
                      color: widget.titleBarColor,
                      borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(8),
                          topRight: Radius.circular(8)),
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
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Row(
                        children: [
                          Text(
                            'Thuộc hóa đơn ${_formatText(widget.editedItem.invoiceID!, textStyle: titleStyle, maxWidth: 155)}',
                            style: titleStyle,
                          ),
                          IconButton(
                            onPressed: () {
                              // Handle info button press (e.g., show a dialog)
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    title: Text("Thông tin",
                                        style: TextStyle(
                                            color: widget.titleColor)),
                                    content: Text(
                                        "Bạn chỉ đang chỉnh sửa một phần trong hóa đơn bán sách này.",
                                        style:
                                            TextStyle(color: Colors.grey[700])),
                                    actions: <Widget>[
                                      TextButton(
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                        },
                                        child: const Text("Đã hiểu",
                                            style: TextStyle(
                                                color: Color.fromRGBO(
                                                    239, 156, 102, 1))),
                                      ),
                                    ],
                                  );
                                },
                              );
                            },
                            icon: Icon(Icons.info_outline,
                                size: 23,
                                color:
                                    widget.titleColor), // Adjust size as needed
                          ),
                        ],
                      ),
                    ),
                  ),
                  Container(
                      // content area
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 8),
                      decoration: BoxDecoration(
                        color: widget.contentAreaColor,
                        borderRadius: const BorderRadius.only(
                            bottomLeft: Radius.circular(8),
                            bottomRight: Radius.circular(8)),
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
                      child: Column(
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text('Ngày lập hóa đơn',
                                      style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                          color: widget.contentTitleColor)),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Material(
                                borderRadius: BorderRadius.circular(4),
                                child: DatePickerBox(
                                  initialDate: widget.editedItem.purchaseDate,
                                  backgroundColor:
                                      widget.contentInputFormFillColor,
                                  foregroundColor: widget.contentInputColor,
                                  isEnabled: false,
                                  errorMessageWhenDisabled:
                                      "Ngày lập hóa đơn đã bị vô hiệu hóa chỉnh sửa để đảm bảo tính toàn vẹn của dữ liệu",
                                ),
                              )
                            ],
                          ),
                          const SizedBox(height: 5),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text('Họ tên khách hàng',
                                      style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                          color: widget.contentTitleColor)),
                                ],
                              ),
                              const SizedBox(height: 4),
                              SizedBox(
                                width: 300,
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
                                      suffixIcon: const Icon(Icons.people),
                                      isDense: true,
                                      filled: true,
                                      fillColor: Colors.grey,
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      enabledBorder: const OutlineInputBorder(
                                        borderSide: BorderSide(
                                            color: Colors.grey, width: 0.0),
                                      ),
                                    ),
                                    style: const TextStyle(
                                        fontSize: 16, color: Colors.black),
                                  ),
                                ),
                              )
                            ],
                          ),
                          const SizedBox(height: 5),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text('Số điện thoại',
                                      style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                          color: widget.contentTitleColor)),
                                ],
                              ),
                              const SizedBox(height: 4),
                              SizedBox(
                                width: 300,
                                child: GestureDetector(
                                  onTap: () {
                                    explainWhyDisable(
                                        context: context,
                                        errorString:
                                            'Số điện thoại đã bị vô hiệu hóa chỉnh sửa để đảm bảo tính toàn vẹn của dữ liệu');
                                  },
                                  child: TextField(
                                    controller: _phoneNumberController,
                                    enabled: false,
                                    decoration: InputDecoration(
                                      suffixIcon: const Icon(Icons.phone),
                                      isDense: true,
                                      filled: true,
                                      fillColor: Colors.grey,
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      enabledBorder: const OutlineInputBorder(
                                        borderSide: BorderSide(
                                            color: Colors.grey, width: 0.0),
                                      ),
                                    ),
                                    style: const TextStyle(
                                        fontSize: 16, color: Colors.black),
                                  ),
                                ),
                              )
                            ],
                          ),
                          const SizedBox(height: 20),
                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Icon(Icons.book,
                                            color: widget.contentTitleColor),
                                        const SizedBox(width: 4),
                                        Text('Tên sách',
                                            style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                                color:
                                                    widget.contentTitleColor)),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    TextField(
                                      focusNode: _bookNameFocusNode,
                                      onSubmitted: (newBookName) {
                                        _becauseOfSubmissionBookName = true;
                                        autoFill(newBookName);
                                      },
                                      onTap: () {
                                        if (!_bookNameFocusNode.hasFocus) {
                                          _originalBookName =
                                              _bookNameController.text;
                                        }
                                      },
                                      controller: _bookNameController,
                                      decoration: InputDecoration(
                                        isDense: true,
                                        filled: true,
                                        fillColor:
                                            widget.contentInputFormFillColor,
                                        hintText: "Nhập tên sách",
                                        border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(4),
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                              color:
                                                  widget.textFieldBorderColor,
                                              width: 1.0),
                                        ),
                                      ),
                                      style: TextStyle(
                                          color: widget.contentInputColor),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Icon(Icons.person,
                                            color: widget.contentTitleColor),
                                        const SizedBox(width: 4),
                                        Text('Tác giả',
                                            style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                                color:
                                                widget.contentTitleColor)),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    TextField(
                                      controller: _authorsController,
                                      decoration: InputDecoration(
                                        isDense: true,
                                        filled: true,
                                        fillColor:
                                        widget.contentInputFormFillColor,
                                        hintText: "Nhập tác giả",
                                        border: OutlineInputBorder(
                                          borderRadius:
                                          BorderRadius.circular(4),
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                              color:
                                              widget.textFieldBorderColor,
                                              width: 1.0),
                                        ),
                                      ),
                                      style: TextStyle(
                                          color: widget.contentInputColor),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Icon(Icons.category,
                                            color: widget.contentTitleColor),
                                        const SizedBox(width: 4),
                                        Text('Thể loại',
                                            style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                                color:
                                                widget.contentTitleColor)),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    TextField(
                                      controller: _genresController,
                                      decoration: InputDecoration(
                                        isDense: true,
                                        filled: true,
                                        fillColor:
                                        widget.contentInputFormFillColor,
                                        hintText: "Nhập thể loại",
                                        border: OutlineInputBorder(
                                          borderRadius:
                                          BorderRadius.circular(4),
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                              color:
                                              widget.textFieldBorderColor,
                                              width: 1.0),
                                        ),
                                      ),
                                      style: TextStyle(
                                          color: widget.contentInputColor),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Icon(Icons.money,
                                            color: widget.contentTitleColor),
                                        const SizedBox(width: 4),
                                        Text('Đơn giá',
                                            style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                                color:
                                                    widget.contentTitleColor)),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    TextField(
                                      controller: _priceController,
                                      keyboardType: TextInputType.number,
                                      inputFormatters: [
                                        ThousandsSeparatorInputFormatter()
                                      ],
                                      decoration: InputDecoration(
                                        isDense: true,
                                        filled: true,
                                        fillColor:
                                            widget.contentInputFormFillColor,
                                        hintText: "Nhập đơn giá",
                                        border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(4),
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                              color:
                                                  widget.textFieldBorderColor,
                                              width: 1.0),
                                        ),
                                        suffixText: "VND",
                                      ),
                                      style: TextStyle(
                                          color: widget.contentInputColor),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(left: 117),
                                child: Row(
                                  children: [
                                    Icon(Icons.production_quantity_limits,
                                        color: widget.contentTitleColor),
                                    const SizedBox(width: 4),
                                    Text('Số lượng',
                                        style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color:
                                            widget.contentTitleColor)),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 4),
                              SizedBox(
                                width: 160,
                                child: TextField(
                                  focusNode: _quantityFocusNode,
                                  onSubmitted: (text) {
                                    checkQuantity(text);
                                    _becauseOfSubmissionQuantity = true;
                                  },
                                  controller: _quantityController,
                                  keyboardType: TextInputType.number,
                                  inputFormatters: [
                                    ThousandsSeparatorInputFormatter()
                                  ],
                                  decoration: InputDecoration(
                                    isDense: true,
                                    filled: true,
                                    fillColor:
                                    widget.contentInputFormFillColor,
                                    hintText: "Nhập số lượng",
                                    border: OutlineInputBorder(
                                      borderRadius:
                                      BorderRadius.circular(4),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                          color:
                                          widget.textFieldBorderColor,
                                          width: 1.0),
                                    ),
                                  ),
                                  style: TextStyle(
                                      color: widget.contentInputColor),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ))
                ],
              ),
            )));
  }

  String removeRedundantSpaces(String str) {
    // Replace multiple spaces with a single space
    return str.trim().replaceAll(RegExp(r'\s+'), ' ');
  }

  InvoiceData getBookSaleInvoiceData() {
    // Remove any thousands separators (e.g., commas) before parsing
    String priceText = _priceController.text.replaceAll('.', '');
    String quantityText = _quantityController.text.replaceAll('.', '');

    return InvoiceData(
      bookName: removeRedundantSpaces(_bookNameController.text),
      genres: _genresController.text
          .split(',')
          .map((name) => removeRedundantSpaces(name))
          .where((name) => name.isNotEmpty)
          .toList(),
      authors: _authorsController.text
          .split(',')
          .map((name) => removeRedundantSpaces(name))
          .where((name) => name.isNotEmpty)
          .toList(),
      price: int.tryParse(priceText) ?? 0,
      quantity: int.tryParse(quantityText) ?? 0,
    );
  }
}
