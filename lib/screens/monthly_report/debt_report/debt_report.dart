import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:month_year_picker/month_year_picker.dart';
import 'package:expandable/expandable.dart';
import 'package:dotted_line/dotted_line.dart';
import '../debt_report/debt_report_edit.dart';
import '../debt_report/debt_report_add.dart';
import '../outstanding_report/outstanding_report.dart';

final List<Map<String, dynamic>> KhachHangNo = [
  {'makhachhang':'KH05238481', 'tenkhachhang' : 'Nguyễn Thiện Nhân', 'nodau': 20000, 'nophatsinh': 0, 'nocuoi': 10000},
  {'makhachhang':'KH05238481', 'tenkhachhang' : 'Trần Trung Chiên', 'nodau': 100000, 'nophatsinh': 20000, 'nocuoi': 60000},
  {'makhachhang':'KH05238481', 'tenkhachhang' : 'Mai Văn Chí', 'nodau': 50000, 'nophatsinh': 0, 'nocuoi': 0},
  {'makhachhang':'KH05238481', 'tenkhachhang' : 'Hồ Minh Lợi', 'nodau': 20000, 'nophatsinh': 10000, 'nocuoi': 10000},
  {'makhachhang':'KH05238481', 'tenkhachhang' : 'Nguyễn Thiện Nhân', 'nodau': 20000, 'nophatsinh': 0, 'nocuoi': 10000},
];

class BaoCaoCongNo extends StatefulWidget {
  final VoidCallback backContextSwitcher;
  final VoidCallback reloadContext;
  final Function(Widget) internalScreenContextSwitcher;
  const BaoCaoCongNo({
    super.key,
    required this.backContextSwitcher,
    required this.internalScreenContextSwitcher,
    required this.reloadContext,
  });

  @override
  State<StatefulWidget> createState() => _BaoCaoCongNoState();
}

class _BaoCaoCongNoState extends State<BaoCaoCongNo> {
  DateTime? _selectedDate;

  @override
  void initState() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
    super.initState();
  }

  Future<void> _pickDate({
    required BuildContext context,
  }) async {
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

  Widget notFound()
  {
    return Container(
      width: double.maxFinite,
      child: const Column(
        crossAxisAlignment:   CrossAxisAlignment.center,
        children: [
          SizedBox(height: 170),
          Icon(Icons.search_off, color: Colors.grey, size: 200,),
          Text('Chưa có tìm kiếm nào được thực hiện, vui lòng nhập tháng năm', textAlign: TextAlign.center, style: TextStyle(color: Colors.grey))
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
                  borderRadius: BorderRadius.only(topRight: Radius.circular(10), bottomRight: Radius.circular(10)),
                ),
                width: 144, height: 64,
                child: Padding(
                  padding: const EdgeInsets.only(left: 5, top: 8),
                  child: Text('Tháng ${_selectedDate!.month}, ${_selectedDate!.year}', style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w400)),
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
              itemCount: KhachHangNo.length,
              itemBuilder: (BuildContext context, int index) {
                return GestureDetector(
                  onTap: () {
                    widget.internalScreenContextSwitcher(
                      DebtReportEdit(backContextSwitcher: widget.backContextSwitcher)
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
                          ]
                      ),
                      margin: EdgeInsets.only(bottom: 20),
                      height: 93,
                      child:  Column(
                          children: [
                            const Padding(
                              padding: EdgeInsets.only(top: 5),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: Text('Mã khách hàng', textAlign: TextAlign.center),
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
                                  child: Text('${KhachHangNo[index]['makhachhang']}', textAlign: TextAlign.center,overflow: TextOverflow.ellipsis,style: const TextStyle(color: Color(0xFF858585))),
                                ),
                                Expanded(
                                  child: Text('${KhachHangNo[index]['tenkhachhang']}', textAlign: TextAlign.center,overflow: TextOverflow.ellipsis,style: const TextStyle(color: Color(0xFF858585))),
                                ),
                              ],
                            ),
                            const Padding(
                              padding: EdgeInsets.only(left: 5, right: 5),
                              child:  DottedLine(
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
                                    child: Text('${KhachHangNo[index]['nodau']}',style: const TextStyle(color: Color(0xFF858585))),
                                  ),
                                ),
                                Expanded(
                                  child: Text('${KhachHangNo[index]['nophatsinh']}', textAlign: TextAlign.center, style: const TextStyle(color: Color(0xFF858585))),
                                ),
                                Expanded(
                                  child: Padding(
                                    padding: EdgeInsets.only(right: 5),
                                    child: Text('${KhachHangNo[index]['nocuoi']}', textAlign: TextAlign.right, style: const TextStyle(color: Color(0xFF858585))),
                                  ),
                                ),
                              ],
                            ),
                          ]
                      )
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
                                  OutstandingReport(backContextSwitcher: widget.backContextSwitcher, internalScreenContextSwitcher: widget.internalScreenContextSwitcher, reloadContext: widget.reloadContext)
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
                    widget.internalScreenContextSwitcher(
                      DebtReportAdd(backContextSwitcher: widget.backContextSwitcher)
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
                    padding: EdgeInsets.only(left: 10, right: 10, top: 5, bottom: 5),
                    decoration: BoxDecoration(
                      color: Color(0xFF3572EF),
                      boxShadow: [BoxShadow(
                        color: Colors.grey.withOpacity(0.5),
                        blurRadius: 7,
                        offset: const Offset(0, 3), // changes position of shadow
                      )],
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

