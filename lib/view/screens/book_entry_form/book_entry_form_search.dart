import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tuple/tuple.dart';
import '../../../controller/goods_receipt_controller.dart';
import '../../../model/book.dart';
import '../../../model/goods_receipt.dart';
import '../../../repository/book_repository.dart';
import '../../../repository/goods_receipt_repository.dart';
import 'book_entry_form_widgets.dart';
import '../mutual_widgets.dart';
import 'book_entry_form_edit_search.dart';

List<EntryData> serverFetchedBookEntriesData =
    []; // backend fetch data from here

class BookEntryFormSearch extends StatefulWidget {
  final VoidCallback backContextSwitcher;
  final Function(Widget) internalScreenContextSwitcher;
  late DateTime? initialDate;

  BookEntryFormSearch(
      {super.key,
      required this.backContextSwitcher,
      required this.internalScreenContextSwitcher,
      this.initialDate});

  @override
  createState() => _BookEntryFormSearchState();
}

class _BookEntryFormSearchState extends State<BookEntryFormSearch> {
  bool hasPickedDate = false;
  bool _allSelected =
      false; // Variable to track the state of the "Select All" checkbox
  bool isEmptyBecauseOfDeletion = false;
  late List<bool> _selectedItems;
  final ScrollController _totalScrollController = ScrollController();
  final ScrollController _searchResultScrollController = ScrollController();
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
        } else {
          // If at the top, scroll the search form to the top as well
          _totalScrollController.animateTo(
            _totalScrollController.position.minScrollExtent,
            duration: const Duration(milliseconds: 300),
            // Adjust speed if needed
            curve: Curves.easeOut,
          );
        }
      }
    });

    if (widget.initialDate != null) {
      hasPickedDate = true;
      onDateChange(widget.initialDate!);
    }

    _selectedItems =
        List.generate(serverFetchedBookEntriesData.length, (index) => false);
  }

  @override
  void dispose() {
    _totalScrollController.dispose();
    _searchResultScrollController.dispose();
    serverFetchedBookEntriesData.clear();
    super.dispose();
  }

  Future<void> search(DateTime date) async {
    final goodsReceiptController =
        GoodsReceiptController(GoodsReceiptRepository());
    final listGoodsReceipt =
        await goodsReceiptController.getGoodsReceiptsByDate(date);
    setState(() {
      // backend code for fetch data into serverFetchedBookEntriesData for that date
      serverFetchedBookEntriesData.clear();
      for (int i = 0; i < listGoodsReceipt.length; ++i) {
        GoodsReceipt entryForm = listGoodsReceipt[i];
        String entryID = entryForm.receiptID;
        DateTime entryDate = entryForm.date;
        for (int j = 0; j < entryForm.bookList.length; ++j) {
          Tuple2<Book, int> pair = entryForm.bookList[j];
          Book entryBook = pair.item1;
          int entryQuantity = pair.item2;
          serverFetchedBookEntriesData.add(EntryData(
            entryID: entryID,
            bookID: entryBook.bookID,
            bookName: entryBook.title,
            genres: entryBook.genres,
            authors: entryBook.authors,
            quantity: entryQuantity,
            entryDate: entryDate,
          ));
        }
      }
    });

    // Sort the list by entryID, then by bookName
    serverFetchedBookEntriesData.sort((a, b) {
      // First compare by entryID
      int? idComparison = a.entryID?.compareTo(b.entryID!);
      if (idComparison != 0) {
        return idComparison!;
      }
      // If entryIDs are the same, then compare by bookName (title)
      return (a.bookName?.compareTo(b.bookName!))!;
    });

    _selectedItems =
        List.generate(serverFetchedBookEntriesData.length, (index) => false);
  }

  Future<void> onDateChange(DateTime date) async {
    widget.initialDate = date;
    hasPickedDate = true;
    isEmptyBecauseOfDeletion =
        false; // meaning if there's no result for desired date, it's not because of deletion

    _isLoading = true;
    setState(() {});

    // backend code
    await search(date);

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

  Future<void> deleteOneItem(EntryData deletedItem) async {
    final goodsReceiptController =
        GoodsReceiptController(GoodsReceiptRepository());
    final receipt =
        await goodsReceiptController.readGoodsReceiptByID(deletedItem.entryID!);

    final bookRepo = BookRepository();
    final targetBookList =
        await bookRepo.getBooksByTitle(deletedItem.bookName!);
    Book targetBook = targetBookList[0];
    var quantity = deletedItem.quantity ?? 0;

    for (Tuple2<Book, int> pair in receipt!.bookList) {
      if (pair.item1.bookID == targetBook.bookID) {
        receipt.bookList.remove(pair);
        break;
      }
    }

    targetBook.stockQuantity -= quantity; // update the old book quantity
    await bookRepo.updateBook(targetBook);

    if (receipt.bookList.isNotEmpty) {
      await goodsReceiptController.updateGoodsReceipt(receipt);
    } else {
      await goodsReceiptController.deleteGoodsReceipt(receipt.receiptID);
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
                  style: TextStyle(color: Color.fromRGBO(255, 105, 105, 1)),
                ),
              ),
            ],
          ),
        ) ??
        false; // Default to false if dialog is dismissed

    if (confirmDelete) {
      // Iterate through the selected items and delete each one asynchronously
      for (int i = _selectedItems.length - 1; i >= 0; i--) {
        if (_selectedItems[i]) {
          await deleteOneItem(serverFetchedBookEntriesData[i]);
          setState(() {
            _selectedItems.removeAt(i);
            serverFetchedBookEntriesData.removeAt(i);
          });
        }
      }

      // After all items have been deleted, update the state
      setState(() {
        if (serverFetchedBookEntriesData.isEmpty) {
          isEmptyBecauseOfDeletion = true;
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
    List<EntryData> editedItems = [
      for (int i = 0; i < _selectedItems.length; ++i)
        if (_selectedItems[i]) serverFetchedBookEntriesData[i]
    ];

    widget.internalScreenContextSwitcher(BookEntryFormEditSearch(
      editedItems: editedItems,
      backContextSwitcher: widget.backContextSwitcher,
      editedDate: widget.initialDate!,
    ));
  }

  @override
  Widget build(BuildContext context) {
    String formattedDate =
        hasPickedDate ? stdDateFormat.format(widget.initialDate!) : '';
    if (widget.initialDate != null) {
      if (widget.initialDate?.day == DateTime.now().day &&
          widget.initialDate?.month == DateTime.now().month &&
          widget.initialDate?.year == DateTime.now().year) {
        formattedDate += " (hôm nay)";
      }
    }

    return Scaffold(
      backgroundColor: const Color.fromRGBO(225, 227, 234, 1),
      appBar: AppBar(
        backgroundColor: const Color.fromRGBO(225, 227, 234, 1),
        foregroundColor: const Color.fromRGBO(12, 24, 68, 1),
        title: const Text(
          "Tra cứu phiếu nhập sách",
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
                      color: Color.fromRGBO(12, 24, 68, 1),
                      fontWeight: FontWeight.bold),
                ),
                DatePickerBox(
                  initialDate: widget.initialDate,
                  onDateChanged: (date) => onDateChange(date),
                  backgroundColor: const Color.fromRGBO(255, 245, 225, 1),
                  foregroundColor: const Color.fromRGBO(12, 24, 68, 1),
                )
              ],
            ),
            Column(
              children: [
                if (_isLoading) ...[
                  const Center(
                    child: CircularProgressIndicator(
                        color: Color.fromRGBO(255, 105, 105, 1)),
                  )
                ] else if (hasPickedDate) ...[
                  if (serverFetchedBookEntriesData.isNotEmpty) ...[
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
                                text: "Phiếu nhập sách ngày ",
                                style: TextStyle(
                                  color: Color.fromRGBO(12, 24, 68, 1),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              TextSpan(
                                text: formattedDate,
                                style: const TextStyle(
                                  color: Color.fromRGBO(255, 105, 105, 1),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              TextSpan(
                                text:
                                    ": ${serverFetchedBookEntriesData.length} kết quả",
                                style: const TextStyle(
                                  color: Color.fromRGBO(12, 24, 68, 1),
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
                                      color: Color.fromRGBO(12, 24, 68, 1)),
                                ),
                                IconButton(
                                  onPressed: _selectedItems.contains(true)
                                      ? deleteSelectedItems
                                      : null,
                                  icon: const Icon(Icons.delete_forever_rounded,
                                      color: Color.fromRGBO(255, 105, 105, 1)),
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
                        color: Color.fromRGBO(12, 24, 68, 1),
                        fontWeight: FontWeight.bold,
                        fontSize: 22,
                      ),),
                      const SizedBox(height: 5,)
                    ],
                    Container(
                      // Table header
                      height: 40,
                      decoration: const BoxDecoration(
                        color: Color.fromRGBO(12, 24, 68, 1),
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
                                        255, 245, 225, 1); // Active color
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
                                        color: Colors.white,
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      )))),
                          const Expanded(
                              flex: 3,
                              child: Center(
                                  child: Text('Tên sách',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      )))),
                          const Expanded(
                              flex: 2,
                              child: Center(
                                  child: Text('Thể loại',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      )))),
                          const Expanded(
                              flex: 2,
                              child: Center(
                                  child: Text('Tác giả',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      )))),
                          const Expanded(
                              flex: 1,
                              child: Center(
                                  child: Text('Số lượng',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
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
                          itemCount: serverFetchedBookEntriesData.length,
                          itemBuilder: (context, index) {
                            final entry = serverFetchedBookEntriesData[index];
                            final isLastItem = index ==
                                serverFetchedBookEntriesData.length - 1;
                            return Column(
                              children: [
                                GestureDetector(
                                  onTap: () => toggleItemSelection(
                                      index, !_selectedItems[index]),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: _selectedItems[index]
                                          ? const Color.fromRGBO(
                                              255, 245, 225, 1)
                                          : Colors.grey[100],
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
                                            activeColor: const Color.fromRGBO(
                                                12, 24, 68, 1),
                                            checkColor: const Color.fromRGBO(
                                                255, 245, 225, 1),
                                          ),
                                        ),
                                        Expanded(
                                            flex: 1,
                                            child: Center(
                                                child: Text('${index + 1}',
                                                    style: const TextStyle(
                                                      color: Color.fromRGBO(
                                                          12, 24, 68, 1),
                                                      fontSize: 16,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    )))),
                                        Expanded(
                                            flex: 3,
                                            child: Center(
                                                child: Text(entry.bookName!,
                                                    style: const TextStyle(
                                                      color: Color.fromRGBO(
                                                          12, 24, 68, 1),
                                                      fontSize: 16,
                                                    )))),
                                        Expanded(
                                            flex: 2,
                                            child: Center(
                                                child: Text(
                                                    entry.genres!.join(', '),
                                                    style: const TextStyle(
                                                      color: Color.fromRGBO(
                                                          12, 24, 68, 1),
                                                      fontSize: 16,
                                                    )))),
                                        Expanded(
                                            flex: 2,
                                            child: Center(
                                                child: Text(
                                                    entry.authors!.join(', '),
                                                    style: const TextStyle(
                                                      color: Color.fromRGBO(
                                                          12, 24, 68, 1),
                                                      fontSize: 16,
                                                    )))),
                                        Expanded(
                                            flex: 1,
                                            child: Center(
                                                child: Text(
                                                    stdNumFormat
                                                        .format(entry.quantity),
                                                    style: const TextStyle(
                                                      color: Color.fromRGBO(
                                                          12, 24, 68, 1),
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
                      padding: EdgeInsets.symmetric(vertical: 70),
                      child: Text("Chọn một ngày để bắt đầu tra cứu",
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
