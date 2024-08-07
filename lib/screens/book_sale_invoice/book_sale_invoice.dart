import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:untitled2/screens/book_sale_invoice/book_sale_invoice_search.dart';
import '../mutual_widgets.dart';
import 'book_sale_invoice_create_invoice.dart';
import 'book_sale_invoice_edit_history.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:diacritic/diacritic.dart';
import 'book_sale_invoice_widgets.dart';

// Fetch data from server to this list here
List<InvoiceData> dataList = [
  InvoiceData(
    invoiceCode: 'HĐ98242142',
    customerName: 'Trịnh Anh Tài',
    bookName: 'Mùa hè không tên',
    genre: "Tiểu thuyết",
    purchaseDate: stdDateFormat.parse('30/06/2024'),
    quantity: 1,
    price: 184000,
  ),
  InvoiceData(
    invoiceCode: 'HĐ22541252',
    customerName: 'Trịnh Anh Tài',
    bookName: 'Chiến tranh tiền tệ',
    genre: "Kinh tế",
    purchaseDate: stdDateFormat.parse('30/06/2024'),
    quantity: 3,
    price: 155000,
  ),
  InvoiceData(
    invoiceCode: 'HĐ09284351',
    customerName: 'Nguyễn Đức Hưng',
    bookName: 'Mắt biếc',
    genre: 'Truyện ngắn',
    purchaseDate: stdDateFormat.parse('30/06/2024'),
    quantity: 1,
    price: 434600,
  ),
  InvoiceData(
    invoiceCode: 'HĐ12098417',
    customerName: 'Trần Nhật Huy',
    bookName: 'Đám Trẻ Ở Đại Dương Đen',
    genre: 'Tiểu thuyết',
    purchaseDate: stdDateFormat.parse('28/06/2024'),
    quantity: 1,
    price: 74250,
  ),
  InvoiceData(
    invoiceCode: 'HĐ73249129',
    customerName: 'Nguyễn Quốc Thuần',
    bookName:
        'Các Siêu Cường AI: Trung Quốc, Thung Lũng Silicon, Và Trật Tự Thế Giới Mới',
    genre: 'Kinh tế',
    purchaseDate: stdDateFormat.parse('29/06/2024'),
    quantity: 1,
    price: 112000,
  ),
];

/// Hóa đơn bán sách
class BookSaleInvoice extends StatefulWidget {
  final VoidCallback backContextSwitcher;
  final VoidCallback reloadContext;
  final Function(Widget) internalScreenContextSwitcher;

  const BookSaleInvoice(
      {super.key,
      required this.backContextSwitcher,
      required this.reloadContext,
      required this.internalScreenContextSwitcher});

  @override
  State<BookSaleInvoice> createState() => _BookSaleInvoiceState();
}

class _BookSaleInvoiceState extends State<BookSaleInvoice> {
  static const String backgroundImageTicket =
      "assets/images/book_sale_invoice_ticket.png";
  bool isHistoryEmpty = dataList.isEmpty ? true : false;

  @override
  void initState() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
    super.initState();
  }

  Future<void> _loadData() async {
    // replace this line by the function where you fetch data from server
  }

  void sortDates({required bool ascending}) {
    // sort date => if dates equal, sort customers' names => if they are equal, sort books' names
    dataList.sort((a, b) {
      DateTime dateA = a.purchaseDate!;
      DateTime dateB = b.purchaseDate!;

      int dateComparison =
          ascending ? dateA.compareTo(dateB) : dateB.compareTo(dateA);
      if (dateComparison != 0) {
        return dateComparison;
      } else {
        int customerNameComparison = removeDiacritics(a.customerName!)
            .compareTo(removeDiacritics(b.customerName!));
        if (customerNameComparison != 0) {
          return customerNameComparison;
        } else {
          return removeDiacritics(a.bookName!)
              .compareTo(removeDiacritics(b.bookName!));
        }
      }
    });
    setState(() {});
  }

  List<Widget> buildResultTicketsUI(List<InvoiceData> dataList) {
    return dataList.expand((dataItem) {
      return [
        BookSaleInvoiceInfoTicket(
          fields: dataItem
              .toMap()
              .entries
              .map((entry) => {'title': entry.key, 'content': entry.value})
              .toList(),
          backgroundImage: backgroundImageTicket,
          onTap: () {
            widget.internalScreenContextSwitcher(BookSaleInvoiceEditHistory(
                backContextSwitcher: widget.backContextSwitcher,
                reloadContext: widget.reloadContext,
                editItem: dataItem));
          },
        ),
        const SizedBox(height: 24),
      ];
    }).toList();
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
              fontWeight: FontWeight.bold,
            ),
          ),
          actions: [
            IconButton(
                onPressed: () {
                  widget.internalScreenContextSwitcher(BookSaleInvoiceSearch(
                      backContextSwitcher: widget.backContextSwitcher,
                      internalScreenContextSwitcher:
                          widget.internalScreenContextSwitcher));
                },
                icon: const Icon(
                  Icons.search_rounded,
                  size: 30,
                ))
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
                child: Column(
                  children: [
                    Expanded(
                        flex: 2,
                        child: Column(
                          children: [
                            const Spacer(),
                            Center(
                              child: CustomRoundedButton(
                                backgroundColor:
                                    const Color.fromRGBO(239, 156, 102, 1),
                                foregroundColor:
                                    const Color.fromRGBO(241, 248, 232, 1),
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
                                    color: Color.fromRGBO(120, 171, 168, 1),
                                    fontWeight: FontWeight.bold),
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
                                              'assets/icons/new_to_old_2.svg',
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
                                              'assets/icons/old_to_new_2.svg',
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
                                ? NotFound(
                                    color: Colors.grey[500],
                                    paddingTop: 50,
                                    paddingLeft: 20,
                                  )
                                : Material(
                                    color:
                                        const Color.fromRGBO(241, 248, 232, 1),
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
        ));
  }
}
