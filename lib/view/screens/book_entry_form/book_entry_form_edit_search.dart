import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tuple/tuple.dart';
import '../../../controller/goods_receipt_controller.dart';
import '../../../controller/rule_controller.dart';
import '../../../model/book.dart';
import '../../../repository/book_repository.dart';
import '../../../repository/goods_receipt_repository.dart';
import '../../../repository/rule_repository.dart';
import '../mutual_widgets.dart';
import 'book_entry_form_widgets.dart';

bool disableButton = false;

List<EntryData> serverUploadedBookEntriesData = [];

class BookEntryFormEditSearch extends StatefulWidget {
  final VoidCallback backContextSwitcher;
  final List<EntryData> editedItems;
  final DateTime editedDate;

  const BookEntryFormEditSearch({
    super.key,
    required this.editedItems,
    required this.backContextSwitcher,
    required this.editedDate,
  });

  @override
  State<BookEntryFormEditSearch> createState() =>
      _BookEntryFormEditSearchState();
}

class _BookEntryFormEditSearchState extends State<BookEntryFormEditSearch> {
  final List<BookEntryInputFormState> _formStates = [];
  bool _isShowingSnackBar = false;

  // for backend requirement constraints
  final ruleController = RuleController(RuleRepository());
  late int maxStockBefore;
  late int minReceive;

  @override
  void initState() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    BookEntryInputFormState.existedNames.clear();
  }

  Future<bool> uploadDataToDtb(EntryData editedItem, int index) async {
    minReceive = await ruleController.getMinReceive();
    maxStockBefore = await ruleController.getMaxStockPreReceipt();
    final goodsReceiptController =
        GoodsReceiptController(GoodsReceiptRepository());
    final receipt = await goodsReceiptController.readGoodsReceiptByID(
        widget.editedItems[index].entryID!); // find the target book entry form

    final bookRepo = BookRepository();
    final newBookList = await bookRepo.getBooksByTitle(editedItem
        .bookName!); // returns the list of books that have the recently typed title
    final oldBookList = await bookRepo.getBooksByTitle(widget.editedItems[index]
        .bookName!); // returns the list of books that have the old title


    var oldQuantity = widget.editedItems[index].quantity ?? 0;
    var newQuantity = editedItem.quantity ?? 0;

    // if update info has empty book name
    if (newBookList.isEmpty) {
      _showUpdateStatus('Tồn tại thông tin tên sách không hợp lệ, vui lòng kiểm tra lại',
          isError: true, duration: 4);
      await Future.delayed(const Duration(seconds: 4));
      return false;
    }

    // if update info has quantity < allowed threshold
    if (newQuantity < minReceive) {
      _showUpdateStatus(
          'Tồn tại thông tin sách có lượng nhập rỗng hoặc nhỏ hơn lượng nhập tối thiểu là $minReceive',
          isError: true,
          duration: 4);
      await Future.delayed(const Duration(seconds: 4));
      return false;
    }

    Book newBook = newBookList[0];
    Book oldBook = oldBookList[0];

    // if update info has a book that has stock quantity >= allowed threshold for inputting
    if (newBook.stockQuantity >= maxStockBefore) {
      _showUpdateStatus(
        'Tồn tại thông tin sách \"${newBook.title}\" có lượng tồn là ${newBook.stockQuantity}, nhiều hơn lượng tồn tối đa được nhập là $maxStockBefore',
        isError: true,
        duration: 4,
      );
      await Future.delayed(const Duration(seconds: 4));
      return false;
    }

    if (oldBook.bookID == newBook.bookID) {
      // old book name = new book name
      // change stock quantity on server
      oldBook.stockQuantity += (newQuantity - oldQuantity);
      await bookRepo.updateBook(oldBook);

      // change quantity that row
      for (Tuple2<Book, int> pair in receipt!.bookList) {
        if (pair.item1.bookID == oldBook.bookID) {
          receipt.bookList.remove(pair);
          break;
        }
      } // delete out the row

      receipt.bookList.add(Tuple2<Book, int>(oldBook, newQuantity));
      await goodsReceiptController.updateGoodsReceipt(receipt);
    } else if (oldBook.bookID != newBook.bookID) {
      Tuple2<Book, int>? oldBookPair;
      Tuple2<Book, int>? newBookPair;
      int oldQuantityOfNewBook = 0;
      for (Tuple2<Book, int> pair in receipt!.bookList) {
        if (pair.item1.bookID == oldBook.bookID) {
          oldBookPair = pair;
        }
        if (pair.item1.bookID == newBook.bookID) {
          oldQuantityOfNewBook += pair.item2;
          newBookPair = pair;
        }
      }
      if (oldBookPair != null) {
        receipt.bookList.remove(oldBookPair);
      }
      if (newBookPair != null) {
        receipt.bookList.remove(newBookPair);
      }

      oldBook.stockQuantity -= oldQuantity; // update the old book quantity
      await bookRepo.updateBook(oldBook);

      newBook.stockQuantity += newQuantity; // update the new book quantity
      await bookRepo.updateBook(newBook);

      receipt.bookList
          .add(Tuple2<Book, int>(newBook, oldQuantityOfNewBook + newQuantity));
      await goodsReceiptController.updateGoodsReceipt(receipt);
    }

    return true;
  }

  Future<void> _onUpdatePressed() async {
    if (_isShowingSnackBar) return; // Prevent spamming button

    _isShowingSnackBar = true; // Set saving state to true

    // Get the updated data from the form states
    serverUploadedBookEntriesData =
        _formStates.map((formState) => formState.getBookEntryData()).toList();

    // Check if there is any change in the data
    bool hasChanges = false;

    for (int i = 0; i < widget.editedItems.length; ++i) {
      if (serverUploadedBookEntriesData[i].bookName !=
              widget.editedItems[i].bookName ||
          serverUploadedBookEntriesData[i].genres?.join(', ') !=
              widget.editedItems[i].genres?.join(', ') ||
          serverUploadedBookEntriesData[i].authors?.join(', ') !=
              widget.editedItems[i].authors?.join(', ') ||
          serverUploadedBookEntriesData[i].quantity !=
              widget.editedItems[i].quantity) {
        hasChanges = true;
        break; // Exit the loop early if any change is detected
      }
    }

    if (!hasChanges) {
      _showUpdateStatus('Không có dữ liệu gì thay đổi!', isError: true);
      return;
    }

    setState(() {
      disableButton = true;
    });

    _showUpdateStatus(
        'Vui lòng không rời màn hình này trong quá trình cập nhật\nSau khi cập nhật xong màn hình này sẽ tự động thoát ra!',
        isError: true,
        duration: 3000);

    // add the code to upload data to server here (backend)
    for (int i = 0; i < serverUploadedBookEntriesData.length; ++i) {
      bool success = await uploadDataToDtb(serverUploadedBookEntriesData[i], i);

      if (success) {
        _showUpdateStatus('Đã cập nhật phiếu STT ${i + 1}', duration: 100);
      } else {
        _showUpdateStatus('Cập nhật thất bại cho phiếu STT ${i + 1}', isError: true);
        continue; // Continue to the next iteration if the upload failed
      }
    }

    await Future.delayed(const Duration(seconds: 3));
    if (widget.editedItems.length > 1) {
      _showUpdateStatus(
          'Đã cập nhật thông tin các phiếu liên quan trong ngày ${stdDateFormat.format(widget.editedDate)}');
    }
    else {
      _showUpdateStatus(
          'Đã cập nhật thông tin phiếu liên quan trong ngày ${stdDateFormat.format(widget.editedDate)}');
    }

    widget.backContextSwitcher();

    disableButton = false;
  }

  void _showUpdateStatus(String message,
      {bool isError = false, int duration = 2000}) {
    ScaffoldMessenger.of(context)
        .showSnackBar(
          SnackBar(
            content: Text(message,
                style:
                    const TextStyle(color: Color.fromRGBO(215, 227, 234, 1))),
            backgroundColor:
                isError ? const Color.fromRGBO(255, 105, 105, 1) : Colors.green,
            duration: Duration(milliseconds: duration),
          ),
        )
        .closed
        .then((reason) {
      _isShowingSnackBar =
          false; // Reset saving state after snack bar is closed
    });
  }

  @override
  Widget build(BuildContext context) {
    print(disableButton);
    return Scaffold(
      backgroundColor: const Color.fromRGBO(225, 227, 234, 1),
      appBar: AppBar(
        backgroundColor: const Color.fromRGBO(225, 227, 234, 1),
        foregroundColor: const Color.fromRGBO(12, 24, 68, 1),
        title: const Text(
          "Chỉnh sửa",
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
        child: Column(
          children: [
            const SizedBox(
              height: 25,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                const Text(
                  "Ngày đang chỉnh sửa: ",
                  style: TextStyle(
                      fontSize: 16,
                      color: Color.fromRGBO(12, 24, 68, 1),
                      fontWeight: FontWeight.bold),
                ),
                DatePickerBox(
                  initialDate: widget.editedDate,
                  backgroundColor: const Color.fromRGBO(255, 245, 225, 1),
                  foregroundColor: const Color.fromRGBO(12, 24, 68, 1),
                  isEnabled: false,
                  errorMessageWhenDisabled:
                      'Ngày chỉnh sửa đã bị vô hiệu hóa chỉnh sửa để đảm bảo tính toàn vẹn của dữ liệu',
                )
              ],
            ),
            const SizedBox(
              height: 46,
            ),
            CustomRoundedButton(
              backgroundColor: const Color.fromRGBO(255, 105, 105, 1),
              foregroundColor: const Color.fromRGBO(255, 227, 234, 1),
              title: "Cập nhật",
              onPressed: _onUpdatePressed,
              width: 108,
              fontSize: 24,
              isDisabled: disableButton,
            ),

            Expanded(
              child: disableButton
                  ? const Center(
                child: CircularProgressIndicator(
                    color: Color.fromRGBO(255, 105, 105, 1)),
              )
                  : Column(
                children: [
                  const SizedBox(
                    height: 46,
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        children: widget.editedItems.map((item) {
                          int index = widget.editedItems.indexOf(item);
                          return Column(
                            children: [
                              BookEntryInputForm(
                                orderNum: index + 1,
                                reference: item,
                                key: GlobalKey(),
                                onStateCreated: (state) =>
                                    _formStates.add(state), // Save the form state
                              ),
                              const SizedBox(
                                height: 16,
                              ),
                            ],
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
