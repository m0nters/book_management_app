import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tuple/tuple.dart';
import '../../../controller/goods_receipt_controller.dart';
import '../../../controller/rule_controller.dart';
import '../../../model/book.dart';
import '../../../model/goods_receipt.dart';
import '../../../repository/book_repository.dart';
import '../../../repository/goods_receipt_repository.dart';
import '../../../repository/rule_repository.dart';
import '../mutual_widgets.dart';
import 'book_entry_form_widgets.dart';

late DateTime serverUploadedDateInputData;
List<EntryData> serverUploadedBookEntriesData = [];

class BookEntryFormCreateForm extends StatefulWidget {
  final VoidCallback backContextSwitcher;

  const BookEntryFormCreateForm({
    super.key,
    required this.backContextSwitcher,
  });

  @override
  State<BookEntryFormCreateForm> createState() =>
      _BookEntryFormCreateFormState();
}

class _BookEntryFormCreateFormState extends State<BookEntryFormCreateForm> {
  final List<BookEntryInputForm> _formWidgets =
      []; // Dynamic list of form widgets
  final List<GlobalKey<BookEntryInputFormState>> _formKeys =
      []; // Corresponding keys
  final ScrollController _scrollController =
      ScrollController(); // Scroll controller
  bool _isShowing = false; // Track snack bar state
  final ruleController = RuleController(RuleRepository());
  late int minReceive;
  late int maxStockBefore;

  @override
  void dispose() {
    serverUploadedBookEntriesData.clear();
    _scrollController.dispose(); // Dispose of the scroll controller
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);

    _addForm(); // Add one form initially
    BookEntryInputFormState.existedNames.clear();
  }

  void _addForm() {
    setState(() {
      final formKey = GlobalKey<BookEntryInputFormState>();
      _formKeys.add(formKey); // Add the key to the list

      _formWidgets.add(
        BookEntryInputForm(
          orderNum: _formWidgets.length + 1, // Dynamic order number
          key: formKey, // Assign the key
        ),
      );
    });

    // make the list view scroll to the bottom automatically when a new form is created
    // first is to keep track with what we've created
    // second is that it won't create a wrong illusion that we haven't created a form in some cases
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        // Check if the controller is attached
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<bool> uploadDataToDtb() async {
    minReceive = await ruleController.getMinReceive();
    maxStockBefore = await ruleController.getMaxStockPreReceipt();
    List<Tuple2<Book, int>> bookList = [];
    final bookRepo = BookRepository();

    for (int i = 0; i < serverUploadedBookEntriesData.length; ++i) {
      var currentEntryObject = serverUploadedBookEntriesData[i];
      final targetList =
          await bookRepo.getBooksByTitle(currentEntryObject.bookName!);

      // if update info has empty book name
      if (targetList.isEmpty) {
        _showSaveStatus(
            'Tồn tại thông tin tên sách không hợp lệ, vui lòng kiểm tra lại',
            isError: true);
        return false;
      }

      // if update info has quantity < allowed threshold
      if (currentEntryObject.quantity! < minReceive) {
        _showSaveStatus(
            'Tồn tại thông tin sách có lượng nhập rỗng hoặc nhỏ hơn lượng nhập tối thiểu là $minReceive',
            isError: true);
        return false;
      }

      Book targetBook = targetList[0];

      // if update info has a book that has stock quantity >= allowed threshold for inputting
      if (targetBook.stockQuantity >= maxStockBefore) {
        _showSaveStatus(
            'Tồn tại sách \"${targetBook.title}\" có lượng tồn là ${targetBook.stockQuantity}, nhiều hơn lượng tồn tối đa được nhập là $maxStockBefore',
            isError: true,
            duration: 4,
        );
        return false;
      }

      targetBook.stockQuantity += currentEntryObject.quantity!;
      await bookRepo.updateBook(targetBook);
      bookList.add(Tuple2(targetBook, currentEntryObject.quantity!));
    }

    if (bookList.isNotEmpty) {
      GoodsReceipt currentInputEntryForm = GoodsReceipt(
          receiptID: '', date: serverUploadedDateInputData, bookList: bookList);
      final goodsReceiptController =
          GoodsReceiptController(GoodsReceiptRepository());
      await goodsReceiptController.createGoodsReceipt(currentInputEntryForm);
    } else {
      _showSaveStatus(
          'Không có thông tin nào hợp lệ để tải lên cơ sở dữ liệu! Vui lòng điền lại các trường.',
          isError: true);
      return false;
    }

    return true;
  }

  Future<void> _onSavePressed() async {
    // frontend: check whether the data is empty or unchanged or not to be ready to be converted to backend data structure
    if (_isShowing) return; // Prevent spamming button

    _isShowing = true; // Set saving state to true

    String dateSaved = (serverUploadedDateInputData.year ==
                DateTime.now().year &&
            serverUploadedDateInputData.month == DateTime.now().month &&
            serverUploadedDateInputData.day == DateTime.now().day)
        ? "hôm nay"
        : "ngày ${serverUploadedDateInputData.day}/${serverUploadedDateInputData.month}/${serverUploadedDateInputData.year}";

    if (_formWidgets.isEmpty) {
      _showSaveStatus('Không có dữ liệu gì để lưu cho $dateSaved!',
          isError: true);
      return;
    }

    serverUploadedBookEntriesData =
        _formKeys.map((key) => key.currentState!.getBookEntryData()).toList();

    // backend: check whether the data is valid to be uploaded to server
    uploadDataToDtb().then((isValid) {
      if (isValid) {
        _showSaveStatus('Đã lưu các phiếu nhập sách cho $dateSaved!');
        setState(() {
          _formWidgets.clear();
          _formKeys.clear();
          BookEntryInputFormState.existedNames.clear();
          _addForm();
        });
      }
    });
  }

  void _showSaveStatus(String message, {bool isError = false, int duration = 2}) {
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
      _isShowing = false; // Reset saving state after snack bar is closed
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(225, 227, 234, 1),
      appBar: AppBar(
        backgroundColor: const Color.fromRGBO(225, 227, 234, 1),
        foregroundColor: const Color.fromRGBO(12, 24, 68, 1),
        title: const Text(
          "Lập phiếu",
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
        actions: [
          IconButton(onPressed: _addForm, icon: const Icon(Icons.add_circle)),
          IconButton(
            onPressed: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    backgroundColor: const Color.fromRGBO(225, 227, 234, 1),
                    title: const Text("Lưu ý về ngày lập phiếu",
                        style:
                        TextStyle(color: Color.fromRGBO(34, 12, 68, 1))),
                    // Customize the title
                    content: Text(
                      "Ngày lập phiếu mặc định luôn là ngày hôm nay.",
                      style: TextStyle(color: Colors.grey[700]),
                    ),
                    // Customize the content
                    actions: <Widget>[
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop(); // Close the dialog
                        },
                        child: const Text("Đã hiểu",
                            style: TextStyle(
                                color: Color.fromRGBO(255, 105, 105, 1))),
                      ),
                    ],
                  );
                },
              );
            },
            icon: const Icon(Icons.info, size: 25),
          )
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
                  style: TextStyle(
                      fontSize: 16,
                      color: Color.fromRGBO(12, 24, 68, 1),
                      fontWeight: FontWeight.bold),
                ),
                DatePickerBox(
                  initialDate: DateTime.now(),
                  onDateChanged: (date) => serverUploadedDateInputData = date,
                  backgroundColor: const Color.fromRGBO(255, 245, 225, 1),
                  foregroundColor: const Color.fromRGBO(12, 24, 68, 1),
                )
              ],
            ),
            const SizedBox(
              height: 46,
            ),
            CustomRoundedButton(
              backgroundColor: const Color.fromRGBO(255, 105, 105, 1),
              foregroundColor: const Color.fromRGBO(255, 227, 234, 1),
              title: "Lưu",
              onPressed: _onSavePressed,
              width: 108,
              fontSize: 24,
            ),
            const SizedBox(
              height: 46,
            ),
            Expanded(
              child: SingleChildScrollView(
                controller: _scrollController,
                child: Column(
                  children: _formWidgets.asMap().entries.map((entry) {
                    final index = entry.key;
                    final formWidget = entry.value;

                    return Column(
                      children: [
                        Dismissible(
                          key: UniqueKey(),
                          direction: DismissDirection.endToStart,
                          confirmDismiss: (direction) async {
                            final bool confirmDelete = await showDialog(
                              context: context,
                              barrierDismissible: true,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  backgroundColor: const Color.fromRGBO(225, 227, 234, 1),
                                  title: Text(
                                    _formWidgets.length != 1
                                        ? 'Xác nhận xóa'
                                        : "ĐÂY LÀ PHIẾU NHẬP SÁCH CUỐI CÙNG!",
                                    style: const TextStyle(
                                        color: Color.fromRGBO(12, 24, 68, 1)),
                                  ),
                                  content: const Text(
                                      "Bạn có chắc chắn muốn xóa phiếu nhập sách này?"),
                                  actions: <Widget>[
                                    TextButton(
                                      onPressed: () {
                                        Navigator.of(context).pop(false);
                                      },
                                      child: const Text("Không"),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        Navigator.of(context).pop(true);
                                      },
                                      style: TextButton.styleFrom(
                                        foregroundColor: Colors.red,
                                      ),
                                      child: const Text(
                                        'Xóa',
                                        style: TextStyle(
                                            color: Color.fromRGBO(255, 105, 105, 1)),
                                      ),
                                    ),
                                  ],
                                );
                              },
                            ) ?? false;

                            if (confirmDelete) {
                              final bookName = _formKeys[index]
                                  .currentState
                                  ?.getBookEntryData()
                                  .bookName;
                              BookEntryInputFormState.existedNames.remove(bookName);

                              setState(() {
                                _formWidgets.removeAt(index);
                                _formKeys.removeAt(index);
                              });

                              if (_formWidgets.isNotEmpty) {
                                _showSaveStatus(
                                    'Đã xóa phiếu nhập sách ở STT ${index + 1}!',
                                    isError: true);
                              } else {
                                _showSaveStatus('Đã xóa toàn bộ phiếu hôm nay!',
                                    isError: true);
                              }

                              // Update order numbers for remaining forms
                              WidgetsBinding.instance.addPostFrameCallback((_) {
                                setState(() {
                                  for (int i = index; i < _formWidgets.length; i++) {
                                    _formKeys[i]
                                        .currentState!
                                        .updateOrderNumber(i + 1);
                                  }
                                });
                              });
                            }

                            return confirmDelete;
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
                          child: formWidget,
                        ),
                        const SizedBox(height: 30),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
