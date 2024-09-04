import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:month_year_picker/month_year_picker.dart';
import 'package:expandable/expandable.dart';
import 'package:dotted_line/dotted_line.dart';
import 'package:untitled2/repository/customer_repository.dart';
import '../../../../controller/customer_controller.dart';
import '../../../../model/customer.dart';
import '../outstanding_report/outstanding_report.dart';

class DebtReport extends StatefulWidget {
  final VoidCallback backContextSwitcher;
  final VoidCallback reloadContext;
  final Function(Widget) internalScreenContextSwitcher;
  final DateTime? debtSelectedDate;
  final DateTime? outstandingSelectedDate;
  final List<Map<String, dynamic>> initialMonthlyCustomerStock; // Thêm biến để lưu trữ danh sách công nợ
  final List<Map<String, dynamic>> initialMonthlyBookStock;

  const DebtReport({
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
  State<StatefulWidget> createState() => _DebtReportState();
}

class _DebtReportState extends State<DebtReport> {
  DateTime? selectedDate;
  bool isSearchVisible = false;
  bool isLoading = false;

  TextEditingController searchController = TextEditingController();
  late final CustomerController customerController;
  late List<Customer> allCustomers = [];
  late List<Map<String, dynamic>> monthlyCustomerStock = [];
  late List<Map<String, dynamic>> filteredCustomerStock = [];

  @override
  void initState() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
    super.initState();

    CustomerRepository customerRepository = CustomerRepository();
    customerController = CustomerController(customerRepository);

    selectedDate = widget.debtSelectedDate;
    monthlyCustomerStock = List.from(widget.initialMonthlyCustomerStock);
    filteredCustomerStock = List.from(monthlyCustomerStock);

    searchController.addListener(() {
      setState(() {
        filterCustomerStock();
      });
    });
  }

  Future<void> generateMonthlyDebtReports() async {
    if (selectedDate == null) return;

    setState(() {
      isLoading = true; // Bắt đầu hiển thị loading screen
    });

    try {
      allCustomers = await customerController.getAllCustomers();
      monthlyCustomerStock.clear();

      final reports = await customerController.getMonthlyDebtReport(allCustomers, selectedDate!);
      for (var report in reports) {
        final debtData = {
          'sodienthoai': report.item1.phoneNumber,
          'tenkhachhang': report.item1.name,
          'nodau': report.item2.item1.toInt(), // Chuyển đổi trực tiếp sang int
          'nophatsinh': report.item2.item2.toInt(), // Chuyển đổi trực tiếp sang int
          'nocuoi': report.item2.item3.toInt(), // Chuyển đổi trực tiếp sang int
        };
        setState(() {
          monthlyCustomerStock.add(debtData);
          filterCustomerStock();
        });
      }
    } catch (e) {
      print('Error generating monthly debt reports: $e');
    } finally {
      setState(() {
        isLoading = false; // Ẩn loading screen khi hoàn thành
      });
    }
  }

  void filterCustomerStock() {
    final query = searchController.text.toLowerCase();
    filteredCustomerStock = monthlyCustomerStock.where((customer) {
      final name = customer['tenkhachhang'].toString().toLowerCase();
      return name.contains(query);
    }).toList();
  }

  Future<void> _pickDate({ required BuildContext context, }) async {
    final selected = await showMonthYearPicker(
      context: context,
      initialDate: selectedDate ?? DateTime.now(),
      firstDate: DateTime(2004),
      lastDate: DateTime(2030),
    );
    if (selected != null) {
      setState(() {
        selectedDate = selected;
        generateMonthlyDebtReports();
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
            SizedBox(height: 170),
            Icon(Icons.search_off, color: Colors.grey, size: 200,),
            Text('Chưa có tìm kiếm nào được thực hiện, vui lòng nhập tháng năm', textAlign: TextAlign.center, style: TextStyle(color: Colors.grey))
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
                  borderRadius: BorderRadius.only(topRight: Radius.circular(10), bottomRight: Radius.circular(10)),
                ),
                width: 144, height: 64,
                child: Padding(
                  padding: const EdgeInsets.only(left: 5, top: 8),
                  child: Text('Tháng ${selectedDate!.month}, ${selectedDate!.year}', style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w400)),
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
              itemCount: filteredCustomerStock.length,
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
                        ]
                    ),
                    margin: EdgeInsets.only(bottom: 20),
                    height: 93,
                    child: Column(
                        children: [
                          const Padding(
                            padding: EdgeInsets.only(top: 5),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Text('Số điện thoại', textAlign: TextAlign.center),
                                ),
                                Expanded(
                                  child: Text('Tên khách hàng', textAlign: TextAlign.center),
                                ),
                              ],
                            ),
                          ),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Text('${filteredCustomerStock[index]['sodienthoai']}', textAlign: TextAlign.center, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Color(0xFF858585))),
                              ),
                              Expanded(
                                child: Text('${filteredCustomerStock[index]['tenkhachhang']}', textAlign: TextAlign.center, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Color(0xFF858585))),
                              ),
                            ],
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
                                  child: Padding(
                                    padding: EdgeInsets.only(left: 5),
                                    child: Text('Nợ đầu'),
                                  ),
                                ),
                                Expanded(
                                  child: Text('Nợ phát sinh', textAlign: TextAlign.center),
                                ),
                                Expanded(
                                  child: Padding(
                                    padding: EdgeInsets.only(right: 5),
                                    child: Text('Nợ cuối', textAlign: TextAlign.right),
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
                                child: Padding(
                                  padding: EdgeInsets.only(left: 5),
                                  child: Text('${filteredCustomerStock[index]['nodau']}', style: const TextStyle(color: Color(0xFF858585), overflow: TextOverflow.ellipsis)),
                                ),
                              ),
                              Expanded(
                                child: Text('${filteredCustomerStock[index]['nophatsinh']}', textAlign: TextAlign.center, style: const TextStyle(color: Color(0xFF858585), overflow: TextOverflow.ellipsis)),
                              ),
                              Expanded(
                                child: Padding(
                                  padding: EdgeInsets.only(right: 5),
                                  child: Text('${filteredCustomerStock[index]['nocuoi']}', textAlign: TextAlign.right, style: const TextStyle(color: Color(0xFF858585),overflow: TextOverflow.ellipsis)),
                                ),
                              ),
                            ],
                          ),
                        ]
                    )
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
      backgroundColor: const Color(0xFFE1E3EA),
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
                    width: 202,
                    padding: const EdgeInsets.only(top: 10),
                    child: ExpandablePanel(
                      header: const Text(
                        'Báo cáo công nợ',
                        style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color.fromRGBO(5, 12, 156, 1)),
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
                                  OutstandingReport(backContextSwitcher: widget.backContextSwitcher, internalScreenContextSwitcher: widget.internalScreenContextSwitcher, reloadContext: widget.reloadContext,
                                      debtSelectedDate: selectedDate, outstandingSelectedDate: widget.outstandingSelectedDate, initialMonthlyBookStock: widget.initialMonthlyBookStock, initialMonthlyCustomerStock: monthlyCustomerStock)
                              );
                            },
                            child: const Text(
                              'Báo cáo tồn',
                              style: TextStyle(
                                fontSize: 20,
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
                const Spacer(),
                IconButton(
                  onPressed: () {
                    setState(() {
                      isSearchVisible = !isSearchVisible;
                    });
                  },
                  icon: const Icon(Icons.search, size: 30),
                  color: const Color.fromRGBO(5, 12, 156, 1),
                ),
              ],
            ),
            if (isSearchVisible) ...[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15.0),
                child: TextField(
                  controller: searchController,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    hintText: 'Nhập tên khách hàng...',
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
                    padding: EdgeInsets.only(left: 10, right: 10, top: 5, bottom: 5),
                    decoration: BoxDecoration(
                      color: Color(0xFF3572EF),
                      boxShadow: [BoxShadow(
                        color: Colors.grey.withOpacity(0.5),
                        blurRadius: 7,
                        offset: const Offset(0, 3),
                      )],
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
                        const Icon(Icons.calendar_month, color: Colors.white, size: 20,)
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
