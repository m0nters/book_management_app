import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tuple/tuple.dart';
import '../../../controller/book_order_controller.dart';
import '../../../model/book.dart';
import '../../../model/book_order.dart';
import '../../../model/customer.dart';
import '../../../repository/book_order_repository.dart';
import '../../../repository/book_repository.dart';
import '../../../repository/customer_repository.dart';
import '../setting/setting.dart';
import 'book_sale_invoice_widgets.dart';
import '../mutual_widgets.dart';
import 'book_sale_invoice_edit_search.dart';

List<InvoiceData> serverFetchedBookSaleInvoicesData =
    []; // backend fetch data from here

class BookSaleInvoiceSearch extends StatefulWidget {
  final VoidCallback backContextSwitcher;
  final Function(Widget) internalScreenContextSwitcher;
  late DateTime? initialDate;
  late String? customerName;
  late String? phoneNumber;

  BookSaleInvoiceSearch({
    super.key,
    required this.backContextSwitcher,
    required this.internalScreenContextSwitcher,
    this.initialDate,
    this.customerName,
    this.phoneNumber,
  });

  @override
  createState() => _BookSaleInvoiceSearchState();
}

class _BookSaleInvoiceSearchState extends State<BookSaleInvoiceSearch> {
  bool hasPickedDate = false;
  bool hasInputtedCustomerName = false;
  bool hasInputtedPhoneNumber = false;
  bool hasEnoughInfo = false;

  bool _allSelected =
      false; // Variable to track the state of the "Select All" checkbox
  bool _isEmptyBecauseOfDeletion = false;
  late List<bool> _selectedItems;
  final ScrollController _totalScrollController = ScrollController();
  final ScrollController _searchResultScrollController = ScrollController();
  final TextEditingController _customerNameController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();
  final FocusNode _customerNameFocusNode = FocusNode();
  bool _becauseOfSubmissionCustomerName = false;
  final FocusNode _phoneNumberFocusNode = FocusNode();
  bool _becauseOfSubmissionPhoneNumber = false;
  bool _isLoading = false;

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
    if (widget.customerName != null && widget.customerName != '') {
      // the second condition is easily to be ignored and when it's ignored it becomes a very insidious bug to detect
      hasInputtedCustomerName = true;
      _customerNameController.text = widget.customerName!.trim();
    }
    if (widget.phoneNumber != null && widget.phoneNumber != '') {
      // the second condition is easily to be ignored and when it's ignored it becomes a very insidious bug to detect
      hasInputtedPhoneNumber = true;
      _phoneNumberController.text = widget.phoneNumber!.replaceAll(' ', '');
    }

    _customerNameFocusNode.addListener(() {
      if (!_customerNameFocusNode.hasFocus &&
          !_becauseOfSubmissionCustomerName) {
        onInfoChange(widget.initialDate, _customerNameController.text,
            _phoneNumberController.text);
      }
    });

    _phoneNumberFocusNode.addListener(() {
      if (!_phoneNumberFocusNode.hasFocus && !_becauseOfSubmissionPhoneNumber) {
        onInfoChange(widget.initialDate, _customerNameController.text,
            _phoneNumberController.text);
      }
    });

    _selectedItems = List.generate(
        serverFetchedBookSaleInvoicesData.length, (index) => false);
  }

  @override
  void dispose() {
    _totalScrollController.dispose();
    _searchResultScrollController.dispose();
    _customerNameController.dispose();
    _phoneNumberController.dispose();
    super.dispose();
  }

  Future<void> search() async {
    final customerRepo = CustomerRepository();
    final customersByName = await customerRepo.getCustomersByName(
        removeRedundantSpaces(_customerNameController.text));
    final customersByPhoneNumber = await customerRepo.getCustomersByPhoneNumber(
        removeRedundantSpaces(_phoneNumberController.text));

    // Create a set of names from customersByName for faster lookups
    final nameSet = customersByName.map((c) => c.name).toSet();

    Customer? targetCustomer;
    for (var customer in customersByPhoneNumber) {
      if (nameSet.contains(customer.name)) {
        targetCustomer = customer;
        break; // Exit the loop once a match is found
      }
    }

    if (targetCustomer == null) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            backgroundColor: const Color.fromRGBO(241, 248, 232, 1),
            title: const Text("Thông tin tìm kiếm không hợp lệ",
                style: TextStyle(color: Color.fromRGBO(120, 171, 168, 1))),
            // Customize the title
            content: Text(
              "Không tồn tại khách hàng có thông tin như vậy. Thử xem lại họ tên khách hàng hoặc số điện thoại",
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

      return;
    }

    final bookOrderController = BookOrderController(BookOrderRepository());
    final orderList = await bookOrderController
        .getBookOrdersByCustomer(targetCustomer.customerID);

    serverFetchedBookSaleInvoicesData.clear();
    for (int i = 0; i < orderList.length; ++i) {
      BookOrder invoiceForm = orderList[i];
      for (int j = 0; j < invoiceForm.bookList.length; ++j) {
        Tuple2<Book, int> pair = invoiceForm.bookList[j];
        Book entryBook = pair.item1;
        int entryQuantity = pair.item2;
        serverFetchedBookSaleInvoicesData.add(InvoiceData(
          invoiceID: invoiceForm.orderID,
          bookID: entryBook.bookID,
          bookName: entryBook.title,
          genres: entryBook.genres,
          authors: entryBook.authors,
          price: entryBook.price as int,
          quantity: entryQuantity,
          purchaseDate: invoiceForm.orderDate,
        ));
      }
    }

    // Sort the list by invoiceID, then by bookName
    serverFetchedBookSaleInvoicesData.sort((a, b) {
      // First compare by invoiceID
      int? idComparison = a.invoiceID?.compareTo(b.invoiceID!);
      if (idComparison != 0) {
        return idComparison!;
      }
      // If invoiceIDs are the same, then compare by bookNames (title)
      return (a.bookName?.compareTo(b.bookName!))!;
    });

    _selectedItems = List.generate(
        serverFetchedBookSaleInvoicesData.length, (index) => false);
  }

  Future<void> onInfoChange(
      DateTime? date, String? customerName, String? phoneNumber) async {
    if (date != null) {
      hasPickedDate = true;
      widget.initialDate = date;
    } else {
      hasPickedDate = false;
    }

    if (customerName != null && customerName != '') {
      customerName = removeRedundantSpaces(customerName);
      hasInputtedCustomerName = true;
      widget.customerName = customerName;
    } else {
      hasInputtedCustomerName = false;
    }

    if (phoneNumber != null && phoneNumber != '') {
      phoneNumber = removeRedundantSpaces(phoneNumber);
      hasInputtedPhoneNumber = true;
      widget.phoneNumber = phoneNumber;
    } else {
      hasInputtedPhoneNumber = false;
    }

    if (hasEnoughInfo =
        hasPickedDate & hasInputtedCustomerName & hasInputtedPhoneNumber) {
      _isEmptyBecauseOfDeletion = false;

      _isLoading = true;
      setState(() {});
      await search();
      _isLoading = false;
      setState(() {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _totalScrollController.animateTo(
            _totalScrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        });
      });
    }
    _becauseOfSubmissionCustomerName = false;
    _becauseOfSubmissionPhoneNumber = false;
  }

  void toggleSelectAll(bool? value) {
    setState(() {
      _allSelected = value ?? false;
      for (int i = 0; i < _selectedItems.length; i++) {
        _selectedItems[i] = _allSelected;
      }
    });
  }

  void toggleItemSelection(int index, bool? value) {
    setState(() {
      _selectedItems[index] = value ?? false;
      // Check if all items are selected
      _allSelected = _selectedItems.every((item) => item);
    });
  }

  Future<void> deleteOneItem(InvoiceData deletedItem) async {
    final bookOrderController = BookOrderController(BookOrderRepository());
    final customerRepo = CustomerRepository();
    final order =
    await bookOrderController.readBookOrderByID(deletedItem.invoiceID!);

    final bookRepo = BookRepository();
    final targetBookList =
    await bookRepo.getBooksByTitle(deletedItem.bookName!);
    Book targetBook = targetBookList[0];
    var quantity = deletedItem.quantity ?? 0;

    for (Tuple2<Book, int> pair in order!.bookList) {
      if (pair.item1.bookID == targetBook.bookID) {
        order.bookList.remove(pair);
        break;
      }
    }

    targetBook.stockQuantity += quantity; // update the old book quantity
    await bookRepo.updateBook(targetBook);

    order.totalCost -= targetBook.price * quantity as int;
    order.customer?.debt -= targetBook.price * quantity as int;
    await customerRepo.updateCustomer(order.customer!);
    if (order.bookList.isNotEmpty) {
      await bookOrderController.updateBookOrder(order);
    } else {
      await bookOrderController.deleteBookOrder(order.orderID);
    }
  }

  void deleteSelectedItems() async {
    bool confirmDelete = await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: _allSelected
                ? Text(
                    'BẠN ĐANG CHUẨN BỊ XOÁ HẾT TOÀN BỘ PHIẾU NHẬP SÁCH CHO NGÀY ${stdDateFormat.format(widget.initialDate!)}')
                : const Text('Xác nhận xóa'),
            content: _selectedItems.fold(
                        0,
                        (count, selectedItem) =>
                            selectedItem ? count + 1 : count) >
                    1
                ? Text('Bạn có chắc chắn muốn xóa ${_selectedItems.where((element) => element).length} mục đã chọn?')
                : const Text('Bạn có chắc chắn muốn xóa mục đã chọn?'),
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
      // Remove items from both _selectedItems and _entryDataList where the item is selected
      for (int i = _selectedItems.length - 1; i >= 0; i--) {
        if (_selectedItems[i]) {
          await deleteOneItem(serverFetchedBookSaleInvoicesData[i]);
          setState(() {
            _selectedItems.removeAt(i);
            serverFetchedBookSaleInvoicesData.removeAt(i);
          });
        }
      }

      // After all items have been deleted, update the state
      setState(() {
        if (serverFetchedBookSaleInvoicesData.isEmpty) {
          _isEmptyBecauseOfDeletion = true;
          _allSelected = false;
          _totalScrollController.animateTo(
            _totalScrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
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
      // these 3 below can be assured to be not null when passing since they must be
      // non null before user can evoke this function
      editedDate: widget.initialDate!,
      customerName: widget.customerName!,
      phoneNumber: widget.phoneNumber!,
    ));
  }

  @override
  Widget build(BuildContext context) {
    // for displaying result title & error message
    final formattedDate =
        hasPickedDate ? stdDateFormat.format(widget.initialDate!) : '';
    final customerName =
        hasInputtedCustomerName ? widget.customerName!.trim() : '';

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
                      fontSize: 16,
                      color: Color.fromRGBO(120, 171, 168, 1),
                      fontWeight: FontWeight.bold),
                ),
                DatePickerBox(
                  initialDate: widget.initialDate,
                  onDateChanged: (date) => onInfoChange(
                      date, widget.customerName, widget.phoneNumber),
                  backgroundColor: const Color.fromRGBO(200, 207, 160, 1),
                  foregroundColor: const Color.fromRGBO(12, 24, 68, 1),
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
                      fontSize: 16,
                      color: Color.fromRGBO(120, 171, 168, 1),
                      fontWeight: FontWeight.bold),
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
                    focusNode: _customerNameFocusNode,
                    onSubmitted: (text) {
                      onInfoChange(
                          widget.initialDate, text, widget.phoneNumber);
                      _becauseOfSubmissionCustomerName = true;
                    },
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
            const SizedBox(
              height: 12,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                const Text(
                  "Số điện thoại: ",
                  style: TextStyle(
                      fontSize: 16,
                      color: Color.fromRGBO(120, 171, 168, 1),
                      fontWeight: FontWeight.bold),
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
                    focusNode: _phoneNumberFocusNode,
                    onSubmitted: (text) {
                      onInfoChange(
                          widget.initialDate, widget.customerName, text);
                      _becauseOfSubmissionPhoneNumber = true;
                    },
                    controller: _phoneNumberController,
                    keyboardType: TextInputType.phone,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                    ],
                    decoration: InputDecoration(
                      isDense: true,
                      filled: true,
                      fillColor: const Color.fromRGBO(200, 207, 160, 1),
                      hintText: "Nhập số điện thoại",
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
                if (_isLoading) ...[
                  const Center(
                    child: CircularProgressIndicator(
                        color: Color.fromRGBO(239, 156, 102, 1)),
                  )
                ] else if (hasEnoughInfo) ...[
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
                                text: "Hóa đơn ngày ",
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
                                text: " cho khách hàng ",
                                style: TextStyle(
                                  color: Color.fromRGBO(120, 171, 168, 1),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              TextSpan(
                                text: customerName.length < 20
                                    ? customerName
                                    : '${customerName.substring(0, 17)}...',
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
                    if (_selectedItems.contains(true)) ...[
                      Text("Đã chọn ${_selectedItems.where((element) => element).length} mục",
                        style: const TextStyle(
                          color: Color.fromRGBO(120, 171, 168, 1),
                          fontWeight: FontWeight.bold,
                          fontSize: 22,
                        ),),
                      const SizedBox(height: 5,)
                    ],
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
                                value: _allSelected,
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
                                        color: Color.fromRGBO(12, 24, 68, 1),
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      )))),
                          const Expanded(
                              flex: 3,
                              child: Center(
                                  child: Text('Tên sách',
                                      style: TextStyle(
                                        color: Color.fromRGBO(12, 24, 68, 1),
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      )))),
                          const Expanded(
                              flex: 2,
                              child: Center(
                                  child: Text('Thể loại',
                                      style: TextStyle(
                                        color: Color.fromRGBO(12, 24, 68, 1),
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      )))),
                          const Expanded(
                              flex: 2,
                              child: Center(
                                  child: Text('Đơn giá',
                                      style: TextStyle(
                                        color: Color.fromRGBO(12, 24, 68, 1),
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      )))),
                          const Expanded(
                              flex: 1,
                              child: Center(
                                  child: Text('Số lượng',
                                      style: TextStyle(
                                        color: Color.fromRGBO(12, 24, 68, 1),
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      )))),
                        ],
                      ),
                    ), // Table header
                    Container(
                      height: 1,
                      decoration: const BoxDecoration(
                        color: Colors.black,
                      ),
                    ),
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
                            return Column(
                              children: [
                                GestureDetector(
                                  onTap: () => toggleItemSelection(
                                      index, !_selectedItems[index]),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: _selectedItems[index]
                                          ? const Color.fromRGBO(
                                              120, 171, 168, 1)
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
                                                toggleItemSelection(
                                                    index, value),
                                            checkColor: const Color.fromRGBO(
                                                120, 171, 168, 1),
                                            fillColor: WidgetStateProperty
                                                .resolveWith<Color>(
                                              (Set<WidgetState> states) {
                                                if (!states.contains(
                                                    WidgetState.selected)) {
                                                  return Colors
                                                      .white; // Checkbox background when not active
                                                }
                                                return const Color.fromRGBO(
                                                    252,
                                                    220,
                                                    148,
                                                    1); // Active color
                                              },
                                            ),
                                          ),
                                        ),
                                        Expanded(
                                            flex: 1,
                                            child: Center(
                                                child: Text('${index + 1}',
                                                    style: TextStyle(
                                                      color:
                                                          _selectedItems[index]
                                                              ? Colors.white
                                                              : const Color
                                                                  .fromRGBO(12,
                                                                  24, 68, 1),
                                                      fontSize: 16,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    )))),
                                        Expanded(
                                            flex: 3,
                                            child: Center(
                                                child: Text(entry.bookName!,
                                                    style: TextStyle(
                                                      color:
                                                          _selectedItems[index]
                                                              ? Colors.white
                                                              : const Color
                                                                  .fromRGBO(12,
                                                                  24, 68, 1),
                                                      fontSize: 16,
                                                    )))),
                                        Expanded(
                                            flex: 2,
                                            child: Center(
                                                child: Text(
                                                    entry.genres!.join(', '),
                                                    style: TextStyle(
                                                      color:
                                                          _selectedItems[index]
                                                              ? Colors.white
                                                              : const Color
                                                                  .fromRGBO(12,
                                                                  24, 68, 1),
                                                      fontSize: 16,
                                                    )))),
                                        Expanded(
                                            flex: 2,
                                            child: Center(
                                                child: Text(
                                                    '${stdNumFormat.format(entry.price)} VND',
                                                    style: TextStyle(
                                                      color:
                                                          _selectedItems[index]
                                                              ? Colors.white
                                                              : const Color
                                                                  .fromRGBO(12,
                                                                  24, 68, 1),
                                                      fontSize: 16,
                                                    )))),
                                        Expanded(
                                            flex: 1,
                                            child: Center(
                                                child: Text(
                                                    stdNumFormat
                                                        .format(entry.quantity),
                                                    style: TextStyle(
                                                      color:
                                                          _selectedItems[index]
                                                              ? Colors.white
                                                              : const Color
                                                                  .fromRGBO(12,
                                                                  24, 68, 1),
                                                      fontSize: 16,
                                                    )))),
                                      ],
                                    ),
                                  ),
                                ),
                                if (!isLastItem)
                                  Container(
                                    height: 1,
                                    decoration: const BoxDecoration(
                                      color: Colors.black,
                                    ),
                                  )
                              ],
                            );
                          },
                        ),
                      ),
                    ), // Content Area
                    const SizedBox(height: 16),
                  ] else if (_isEmptyBecauseOfDeletion) ...[
                    NotFound(
                      errorText:
                          "Bạn đã xóa hết kết quả cho ngày $formattedDate",
                    )
                  ] else ...[
                    NotFound(
                      errorText:
                          "Không có kết quả nào cho khách hàng $customerName ngày $formattedDate",
                    )
                  ],
                ] else ...[
                  const Padding(
                      padding: EdgeInsets.symmetric(vertical: 20),
                      child: Text(
                          "Nhập đầy đủ các thông tin trên để bắt đầu tra cứu",
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
