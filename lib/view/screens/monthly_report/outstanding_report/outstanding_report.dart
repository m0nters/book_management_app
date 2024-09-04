import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:month_year_picker/month_year_picker.dart';
import 'package:expandable/expandable.dart';
import 'package:dotted_line/dotted_line.dart';
import 'package:untitled2/controller/book_controller.dart';
import '../../../../model/book.dart';
import '../../../../repository/book_repository.dart';
import '../debt_report/debt_report.dart';

class OutstandingReport extends StatefulWidget {
  final VoidCallback backContextSwitcher;
  final VoidCallback reloadContext;
  final Function(Widget) internalScreenContextSwitcher;
  final DateTime? debtSelectedDate;
  final DateTime? outstandingSelectedDate;
  final List<Map<String, dynamic>> initialMonthlyCustomerStock;
  final List<Map<String, dynamic>> initialMonthlyBookStock;

  const OutstandingReport({
    super.key,
    required this.backContextSwitcher,
    required this.internalScreenContextSwitcher,
    required this.reloadContext,
    this.debtSelectedDate,
    this.outstandingSelectedDate,
    this.initialMonthlyCustomerStock = const [],
    this.initialMonthlyBookStock = const [],
  });

  @override
  State<StatefulWidget> createState() => _OutstandingReportState();
}

class _OutstandingReportState extends State<OutstandingReport> {
  DateTime? selectedDate;
  bool isSearchVisible = false;
  bool isLoading = false;

  TextEditingController searchController = TextEditingController();
  late final BookController bookController;
  late List<Book> allBooks = [];
  late List<Map<String, dynamic>> monthlyBookStock = [];
  late List<Map<String, dynamic>> filteredBookStock = [];

  @override
  void initState() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
    super.initState();

    BookRepository bookRepository = BookRepository();
    bookController = BookController(bookRepository);

    selectedDate = widget.outstandingSelectedDate;
    monthlyBookStock = List.from(widget.initialMonthlyBookStock);
    filteredBookStock = List.from(monthlyBookStock);

    searchController.addListener(() {
      setState(() {
        filterBookStock();
      });
    });
  }

  Future<void> generateMonthlyStockReports () async {
    if (selectedDate == null) return;

    setState(() {
      isLoading = true; // Bắt đầu hiển thị loading screen
    });

    try {
      allBooks = await bookController.getAllBooks();
      monthlyBookStock.clear();

      final reports = await bookController.getMonthlyStockReport(allBooks, selectedDate!);
      for (var report in reports) {
        final stockData = {
          'masach': report.item1.bookID,
          'tensach': report.item1.title,
          'tacgia': report.item1.authors,
          'tondau': report.item2.item1,
          'phatsinhnhap': report.item2.item2,
          'phatsinhxuat': report.item2.item3,
          'toncuoi': report.item2.item4,
        };
        setState(() {
          monthlyBookStock.add(stockData);
          filterBookStock();
        });
      }
    } catch (e) {
      print('Error generating monthly stock reports: $e');
    } finally {
      setState(() {
        isLoading = false; // Ẩn loading screen khi hoàn thành
      });
    }
  }


  void filterBookStock() {
    final query = searchController.text.toLowerCase();
    filteredBookStock = monthlyBookStock.where((book) {
      final name = book['tensach'].toString().toLowerCase();
      return name.contains(query);
    }).toList();
  }

  Future<void> _pickDate({required BuildContext context}) async {
    final selected = await showMonthYearPicker(
      context: context,
      initialDate: selectedDate ?? DateTime.now(),
      firstDate: DateTime(2004),
      lastDate: DateTime(2030),
    );
    if (selected != null) {
      setState(() {
        selectedDate = selected;
        generateMonthlyStockReports();
      });
    }
  }

  Widget notFound() {
    return Container(
      width: double.maxFinite,
      child: const SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: 120),
            Icon(Icons.search_off, color: Colors.grey, size: 200),
            Text('Chưa có tìm kiếm nào được thực hiện, vui lòng nhập tháng năm',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey, fontFamily: 'archivo')),
          ],
        ),
      ),
    );
  }

  Widget list() {
    return Padding(
      padding: const EdgeInsets.only(left: 5, right: 5, top: 50),
      child: Stack(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                decoration: const BoxDecoration(
                  color: Color(0xFF050C9C),
                  borderRadius: BorderRadius.only(
                    topRight: Radius.circular(10),
                    bottomRight: Radius.circular(10),
                  ),
                ),
                width: 144,
                height: 64,
                child: Padding(
                  padding: const EdgeInsets.only(left: 5, top: 8),
                  child: Text(
                    'Tháng ${selectedDate!.month}, ${selectedDate!.year}',
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w400),
                  ),
                ),
              ),
            ],
          ),
          Positioned(
            top: 40,
            left: 0,
            right: 0,
            bottom: 0,
            child: ListView.builder(
              itemCount: filteredBookStock.length,
              itemBuilder: (BuildContext context, int index) {
                return Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: const Color(0xFFFCFFEB),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.5),
                        spreadRadius: 5,
                        blurRadius: 7,
                        offset: Offset(0, 3),
                      )
                    ],
                  ),
                  margin: const EdgeInsets.only(bottom: 20),
                  height: 93,
                  child: Column(
                    children: [
                      const Padding(
                        padding: EdgeInsets.only(top: 5),
                        child: Padding(
                          padding: EdgeInsets.only(left: 5, right: 5),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Text('Mã sách', textAlign: TextAlign.left),
                              ),
                              Expanded(
                                child: Text('Tên sách', textAlign: TextAlign.center),
                              ),
                              Expanded(
                                child: Text('Tác giả', textAlign: TextAlign.right),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 5, right: 5),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Text(
                                '${filteredBookStock[index]['masach']}',
                                textAlign: TextAlign.left,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(color: Color(0xFF858585)),
                              ),
                            ),
                            Expanded(
                              child: Text(
                                '${filteredBookStock[index]['tensach']}',
                                textAlign: TextAlign.center,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(color: Color(0xFF858585)),
                              ),
                            ),
                            Expanded(
                              child: Text(
                                '${filteredBookStock[index]['tacgia']}',
                                textAlign: TextAlign.right,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(color: Color(0xFF858585)),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.only(left: 5, right: 5),
                        child: DottedLine(
                          dashLength: 10,
                          dashGapLength: 10,
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.only(top: 5),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              flex: 1,
                              child: Padding(
                                padding: EdgeInsets.only(left: 5),
                                child: Text('Tồn đầu'),
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: Text('Phát sinh nhập', textAlign: TextAlign.center),
                            ),
                            Expanded(
                              flex: 2,
                              child: Text('Phát sinh xuất', textAlign: TextAlign.center),
                            ),
                            Expanded(
                              flex: 1,
                              child: Padding(
                                padding: EdgeInsets.only(right: 5),
                                child: Text('Tồn cuối', textAlign: TextAlign.right),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 1,
                            child: Padding(
                              padding: EdgeInsets.only(left: 5),
                              child: Text('${filteredBookStock[index]['tondau']}',
                                  style: const TextStyle(color: Color(0xFF858585), overflow: TextOverflow.ellipsis)),
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: Text('${filteredBookStock[index]['phatsinhnhap']}',
                                textAlign: TextAlign.center,
                                style: const TextStyle(color: Color(0xFF858585), overflow: TextOverflow.ellipsis)),
                          ),
                          Expanded(
                            flex: 2,
                            child: Text('${filteredBookStock[index]['phatsinhxuat']}',
                                textAlign: TextAlign.center,
                                style: const TextStyle(color: Color(0xFF858585)), overflow: TextOverflow.ellipsis),
                          ),
                          Expanded(
                            flex: 1,
                            child: Padding(
                              padding: EdgeInsets.only(right: 5),
                              child: Text('${filteredBookStock[index]['toncuoi']}',
                                  textAlign: TextAlign.right,
                                  style: const TextStyle(color: Color(0xFF858585)), overflow: TextOverflow.ellipsis),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(225, 227, 234, 1),
      body: Padding(
        padding: const EdgeInsets.only(top: 4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 15.0),
                  child: Container(
                    width: 200,
                    padding: const EdgeInsets.only(top: 10),
                    child: ExpandablePanel(
                      header: const Text(
                        'Báo cáo tồn',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Color.fromRGBO(5, 12, 156, 1),
                        ),
                      ),
                      collapsed: const Text(''),
                      expanded: Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TextButton(
                            style: TextButton.styleFrom(
                              padding: const EdgeInsets.only(left: 0, right: 10),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            onPressed: () {
                              widget.internalScreenContextSwitcher(
                                DebtReport(
                                  backContextSwitcher: widget.backContextSwitcher,
                                  internalScreenContextSwitcher: widget.internalScreenContextSwitcher,
                                  reloadContext: widget.reloadContext,
                                  debtSelectedDate: widget.debtSelectedDate,
                                  outstandingSelectedDate: selectedDate,
                                  initialMonthlyBookStock: monthlyBookStock,
                                  initialMonthlyCustomerStock: widget.initialMonthlyCustomerStock,
                                ),
                              );
                            },
                            child: const Text(
                              'Báo cáo công nợ',
                              style: TextStyle(
                                fontSize: 22,
                                color: Color.fromRGBO(5, 12, 156, 1),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      theme: const ExpandableThemeData(
                        iconColor: Color.fromRGBO(5, 12, 156, 1),
                        headerAlignment: ExpandablePanelHeaderAlignment.center,
                        iconPadding: EdgeInsets.zero,
                      ),
                    ),
                  ),
                ),
                Spacer(),
                IconButton(
                  onPressed: () {
                    setState(() {
                      isSearchVisible = !isSearchVisible;
                    });
                  },
                  icon: const Icon(
                    Icons.search,
                    size: 30,
                  ),
                  color: const Color.fromRGBO(5, 12, 156, 1),
                ),
              ],
            ),
            if (isSearchVisible) ...[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                child: TextField(
                  controller: searchController,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    hintText: 'Nhập tên sách...',
                    border: OutlineInputBorder(),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        setState(() {
                          searchController.clear();
                          isSearchVisible = false;
                        });
                      },
                    ),
                  ),
                ),
              ),
            ],
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                const Text('Tháng, Năm:'),
                TextButton(
                  onPressed: () async => _pickDate(context: context),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: const Color(0xFF3572EF),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.5),
                          blurRadius: 7,
                          offset: const Offset(0, 3),
                        ),
                      ],
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Row(
                      children: [
                        Text(
                          selectedDate != null
                              ? '${selectedDate!.month}/${selectedDate!.year}'
                              : 'Chọn tháng, năm',
                          style: const TextStyle(fontSize: 16, color: Colors.white),
                        ),
                        const SizedBox(width: 10),
                        const Icon(Icons.calendar_month, color: Colors.white, size: 20),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            Expanded(
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : (selectedDate == null ? notFound() : list()),
            ),
          ],
        ),
      ),
    );
  }
}
