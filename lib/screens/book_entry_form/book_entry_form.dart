import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:diacritic/diacritic.dart';
import '../mutual_widgets.dart';
import 'book_entry_form_create_form.dart';
import 'book_entry_form_edit.dart';

class EntryDataForTicket {
  final String entryCode;
  final String bookName;
  final String genre;
  final String author;
  final String entryDate;
  final int quantity;

  EntryDataForTicket({
    required this.entryCode,
    required this.bookName,
    required this.genre,
    required this.author,
    required this.entryDate,
    required this.quantity,
  });

  // Method to convert to map for compatibility with InfoTicket
  Map<String, String> toMap() {
    return {
      'Mã phiếu': entryCode,
      'Sách': bookName,
      'Tác giả': author,
      'Ngày nhập': entryDate,
      'Số lượng': quantity.toString(),
    };
  }
}

class EntryDataForForm {
  String title;
  String category;
  String author;
  int quantity;

  EntryDataForForm({
    required this.title,
    required this.category,
    required this.author,
    required this.quantity,
  });
} // for book_entry_form_create_form.dart

// Fetch data from server to this list here
List<EntryDataForTicket> dataList = [
  EntryDataForTicket(
    entryCode: 'PNS0124512',
    bookName: 'Mắt biếc',
    genre: 'Truyện ngắn',
    author: 'Nguyễn Nhật Ánh',
    entryDate: '30/06/2024',
    quantity: 133,
  ),
  EntryDataForTicket(
    entryCode: 'PNS3252655',
    bookName: 'Thép đã tôi thế đấy',
    genre: 'Tiểu thuyết',
    author: 'Nikolai Ostrovsky',
    entryDate: '29/06/2024',
    quantity: 12,
  ),
  EntryDataForTicket(
    entryCode: 'PNS9884712',
    bookName: 'Homo Deus - Lược Sử Tương Lai',
    genre: 'Lịch sử',
    author: 'Yuval Noah Harari',
    entryDate: '29/06/2024',
    quantity: 12,
  ),
  EntryDataForTicket(
    entryCode: 'PNS2252363',
    bookName: 'Con chim xanh biếc bay về trời',
    genre: 'Truyện ngắn',
    author: 'Nguyễn Nhật Ánh',
    entryDate: '26/06/2024',
    quantity: 124,
  ),
  EntryDataForTicket(
    entryCode: 'PNS2252363',
    bookName: 'Chip War - Cuộc Chiến Vi Mạch',
    genre: 'Khoa học công nghệ',
    author: 'Chris Miller',
    entryDate: '26/06/2024',
    quantity: 12,
  ),
];

/// Phiếu nhập sách
class BookEntryForm extends StatefulWidget {
  final VoidCallback backContextSwitcher;
  final VoidCallback reloadContext;
  final Function(Widget) internalScreenContextSwitcher;

  const BookEntryForm(
      {super.key,
      required this.backContextSwitcher,
      required this.reloadContext,
      required this.internalScreenContextSwitcher});

  @override
  State<BookEntryForm> createState() => _BookEntryFormState();
}

class _BookEntryFormState extends State<BookEntryForm> {
  static const String backgroundImageTicket =
      "assets/images/book_entry_form_ticket.png";
  bool isHistoryEmpty = dataList.isEmpty ? true : false;

  Future<void> _loadData() async {
    // replace this line by the function where you fetch data from server
  }

  void sortDates({required bool ascending}) {
    // sort date => if dates equal, sort books' names
    dataList.sort((a, b) {
      DateTime dateA = DateTime.parse(
          '${a.entryDate.split('/')[2]}-${a.entryDate.split('/')[1]}-${a.entryDate.split('/')[0]}');
      DateTime dateB = DateTime.parse(
          '${b.entryDate.split('/')[2]}-${b.entryDate.split('/')[1]}-${b.entryDate.split('/')[0]}');

      int dateComparison =
          ascending ? dateA.compareTo(dateB) : dateB.compareTo(dateA);
      if (dateComparison != 0) {
        return dateComparison;
      } else {
        return removeDiacritics(a.bookName)
            .compareTo(removeDiacritics(b.bookName));
      }
    });
    setState(() {});
  }

  List<Widget> buildResultTicketsUI(List<EntryDataForTicket> dataList) {
    return dataList.expand((dataItem) {
      return [
        BookEntryFormInfoTicket(
          fields: dataItem
              .toMap()
              .entries
              .map((entry) => {'title': entry.key, 'content': entry.value})
              .toList(),
          backgroundImage: backgroundImageTicket,
          onTap: () {
            widget.internalScreenContextSwitcher(BookEntryFormEdit(
              backContextSwitcher: widget.backContextSwitcher,
              reloadContext: widget.reloadContext,
              editItem: dataItem,
            ));
          },
        ),
        const SizedBox(height: 24),
      ];
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(225, 227, 234, 1),
      appBar: AppBar(
        backgroundColor: const Color.fromRGBO(225, 227, 234, 1),
        foregroundColor: const Color.fromRGBO(12, 24, 68, 1),
        title: const Text(
          "Phiếu nhập sách",
          style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Color.fromRGBO(12, 24, 68, 1)),
        ),
      ),
      body: FutureBuilder(
        future: _loadData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(
                  color: Color.fromRGBO(255, 105, 105, 1)),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          } else {
            return Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 0.0),
              child: Column(
                children: <Widget>[
                  Expanded(
                      flex: 2,
                      child: Column(
                        children: [
                          const Spacer(),
                          Center(
                            child: CustomRoundedButton(
                              backgroundColor:
                                  const Color.fromRGBO(255, 105, 105, 1),
                              foregroundColor:
                                  const Color.fromRGBO(225, 227, 234, 1),
                              title: "Lập mới",
                              fontSize: 24,
                              onPressed: () {
                                widget.internalScreenContextSwitcher(
                                  BookEntryFormCreateForm(
                                    backContextSwitcher:
                                        widget.backContextSwitcher,
                                  ),
                                );
                              },
                            ),
                          ),
                          const Spacer(),
                        ],
                      )),
                  Expanded(
                    flex: 3,
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              'Lịch sử',
                              style: TextStyle(
                                  fontSize: 22,
                                  color: Color.fromRGBO(12, 24, 68, 1)),
                            ),
                            const Spacer(),
                            Row(
                              children: isHistoryEmpty
                                  ? []
                                  : [
                                      IconButton(
                                        onPressed: () {
                                          sortDates(ascending: false);
                                        },
                                        icon: Tooltip(
                                          message: 'Mới đến cũ',
                                          child: SvgPicture.asset(
                                            'assets/icons/new_to_old_1.svg',
                                            width: 30,
                                            height: 30,
                                          ),
                                        ),
                                      ),
                                      IconButton(
                                        onPressed: () {
                                          sortDates(ascending: true);
                                        },
                                        icon: Tooltip(
                                          message: 'Cũ đến mới',
                                          child: SvgPicture.asset(
                                            'assets/icons/old_to_new_1.svg',
                                            width: 30,
                                            height: 30,
                                          ),
                                        ),
                                      ),
                                    ],
                            )
                          ],
                        ),
                        const SizedBox(height: 15),
                        Expanded(
                          child: isHistoryEmpty
                              ? const NotFound(
                                  paddingTop: 50,
                                  paddingLeft: 20,
                                )
                              : Material(
                                  color: const Color.fromRGBO(225, 227, 234, 1),
                                  child: ListView.builder(
                                    itemCount:
                                        buildResultTicketsUI(dataList).length,
                                    itemBuilder: (context, index) {
                                      return buildResultTicketsUI(
                                          dataList)[index];
                                    },
                                  ),
                                ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }
        },
      ),
    );
  }
}

class BookEntryFormInfoTicket extends InfoTicket {
  // Basically nothing has changed, this is just a form, to synchronize with book_sale_invoice.dart
  const BookEntryFormInfoTicket(
      {super.key,
      required super.fields,
      required super.backgroundImage,
      required super.onTap});
}
