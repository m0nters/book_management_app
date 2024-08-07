import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../mutual_widgets.dart';
import 'book_entry_form_widgets.dart';

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

  @override
  void initState() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
    super.initState();
  }

  void _onUpdatePressed() {
    if (_isShowingSnackBar) return; // Prevent spamming button

    _isShowingSnackBar = true; // Set saving state to true

    // Get the updated data from the form states
    serverUploadedBookEntriesData =
        _formStates.map((formState) => formState.getBookEntryData()).toList();
    for (int i = 0; i < serverUploadedBookEntriesData.length; ++i) {
      print(serverUploadedBookEntriesData[i].bookName);
      print(serverUploadedBookEntriesData[i].genre);
      print(serverUploadedBookEntriesData[i].author);
      print(serverUploadedBookEntriesData[i].quantity);
    }

    // Check if there is any change in the data
    bool hasChanges = false;

    for (int i = 0; i < widget.editedItems.length; ++i) {
      if (serverUploadedBookEntriesData[i].bookName !=
              widget.editedItems[i].bookName ||
          serverUploadedBookEntriesData[i].genre !=
              widget.editedItems[i].genre ||
          serverUploadedBookEntriesData[i].author !=
              widget.editedItems[i].author ||
          serverUploadedBookEntriesData[i].quantity !=
              widget.editedItems[i].quantity) {
        hasChanges = true;
        break; // Exit the loop early if any change is detected
      }
    }

    if (!hasChanges) {
      _showSnackBar('Không có dữ liệu gì thay đổi!', isError: true);
      return;
    }

    // add the code to upload data to server here (backend)

    _showSnackBar(
        'Đã cập nhật thông tin các phiếu nhập ngày ${stdDateFormat.format(widget.editedDate)}');
    widget.backContextSwitcher();
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context)
        .showSnackBar(
          SnackBar(
            content: Text(message,
                style:
                    const TextStyle(color: Color.fromRGBO(215, 227, 234, 1))),
            backgroundColor:
                isError ? const Color.fromRGBO(255, 105, 105, 1) : Colors.green,
            duration: const Duration(seconds: 2),
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
            ),
            const SizedBox(
              height: 46,
            ),
            Expanded(
              child: ListView.builder(
                itemCount: widget.editedItems.length,
                itemBuilder: (context, index) {
                  return Column(
                    children: [
                      BookEntryInputForm(
                        orderNum: index + 1,
                        reference: widget.editedItems[index],
                        key: GlobalKey(),
                        onStateCreated: (state) =>
                            _formStates.add(state), // Save the form state
                      ),
                      const SizedBox(
                        height: 16,
                      )
                    ],
                  );
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}
