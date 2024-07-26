import 'package:flutter/material.dart';
import 'mutual_widgets.dart';
import 'book_entry_form.dart';
import 'setting.dart';
import 'package:flutter/services.dart'; // Import for FilteringTextInputFormatter

late DateTime serverUploadedDateInputData;
List<EntryDataForForm> serverUploadedBookEntriesData = [];

// group data in group for convenience

// =============================================================================

// Book Input Form
class BookEntryInputForm extends StatefulWidget {
  late int
      orderNum; // this cannot be `final` since we may remove a form and other forms behind it must update their `orderNum`s
  final Color titleBarColor;
  final Color titleColor;
  final Color contentAreaColor;
  final Color contentTitleColor;
  final Color contentInputColor;
  final Color contentInputFormFillColor;
  final Color textFieldBorderColor;

  BookEntryInputForm({
    super.key,
    required this.orderNum,
    this.titleBarColor = const Color.fromRGBO(12, 24, 68, 1),
    this.titleColor = const Color.fromRGBO(225, 227, 234, 1),
    this.contentAreaColor = const Color.fromRGBO(255, 245, 225, 1),
    this.contentTitleColor = const Color.fromRGBO(12, 24, 68, 1),
    this.contentInputColor = const Color.fromRGBO(12, 24, 68, 1),
    this.contentInputFormFillColor = Colors.white,
    this.textFieldBorderColor = Colors.grey,
  });

  @override
  createState() => _BookEntryInputFormState();
}

class _BookEntryInputFormState extends State<BookEntryInputForm> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _authorController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();
  String _genreController = '';

  @override
  void dispose() {
    _titleController.dispose();
    _authorController.dispose();
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
                              Icon(Icons.person,
                                  color: widget.contentTitleColor),
                              const SizedBox(width: 4),
                              Text('Tác giả',
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: widget.contentTitleColor)),
                            ],
                          ),
                          const SizedBox(height: 4),
                          TextField(
                            controller: _authorController,
                            decoration: InputDecoration(
                              isDense: true,
                              filled: true,
                              fillColor: widget.contentInputFormFillColor,
                              hintText: "Nhập tác giả",
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
    setState(() {
      widget.orderNum = newOrderNum;
    });
  }

  EntryDataForForm getBookEntryData() {
    return EntryDataForForm(
      title: _titleController.text,
      category: _genreController,
      author: _authorController.text,
      quantity: int.tryParse(_quantityController.text) ?? 0,
    );
  }
}

// =============================================================================

class BookEntryFormCreateForm extends StatefulWidget {
  final VoidCallback backContextSwitcher;

  const BookEntryFormCreateForm(
      {super.key,
      required this.backContextSwitcher,});

  @override
  State<BookEntryFormCreateForm> createState() =>
      _BookEntryFormCreateFormState();
}

class _BookEntryFormCreateFormState extends State<BookEntryFormCreateForm> {
  final List<Widget> _formWidgets = []; // Dynamic list of form widgets
  final List<GlobalKey<_BookEntryInputFormState>> _formKeys =
      []; // Corresponding keys
  final ScrollController _scrollController =
      ScrollController(); // Scroll controller
  bool _isSaving = false; // Track save button state

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
      final formKey = GlobalKey<_BookEntryInputFormState>();
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
    if (_isSaving) return; // Prevent spamming button

    setState(() {
      _isSaving = true; // Set saving state to true
    });

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
      setState(() {
        _isSaving = false; // Reset saving state after snack bar is closed
      });
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
                      "Nếu có nhiều hơn 1 phiếu nhập có cùng thông tin sách, dữ liệu về số lượng nhập ngày hôm đó cho cuốn sách đó khi lưu lại sẽ được cộng gộp các phiếu liên quan lại với nhau.",
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
                      fontSize: 16, color: Color.fromRGBO(12, 24, 68, 1)),
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
                        // Wrap the form in Dismissible
                        key: UniqueKey(),
                        // Unique key for Dismissible
                        direction: DismissDirection.endToStart,
                        // Swipe left to delete
                        onDismissed: (direction) {
                          setState(() {
                            _formWidgets.removeAt(index);
                            _formKeys.removeAt(index);

                            // Update order numbers of remaining forms behind
                            for (int i = index; i < _formWidgets.length; i++) {
                              (_formWidgets[i].key
                                      as GlobalKey<_BookEntryInputFormState>)
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
