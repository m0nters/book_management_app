import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:month_year_picker/month_year_picker.dart';

class OutstandingReportEdit extends StatefulWidget {
  final VoidCallback backContextSwitcher;
  const OutstandingReportEdit({
    super.key,
    required this.backContextSwitcher,
  });

  @override
  State<StatefulWidget> createState() => _OutstandingReportEditState();
}

class _OutstandingReportEditState extends State<OutstandingReportEdit> {
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
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:AppBar(
        backgroundColor: const Color(0xFFE1E3EA),
        foregroundColor: const Color(0xFF050C9C),
        title: const Text(
          "Chỉnh sửa",
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          onPressed: () {
            widget.backContextSwitcher();
          },
          icon: const Icon(Icons.arrow_back),
        ),
      ),
      backgroundColor: const Color(0xFFE1E3EA),
      body: Padding(
          padding: const EdgeInsets.only(top: 10, right: 10),
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 30,),
                Container(
                  margin: EdgeInsets.only(left: 10),
                  decoration: const BoxDecoration(
                    borderRadius: BorderRadius.only(topLeft: Radius.circular(8), topRight: Radius.circular(8)),
                    color: Color(0xFF050C9C),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      const Text('Tháng, Năm:', style: TextStyle(color: Colors.white),),
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
                              const Icon(Icons.calendar_month, color: Colors.white, size: 20),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(left: 10),
                  color: Color(0xFFFFF5E1),
                  child:  Column(
                    children: [
                      const Padding(
                        padding: EdgeInsets.only(left: 8.0, top: 8.0, right: 8.0),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text('Tên Sách'),
                            ),
                            Expanded(
                              child: Text(' Tác giả'),
                            ),
                          ],
                        ),
                      ),
                      Row(
                        children: [
                          Expanded(
                              child: Container(
                                decoration: BoxDecoration(
                                    color: Color(0xFFCECEC9),
                                    borderRadius: BorderRadius.circular(8)
                                ),
                                margin: EdgeInsets.only(left: 8.0, right: 8.0),
                                padding: EdgeInsets.all(8.0),
                                child: Text('Mắt biếc', overflow: TextOverflow.ellipsis,),
                              )
                          ),
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                color: Color(0xFFCECEC9),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              margin: EdgeInsets.only(right: 8.0),
                              padding: EdgeInsets.all(8.0),
                              child: Text(' Nguyễn Nhật Ánh', overflow: TextOverflow.ellipsis,),
                            ),
                          )
                        ],
                      ),
                      const SizedBox(height: 30,),
                      const Padding(
                        padding: EdgeInsets.only(left: 8.0, right: 8.0),
                        child: Row(
                          children: [
                            Expanded(
                              flex: 1,
                              child: Text('Tồn đầu'),
                            ),
                            Expanded(
                              flex: 2,
                              child: Text('Phát sinh nhập', textAlign: TextAlign.center,),
                            ),
                            Expanded(
                              flex: 2,
                              child: Text('Phát sinh xuất', textAlign: TextAlign.center),
                            ),
                            Expanded(
                              flex: 1,
                              child: Text('Tồn cuối'),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(left: 8.0, right: 8.0, bottom: 20.0),
                        child: Row(
                          children: [
                            Expanded(
                              flex: 1,
                              child: Container(
                                height: 35,
                                child: const TextField(
                                  textAlign: TextAlign.center,
                                  textAlignVertical: TextAlignVertical.top,
                                  keyboardType: TextInputType.number,
                                  decoration: InputDecoration(
                                    border: OutlineInputBorder(),
                                    filled: true,
                                    fillColor: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: Container(
                                margin: EdgeInsets.only(left: 8, right: 8),
                                height: 35,
                                child: const TextField(
                                  textAlign: TextAlign.center,
                                  textAlignVertical: TextAlignVertical.top,
                                  keyboardType: TextInputType.number,
                                  decoration: InputDecoration(
                                    border: OutlineInputBorder(),
                                    filled: true,
                                    fillColor: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: Container(
                                margin: EdgeInsets.only(left: 8, right: 8),
                                height: 35,
                                child: const TextField(
                                  textAlign: TextAlign.center,
                                  textAlignVertical: TextAlignVertical.top,
                                  keyboardType: TextInputType.number,
                                  decoration: InputDecoration(
                                    border: OutlineInputBorder(),
                                    filled: true,
                                    fillColor: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 1,
                              child: Container(
                                height: 35,
                                child: const TextField(
                                  textAlign: TextAlign.center,
                                  textAlignVertical: TextAlignVertical.top,
                                  keyboardType: TextInputType.number,
                                  decoration: InputDecoration(
                                    filled: true,
                                    fillColor: Colors.white,
                                    border: OutlineInputBorder(),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),

                      )
                    ],
                  ),
                ),
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        margin: const EdgeInsets.only(top: 20, left: 50, right: 20),
                        child: TextButton(
                            onPressed: () {},
                            style: TextButton.styleFrom(
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(0)),
                              backgroundColor: const Color(0xFFCEC7C7),
                              elevation: 8,
                              shadowColor: Colors.grey,
                            ),
                            child: Text('Xoá', style: TextStyle(color: Colors.white),)
                        ),
                      ),
                    ),
                    Expanded(
                      child: Container(
                        margin: const EdgeInsets.only(top: 20, left: 20, right: 50),
                        child: TextButton(
                            onPressed: () {},
                            style: TextButton.styleFrom(
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(0)),
                              backgroundColor: const Color(0xFF050C9C),
                              elevation: 8,
                              shadowColor: Colors.grey,
                            ),
                            child: const Text('Lưu', style: TextStyle(color: Colors.white),)
                        ),
                      ),
                    ),
                  ],
                )
              ]
          )
      ),
    );
  }
}