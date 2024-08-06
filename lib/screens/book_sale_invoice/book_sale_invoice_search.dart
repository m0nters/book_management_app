import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../setting/setting.dart';
import 'book_sale_invoice_widgets.dart';
import '../mutual_widgets.dart';
import 'book_sale_invoice_edit_search.dart';

List<InvoiceData> serverFetchedBookSaleInvoicesData = [
  InvoiceData(
      bookName: 'Tôi thấy hoa vàng ở trên cỏ xanh',
      genre: 'Tiểu thuyết',
      price: 30000,
      quantity: 29),
  InvoiceData(
      bookName: 'Cho tôi biển mặn',
      genre: 'Truyện ngắn',
      price: 60000,
      quantity: 12),
  InvoiceData(
      bookName: 'Cho tôi biến mất một ngày',
      genre: 'Tình cảm',
      price: 120000,
      quantity: 25),
  InvoiceData(
      bookName: 'Hai con mèo ngồi bên cửa sổ',
      genre: 'Truyện ngắn',
      price: 12000,
      quantity: 21),
]; // backend fetch data from here

class BookSaleInvoiceSearch extends StatefulWidget {
  final VoidCallback backContextSwitcher;
  final Function(Widget) internalScreenContextSwitcher;
  late DateTime? initialDate;
  late String? customerName;

  BookSaleInvoiceSearch({
    super.key,
    required this.backContextSwitcher,
    required this.internalScreenContextSwitcher,
    this.initialDate,
    this.customerName,
  });

  @override
  createState() => _BookSaleInvoiceSearchState();
}

class _BookSaleInvoiceSearchState extends State<BookSaleInvoiceSearch> {
  bool hasPickedDate = false;
  bool hasInputtedCustomerName = false;
  bool hasEnoughInfo = false;

  bool allSelected =
      false; // Variable to track the state of the "Select All" checkbox
  bool isEmptyBecauseOfDeletion = false;
  late List<bool> _selectedItems;
  final ScrollController _totalScrollController = ScrollController();
  final ScrollController _searchResultScrollController = ScrollController();
  final TextEditingController _customerNameController = TextEditingController();

  @override
  void initState() {
    super.initState();

    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft, // only rotate left
    ]);

    _searchResultScrollController.addListener(() {
      if (_searchResultScrollController.position.atEdge) {
        if (_searchResultScrollController.position.pixels != 0) {
          // If at the bottom, scroll the search form to the bottom as well
          _totalScrollController.animateTo(
            _totalScrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            // Adjust speed if needed
            curve: Curves.easeOut,
          );
        }
      }
    });

    if (widget.initialDate != null) {
      hasPickedDate = true;
    }

    _selectedItems = List.generate(
        serverFetchedBookSaleInvoicesData.length, (index) => false);
  }

  @override
  void dispose() {
    _totalScrollController.dispose();
    _searchResultScrollController.dispose();
    _customerNameController.dispose();
    super.dispose();
  }

  void onInfoChange(DateTime? date, String? customerName) {
    setState(() {
      if (date != null) {
        hasPickedDate = true;
        widget.initialDate = date;
      }
      else {
        hasPickedDate = false;
      }
      if (customerName != null && customerName != '') {
        hasInputtedCustomerName = true;
        widget.customerName = customerName;
      }
      else {
        hasInputtedCustomerName = false;
      }
      hasEnoughInfo = hasPickedDate & hasInputtedCustomerName;

      isEmptyBecauseOfDeletion = false;
      // backend code for fetch data into serverFetchedBookEntriesData for that date
    });
  }

  void toggleSelectAll(bool? value) {
    setState(() {
      allSelected = value ?? false;
      for (int i = 0; i < _selectedItems.length; i++) {
        _selectedItems[i] = allSelected;
      }
    });
  }

  void toggleItemSelection(int index, bool? value) {
    setState(() {
      _selectedItems[index] = value ?? false;
      // Check if all items are selected
      allSelected = _selectedItems.every((item) => item);
    });
  }

  void deleteSelectedItems() async {
    // Make it asynchronous

    bool confirmDelete = await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Xác nhận xóa'),
            content: const Text('Bạn có chắc chắn muốn xóa các mục đã chọn?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false), // Cancel
                child: const Text('Không'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true), // Confirm
                child: const Text(
                  'Xóa',
                  style: TextStyle(color: Color.fromRGBO(239, 156, 102, 1)),
                ),
              ),
            ],
          ),
        ) ??
        false; // Default to false if dialog is dismissed

    if (confirmDelete) {
      setState(() {
        // Remove items from both _selectedItems and _entryDataList where the item is selected
        for (int i = _selectedItems.length - 1; i >= 0; i--) {
          if (_selectedItems[i]) {
            _selectedItems.removeAt(i);
            serverFetchedBookSaleInvoicesData.removeAt(i);
            // backend code to delete data corresponding serverFetchedBookEntriesData[i] on server
          }
        }
        if (serverFetchedBookSaleInvoicesData.isEmpty) {
          isEmptyBecauseOfDeletion = true;
          _totalScrollController.animateTo(
            _totalScrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            // Adjust speed if needed
            curve: Curves.easeOut,
          );
        }
      });
    }
  }

  void editSelectedItems() {
    List<InvoiceData> editedItems = [
      for (int i = 0; i < _selectedItems.length; ++i)
        if (_selectedItems[i]) serverFetchedBookSaleInvoicesData[i]
    ];

    widget.internalScreenContextSwitcher(BookSaleInvoiceEditSearch(
      editedItems: editedItems,
      backContextSwitcher: widget.backContextSwitcher,
      editedDate: widget.initialDate!,
      customerName: widget.customerName!,
    ));
  }

  @override
  Widget build(BuildContext context) {
    final formattedDate =
        hasPickedDate ? stdDateFormat.format(widget.initialDate!) : '';
    final customerName = hasInputtedCustomerName ? widget.customerName!.trim() : '';

    return Scaffold(
      backgroundColor: const Color.fromRGBO(241, 248, 232, 1),
      appBar: AppBar(
        backgroundColor: const Color.fromRGBO(241, 248, 232, 1),
        foregroundColor: const Color.fromRGBO(120, 171, 168, 1),
        title: const Text(
          "Tra cứu hóa đơn sách",
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
        child: ListView(
          controller: _totalScrollController,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                const Text(
                  "Ngày tra: ",
                  style: TextStyle(
                      fontSize: 16, color: Color.fromRGBO(120, 171, 168, 1)),
                ),
                DatePickerBox(
                  initialDate: widget.initialDate,
                  onDateChanged: (date) =>
                      onInfoChange(date, widget.customerName),
                  backgroundColor: const Color.fromRGBO(200, 207, 160, 1),
                  foregroundColor: Colors.black,
                  hintColor: const Color.fromRGBO(122, 122, 122, 1),
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
                      fontSize: 16, color: Color.fromRGBO(120, 171, 168, 1)),
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
                    onSubmitted: (text) =>
                        onInfoChange(widget.initialDate, text),
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
            Column(
              children: [
                if (hasEnoughInfo) ...[
                  if (serverFetchedBookSaleInvoicesData.isNotEmpty) ...[
                    Row(
                      children: [
                        RichText(
                          text: TextSpan(
                            style: const TextStyle(
                              fontFamily: 'Archivo', // Use font from theme
                              fontSize: 20,
                            ),
                            children: [
                              const TextSpan(
                                text: "Hóa đơn bán sách ngày ",
                                style: TextStyle(
                                  color: Color.fromRGBO(120, 171, 168, 1),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              TextSpan(
                                text: formattedDate,
                                style: const TextStyle(
                                  color: Color.fromRGBO(239, 156, 102, 1),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const TextSpan(
                                text: " cho ",
                                style: TextStyle(
                                  color: Color.fromRGBO(120, 171, 168, 1),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              TextSpan(
                                text: customerName,
                                style: const TextStyle(
                                  color: Color.fromRGBO(239, 156, 102, 1),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              TextSpan(
                                text:
                                    ": ${serverFetchedBookSaleInvoicesData.length} kết quả",
                                style: const TextStyle(
                                  color: Color.fromRGBO(120, 171, 168, 1),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Spacer(),
                        Opacity(
                          opacity: _selectedItems.contains(true) ? 1.0 : 0.0,
                          child: AbsorbPointer(
                            absorbing: !_selectedItems.contains(true),
                            child: Row(
                              children: [
                                IconButton(
                                  onPressed: _selectedItems.contains(true)
                                      ? editSelectedItems
                                      : null,
                                  icon: const Icon(Icons.edit,
                                      color: Color.fromRGBO(120, 171, 168, 1)),
                                ),
                                IconButton(
                                  onPressed: _selectedItems.contains(true)
                                      ? deleteSelectedItems
                                      : null,
                                  icon: const Icon(Icons.delete_forever_rounded,
                                      color: Color.fromRGBO(239, 156, 102, 1)),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    Container(
                      // Table header
                      height: 40,
                      decoration: const BoxDecoration(
                        color: Color.fromRGBO(252, 220, 148, 1),
                        borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(8),
                            topRight: Radius.circular(8)),
                      ),
                      child: Row(
                        children: [
                          SizedBox(
                            width: 40,
                            child: Transform.scale(
                              scale: 1.2,
                              child: Checkbox(
                                value: allSelected,
                                onChanged: toggleSelectAll,
                                activeColor:
                                    const Color.fromRGBO(255, 245, 225, 1),
                                checkColor: const Color.fromRGBO(12, 24, 68, 1),
                                fillColor:
                                    WidgetStateProperty.resolveWith<Color>(
                                  (Set<WidgetState> states) {
                                    if (!states
                                        .contains(WidgetState.selected)) {
                                      return Colors
                                          .white; // Checkbox background when not active
                                    }
                                    return const Color.fromRGBO(
                                        120, 171, 168, 1); // Active color
                                  },
                                ),
                              ),
                            ),
                          ),
                          const Expanded(
                              flex: 1,
                              child: Center(
                                  child: Text('STT',
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 16,
                                      )))),
                          const Expanded(
                              flex: 3,
                              child: Center(
                                  child: Text('Tên sách',
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 16,
                                      )))),
                          const Expanded(
                              flex: 2,
                              child: Center(
                                  child: Text('Thể loại',
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 16,
                                      )))),
                          const Expanded(
                              flex: 2,
                              child: Center(
                                  child: Text('Đơn giá',
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 16,
                                      )))),
                          const Expanded(
                              flex: 1,
                              child: Center(
                                  child: Text('Số lượng',
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 16,
                                      )))),
                        ],
                      ),
                    ), // Table header
                    SingleChildScrollView(
                      // Content Area
                      child: SizedBox(
                        height: MediaQuery.of(context).size.height - 250,
                        child: ListView.builder(
                          controller: _searchResultScrollController,
                          itemCount: serverFetchedBookSaleInvoicesData.length,
                          itemBuilder: (context, index) {
                            final entry =
                                serverFetchedBookSaleInvoicesData[index];
                            final isLastItem = index ==
                                serverFetchedBookSaleInvoicesData.length - 1;
                            return Container(
                              decoration: BoxDecoration(
                                color: _selectedItems[index]
                                    ? const Color.fromRGBO(120, 171, 168, 1)
                                    : Colors.grey[300],
                                borderRadius: isLastItem
                                    ? const BorderRadius.only(
                                        bottomLeft: Radius.circular(8),
                                        bottomRight: Radius.circular(8))
                                    : null, // to make the complete table border radius
                              ),
                              child: Row(
                                children: [
                                  SizedBox(
                                    width: 40,
                                    child: Checkbox(
                                      value: _selectedItems[index],
                                      onChanged: (value) =>
                                          toggleItemSelection(index, value),
                                      checkColor: const Color.fromRGBO(
                                          120, 171, 168, 1),
                                      fillColor: WidgetStateProperty
                                          .resolveWith<Color>(
                                        (Set<WidgetState> states) {
                                          if (!states
                                              .contains(WidgetState.selected)) {
                                            return Colors
                                                .white; // Checkbox background when not active
                                          }
                                          return const Color.fromRGBO(
                                              252, 220, 148, 1); // Active color
                                        },
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                      flex: 1,
                                      child: Center(
                                          child: Text('${index + 1}',
                                              style: TextStyle(
                                                color: _selectedItems[index]
                                                    ? Colors.white
                                                    : Colors.black,
                                                fontSize: 16,
                                              )))),
                                  Expanded(
                                      flex: 3,
                                      child: Center(
                                          child: Text(entry.bookName!,
                                              style: TextStyle(
                                                color: _selectedItems[index]
                                                    ? Colors.white
                                                    : Colors.black,
                                                fontSize: 16,
                                              )))),
                                  Expanded(
                                      flex: 2,
                                      child: Center(
                                          child: Text(entry.genre!,
                                              style: TextStyle(
                                                color: _selectedItems[index]
                                                    ? Colors.white
                                                    : Colors.black,
                                                fontSize: 16,
                                              )))),
                                  Expanded(
                                      flex: 2,
                                      child: Center(
                                          child: Text('${entry.price} VND',
                                              style: TextStyle(
                                                color: _selectedItems[index]
                                                    ? Colors.white
                                                    : Colors.black,
                                                fontSize: 16,
                                              )))),
                                  Expanded(
                                      flex: 1,
                                      child: Center(
                                          child: Text('${entry.quantity}',
                                              style: TextStyle(
                                                color: _selectedItems[index]
                                                    ? Colors.white
                                                    : Colors.black,
                                                fontSize: 16,
                                              )))),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    ), // Content Area
                    const SizedBox(height: 16),
                  ] else if (isEmptyBecauseOfDeletion) ...[
                    NotFound(
                      errorText:
                          "Bạn đã xóa hết kết quả cho ngày $formattedDate",
                    )
                  ] else ...[
                    NotFound(
                      errorText: "Không có kết quả nào cho ngày $formattedDate",
                    )
                  ],
                ] else ...[
                  const Padding(
                      padding: EdgeInsets.symmetric(vertical: 40),
                      child: Text(
                          "Chọn một ngày và nhập một tên khách hàng để bắt đầu tra cứu",
                          style: TextStyle(
                              fontSize: 25,
                              color: Color.fromRGBO(123, 123, 123, 1))))
                ]
              ],
            )
          ],
        ),
      ),
    );
  }
}
