import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:tuple/tuple.dart';
import '../../../controller/goods_receipt_controller.dart';
import '../../../controller/rule_controller.dart';
import '../../../model/book.dart';
import '../../../repository/book_repository.dart';
import '../../../repository/goods_receipt_repository.dart';
import '../../../repository/rule_repository.dart';
import '../setting/setting.dart';
import '../mutual_widgets.dart';
import 'book_entry_form_widgets.dart';
import 'package:flutter/services.dart'; // Import for FilteringTextInputFormatter

late EntryData serverUploadedBookEntryData;

class BookEntryFormEditHistory extends StatefulWidget {
  final VoidCallback backContextSwitcher;
  final VoidCallback reloadContext;
  final EntryData editItem;

  final Color titleBarColor;
  final Color titleColor;
  final Color contentAreaColor;
  final Color contentTitleColor;
  final Color contentInputColor;
  final Color contentInputFormFillColor;
  final Color textFieldBorderColor;

  const BookEntryFormEditHistory({
    super.key,
    required this.backContextSwitcher,
    required this.reloadContext,
    required this.editItem,
    this.titleBarColor = const Color.fromRGBO(12, 24, 68, 1),
    this.titleColor = const Color.fromRGBO(225, 227, 234, 1),
    this.contentAreaColor = const Color.fromRGBO(255, 245, 225, 1),
    this.contentTitleColor = const Color.fromRGBO(12, 24, 68, 1),
    this.contentInputColor = const Color.fromRGBO(12, 24, 68, 1),
    this.contentInputFormFillColor = Colors.white,
    this.textFieldBorderColor = Colors.grey,
  });

  @override
  State<BookEntryFormEditHistory> createState() =>
      _BookEntryFormEditHistoryState();
}

class _BookEntryFormEditHistoryState extends State<BookEntryFormEditHistory> {
  final TextEditingController _bookNameController = TextEditingController();
  final TextEditingController _genresController = TextEditingController();
  final TextEditingController _authorsController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();
  final FocusNode _bookNameFocusNode = FocusNode();
  final FocusNode _quantityFocusNode = FocusNode();
  String? _originalBookName;
  String? _originalQuantity;
  bool _becauseOfSubmissionBookName = false;
  bool _becauseOfSubmissionQuantity = false;
  bool _isShowingSnackBar = false;
  late TextStyle titleStyle;

  // for backend requirement constraints
  final ruleController = RuleController(RuleRepository());
  late int maxStockBefore;
  late int minReceive;

  @override
  void initState() {
    super.initState();

    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);

    _bookNameController.text = widget.editItem.bookName ?? '';
    _authorsController.text = widget.editItem.authors?.join(', ') ?? '';
    _quantityController.text =
        stdNumFormat.format(widget.editItem.quantity).toString();
    _genresController.text = widget.editItem.genres?.join(', ') ?? '';

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

    _bookNameController.dispose();
    _authorsController.dispose();
    _quantityController.dispose();
    _genresController.dispose();
  }

  Future<void> autoFill(String bookName) async {
    maxStockBefore = await ruleController.getMaxStockPreReceipt();
    _becauseOfSubmissionBookName = false;

    bookName = removeRedundantSpaces(bookName);
    final bookRepo = BookRepository();
    final targetList = await bookRepo.getBooksByTitle(bookName);

    if (!mounted) return;

    // If that book doesn't exist
    if (targetList.isEmpty) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text("Nhập không thành công",
                style: TextStyle(color: Color.fromRGBO(34, 12, 68, 1))),
            // Customize the title
            content: Text(
              "Không tồn tại sách nào có tên như vậy trong cơ sở dữ liệu!",
              style: TextStyle(color: Colors.grey[700]),
            ),
            // Customize the content
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Close the dialog
                },
                child: const Text("Đã hiểu",
                    style: TextStyle(color: Color.fromRGBO(255, 105, 105, 1))),
              ),
            ],
          );
        },
      );
      _bookNameController.text = _originalBookName!;
      return;
    }
    Book targetBookEntity = targetList[0];

    // if the stockQuantity of that book is >= allowed threshold
    if (targetBookEntity.stockQuantity >= maxStockBefore) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text("Nhập không thành công",
                style: TextStyle(color: Color.fromRGBO(34, 12, 68, 1))),
            // Customize the title
            content: Text(
              "Chỉ nhập các đầu sách có lượng tồn ít hơn $maxStockBefore.",
              style: TextStyle(color: Colors.grey[700]),
            ),
            // Customize the content
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Close the dialog
                },
                child: const Text("Đã hiểu",
                    style: TextStyle(color: Color.fromRGBO(255, 105, 105, 1))),
              ),
            ],
          );
        },
      );
      _bookNameController.text = _originalBookName!;
      return;
    }

    _bookNameController.text = bookName;
    _genresController.text = targetBookEntity.genres.join(', ');
    _authorsController.text = targetBookEntity.authors.join(', ');
  }

  Future<void> checkQuantity(String quantity) async {
    quantity = quantity.replaceAll('.', '');
    int numQuantity = int.tryParse(quantity) ?? 0;
    minReceive = await ruleController.getMinReceive();
    _becauseOfSubmissionQuantity = false;

    if (numQuantity >= minReceive) {
      return;
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Nhập không thành công",
              style: TextStyle(color: Color.fromRGBO(34, 12, 68, 1))),
          // Customize the title
          content: Text(
            "Số lượng nhập ít nhất là $minReceive.",
            style: TextStyle(color: Colors.grey[700]),
          ),
          // Customize the content
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text("Đã hiểu",
                  style: TextStyle(color: Color.fromRGBO(255, 105, 105, 1))),
            ),
          ],
        );
      },
    );

    _quantityController.text = _originalQuantity!;
  }

  Future<bool> uploadDataToDtb() async {
    minReceive = await ruleController.getMinReceive();
    maxStockBefore = await ruleController.getMaxStockPreReceipt();
    final goodsReceiptController =
        GoodsReceiptController(GoodsReceiptRepository());
    final receipt = await goodsReceiptController.readGoodsReceiptByID(
        widget.editItem.entryID!); // find the target book entry form

    final bookRepo = BookRepository();
    final newBookList = await bookRepo.getBooksByTitle(serverUploadedBookEntryData
        .bookName!); // returns the list of books that have the recently typed title
    final oldBookList = await bookRepo.getBooksByTitle(widget.editItem
        .bookName!); // returns the list of books that have the old title
    var oldQuantity = widget.editItem.quantity ?? 0;
    var newQuantity = serverUploadedBookEntryData.quantity ?? 0;

    // if update info has empty book name
    if (newBookList.isEmpty) {
      _showUpdateStatus('Tên sách không hợp lệ, vui lòng kiểm tra lại',
          isError: true, duration: 4);
      return false;
    }

    // if update info has quantity < allowed threshold
    if (newQuantity < minReceive) {
      _showUpdateStatus(
          'Sách có lượng nhập rỗng hoặc nhỏ hơn lượng nhập tối thiểu là $minReceive',
          isError: true,
          duration: 4);
      return false;
    }

    Book newBook = newBookList[0];
    Book oldBook = oldBookList[0];

    // if book that has stock quantity >= allowed threshold for inputting
    if (newBook.stockQuantity >= maxStockBefore) {
      _showUpdateStatus(
        'Sách \"${newBook.title}\" có lượng tồn là ${newBook.stockQuantity}, nhiều hơn lượng tồn tối đa được nhập là $maxStockBefore',
        isError: true,
        duration: 4,
      );
      return false;
    }

    if (oldBook.bookID == newBook.bookID) {
      // old book name = new book name
      // change stock quantity on server
      oldBook.stockQuantity += (newQuantity - oldQuantity);
      await bookRepo.updateBook(oldBook);

      // change quantity that row
      for (Tuple2<Book, int> pair in receipt!.bookList) {
        if (pair.item1.bookID == oldBook.bookID) {
          receipt.bookList.remove(pair);
          break;
        }
      } // delete out the row

      receipt.bookList.add(Tuple2<Book, int>(oldBook, newQuantity));
      await goodsReceiptController.updateGoodsReceipt(receipt);
    } else if (oldBook.bookID != newBook.bookID) {
      Tuple2<Book, int>? oldBookPair;
      Tuple2<Book, int>? newBookPair;
      int oldQuantityOfNewBook = 0;
      for (Tuple2<Book, int> pair in receipt!.bookList) {
        if (pair.item1.bookID == oldBook.bookID) {
          oldBookPair = pair;
        }
        if (pair.item1.bookID == newBook.bookID) {
          oldQuantityOfNewBook += pair.item2;
          newBookPair = pair;
        }
      }
      if (oldBookPair != null) {
        receipt.bookList.remove(oldBookPair);
      }
      if (newBookPair != null) {
        receipt.bookList.remove(newBookPair);
      }

      oldBook.stockQuantity -= oldQuantity; // update the old book quantity
      await bookRepo.updateBook(oldBook);

      newBook.stockQuantity += newQuantity; // update the new book quantity
      await bookRepo.updateBook(newBook);

      receipt.bookList
          .add(Tuple2<Book, int>(newBook, oldQuantityOfNewBook + newQuantity));
      await goodsReceiptController.updateGoodsReceipt(receipt);
    }

    return true;
  }

  void _onUpdatePressed() {
    if (_isShowingSnackBar) return; // Prevent spamming button

    _isShowingSnackBar = true; // Set saving state to true

    serverUploadedBookEntryData = getBookEntryData();

    if (serverUploadedBookEntryData.bookName == widget.editItem.bookName &&
        listEquals(serverUploadedBookEntryData.genres?..sort(),
            widget.editItem.genres?..sort()) &&
        listEquals(serverUploadedBookEntryData.authors?..sort(),
            widget.editItem.authors?..sort()) &&
        serverUploadedBookEntryData.quantity == widget.editItem.quantity) {
      _showUpdateStatus('Không có dữ liệu gì thay đổi!', isError: true);
      return;
    }

    // add the code to upload data to server here (backend)
    uploadDataToDtb().then((isValid) {
      if (isValid) {
        _showUpdateStatus(
            'Đã chỉnh sửa phiếu nhập sách số ${widget.editItem.entryID}!');
        widget.reloadContext();
      }
    });
  }

  void _showUpdateStatus(String message,
      {bool isError = false, int duration = 2}) {
    ScaffoldMessenger.of(context)
        .showSnackBar(
          SnackBar(
            content: Text(message,
                style:
                    const TextStyle(color: Color.fromRGBO(215, 227, 234, 1))),
            backgroundColor:
                isError ? const Color.fromRGBO(255, 105, 105, 1) : Colors.green,
            duration: Duration(seconds: duration),
          ),
        )
        .closed
        .then((reason) {
      _isShowingSnackBar =
          false; // Reset saving state after snack bar is closed
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
        backgroundColor: const Color.fromRGBO(225, 227, 234, 1),
        appBar: AppBar(
          backgroundColor: const Color.fromRGBO(225, 227, 234, 1),
          foregroundColor: const Color.fromRGBO(12, 24, 68, 1),
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
                    height: 46,
                  ),
                  CustomRoundedButton(
                    backgroundColor: const Color.fromRGBO(255, 105, 105, 1),
                    foregroundColor: const Color.fromRGBO(255, 227, 234, 1),
                    title: "Cập nhật",
                    onPressed: () {
                      _onUpdatePressed();
                    },
                    width: 108,
                    fontSize: 24,
                  ),
                  const SizedBox(
                    height: 46,
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
                            'Thuộc phiếu ${_formatText(widget.editItem.entryID!, textStyle: titleStyle, maxWidth: 160)}',
                            style: titleStyle,
                          ),
                          const Spacer(),
                          IconButton(
                            onPressed: () {
                              // Handle info button press (e.g., show a dialog)
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    title: Text("Thông tin",
                                        style: TextStyle(
                                            color: widget.titleBarColor)),
                                    content: Text(
                                        "Bạn chỉ đang chỉnh sửa một phần trong phiếu nhập sách này.",
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
                                                    255, 105, 105, 1))),
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
                                  Text('Ngày nhập',
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
                                  initialDate: widget.editItem.entryDate,
                                  backgroundColor:
                                      widget.contentInputFormFillColor,
                                  foregroundColor: widget.contentTitleColor,
                                  isEnabled: false,
                                  errorMessageWhenDisabled:
                                      "Ngày nhập đã bị vô hiệu hóa chỉnh sửa để đảm bảo tính toàn vẹn của dữ liệu",
                                ),
                              )
                            ],
                          ),
                          const SizedBox(height: 28),
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
                            ],
                          ),
                          const SizedBox(height: 28),
                          Row(
                            children: [
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
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
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
                                    const SizedBox(height: 4),
                                    TextField(
                                      focusNode: _quantityFocusNode,
                                      onSubmitted: (quantity) {
                                        _becauseOfSubmissionQuantity = true;
                                        checkQuantity(quantity);
                                      },
                                      onTap: () {
                                        if (!_quantityFocusNode.hasFocus) {
                                          _originalQuantity =
                                              _quantityController.text;
                                        }
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
                                  ],
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

  EntryData getBookEntryData() {
    String quantityText = _quantityController.text.replaceAll('.', '');
    return EntryData(
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
      quantity: int.tryParse(quantityText) ?? 0,
    );
  }
}
