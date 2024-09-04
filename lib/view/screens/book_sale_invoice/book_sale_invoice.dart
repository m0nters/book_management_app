import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tuple/tuple.dart';
import 'package:untitled2/model/book_order.dart';
import '../../../controller/book_order_controller.dart';
import '../../../model/book.dart';
import '../../../model/customer.dart';
import '../../../repository/book_order_repository.dart';
import '../mutual_widgets.dart';
import 'book_sale_invoice_create_invoice.dart';
import 'book_sale_invoice_edit_history.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:diacritic/diacritic.dart';
import 'book_sale_invoice_search.dart';
import 'book_sale_invoice_widgets.dart';

// Fetch data from server to this list here
List<InvoiceData> dataList = [];

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
  bool hasFetched = false;

  @override
  void initState() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
    super.initState();
  }

  Future<void> _loadData() async {
    if (hasFetched) return;
    hasFetched = true;
    dataList.clear();

    final bookOrderController = BookOrderController(BookOrderRepository());
    final allBookOrders = await bookOrderController.getAllBookOrders();

    for (int i = 0; i < allBookOrders.length; ++i) {
      BookOrder invoiceForm = allBookOrders[i];
      String invoiceID = invoiceForm.orderID;
      Customer customer = invoiceForm.customer!;
      DateTime purchaseDate = invoiceForm.orderDate!;
      for (int j = 0; j < invoiceForm.bookList.length; ++j) {
        Tuple2<Book, int> pair = invoiceForm.bookList[j];
        Book entryBook = pair.item1;
        int entryQuantity = pair.item2;
        dataList.add(InvoiceData(
          invoiceID: invoiceID,
          customerName: customer.name,
          phoneNumber: customer.phoneNumber,
          bookName: entryBook.title,
          genres: entryBook.genres,
          authors: entryBook.authors,
          purchaseDate: purchaseDate,
          quantity: entryQuantity,
          price: entryBook.price as int,
        ));
      }
    }


    // Sort the data by date from the newest to oldest right from beginning
    sortDates(ascending: false);

    isHistoryEmpty = dataList.isEmpty;
  }

  void sortDates({required bool ascending}) {
    // sort rule
    // 1. date
    // 2. entry id
    // 3. book's name
    dataList.sort((a, b) {
      DateTime dateA = a.purchaseDate!;
      DateTime dateB = b.purchaseDate!;

      int dateComparison =
          ascending ? dateA.compareTo(dateB) : dateB.compareTo(dateA);
      if (dateComparison != 0) {
        return dateComparison;
      }

      String invoiceIDA = a.invoiceID!;
      String invoiceIDB = b.invoiceID!;
      int invoiceIDComparison = invoiceIDA.compareTo(invoiceIDB);
      if (invoiceIDComparison != 0) {
        return invoiceIDComparison;
      }

      String bookNameA = a.bookName!;
      String bookNameB = b.bookName!;
      return removeDiacritics(bookNameA)
          .compareTo(removeDiacritics(bookNameB));
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
                editedItem: dataItem));
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
                                      itemCount: dataList.length * 2,
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
