import 'package:flutter/material.dart';
import 'setting.dart';
import 'mutual_widgets.dart';
import 'book_entry_form.dart';
import 'package:intl/intl.dart';
import 'package:flutter/services.dart'; // Import for FilteringTextInputFormatter

late DateTime serverUploadedDateInputData;
late EntryDataForForm serverUploadedBookEntryData;

class BookEntryFormEdit extends StatefulWidget {
  final VoidCallback backContextSwitcher;
  final VoidCallback reloadContext;
  final EntryDataForTicket editItem;

  final Color titleBarColor;
  final Color titleColor;
  final Color contentAreaColor;
  final Color contentTitleColor;
  final Color contentInputColor;
  final Color contentInputFormFillColor;
  final Color textFieldBorderColor;

  const BookEntryFormEdit({
    super.key,
    required this.backContextSwitcher,
    required this.reloadContext,
    required this.editItem,
    this.titleBarColor = const Color.fromRGBO(12, 24, 68, 1),
    this.titleColor = const Color.fromRGBO(225, 227, 234, 1),
    this.contentAreaColor = const Color.fromRGBO(255, 245, 225, 1),
    this.contentTitleColor = const Color.fromRGBO(12, 24, 68, 1),
    this.contentInputColor = const Color.fromRGBO(12, 24, 68, 1),
    this.contentInputFormFillColor = Colors.white,
    this.textFieldBorderColor = Colors.grey,
  });

  @override
  State<BookEntryFormEdit> createState() => _BookEntryFormEditState();
}

class _BookEntryFormEditState extends State<BookEntryFormEdit> {
  late DateTime _dateController;
  final TextEditingController _titleController = TextEditingController();
  String _genreController = '';
  final TextEditingController _authorController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _titleController.text = widget.editItem.bookName;
    _authorController.text = widget.editItem.author;
    _quantityController.text = widget.editItem.quantity.toString();
    _genreController = widget.editItem.genre;
  }

  bool _isSaving = false;

  void _onUpdatePressed() {
    if (_isSaving) return; // Prevent spamming button

    setState(() {
      _isSaving = true; // Set saving state to true
    });

    if (_dateController ==
            DateFormat('dd/MM/yy').parse(widget.editItem.entryDate) &&

        _titleController.text == widget.editItem.bookName &&
        _genreController == widget.editItem.genre &&
        _authorController.text == widget.editItem.author &&
        _quantityController.text == widget.editItem.quantity.toString()) {
      _showSnackBar('Không có dữ liệu gì thay đổi!', isError: true);
      return;
    }

    serverUploadedBookEntryData = getBookEntryData();
    serverUploadedDateInputData = _dateController;

    // add the code to upload data to server here (backend)

    _showSnackBar(
        'Đã chỉnh sửa phiếu nhập sách số ${widget.editItem.entryCode}!');

    widget.reloadContext();
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
            "Chỉnh sửa",
            style: TextStyle(
                fontWeight: FontWeight.w400,
                color: Color.fromRGBO(12, 24, 68, 1)),
          ),
          leading: IconButton(
            onPressed: () {
              widget.backContextSwitcher();
            },
            icon: const Icon(Icons.arrow_back),
            color: const Color.fromRGBO(12, 24, 68, 1),
          ),
        ),
        body: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 0.0),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(
                    height: 46,
                  ),
                  CustomRoundedButton(
                    backgroundColor: const Color.fromRGBO(255, 105, 105, 1),
                    foregroundColor: const Color.fromRGBO(255, 227, 234, 1),
                    title: "Cập nhật",
                    onPressed: () {
                      _onUpdatePressed();
                    },
                    width: 108,
                    fontSize: 24,
                  ),
                  const SizedBox(
                    height: 46,
                  ),
                  Container(
                    // title bar
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8.0, vertical: 8.0),
                    decoration: BoxDecoration(
                      color: widget.titleBarColor,
                      borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(8),
                          topRight: Radius.circular(8)),
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
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Row(
                        children: [
                          Text(
                            'Mã phiếu ${widget.editItem.entryCode}',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: widget.titleColor,
                            ),
                          ),
                          IconButton(
                            onPressed: () {
                              // Handle info button press (e.g., show a dialog)
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    title: Text("Thông tin",
                                        style: TextStyle(
                                            color:
                                                widget.titleBarColor)),
                                    content: Text(
                                        "Mã phiếu là khóa chính để định danh bản thân phiếu trên cơ sở dữ liệu, do đó ta không (thể) chỉnh sửa nó.",
                                        style:
                                            TextStyle(color: Colors.grey[700])),
                                    actions: <Widget>[
                                      TextButton(
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                        },
                                        child: const Text("Đã hiểu",
                                            style: TextStyle(
                                                color: Color.fromRGBO(
                                                    255, 105, 105, 1))),
                                      ),
                                    ],
                                  );
                                },
                              );
                            },
                            icon: Icon(Icons.info_outline,
                                size: 23,
                                color:
                                    widget.titleColor), // Adjust size as needed
                          ),
                        ],
                      ),
                    ),
                  ),
                  Container(
                      // content area
                      padding:
                          const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
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
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text('Ngày nhập',
                                      style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: widget.contentTitleColor)),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Material(
                                borderRadius: BorderRadius.circular(4),
                                child: DatePickerBox(
                                  initialDate: DateFormat('dd/MM/yy')
                                      .parse(widget.editItem.entryDate),
                                  onDateChanged: (date) => _dateController = date,
                                  backgroundColor:
                                      widget.contentInputFormFillColor,
                                  foregroundColor: widget.contentTitleColor,
                                ),
                              )
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
                                        Icon(Icons.book,
                                            color: widget.contentTitleColor),
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
                                        fillColor:
                                            widget.contentInputFormFillColor,
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
                                      style: TextStyle(
                                          color: widget.contentInputColor),
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
                                      action: (genre) =>
                                          _genreController = genre ?? '',
                                      fillColor: widget.contentInputFormFillColor,
                                      width: double.infinity,
                                      hintText: 'Chọn một thể loại',
                                      initialValue: widget.editItem.genre,
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
                                        fillColor:
                                            widget.contentInputFormFillColor,
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
                                      style: TextStyle(
                                          color: widget.contentInputColor),
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
                                            RegExp(r'[0-9]')),
                                        // Allow only digits
                                      ],
                                      decoration: InputDecoration(
                                        isDense: true,
                                        filled: true,
                                        fillColor:
                                            widget.contentInputFormFillColor,
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
                                      style: TextStyle(
                                          color: widget.contentInputColor),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ))
                ],
              ),
            )));
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
