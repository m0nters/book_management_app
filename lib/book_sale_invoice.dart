import 'package:flutter/material.dart';
import 'mutual_widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'book_sale_invoice_create_invoice.dart';

class InvoiceData {
  final String invoiceCode;
  final String customerName;
  final String bookName;
  final String purchaseDate;
  final int quantity;
  final int price;

  InvoiceData({
    required this.invoiceCode,
    required this.customerName,
    required this.bookName,
    required this.purchaseDate,
    required this.quantity,
    required this.price,
  });

  // Method to convert to map for compatibility with InfoTicket
  Map<String, String> toMap() {
    return {
      'Mã hóa đơn': invoiceCode,
      'Tên khách hàng': customerName,
      'Tên sách': bookName,
      'Ngày mua': purchaseDate,
      'Số lượng': quantity.toString(),
      'Đơn giá': price.toString(),
    };
  }
}

// Fetch data from server to this list here
List<InvoiceData> dataList = [
  InvoiceData(
    invoiceCode: 'HĐ22541252',
    customerName: 'Trịnh Anh Tài',
    bookName: 'Chiến tranh tiền tệ',
    purchaseDate: '29/06/2024',
    quantity: 3,
    price: 155000,
  ),
  InvoiceData(
    invoiceCode: 'HĐ98242142',
    customerName: 'Trịnh Anh Tài',
    bookName: 'Mùa hè không tên',
    purchaseDate: '30/06/2024',
    quantity: 1,
    price: 184000,
  ),
  InvoiceData(
    invoiceCode: 'HĐ09284351',
    customerName: 'Nguyễn Đức Hưng',
    bookName: 'Mắt biếc',
    purchaseDate: '30/06/2024',
    quantity: 1,
    price: 434600,
  ),
  InvoiceData(
    invoiceCode: 'HĐ12098417',
    customerName: 'Trần Nhật Huy',
    bookName: 'Đám Trẻ Ở Đại Dương Đen',
    purchaseDate: '28/06/2024',
    quantity: 1,
    price: 74250,
  ),
  InvoiceData(
    invoiceCode: 'HĐ73249129',
    customerName: 'Nguyễn Quốc Thuần',
    bookName: 'Các Siêu Cường AI: Trung Quốc, Thung Lũng Silicon, Và Trật Tự Thế Giới Mới',
    purchaseDate: '29/06/2024',
    quantity: 1,
    price: 112000,
  ),
];

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
  static const String backgroundImageTicket = "assets/images/book_sale_invoice_ticket.png";

  Future<void> _loadData() async {
    // replace this line by the function where you fetch data from server

  }

  void sortDates(bool ascending) {
    dataList.sort((a, b) {
      DateTime dateA = DateTime.parse(
          '${a.purchaseDate.split('/')[2]}-${a.purchaseDate.split('/')[1]}-${a.purchaseDate.split('/')[0]}');
      DateTime dateB = DateTime.parse(
          '${b.purchaseDate.split('/')[2]}-${b.purchaseDate.split('/')[1]}-${b.purchaseDate.split('/')[0]}');

      int dateComparison =
      ascending ? dateA.compareTo(dateB) : dateB.compareTo(dateA);
      if (dateComparison != 0) {
        return dateComparison;
      } else {
        return a.customerName.compareTo(b.customerName);
      }
    });
    setState(() {});
  }

  List<Widget> buildContentColumn(List<InvoiceData> dataList) {
    return dataList.expand((dataItem) {
      return [
        BookSaleInvoiceInfoTicket(
          fields: dataItem.toMap().entries
              .map((entry) => {'title': entry.key, 'content': entry.value})
              .toList(),
          backgroundImage: backgroundImageTicket,
          onTap: () {},
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
                child: Column(
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
                    Expanded(
                      child: Material(
                        color: const Color.fromRGBO(241, 248,232, 1),
                        child: ListView.builder(
                          itemCount: buildContentColumn(dataList).length,
                          itemBuilder: (context, index) {
                            return buildContentColumn(dataList)[index];
                          },
                        ),
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
