import 'package:flutter/material.dart';
import '../mutual_widgets.dart';
import '../setting/setting.dart';
import 'package:flutter/services.dart'; // Import for FilteringTextInputFormatter

// =============================================================================
class EntryData {
  String? entryCode;
  String? bookName;
  String? genre;
  String? author;
  int? quantity;
  DateTime? entryDate;

  EntryData({
    this.entryCode = '',
    this.bookName = '',
    this.genre = '',
    this.author = '',
    this.quantity = 0,
    this.entryDate,
  });

  // Method to convert to map for compatibility with InfoTicket (for UI)
  Map<String, String> toMap() {
    return {
      'Mã phiếu': entryCode!,
      'Sách': bookName!,
      'Tác giả': author!,
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
  final TextEditingController _authorController = TextEditingController();
  String _genreController = '';
  final TextEditingController _quantityController = TextEditingController();

  @override
  void initState() {
    // Notify the parent widget that the state has been created
    if (widget.onStateCreated != null) {
      widget.onStateCreated!(this);
    }

    _bookNameController.text = widget.reference?.bookName ?? '';
    _authorController.text = widget.reference?.author ?? '';
    _quantityController.text = stdNumFormat.format(widget.reference?.quantity);
    _genreController = widget.reference?.genre ?? '';
    super.initState();
  }

  @override
  void dispose() {
    _bookNameController.dispose();
    _authorController.dispose();
    _quantityController.dispose();
    super.dispose();
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
              'STT ${widget.orderNum}',
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
                          CustomDropdownMenu(
                            initialValue: _genreController,
                            options: genres,
                            action: (genre) => _genreController = genre ?? '',
                            fillColor: widget.contentInputFormFillColor,
                            width: double.infinity,
                            hintText: 'Chọn một thể loại',
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
                            controller: _authorController,
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
                            controller: _quantityController,
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              ThousandsSeparatorInputFormatter(), // Apply custom formatter
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
    return EntryData(
      bookName: _bookNameController.text,
      genre: _genreController,
      author: _authorController.text,
      quantity: int.tryParse(_quantityController.text) ?? 0,
    );
  }
}
