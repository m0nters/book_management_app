import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

  @override
  void dispose() {
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

  void _onSavePressed() {
    if (_isShowing) return; // Prevent spamming button

    _isShowing = true; // Set saving state to true

    String dateSaved = (serverUploadedDateInputData.year ==
                DateTime.now().year &&
            serverUploadedDateInputData.month == DateTime.now().month &&
            serverUploadedDateInputData.day == DateTime.now().day)
        ? "hôm nay"
        : "ngày ${serverUploadedDateInputData.day}/${serverUploadedDateInputData.month}/${serverUploadedDateInputData.year}";

    if (_formWidgets.isEmpty) {
      _showSnackBar('Không có dữ liệu gì để lưu cho $dateSaved!',
          isError: true);
      return;
    }

    serverUploadedBookEntriesData =
        _formKeys.map((key) => key.currentState!.getBookEntryData()).toList();

    // add the code to upload data to server here (backend)

    _showSnackBar('Đã lưu các phiếu nhập sách cho $dateSaved!');
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
                    title: const Text("Lưu ý về nhập trùng dữ liệu",
                        style: TextStyle(color: Color.fromRGBO(34, 12, 68, 1))),
                    // Customize the title
                    content: Text(
                      "Nếu có nhiều hơn 1 form nhập dưới đây có cùng thông tin về một cuốn sách nào đó, dữ liệu về số lượng nhập cho cuốn sách đó khi lưu lại sẽ được cộng gộp các form liên quan lại với nhau.",
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
                      fontSize: 16, color: Color.fromRGBO(12, 24, 68, 1), fontWeight: FontWeight.bold),
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
              // Make the forms scrollable
              child: ListView.builder(
                controller: _scrollController,
                itemCount: _formWidgets.length,
                itemBuilder: (context, index) {
                  return Column(
                    children: [
                      Dismissible(
                        key: UniqueKey(),
                        direction: DismissDirection.endToStart,
                        confirmDismiss: (direction) async {
                          return await showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                backgroundColor:
                                    const Color.fromRGBO(225, 227, 234, 1),
                                title: Text(
                                    _formWidgets.length != 1
                                        ? 'Xác nhận xóa'
                                        : "ĐÂY LÀ PHIẾU NHẬP SÁCH CUỐI CÙNG!",
                                    style: const TextStyle(
                                        color: Color.fromRGBO(12, 24, 68, 1))),
                                content: const Text(
                                    "Bạn có chắc chắn muốn xóa phiếu nhập sách này?"),
                                actions: <Widget>[
                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(context).pop(
                                          false); // Dismisses the dialog and does not delete the form
                                    },
                                    child: const Text("Không"),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(context).pop(
                                          true); // Dismisses the dialog and confirms deletion
                                    },
                                    style: TextButton.styleFrom(
                                      foregroundColor:
                                          Colors.red, // Color for delete button
                                    ),
                                    child: const Text(
                                      'Xóa',
                                      style: TextStyle(
                                          color:
                                              Color.fromRGBO(255, 105, 105, 1)),
                                    ),
                                  ),
                                ],
                              );
                            },
                          );
                        },
                        // Swipe left to delete
                        onDismissed: (direction) {
                          setState(() {
                            _formWidgets.removeAt(index);
                            _formKeys.removeAt(index);
                          });

                          if (_formWidgets.isNotEmpty) {
                            _showSnackBar(
                                'Đã xóa phiếu nhập sách ở STT ${index + 1}!',
                                isError: true);
                          } else {
                            _showSnackBar('Đã xóa toàn bộ phiếu hôm nay!',
                                isError: true);
                          }

                          // Use addPostFrameCallback to update order numbers after the build is complete
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            setState(() {
                              for (int i = index;
                                  i < _formWidgets.length;
                                  i++) {
                                _formKeys[i]
                                    .currentState!
                                    .updateOrderNumber(i + 1);
                              }
                            });
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
                        child: _formWidgets[index],
                      ),
                      const SizedBox(height: 30),
                    ],
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
