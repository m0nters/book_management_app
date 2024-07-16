import 'package:flutter/material.dart';
import 'main_screen_context_controller.dart';
import 'mutual_widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';

const String title1 = "Mã hóa đơn";
const String title2 = "Tên khách hàng";
const String title3 = "Ngày mua";
const String title4 = "Tên sách";
const String title5 = "Số lượng";
const String title6 = "Đơn giá";

const String backgroundImageTicket = "assets/images/book_sale_invoice_ticket.png";

// HARD CODE PLACEHOLDER, JUST FOR PREVIEW
// IN FUTURE DEVELOPMENT STAGE, IMPORT IT SOMEHOW FROM THE DATABASE
const List<Map<String, String>> data1 = [
  {'title': title1, 'content': 'HĐ09284351'},
  {'title': title2, 'content': 'Trịnh Anh Tài'},
  {'title': title3, 'content': '30/06/2024'},
  {'title': title4, 'content': 'Mắt biếc'},
  {'title': title5, 'content': '1'},
  {'title': title6, 'content': '434.600 VND'},
];
const List<Map<String, String>> data2 = [
  {'title': title1, 'content': 'HĐ98242142'},
  {'title': title2, 'content': 'Trịnh Anh Tài'},
  {'title': title3, 'content': '30/06/2024'},
  {'title': title4, 'content': 'Mùa hè không tên'},
  {'title': title5, 'content': '1'},
  {'title': title6, 'content': '184.000 VND'},
];
const List<Map<String, String>> data3 = [
  {'title': title1, 'content': 'HĐ12098417'},
  {'title': title2, 'content': 'Trần Nhật Huy'},
  {'title': title3, 'content': '30/06/2024'},
  {'title': title4, 'content': 'Đám Trẻ Ở Đại Dương Đen'},
  {'title': title5, 'content': '1'},
  {'title': title6, 'content': '74.250 VND'},
];
const List<Map<String, String>> data4 = [
  {'title': title1, 'content': 'HĐ73249129'},
  {'title': title2, 'content': 'Nguyễn Quốc Thuần'},
  {'title': title3, 'content': '29/06/2024'},
  {'title': title4, 'content': 'Các Siêu Cường AI: Trung Quốc, Thung Lũng Silicon, Và Trật Tự Thế Giới Mới'},
  {'title': title5, 'content': '1'},
  {'title': title6, 'content': '112.000 VND'},
];




// Add the content here
List<Widget> contentColumn = [
  BookSaleInvoiceInfoTicket(
    fields: data1,
    backgroundImage: backgroundImageTicket,
    onTap: () {},
  ),
  const SizedBox(height: 24),
  BookSaleInvoiceInfoTicket(
    fields: data2,
    backgroundImage: backgroundImageTicket,
    onTap: () {},
  ),
  const SizedBox(height: 24),
  BookSaleInvoiceInfoTicket(
    fields: data3,
    backgroundImage: backgroundImageTicket,
    onTap: () {},
  ),
  const SizedBox(height: 24),
  BookSaleInvoiceInfoTicket(
    fields: data4,
    backgroundImage: backgroundImageTicket,
    onTap: () {},
  ),
  const SizedBox(height: 24),
  BookSaleInvoiceInfoTicket(
    fields: data4,
    backgroundImage: backgroundImageTicket,
    onTap: () {},
  ),
  const SizedBox(height: 24),
  BookSaleInvoiceInfoTicket(
    fields: data4,
    backgroundImage: backgroundImageTicket,
    onTap: () {},
  ),
  const SizedBox(height: 24),
  BookSaleInvoiceInfoTicket(
    fields: data4,
    backgroundImage: backgroundImageTicket,
    onTap: () {},
  ),
  const SizedBox(height: 24),
  BookSaleInvoiceInfoTicket(
    fields: data4,
    backgroundImage: backgroundImageTicket,
    onTap: () {},
  ),
];

/// Hóa đơn bán sách
class BookSaleInvoice extends StatefulWidget{
  final VoidCallback mainScreenContextSwitcher;
  const BookSaleInvoice({super.key, required this.mainScreenContextSwitcher});

  @override
  State<BookSaleInvoice> createState() => _BookSaleInvoiceState();
}

class _BookSaleInvoiceState extends State<BookSaleInvoice> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(241, 248, 232, 1),
      appBar: AppBar(
        backgroundColor: const Color.fromRGBO(241, 248, 232, 1),
        foregroundColor: const Color.fromRGBO(120, 171, 168, 1),
        title: const Text("Hóa đơn bán sách", style: TextStyle(fontWeight: FontWeight.w400, color: Color.fromRGBO(120, 171, 168, 1)),),
        leading: IconButton(onPressed: (){
          widget.mainScreenContextSwitcher();
        }, icon: const Icon(Icons.arrow_back), color: const Color.fromRGBO(120, 171, 168, 1),),
        actions: [
          IconButton(onPressed: (){}, icon: const Icon(Icons.add_circle)),
          IconButton(onPressed: (){}, icon: const Icon(Icons.search,size: 29,)),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 0.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 103),
              Center(
                child: CustomRoundedButton(
                  backgroundColor: const Color.fromRGBO(239, 156, 102, 1),
                  foregroundColor: const Color.fromRGBO(241, 248, 232, 1),
                  title: "Lập mới",
                  fontSize: 24,
                  onPressed: () {},
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
                            fontSize: 22, color: Color.fromRGBO(120, 171, 168, 1)),
                      ),
                      const SizedBox(width: 199),
                      IconButton(
                        onPressed: () {},
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
                        onPressed: () {},
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
                  Column(children: contentColumn),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class BookSaleInvoiceInfoTicket extends InfoTicket{
  const BookSaleInvoiceInfoTicket({super.key, required super.fields, required super.backgroundImage, required super.onTap});

  @override
  // TODO: implement titleColor
  Color get titleColor => const Color.fromRGBO(252, 220, 148, 1);
  @override
  // TODO: implement contentColor
  Color get contentColor => const Color.fromRGBO(241, 248, 232, 1);
}