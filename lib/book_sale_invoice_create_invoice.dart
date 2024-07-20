import 'package:flutter/material.dart';
import 'mutual_widgets.dart';

late DateTime serverUploadedDateInputData;
List<BookSaleInvoice> serverUploadedBookSaleInvoicesData = [];

// THIS FILE IS FOR TESTING NEW FUNCTIONALITIES
class BookSaleInvoice {
  String title;
  String category;
  int price;
  int quantity;

  BookSaleInvoice({
    required this.title,
    required this.category,
    required this.price,
    required this.quantity,
  });
}

// Book Input Form
class BookSaleInvoiceInputForm extends StatefulWidget {
  late int orderNum; // this cannot be `final` since we may remove a form and other forms behind it must update their `orderNum`s
  final Color titleBarColor;
  final Color titleColor;
  final Color contentAreaColor;
  final Color contentTitleColor;
  final Color contentInputColor;
  final Color contentInputFormFillColor;
  final Color textFieldBorderColor;

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
  });

  @override
  createState() => _BookSaleInvoiceInputFormState();
}

class _BookSaleInvoiceInputFormState extends State<BookSaleInvoiceInputForm> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();
  String genreController = '';

  final List<String> genres = [
    'Tiểu thuyết thanh thiếu niên',
    'Tiểu thuyết phiêu lưu',
    'Khoa học viễn tưởng',
    'Văn học cổ điển',
    // Add more genres as needed
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _priceController.dispose();
    _quantityController.dispose();
    super.dispose();
  }

  void updateOrderNumber(int newOrderNum) {
    setState(() {
      widget.orderNum = newOrderNum;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          // title bar
          padding: const EdgeInsets.symmetric(horizontal: 8),
          height: 40,
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
                    bottomRight: Radius.circular(8))),
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
                            controller: _titleController,
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
                            action: (genre) => genreController = genre ?? '',
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
                              Icon(Icons.confirmation_num,
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

  BookSaleInvoice getBookSaleInvoiceData() {
    return BookSaleInvoice(
      title: _titleController.text,
      category: genreController,
      price: int.tryParse(_priceController.text) ?? 0,
      quantity: int.tryParse(_quantityController.text) ?? 0,
    );
  }
}

class BookSaleInvoiceCreateInvoice extends StatefulWidget {
  final VoidCallback backContextSwitcher;
  const BookSaleInvoiceCreateInvoice({super.key, required this.backContextSwitcher});

  @override
  State<BookSaleInvoiceCreateInvoice> createState() => _BookSaleInvoiceCreateInvoiceState();
}

class _BookSaleInvoiceCreateInvoiceState extends State<BookSaleInvoiceCreateInvoice> {
  final List<Widget> _formWidgets = []; // Dynamic list of form widgets
  final List<GlobalKey<_BookSaleInvoiceInputFormState>> _formKeys =
  []; // Corresponding keys
  final ScrollController _scrollController = ScrollController(); // Scroll controller

  @override
  void dispose() {
    _scrollController.dispose(); // Dispose of the scroll controller
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _addForm(); // Add one form initially
  }

  void _addForm() {
    setState(() {
      final formKey = GlobalKey<_BookSaleInvoiceInputFormState>();
      _formKeys.add(formKey); // Add the key to the list

      _formWidgets.add(
        BookSaleInvoiceInputForm(
          orderNum: _formWidgets.length + 1, // Dynamic order number
          key: formKey, // Assign the key
        ),
      );
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) { // Check if the controller is attached
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _onSavePressed() {
    serverUploadedBookSaleInvoicesData = _formKeys.map((key) => key.currentState!.getBookSaleInvoiceData()).toList();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Đã lưu các hóa đơn bán sách hôm nay!', style: TextStyle(color: Color.fromRGBO(241, 248, 232, 1))),
        backgroundColor: Color.fromRGBO(239, 156, 102, 1),
        duration: Duration(seconds: 2), // Adjust duration as needed
      ),
    );
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
              fontWeight: FontWeight.w400,
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
              onPressed: () {},
              icon: const Icon(
                Icons.search,
                size: 29,
              )),
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
                  "Ngày lập: ",
                  style: TextStyle(fontSize: 16, color: Color.fromRGBO(12, 24, 68, 1)),
                ),
                DatePickerBox(
                  initialDate: DateTime.now(),
                  onDateChanged: (date) => serverUploadedDateInputData = date,
                  backgroundColor: const Color.fromRGBO(200, 207, 160, 1),
                  foregroundColor: const Color.fromRGBO(12, 24, 68, 1),
                )
              ],
            ),
            // Row(
            //   mainAxisAlignment: MainAxisAlignment.end,
            //   children: [
            //     const Text(
            //       "Họ tên khách hàng: ",
            //       style: TextStyle(fontSize: 16),
            //     ),
            //     TextField(
            //       decoration: InputDecoration(
            //         isDense: true,
            //         filled: true,
            //         fillColor: const Color.fromRGBO(200, 207, 160, 1),
            //         hintText: "Nhập tên sách",
            //         border: OutlineInputBorder(
            //           borderRadius: BorderRadius.circular(4),
            //         ),
            //         enabledBorder: const OutlineInputBorder(),
            //       ),
            //     ),
            //   ],
            // ),
            const SizedBox(
              height: 46,
            ),
            CustomRoundedButton(
              backgroundColor: const Color.fromRGBO(239, 156, 102, 1),
              foregroundColor: const Color.fromRGBO(241, 248, 232, 1),
              title: "Lưu",
              onPressed: _onSavePressed,
              width: 108,
              fontSize: 24,
            ),
            const SizedBox(height: 46,),
            Expanded(
              // Make the forms scrollable
              child: ListView.builder(
                controller: _scrollController,
                itemCount: _formWidgets.length,
                itemBuilder: (context, index) {
                  return Dismissible( // Wrap the form in Dismissible
                    key: UniqueKey(), // Unique key for Dismissible
                    direction: DismissDirection.endToStart, // Swipe left to delete
                    onDismissed: (direction) {
                      setState(() {
                        _formWidgets.removeAt(index);
                        _formKeys.removeAt(index);

                        // Update order numbers of remaining forms
                        for (int i = index; i < _formWidgets.length; i++) {
                          (_formWidgets[i].key as GlobalKey<_BookSaleInvoiceInputFormState>)
                              .currentState!
                              .updateOrderNumber(i + 1);
                        }
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
                    child: Column(
                      children: [
                        _formWidgets[index],
                        const SizedBox(height: 30),
                      ],
                    ),
                  );
                },
              ),
            ),

          ],
        ),
      ),
    );
  }
}
