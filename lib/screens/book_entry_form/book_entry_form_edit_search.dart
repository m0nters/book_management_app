import 'package:flutter/material.dart';
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

  void _onUpdatePressed() {
    setState(() {
      serverUploadedBookEntriesData =
          _formStates.map((formState) => formState.getBookEntryData()).toList();
      widget.backContextSwitcher();
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
                      fontSize: 16, color: Color.fromRGBO(12, 24, 68, 1)),
                ),
                DatePickerBox(
                  initialDate: widget.editedDate,
                  backgroundColor: const Color.fromRGBO(255, 245, 225, 1),
                  foregroundColor: const Color.fromRGBO(12, 24, 68, 1),
                  isEnabled: false,
                  errorMessageWhenDisabled: 'Ngày chỉnh sửa đã bị vô hiệu hóa chỉnh sửa để đảm bảo tính toàn vẹn của dữ liệu',
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
