import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../mutual_widgets.dart';
import '../setting/setting.dart';

// =============================================================================
class InvoiceData {
  String? invoiceCode;
  String? customerName;
  String? bookName;
  String? genre;
  int? price;
  int? quantity;
  DateTime? purchaseDate;

  InvoiceData({
    this.invoiceCode = '',
    this.customerName = '',
    this.bookName = '',
    this.genre = '',
    this.price = 0,
    this.quantity = 0,
    this.purchaseDate,
  });

  Map<String, String> toMap() {
    return {
      'Mã hóa đơn': invoiceCode!,
      'Tên khách hàng': customerName!,
      'Tên sách': bookName!,
      'Ngày mua':
          purchaseDate != null ? stdDateFormat.format(purchaseDate!) : '',
      'Số lượng': quantity.toString(),
      'Đơn giá': "$price VND",
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
  });

  @override
  createState() => BookSaleInvoiceInputFormState();
}

class BookSaleInvoiceInputFormState extends State<BookSaleInvoiceInputForm> {
  final TextEditingController _bookNameController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();
  String _genreController = '';

  @override
  void initState() {
    // Notify the parent widget that the state has been created
    if (widget.onStateCreated != null) {
      widget.onStateCreated!(this);
    }

    _bookNameController.text = widget.reference?.bookName ?? '';
    _priceController.text = widget.reference?.price.toString() ?? '';
    _quantityController.text = widget.reference?.quantity.toString() ?? '';
    _genreController = widget.reference?.genre ?? '';
    super.initState();
  }

  @override
  void dispose() {
    _bookNameController.dispose();
    _priceController.dispose();
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
                            inputFormatters: <TextInputFormatter>[
                              FilteringTextInputFormatter.allow(
                                  RegExp(r'[0-9]')), // Allow only digits
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

  InvoiceData getBookSaleInvoiceData() {
    return InvoiceData(
      bookName: _bookNameController.text,
      genre: _genreController,
      price: int.tryParse(_priceController.text) ?? 0,
      quantity: int.tryParse(_quantityController.text) ?? 0,
    );
  }
}
