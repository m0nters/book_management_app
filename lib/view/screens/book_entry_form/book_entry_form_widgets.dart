import 'package:flutter/material.dart';
import '../../../controller/rule_controller.dart';
import '../../../model/book.dart';
import '../../../repository/book_repository.dart';
import '../../../repository/rule_repository.dart';
import '../mutual_widgets.dart';
import '../setting/setting.dart';

// =============================================================================
class EntryData {
  String? entryID;
  String? bookID;
  String? bookName;
  List<String>? genres;
  List<String>? authors;
  int? quantity;
  DateTime? entryDate;

  EntryData({
    this.entryID = '',
    this.bookID = '',
    this.bookName = '',
    this.genres = const [],
    this.authors = const [],
    this.quantity = 0,
    this.entryDate,
  });

  // Method to convert to map for compatibility with InfoTicket (for UI)
  Map<String, String> toMap() {
    return {
      'Mã phiếu': entryID!,
      'Sách': bookName!,
      'Tác giả': authors?.join(', ') ?? '',
      'Ngày nhập': entryDate != null ? stdDateFormat.format(entryDate!) : '',
      'Số lượng': stdNumFormat.format(quantity), // Convert quantity to String
    };
  }
}

// =============================================================================

class BookEntryFormInfoTicket extends InfoTicket {
  // Basically nothing has changed, this is just to synchronize with book_sale_invoice.dart
  const BookEntryFormInfoTicket(
      {super.key,
      required super.fields,
      required super.backgroundImage,
      required super.onTap});
}

// =============================================================================
class BookEntryInputForm extends StatefulWidget {
  late int orderNum;
  final Color titleBarColor;
  final Color titleColor;
  final Color contentAreaColor;
  final Color contentTitleColor;
  final Color contentInputColor;
  final Color contentInputFormFillColor;
  final Color textFieldBorderColor;

  /// Call this when you want to edit an existing information through form, otherwise it means you are creating new form to create new information
  final EntryData? reference;
  final ValueChanged<BookEntryInputFormState>? onStateCreated;

  BookEntryInputForm({
    super.key,
    required this.orderNum,
    this.titleBarColor = const Color.fromRGBO(12, 24, 68, 1),
    this.titleColor = const Color.fromRGBO(225, 227, 234, 1),
    this.contentAreaColor = const Color.fromRGBO(255, 245, 225, 1),
    this.contentTitleColor = const Color.fromRGBO(12, 24, 68, 1),
    this.contentInputColor = const Color.fromRGBO(12, 24, 68, 1),
    this.contentInputFormFillColor = Colors.white,
    this.textFieldBorderColor = Colors.grey,
    this.reference,
    this.onStateCreated, // New callback
  });

  @override
  createState() => BookEntryInputFormState();
}

class BookEntryInputFormState extends State<BookEntryInputForm> {
  final TextEditingController _bookNameController = TextEditingController();
  final TextEditingController _authorsController = TextEditingController();
  final TextEditingController _genresController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();
  final FocusNode _bookNameFocusNode = FocusNode();
  final FocusNode _quantityFocusNode = FocusNode();
  String? _fromEntryID = '';
  static Set<String> existedNames =
      {}; // use to ensure there's no 2 forms in the list can enter same name, can be called anywhere through `BookEntryInputFormState.existedNames`
  String?
      _originalBookName; // Store the initial book name before changing in form
  String? _originalQuantity;
  bool _becauseOfSubmissionBookName =
      false; // check if book name TextField lost its focus node because of obSubmitted event or not
  bool _becauseOfSubmissionQuantity = false;

  // for backend requirement constraints
  final ruleController = RuleController(RuleRepository());
  late int maxStockBefore;
  late int minReceive;

  @override
  void initState() {
    // Notify the parent widget that the state has been created
    if (widget.onStateCreated != null) {
      widget.onStateCreated!(this);
    }

    if (widget.reference != null) {
      _fromEntryID = widget.reference?.entryID;
      existedNames.add(widget.reference!.bookName!);
    }

    _bookNameController.text = widget.reference?.bookName ?? '';
    _authorsController.text = widget.reference?.authors?.join(', ') ?? '';
    _quantityController.text = widget.reference?.quantity != null
        ? stdNumFormat.format(widget.reference?.quantity)
        : '';
    _genresController.text = widget.reference?.genres?.join(', ') ?? '';

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
    _quantityController.dispose();
    _genresController.dispose();
    _bookNameFocusNode.dispose();
    super.dispose();
  }

  Future<void> autoFill(String newBookName) async {
    maxStockBefore = await ruleController.getMaxStockPreReceipt();

    _becauseOfSubmissionBookName = false; // reset the flag (if need)
    if (_originalBookName != null) {
      existedNames.remove(_originalBookName); // Remove the original book name
    }

    newBookName = removeRedundantSpaces(newBookName);
    final bookRepo = BookRepository();
    final targetList = await bookRepo.getBooksByTitle(newBookName);

    if (!mounted) return;

    // If that book doesn't exist
    if (targetList.isEmpty) {
      // if new book does not exist
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
    Book targetBookEntity = targetList[0];

    // if the stockQuantity of that book >= allowed threshold
    if (targetBookEntity.stockQuantity >= maxStockBefore) {
      // if new book does not exist
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
      if (_originalBookName != null) {
        existedNames.add(_originalBookName!);
        _bookNameController.text = _originalBookName!;
      }
      return;
    }

    // if that book has been already inputted before
    if (existedNames.contains(newBookName)) {
      // if this "new" book has been typed before
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text("Nhập không thành công",
                style: TextStyle(color: Color.fromRGBO(34, 12, 68, 1))),
            // Customize the title
            content: Text(
              "Phiếu hiện tại đã bao gồm sách này ở trước đó, vui lòng kiểm tra lại!",
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

    existedNames.add(newBookName);
    _bookNameController.text = newBookName;
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
              _fromEntryID == ''
                  ? 'STT ${widget.orderNum}'
                  : "STT ${widget.orderNum}\nThuộc phiếu ${_fromEntryID?.substring(0, 17)}...",
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
                              _becauseOfSubmissionBookName = true;
                              autoFill(newBookName);
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
                                      color: widget.contentTitleColor)),
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
                                _originalQuantity = _quantityController.text;
                              }
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

  EntryData getBookEntryData() {
    print("Getting book entry data for form order number: ${widget.orderNum}");
    print("Book Name: ${_bookNameController.text}");
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
