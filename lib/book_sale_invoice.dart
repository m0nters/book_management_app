import 'package:flutter/material.dart';
import 'package:untitled2/advanced_search.dart';
import 'mutual_widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'book_sale_invoice_create_invoice.dart';

const String title1 = "Mã hóa đơn";
const String title2 = "Tên khách hàng";
const String title3 = "Tên sách";
const String title4 = "Ngày mua";
const String title5 = "Số lượng";
const String title6 = "Đơn giá";

const String backgroundImageTicket =
    "assets/images/book_sale_invoice_ticket.png";

// HARD CODE PLACEHOLDER, JUST FOR PREVIEW
// IN FUTURE DEVELOPMENT STAGE, IMPORT IT SOMEHOW FROM THE DATABASE
const List<Map<String, String>> data1 = [
  {'title': title1, 'content': 'HĐ09284351'},
  {'title': title2, 'content': 'Nguyễn Đức Hưng'},
  {'title': title3, 'content': 'Mắt biếc'},
  {'title': title4, 'content': '30/06/2024'},
  {'title': title5, 'content': '1'},
  {'title': title6, 'content': '434.600 VND'},
];
const List<Map<String, String>> data2 = [
  {'title': title1, 'content': 'HĐ98242142'},
  {'title': title2, 'content': 'Trịnh Anh Tài'},
  {'title': title3, 'content': 'Mùa hè không tên'},
  {'title': title4, 'content': '30/06/2024'},
  {'title': title5, 'content': '1'},
  {'title': title6, 'content': '184.000 VND'},
];
const List<Map<String, String>> data3 = [
  {'title': title1, 'content': 'HĐ12098417'},
  {'title': title2, 'content': 'Trần Nhật Huy'},
  {'title': title3, 'content': 'Đám Trẻ Ở Đại Dương Đen'},
  {'title': title4, 'content': '28/06/2024'},
  {'title': title5, 'content': '1'},
  {'title': title6, 'content': '74.250 VND'},
];
const List<Map<String, String>> data4 = [
  {'title': title1, 'content': 'HĐ73249129'},
  {'title': title2, 'content': 'Nguyễn Quốc Thuần'},
  {
    'title': title3,
    'content':
        'Các Siêu Cường AI: Trung Quốc, Thung Lũng Silicon, Và Trật Tự Thế Giới Mới'
  },
  {'title': title4, 'content': '29/06/2024'},
  {'title': title5, 'content': '1'},
  {'title': title6, 'content': '112.000 VND'},
];
const List<Map<String, String>> data5 = [
  {'title': title1, 'content': 'HĐ22541252'},
  {'title': title2, 'content': 'Trịnh Anh Tài'},
  {'title': title3, 'content': 'Chiến tranh tiền tệ'},
  {'title': title4, 'content': '29/06/2024'},
  {'title': title5, 'content': '3'},
  {'title': title6, 'content': '155.000 VND'},
];

// Fetch data from server to this list here
List<List<Map<String, String>>> dataList = [
  data5,
  data2,
  data1,
  data3,
  data4
]; // prove that the data will always be sorted at the beginning, regardless of the input order

List<Widget> buildContentColumn(List<List<Map<String, String>>> dataList) {
  return dataList.expand((dataItem) {
    return [
      BookSaleInvoiceInfoTicket(
        fields: dataItem,
        backgroundImage: backgroundImageTicket,
        onTap: () {},
      ),
      const SizedBox(height: 24),
    ];
  }).toList();
}

/// Hóa đơn bán sách
class BookSaleInvoice extends StatefulWidget {
  final VoidCallback backContextSwitcher;
  final Function(Widget) internalScreenContextSwitcher;

  const BookSaleInvoice(
      {super.key,
      required this.backContextSwitcher,
      required this.internalScreenContextSwitcher});

  @override
  State<BookSaleInvoice> createState() => _BookSaleInvoiceState();
}

class _BookSaleInvoiceState extends State<BookSaleInvoice> {
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
        backgroundColor: const Color.fromRGBO(241, 248, 232, 1),
        appBar: AppBar(
          backgroundColor: const Color.fromRGBO(241, 248, 232, 1),
          foregroundColor: const Color.fromRGBO(120, 171, 168, 1),
          title: const Text(
            "Hóa đơn bán sách",
            style: TextStyle(
                fontWeight: FontWeight.w400,
                color: Color.fromRGBO(120, 171, 168, 1)),
          ),
          leading: IconButton(
            onPressed: () {
              widget.backContextSwitcher();
            },
            icon: const Icon(Icons.arrow_back),
            color: const Color.fromRGBO(120, 171, 168, 1),
          ),
          actions: [
            IconButton(
                onPressed: () {
                  widget.internalScreenContextSwitcher(
                      BookSaleInvoiceCreateInvoice(
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
                  color: Color.fromRGBO(239, 156, 102, 1),
                ),
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
                  children: [
                    const SizedBox(height: 103),
                    Center(
                      child: CustomRoundedButton(
                        backgroundColor: const Color.fromRGBO(239, 156, 102, 1),
                        foregroundColor: const Color.fromRGBO(241, 248, 232, 1),
                        title: "Lập mới",
                        fontSize: 24,
                        onPressed: () {
                          widget.internalScreenContextSwitcher(
                              BookSaleInvoiceCreateInvoice(
                                  backContextSwitcher:
                                      widget.backContextSwitcher));
                        },
                      ),
                    ),
                    const SizedBox(height: 103),
                    Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              'Lịch sử',
                              style: TextStyle(
                                  fontSize: 22,
                                  color: Color.fromRGBO(120, 171, 168, 1)),
                            ),
                            const Spacer(),
                            IconButton(
                              onPressed: () {
                                sortDates(false);
                              },
                              icon: Tooltip(
                                message: 'Mới đến cũ',
                                child: SvgPicture.asset(
                                  'assets/icons/new_to_old_2.svg',
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
                                  'assets/icons/old_to_new_2.svg',
                                  width: 30,
                                  height: 30,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        Column(children: buildContentColumn(dataList)),
                      ],
                    ),
                  ],
                ),
              );
            }
          },
        ));
  }
}

class BookSaleInvoiceInfoTicket extends InfoTicket {
  const BookSaleInvoiceInfoTicket(
      {super.key,
      required super.fields,
      required super.backgroundImage,
      required super.onTap});

  @override
  Color get titleColor => const Color.fromRGBO(252, 220, 148, 1);

  @override
  Color get contentColor => const Color.fromRGBO(241, 248, 232, 1);
}
