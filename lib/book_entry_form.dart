import 'package:flutter/material.dart';
import 'mutual_widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'book_entry_form_create_form.dart';

const String title1 = "Mã phiếu";
const String title2 = "Sách";
const String title3 = "Tác giả";
const String title4 = "Ngày nhập";
const String title5 = "Số lượng";

const String backgroundImageTicket = "assets/images/book_entry_form_ticket.png";

// HARD CODE PLACEHOLDER, JUST FOR PREVIEW
// IN FUTURE DEVELOPMENT STAGE, IMPORT IT SOMEHOW FROM THE DATABASE
const List<Map<String, String>> data1 = [
  {'title': title1, 'content': 'PNS0124512'},
  {'title': title2, 'content': 'Mắt biếc'},
  {'title': title3, 'content': 'Nguyễn Nhật Ánh'},
  {'title': title4, 'content': '30/06/2024'},
  {'title': title5, 'content': '133'},
];

const List<Map<String, String>> data2 = [
  {'title': title1, 'content': 'PNS3252655'},
  {'title': title2, 'content': 'Thép đã tôi thế đấy'},
  {'title': title3, 'content': 'Nikolai Ostrovsky'},
  {'title': title4, 'content': '29/06/2024'},
  {'title': title5, 'content': '12'},
];

const List<Map<String, String>> data3 = [
  {'title': title1, 'content': 'PNS9884712'},
  {'title': title2, 'content': 'Homo Deus - Lược Sử Tương Lai'},
  {'title': title3, 'content': 'Yuval Noah Harari'},
  {'title': title4, 'content': '29/06/2024'},
  {'title': title5, 'content': '12'},
];

const List<Map<String, String>> data4 = [
  {'title': title1, 'content': 'PNS2252363'},
  {'title': title2, 'content': 'Con chim xanh biếc bay về trời'},
  {'title': title3, 'content': 'Nguyễn Nhật Ánh'},
  {'title': title4, 'content': '26/06/2024'},
  {'title': title5, 'content': '124'},
];

const List<Map<String, String>> data5 = [
  {'title': title1, 'content': 'PNS2252363'},
  {'title': title2, 'content': 'Chip War - Cuộc Chiến Vi Mạch'},
  {'title': title3, 'content': 'Chris Miller'},
  {'title': title4, 'content': '26/06/2024'},
  {'title': title5, 'content': '12'},
];

// Fetch data from server to this list here
List<List<Map<String, String>>> dataList = [
  data1,
  data5,
  data4,
  data2,
  data3,
]; // prove that the data will always be sorted at the beginning, regardless of the input order

List<Widget> buildContentColumn(List<List<Map<String, String>>> dataList) {
  return dataList.expand((dataItem) {
    return [
      BookEntryFormInfoTicket(
        fields: dataItem,
        backgroundImage: backgroundImageTicket,
        onTap: () {},
      ),
      const SizedBox(height: 24),
    ];
  }).toList();
}

/// Phiếu nhập sách
class BookEntryForm extends StatefulWidget {
  final VoidCallback backContextSwitcher;
  final Function(Widget) internalScreenContextSwitcher;

  const BookEntryForm(
      {super.key,
      required this.backContextSwitcher,
      required this.internalScreenContextSwitcher});

  @override
  State<BookEntryForm> createState() => _BookEntryFormState();
}

class _BookEntryFormState extends State<BookEntryForm> {
  Future<void> _loadData() async {
    // replace this line by the function where you fetch data from server

  }

  void sortDates(bool ascending) {
    dataList.sort((a, b) {
      DateTime dateA = DateTime.parse(
          '${a[3]['content']!.split('/')[2]}-${a[3]['content']!.split('/')[1]}-${a[3]['content']!.split('/')[0]}');
      DateTime dateB = DateTime.parse(
          '${b[3]['content']!.split('/')[2]}-${b[3]['content']!.split('/')[1]}-${b[3]['content']!.split('/')[0]}');

      int dateComparison =
          ascending ? dateA.compareTo(dateB) : dateB.compareTo(dateA);
      if (dateComparison != 0) {
        return dateComparison;
      } else {
        String bookNameA = a[1]['content']!;
        String bookNameB = b[1]['content']!;
        return bookNameA.compareTo(bookNameB);
      }
    });
    setState(() {});
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
        actions: [
          IconButton(
              onPressed: () {
                widget.internalScreenContextSwitcher(BookEntryFormCreateForm(
                    backContextSwitcher: widget.backContextSwitcher));
              },
              icon: const Icon(Icons.add_circle)),
          IconButton(
              onPressed: () {},
              icon: const Icon(
                Icons.search,
                size: 29,
              )),
        ],
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
              child: ListView(
                children: <Widget>[
                  const SizedBox(height: 103),
                  Center(
                    child: CustomRoundedButton(
                      backgroundColor: const Color.fromRGBO(255, 105, 105, 1),
                      foregroundColor: const Color.fromRGBO(225, 227, 234, 1),
                      title: "Lập mới",
                      fontSize: 24,
                      onPressed: () {
                        widget.internalScreenContextSwitcher(
                            BookEntryFormCreateForm(
                                backContextSwitcher:
                                    widget.backContextSwitcher));
                      },
                    ),
                  ),
                  const SizedBox(height: 103),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Lịch sử',
                        style: TextStyle(
                            fontSize: 22, color: Color.fromRGBO(12, 24, 68, 1)),
                      ),
                      const Spacer(),
                      IconButton(
                        onPressed: () {
                          sortDates(false);
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
                          sortDates(true);
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
                  ),
                  const SizedBox(height: 24),
                  Column(
                    children: buildContentColumn(dataList),
                  )
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
  const BookEntryFormInfoTicket(
      {super.key,
      required super.fields,
      required super.backgroundImage,
      required super.onTap});
}
