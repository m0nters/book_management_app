import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'book_entry_form_widgets.dart';
import '../mutual_widgets.dart';
import 'book_entry_form_edit_search.dart';

List<EntryData> serverFetchedBookEntriesData = [
  EntryData(
      bookName: 'Tôi thấy hoa vàng ở trên cỏ xanh',
      genre: 'Tiểu thuyết',
      author: 'Nguyễn Nhật Ánh',
      quantity: 29),
  EntryData(
      bookName: 'Cho tôi biển mặn',
      genre: 'Truyện ngắn',
      author: 'Việt',
      quantity: 12),
  EntryData(
      bookName: 'Cho tôi biến mất một ngày',
      genre: 'Tình cảm',
      author: 'Việt',
      quantity: 25),
  EntryData(
      bookName: 'Hai con mèo ngồi bên cửa sổ',
      genre: 'Truyện ngắn',
      author: 'Ngô Thùy Linh',
      quantity: 21),
]; // backend fetch data from here

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
  bool allSelected =
      false; // Variable to track the state of the "Select All" checkbox
  bool isEmptyBecauseOfDeletion = false;
  late List<bool> _selectedItems;
  final ScrollController _totalScrollController = ScrollController();
  final ScrollController _searchResultScrollController = ScrollController();

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
    }

    _selectedItems =
        List.generate(serverFetchedBookEntriesData.length, (index) => false);
  }

  @override
  void dispose() {
    _totalScrollController.dispose();
    _searchResultScrollController.dispose();
    super.dispose();
  }

  void onDateChange(DateTime date) {
    setState(() {
      widget.initialDate = date;
      hasPickedDate = true;
      isEmptyBecauseOfDeletion =
          false; // meaning if there's no result for desired date, it's not because of deletion
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
                  style: TextStyle(color: Color.fromRGBO(255, 105, 105, 1)),
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
            serverFetchedBookEntriesData.removeAt(i);
            // backend code to delete data corresponding serverFetchedBookEntriesData[i] on server
          }
        }
        if (serverFetchedBookEntriesData.isEmpty) {
          isEmptyBecauseOfDeletion = true;
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
    final formattedDate =
        hasPickedDate ? stdDateFormat.format(widget.initialDate!) : '';

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
                      fontSize: 16, color: Color.fromRGBO(12, 24, 68, 1)),
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
                if (hasPickedDate) ...[
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
                                        fontSize: 16,
                                      )))),
                          const Expanded(
                              flex: 3,
                              child: Center(
                                  child: Text('Tên sách',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                      )))),
                          const Expanded(
                              flex: 2,
                              child: Center(
                                  child: Text('Thể loại',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                      )))),
                          const Expanded(
                              flex: 2,
                              child: Center(
                                  child: Text('Tác giả',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                      )))),
                          const Expanded(
                              flex: 1,
                              child: Center(
                                  child: Text('Số lượng',
                                      style: TextStyle(
                                        color: Colors.white,
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
                          itemCount: serverFetchedBookEntriesData.length,
                          itemBuilder: (context, index) {
                            final entry = serverFetchedBookEntriesData[index];
                            final isLastItem = index ==
                                serverFetchedBookEntriesData.length - 1;
                            return Container(
                              decoration: BoxDecoration(
                                color: _selectedItems[index]
                                    ? const Color.fromRGBO(255, 245, 225, 1)
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
                                          toggleItemSelection(index, value),
                                      activeColor:
                                          const Color.fromRGBO(12, 24, 68, 1),
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
                                          child: Text(entry.genre!,
                                              style: const TextStyle(
                                                color: Color.fromRGBO(
                                                    12, 24, 68, 1),
                                                fontSize: 16,
                                              )))),
                                  Expanded(
                                      flex: 2,
                                      child: Center(
                                          child: Text(entry.author!,
                                              style: const TextStyle(
                                                color: Color.fromRGBO(
                                                    12, 24, 68, 1),
                                                fontSize: 16,
                                              )))),
                                  Expanded(
                                      flex: 1,
                                      child: Center(
                                          child: Text('${entry.quantity}',
                                              style: const TextStyle(
                                                color: Color.fromRGBO(
                                                    12, 24, 68, 1),
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
