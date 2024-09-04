import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:diacritic/diacritic.dart';
import 'package:tuple/tuple.dart';
import '../../../controller/goods_receipt_controller.dart';
import '../../../model/book.dart';
import '../../../model/goods_receipt.dart';
import '../../../repository/goods_receipt_repository.dart';
import '../mutual_widgets.dart';
import 'book_entry_form_create_form.dart';
import 'book_entry_form_edit_history.dart';
import 'book_entry_form_search.dart';
import 'book_entry_form_widgets.dart';

// Fetch data from server to this list here
List<EntryData> dataList = [];

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

    // Clear the dataList first to avoid duplication
    dataList.clear();

    final GoodsReceiptController goodsReceiptController =
        GoodsReceiptController(GoodsReceiptRepository());
    final allGoodsReceipts = await goodsReceiptController.getAllGoodsReceipts();

    for (int i = 0; i < allGoodsReceipts.length; ++i) {
      GoodsReceipt entryForm = allGoodsReceipts[i];
      String entryID = entryForm.receiptID;
      DateTime entryDate = entryForm.date;
      for (int j = 0; j < entryForm.bookList.length; ++j) {
        Tuple2<Book, int> pair = entryForm.bookList[j];
        Book entryBook = pair.item1;
        int entryQuantity = pair.item2;
        dataList.add(EntryData(
          entryID: entryID,
          bookID: entryBook.bookID,
          bookName: entryBook.title,
          genres: entryBook.genres,
          authors: entryBook.authors,
          quantity: entryQuantity,
          entryDate: entryDate,
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
      DateTime dateA = a.entryDate!;
      DateTime dateB = b.entryDate!;

      int dateComparison =
          ascending ? dateA.compareTo(dateB) : dateB.compareTo(dateA);
      if (dateComparison != 0) {
        return dateComparison;
      }

      String entryIDA = a.entryID!;
      String entryIDB = b.entryID!;
      int entryIDComparison = entryIDA.compareTo(entryIDB);
      if (entryIDComparison != 0) {
        return entryIDComparison;
      }

      return removeDiacritics(a.bookName!)
          .compareTo(removeDiacritics(b.bookName!));
    });
    setState(() {});
  }

  List<Widget> buildResultTicketsUI(List<EntryData> dataList) {
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
            widget.internalScreenContextSwitcher(BookEntryFormEditHistory(
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
          ),
        ),
        actions: [
          IconButton(
              onPressed: () {
                widget.internalScreenContextSwitcher(BookEntryFormSearch(
                  backContextSwitcher: widget.backContextSwitcher,
                  internalScreenContextSwitcher:
                      widget.internalScreenContextSwitcher,
                ));
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
                                  color: Color.fromRGBO(12, 24, 68, 1),
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
                                    itemCount: dataList.length * 2,
                                    // * 2 is for SizedBox
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
