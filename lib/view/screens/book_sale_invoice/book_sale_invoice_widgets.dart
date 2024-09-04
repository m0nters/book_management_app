import 'package:flutter/material.dart';
import '../../../controller/rule_controller.dart';
import '../../../model/book.dart';
import '../../../repository/book_repository.dart';
import '../../../repository/rule_repository.dart';
import '../mutual_widgets.dart';
import '../setting/setting.dart';

// =============================================================================
class InvoiceData {
  String? invoiceID;
  String? bookID;
  String? customerName;
  String? phoneNumber;
  String? bookName;
  List<String>? genres;
  List<String>? authors;
  int? price;
  int? quantity;
  DateTime? purchaseDate;

  InvoiceData({
    this.invoiceID = '',
    this.bookID = '',
    this.customerName = '',
    this.phoneNumber = '',
    this.bookName = '',
    this.genres = const [],
    this.authors = const [],
    this.price = 0,
    this.quantity = 0,
    this.purchaseDate,
  });

  Map<String, String> toMap() {
    return {
      'Mã hóa đơn': invoiceID!,
      'Tên khách hàng': customerName!,
      'Số điện thoại': phoneNumber!,
      'Tên sách': bookName!,
      'Ngày mua':
          purchaseDate != null ? stdDateFormat.format(purchaseDate!) : '',
      'Số lượng': stdNumFormat.format(quantity),
      'Đơn giá': "${stdNumFormat.format(price)} VND",
    };
  }
}

// =============================================================================
class BookSaleInvoiceInfoTicket extends InfoTicket {
  const BookSaleInvoiceInfoTicket(
      {super.key,
      required super.fields,
      required super.backgroundImage,
      required super.onTap});

  @override
  Color get titleColor => const Color.fromRGBO(252, 220, 148, 1);

  @override
  Color get contentColor => const Color.fromRGBO(241, 248, 232, 1);
}

// =============================================================================
// Book Input Form
class BookSaleInvoiceInputForm extends StatefulWidget {
  late int
      orderNum; // this cannot be `final` since we may remove a form and other forms behind it must update their `orderNum`s
  final Color titleBarColor;
  final Color titleColor;
  final Color contentAreaColor;
  final Color contentTitleColor;
  final Color contentInputColor;
  final Color contentInputFormFillColor;
  final Color textFieldBorderColor;

  /// Call this when you want to edit an existing information through form, otherwise it means you are creating new form to create new information
  final InvoiceData? reference;
  final ValueChanged<BookSaleInvoiceInputFormState>? onStateCreated;
  bool isEditingSearch;

  BookSaleInvoiceInputForm({
    super.key,
    required this.orderNum,
    this.titleBarColor = const Color.fromRGBO(252, 220, 148, 1),
    this.titleColor = const Color.fromRGBO(120, 171, 168, 1),
    this.contentAreaColor = const Color.fromRGBO(120, 171, 168, 1),
    this.contentTitleColor = const Color.fromRGBO(241, 248, 232, 1),
    this.contentInputColor = const Color.fromRGBO(12, 24, 68, 1),
    this.contentInputFormFillColor = const Color.fromRGBO(241, 248, 232, 1),
    this.textFieldBorderColor = Colors.grey,
    this.reference,
    this.onStateCreated,
    this.isEditingSearch = false,
  });

  @override
  createState() => BookSaleInvoiceInputFormState();
}

class BookSaleInvoiceInputFormState extends State<BookSaleInvoiceInputForm> {
  final TextEditingController _bookNameController = TextEditingController();
  final TextEditingController _authorsController = TextEditingController();
  final TextEditingController _genresController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();

  final FocusNode _bookNameFocusNode = FocusNode();
  final FocusNode _quantityFocusNode = FocusNode();
  String? _fromInvoiceID =
      ''; // if the BookSaleInvoiceInputForm object is from defined reference, then this is non-null, otherwise it's null
  static Set<String> existedNames = {};
  String? _originalBookName;
  bool _becauseOfSubmissionBookName = false;
  bool _becauseOfSubmissionQuantity = false;

  Book? _originalBookEntity; // in case there's reference, this is that book entity
  Book? _currentBookEntity; // the book entity we are working on, initialize as above, but can change through time
  late int _minStockAfter;

  Future<Book?> getBookEntity(String name) async {
    final bookRepo = BookRepository();
    final targetList = await bookRepo.getBooksByTitle(name);
    return targetList.isNotEmpty ? targetList[0] : null;
  }

  Future<void> getOriginalBookEntity() async {
    _originalBookEntity = await getBookEntity(widget.reference!.bookName!);
    _currentBookEntity = _originalBookEntity;
  }

  @override
  void initState() {
    // Notify the parent widget that the state has been created
    if (widget.onStateCreated != null) {
      widget.onStateCreated!(this);
    }

    if (widget.reference != null) {
      _fromInvoiceID = widget.reference?.invoiceID;
      existedNames.add(widget.reference!.bookName!);
      getOriginalBookEntity();
    }

    _bookNameController.text = widget.reference?.bookName ?? '';
    _authorsController.text = widget.reference?.authors?.join(', ') ?? '';
    _genresController.text = widget.reference?.genres?.join(', ') ?? '';
    _priceController.text = widget.reference?.price != null
        ? stdNumFormat.format(widget.reference?.price)
        : '';
    _quantityController.text = widget.reference?.quantity != null
        ? stdNumFormat.format(widget.reference?.quantity)
        : '';

    // Add a listener to the FocusNode to detect when the "Tên sách" field loses focus
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

    super.initState();
  }

  @override
  void dispose() {
    _bookNameController.dispose();
    _authorsController.dispose();
    _genresController.dispose();
    _priceController.dispose();
    _quantityController.dispose();

    _bookNameFocusNode.dispose();
    _quantityFocusNode.dispose();
    super.dispose();
  }

  Future<void> autoFill(String newBookName) async {
    _becauseOfSubmissionBookName = false; // reset the flag (if need)

    if (_originalBookName != null) {
      existedNames.remove(_originalBookName); // Remove the original book name
    }

    newBookName = removeRedundantSpaces(newBookName);
    _currentBookEntity = await getBookEntity(newBookName); // can be null

    if (!mounted) return;

    // if new book does not exist
    if (_currentBookEntity == null) {
      _currentBookEntity = _originalBookEntity; // reset back to original one when encounter error
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
      if (_originalBookName != null) {
        existedNames.add(_originalBookName!);
        _bookNameController.text = _originalBookName!;
      }
      return;
    }

    // if this "new" book has been typed before
    if (existedNames.contains(newBookName)) {
      _currentBookEntity = _originalBookEntity;
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            backgroundColor: const Color.fromRGBO(241, 248, 232, 1),
            title: const Text("Nhập không thành công",
                style: TextStyle(color: Color.fromRGBO(120, 171, 168, 1))),
            // Customize the title
            content: Text(
              "Hóa đơn hiện tại đã bao gồm sách này ở trước đó, vui lòng kiểm tra lại!",
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
      if (_originalBookName != null) {
        existedNames.add(_originalBookName!);
        _bookNameController.text = _originalBookName!;
      }
      return;
    }
    existedNames.add(newBookName);

    _bookNameController.text = newBookName;
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
    bool isErrorWhileCreatingInvoice = false;
    bool isErrorWhileEditingSearchOnTheSameBook = false;
    bool isErrorWhileEditingSearchOnDifferentBooks = false;
    if (widget.isEditingSearch) {
      // if working on the same book
      if (_currentBookEntity == _originalBookEntity &&
          _currentBookEntity!.stockQuantity +
                  widget.reference!.quantity! -
                  sellQuantity <
              _minStockAfter) {
        isErrorWhileEditingSearchOnTheSameBook = true;
      }

      // if working on different books
      else if (_currentBookEntity != _originalBookEntity && _currentBookEntity!.stockQuantity - sellQuantity < _minStockAfter) {
        isErrorWhileEditingSearchOnDifferentBooks = true;
      }
    } else {
      if (_currentBookEntity!.stockQuantity - sellQuantity < _minStockAfter) {
        isErrorWhileCreatingInvoice = true;
      }
    }
    if (isErrorWhileCreatingInvoice || isErrorWhileEditingSearchOnDifferentBooks) {
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
    if (isErrorWhileEditingSearchOnTheSameBook) {
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
              "là ${widget.reference!.quantity}, nếu hủy nó thì số lượng tồn kho của "
              "\"${_currentBookEntity?.title}\" sẽ lại là ${widget.reference!.quantity! + _currentBookEntity!.stockQuantity}, "
              "do đó số lượng bán sau chỉnh sửa chỉ có thể tối đa là ${widget.reference!.quantity! + _currentBookEntity!.stockQuantity - _minStockAfter}.",
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

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          // title bar
          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
          decoration: BoxDecoration(
              color: widget.titleBarColor,
              borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(8), topRight: Radius.circular(8))),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              _fromInvoiceID == ''
                  ? 'STT ${widget.orderNum}'
                  : "STT ${widget.orderNum}\nThuộc phiếu ${_fromInvoiceID?.substring(0, 17)}...",
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: widget.titleColor),
            ),
          ),
        ),
        Container(
            // content area
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
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
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.book, color: widget.contentTitleColor),
                              const SizedBox(width: 4),
                              Text('Tên sách',
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: widget.contentTitleColor)),
                            ],
                          ),
                          const SizedBox(height: 4),
                          TextField(
                            focusNode: _bookNameFocusNode,
                            onSubmitted: (newBookName) {
                              autoFill(newBookName);
                              _becauseOfSubmissionBookName = true;
                            },
                            onTap: () {
                              if (!_bookNameFocusNode.hasFocus) {
                                _originalBookName = _bookNameController.text;
                              }
                            },
                            controller: _bookNameController,
                            decoration: InputDecoration(
                              isDense: true,
                              filled: true,
                              fillColor: widget.contentInputFormFillColor,
                              hintText: "Nhập tên sách",
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(4),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                    color: widget.textFieldBorderColor,
                                    width: 1.0),
                              ),
                            ),
                            style: TextStyle(color: widget.contentInputColor),
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
                              Icon(Icons.person, color: widget.contentTitleColor),
                              const SizedBox(width: 4),
                              Text('Tác giả',
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: widget.contentTitleColor)),
                            ],
                          ),
                          const SizedBox(height: 4),
                          TextField(
                            controller: _authorsController,
                            decoration: InputDecoration(
                              isDense: true,
                              filled: true,
                              fillColor: widget.contentInputFormFillColor,
                              hintText: "Nhập tác giả",
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(4),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                    color: widget.textFieldBorderColor,
                                    width: 1.0),
                              ),
                            ),
                            style: TextStyle(color: widget.contentInputColor),
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
                              Icon(Icons.category,
                                  color: widget.contentTitleColor),
                              const SizedBox(width: 4),
                              Text('Thể loại',
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: widget.contentTitleColor)),
                            ],
                          ),
                          const SizedBox(height: 4),
                          TextField(
                            controller: _genresController,
                            decoration: InputDecoration(
                              isDense: true,
                              filled: true,
                              fillColor: widget.contentInputFormFillColor,
                              hintText: "Nhập thể loại",
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(4),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                    color: widget.textFieldBorderColor,
                                    width: 1.0),
                              ),
                            ),
                            style: TextStyle(color: widget.contentInputColor),
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
                                      color: widget.contentTitleColor)),
                            ],
                          ),
                          const SizedBox(height: 4),
                          TextField(
                            controller: _priceController,
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              ThousandsSeparatorInputFormatter(),
                              // Apply custom formatter
                            ],
                            decoration: InputDecoration(
                              isDense: true,
                              filled: true,
                              fillColor: widget.contentInputFormFillColor,
                              hintText: "Nhập đơn giá",
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(4),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                    color: widget.textFieldBorderColor,
                                    width: 1.0),
                              ),
                              suffixText: "VND",
                            ),
                            style: TextStyle(color: widget.contentInputColor),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 28),
                SizedBox(
                  width: 200,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 42),
                        child: Row(
                          children: [
                            Icon(Icons.production_quantity_limits,
                                color: widget.contentTitleColor),
                            const SizedBox(width: 4),
                            Text('Số lượng',
                                style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: widget.contentTitleColor)),
                          ],
                        ),
                      ),
                      const SizedBox(height: 4),
                      TextField(
                        focusNode: _quantityFocusNode,
                        onSubmitted: (text) {
                          checkQuantity(text);
                          _becauseOfSubmissionQuantity = true;
                        },
                        controller: _quantityController,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          ThousandsSeparatorInputFormatter(),
                          // Apply custom formatter
                        ],
                        decoration: InputDecoration(
                          isDense: true,
                          filled: true,
                          fillColor: widget.contentInputFormFillColor,
                          hintText: "Nhập số lượng",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(4),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                                color: widget.textFieldBorderColor, width: 1.0),
                          ),
                        ),
                        style: TextStyle(color: widget.contentInputColor),
                      ),
                    ],
                  ),
                )
              ],
            ))
      ],
    );
  }

  void updateOrderNumber(int newOrderNum) {
    if (mounted) {
      setState(() {
        widget.orderNum = newOrderNum;
      });
    }
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
