import 'package:flutter/material.dart';
import 'package:month_year_picker/month_year_picker.dart';
import 'package:expandable/expandable.dart';
import 'package:dotted_line/dotted_line.dart';
import 'package:untitled2/screens/monthly_report/debt_report/debt_report.dart';
import '../outstanding_report/outstanding_report_add.dart';
import '../outstanding_report/outstanding_report_edit.dart';

final List<Map<String, dynamic>> SachTon = [
  {'masach' : 'PNS0124512', 'tensach': 'Mắt biếc', 'tacgia': 'Nguyễn Nhât Ánh', 'tondau': 100, 'phatsinhnhap': 50, 'phatsinhxuat': 30, 'toncuoi': 120},
  {'masach' : 'IRA90281847', 'tensach': 'WELL MET', 'tacgia': 'Jen Deluca', 'tondau': 200, 'phatsinhnhap': 40, 'phatsinhxuat': 50, 'toncuoi': 190},
  {'masach' : 'PMI9201919', 'tensach': 'Tôi thấy hoa vàng trên cỏ xanh', 'tacgia': 'Nguyễn Nhât Ánh', 'tondau': 150, 'phatsinhnhap': 60, 'phatsinhxuat': 20, 'toncuoi': 190},
  {'masach' : 'UYH024828', 'tensach': 'Cho tôi xin một vé đi tuổi thơ', 'tacgia': 'Nguyễn Nhât Ánh', 'tondau': 140, 'phatsinhnhap': 50, 'phatsinhxuat': 40, 'toncuoi': 120},
  {'masach' : 'PNS0124512', 'tensach': 'Mắt biếc', 'tacgia': 'Nguyễn Nhât Ánh', 'tondau': 100, 'phatsinhnhap': 50, 'phatsinhxuat': 30, 'toncuoi': 120},
];

class OutstandingReport extends StatefulWidget {
  final VoidCallback backContextSwitcher;
  final VoidCallback reloadContext;
  final Function(Widget) internalScreenContextSwitcher;

  const OutstandingReport({
    super.key,
    required this.backContextSwitcher,
    required this.internalScreenContextSwitcher,
    required this.reloadContext,
  });

  @override
  State<StatefulWidget> createState() => _OutstandingReportState();
}

class _OutstandingReportState extends State<OutstandingReport> {
  DateTime? _selectedDate;

  Future<void> _pickDate({required BuildContext context}) async {
    final selected = await showMonthYearPicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2004),
      lastDate: DateTime(2030),
    );
    if (selected != null) {
      setState(() {
        _selectedDate = selected;
      });
    }
  }

  Widget notFound() {
    return Container(
      width: double.maxFinite,
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(height: 170),
          Icon(Icons.search_off, color: Colors.grey, size: 200),
          Text('Chưa có tìm kiếm nào được thực hiện, vui lòng nhập tháng năm',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey, fontFamily: 'archivo')),
        ],
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
                    'Tháng ${_selectedDate!.month}, ${_selectedDate!.year}',
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
              itemCount: SachTon.length,
              itemBuilder: (BuildContext context, int index) {
                return GestureDetector(
                  onTap: () {
                    widget.internalScreenContextSwitcher(
                      OutstandingReportEdit(backContextSwitcher: widget.backContextSwitcher)
                    );
                  },
                  child: Container(
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
                                  '${SachTon[index]['masach']}',
                                  textAlign: TextAlign.left,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(color: Color(0xFF858585)),
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  '${SachTon[index]['tensach']}',
                                  textAlign: TextAlign.center,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(color: Color(0xFF858585)),
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  '${SachTon[index]['tacgia']}',
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
                                child: Text('${SachTon[index]['tondau']}',
                                    style: const TextStyle(color: Color(0xFF858585))),
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: Text('${SachTon[index]['phatsinhnhap']}',
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(color: Color(0xFF858585))),
                            ),
                            Expanded(
                              flex: 2,
                              child: Text('${SachTon[index]['phatsinhxuat']}',
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(color: Color(0xFF858585))),
                            ),
                            Expanded(
                              flex: 1,
                              child: Padding(
                                padding: EdgeInsets.only(right: 5),
                                child: Text('${SachTon[index]['toncuoi']}',
                                    textAlign: TextAlign.right,
                                    style: const TextStyle(color: Color(0xFF858585))),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
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
                        style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold,color: Color.fromRGBO(5, 12, 156, 1), ),
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
                                BaoCaoCongNo(backContextSwitcher: widget.backContextSwitcher, internalScreenContextSwitcher: widget.internalScreenContextSwitcher, reloadContext: widget.reloadContext)
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
                const Spacer(),
                IconButton(
                  onPressed: () {
                    widget.internalScreenContextSwitcher(
                      OutstandingReportAdd(
                        backContextSwitcher:
                        widget.backContextSwitcher,
                      ),
                    );
                  },
                  icon: const Icon(Icons.add_circle, size: 30),
                  color: const Color.fromRGBO(5, 12, 156, 1),
                ),
              ],
            ),
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
                        )
                      ],
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Row(
                      children: [
                        Text(
                          _selectedDate != null
                              ? '${_selectedDate!.month}/${_selectedDate!.year}'
                              : 'Chọn tháng, năm',
                          style: const TextStyle(fontSize: 16, color: Colors.white),
                        ),
                        const SizedBox(width: 10),
                        const Icon(Icons.calendar_month, color: Colors.white, size: 20, )
                      ],
                    ),
                  ),
                ),
              ],
            ),
            Expanded(
              child: _selectedDate == null ? notFound() : list(),
            ),
          ],
        ),
      ),
    );
  }
}
