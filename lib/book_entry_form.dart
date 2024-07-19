import 'package:flutter/material.dart';
import 'mutual_widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';

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
  {'title': title1, 'content': 'PNS9884712'},
  {'title': title2, 'content': 'Homo Deus - Lược Sử Tương Lai'},
  {'title': title3, 'content': 'Yuval Noah Harari'},
  {'title': title4, 'content': '29/06/2024'},
  {'title': title5, 'content': '12'},
];

// Add the content here
List<Widget> contentColumn = [
  BookEntryFormInfoTicket(
    fields: data1,
    backgroundImage: backgroundImageTicket,
    onTap: () {},
  ),
  const SizedBox(height: 24,),
  BookEntryFormInfoTicket(
    fields: data2,
    backgroundImage: backgroundImageTicket,
    onTap: () {},
  ),
  const SizedBox(height: 24,),
  BookEntryFormInfoTicket(
    fields: data3,
    backgroundImage: backgroundImageTicket,
    onTap: () {},
  ),
  const SizedBox(height: 24,),
  BookEntryFormInfoTicket(
    fields: data4,
    backgroundImage: backgroundImageTicket,
    onTap: () {},
  ),
  const SizedBox(height: 24,),
  BookEntryFormInfoTicket(
    fields: data4,
    backgroundImage: backgroundImageTicket,
    onTap: () {},
  ),
  const SizedBox(height: 24,),
  BookEntryFormInfoTicket(
    fields: data4,
    backgroundImage: backgroundImageTicket,
    onTap: () {},
  ),
  const SizedBox(height: 24,),
  BookEntryFormInfoTicket(
    fields: data4,
    backgroundImage: backgroundImageTicket,
    onTap: () {},
  ),
  const SizedBox(height: 24,),
  BookEntryFormInfoTicket(
    fields: data4,
    backgroundImage: backgroundImageTicket,
    onTap: () {},
  ),
];

/// Phiếu nhập sách
class BookEntryForm extends StatefulWidget {
  final VoidCallback mainScreenContextSwitcher;
  const BookEntryForm({super.key, required this.mainScreenContextSwitcher});

  @override
  State<BookEntryForm> createState() => _BookEntryFormState();
}

class _BookEntryFormState extends State<BookEntryForm> {
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
            widget.mainScreenContextSwitcher();
          },
          icon: const Icon(Icons.arrow_back),
          color: const Color.fromRGBO(12, 24, 68, 1),
        ),
        actions: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.add_circle)),
          IconButton(
              onPressed: () {},
              icon: const Icon(
                Icons.search,
                size: 29,
              )),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 0.0),
        child: ListView(
          children: [
            const SizedBox(height: 103),
            Center(
              child: CustomRoundedButton(
                backgroundColor: const Color.fromRGBO(255, 105, 105, 1),
                foregroundColor: const Color.fromRGBO(225, 227, 234, 1),
                title: "Lập mới",
                fontSize: 24,
                onPressed: () {},
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
                const SizedBox(width: 199),
                IconButton(
                  onPressed: () {},
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
                  onPressed: () {},
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
            Column(children: contentColumn,)
          ],
        ),
      ),
    );
  }
}

class BookEntryFormInfoTicket extends InfoTicket{
  const BookEntryFormInfoTicket({super.key, required super.fields, required super.backgroundImage, required super.onTap});
}