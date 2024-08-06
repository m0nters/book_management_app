import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class BillEdit extends StatefulWidget {
  final VoidCallback backContextSwitcher;

  const BillEdit({super.key, required this.backContextSwitcher,});

  @override
  State<StatefulWidget> createState() => _BillEditState();
}

class _BillEditState extends State<BillEdit> {
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
    final selected = await showDatePicker(
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
      appBar: AppBar(
        backgroundColor: const Color(0xFFEBF4F6),
        foregroundColor: const Color.fromRGBO(8, 131, 149, 1),
        title: const Text(
          "Chỉnh sửa phiếu thu tiền",
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
      backgroundColor: const Color(0xFFEBF4F6),
      body: Padding(
          padding: const EdgeInsets.only(top: 10, right: 10),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 10,),
                Container(
                  margin: EdgeInsets.only(left: 10),
                  decoration: const BoxDecoration(
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(8),
                        topRight: Radius.circular(8)),
                    color: Color(0xFF088395),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Padding(
                        padding: EdgeInsets.all(10.0),
                        child: Text('Điền thông tin', style: TextStyle(
                            fontSize: 18,
                            color: Colors.white,
                            fontWeight: FontWeight.w500),),
                      )
                    ],
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(left: 10),
                  color: Color(0xFFFCFFEB),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Padding(
                          padding: EdgeInsets.only(left: 15.0, top: 8.0),
                          child: Text(
                            'Tên khách hàng', textAlign: TextAlign.left,)
                      ),
                      Container(
                        height: 35,
                        margin: const EdgeInsets.only(left: 15, right: 15),
                        child: const TextField(
                          cursorColor: Colors.grey,
                          textAlignVertical: TextAlignVertical.bottom,
                          decoration: InputDecoration(
                            hintText: 'Họ và tên...',
                            hintStyle: TextStyle(color: Color(0xFFA3A3A3),
                                fontWeight: FontWeight.w500),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: Colors
                                    .grey, // Màu xám cho border khi focus
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: Colors
                                    .grey, // Màu xám cho border khi không focus
                              ),
                            ),
                            filled: true,
                            fillColor: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(height: 10,),
                      const Padding(
                        padding: EdgeInsets.only(left: 15, right: 15),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text('Địa chỉ'),
                            ),
                            Expanded(
                              child: Text('Số điện thoại'),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(left: 15.0, right: 15.0),
                        child: Row(
                          children: [
                            Expanded(
                              child: Container(
                                margin: const EdgeInsets.only(right: 10),
                                height: 35,
                                child: const TextField(
                                  cursorColor: Colors.grey,
                                  textAlignVertical: TextAlignVertical.bottom,
                                  decoration: InputDecoration(
                                    hintText: 'Nhập địa chỉ...',
                                    hintStyle: TextStyle(
                                        color: Color(0xFFA3A3A3),
                                        fontWeight: FontWeight.w500),
                                    focusedBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                        color: Colors
                                            .grey, // Màu xám cho border khi focus
                                      ),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                        color: Colors
                                            .grey, // Màu xám cho border khi không focus
                                      ),
                                    ),
                                    filled: true,
                                    fillColor: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              child: Container(
                                height: 35,
                                child: const TextField(
                                  keyboardType: TextInputType.number,
                                  cursorColor: Colors.grey,
                                  textAlignVertical: TextAlignVertical.bottom,
                                  decoration: InputDecoration(
                                    hintText: 'Nhập số điện thoại...',
                                    hintStyle: TextStyle(
                                        color: Color(0xFFA3A3A3),
                                        fontWeight: FontWeight.w500),
                                    focusedBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                        color: Colors
                                            .grey, // Màu xám cho border khi focus
                                      ),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                        color: Colors
                                            .grey, // Màu xám cho border khi không focus
                                      ),
                                    ),
                                    filled: true,
                                    fillColor: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),

                      ),
                      const SizedBox(height: 10),
                      const Padding(
                        padding: EdgeInsets.only(left: 15),
                        child: Text('Email'),
                      ),
                      Container(
                        height: 35,
                        margin: const EdgeInsets.only(left: 15, right: 15),
                        child: const TextField(
                          cursorColor: Colors.grey,
                          textAlignVertical: TextAlignVertical.bottom,
                          decoration: InputDecoration(
                            hintText: 'Nhập email khách hàng...',
                            hintStyle: TextStyle(color: Color(0xFFA3A3A3),
                                fontWeight: FontWeight.w500),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: Colors
                                    .grey, // Màu xám cho border khi focus
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: Colors
                                    .grey, // Màu xám cho border khi không focus
                              ),
                            ),
                            filled: true,
                            fillColor: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(height: 10,),
                      const Padding(
                        padding: EdgeInsets.only(left: 15, right: 15),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text('Ngày thu tiền'),
                            ),
                            Expanded(
                              child: Text('Số tiền thu'),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(
                            left: 15.0, right: 15.0, bottom: 20.0),
                        child: Row(
                          children: [
                            Expanded(
                              child: Container(
                                height: 35,
                                decoration: BoxDecoration(
                                    color: Colors.white,
                                    border: Border.all(color: Colors.grey),
                                    borderRadius: BorderRadius.circular(4)
                                ),
                                margin: EdgeInsets.only(right: 10.0),
                                child: TextButton(
                                  onPressed: () async =>
                                      _pickDate(context: context),
                                  child: Row(
                                    children: [
                                      Text(
                                        _selectedDate != null
                                            ? '${_selectedDate!
                                            .day}/${_selectedDate!
                                            .month}/${_selectedDate!.year}'
                                            : '../../..',
                                        style: const TextStyle(fontSize: 16,
                                            color: Colors.grey,
                                            fontWeight: FontWeight.w500),
                                      ),
                                      const Spacer(),
                                      const Icon(Icons.calendar_month,
                                        color: Colors.grey, size: 20,),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              child: Container(
                                height: 35,
                                child: const TextField(
                                  keyboardType: TextInputType.number,
                                  cursorColor: Colors.grey,
                                  textAlignVertical: TextAlignVertical.bottom,
                                  decoration: InputDecoration(
                                    hintText: 'Tiền thu',
                                    hintStyle: TextStyle(
                                        color: Color(0xFFA3A3A3),
                                        fontWeight: FontWeight.w500),
                                    focusedBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                        color: Colors
                                            .grey, // Màu xám cho border khi focus
                                      ),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                        color: Colors
                                            .grey, // Màu xám cho border khi không focus
                                      ),
                                    ),
                                    filled: true,
                                    fillColor: Colors.white,
                                    suffixText: 'VNĐ',
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Align(
                  alignment: Alignment.center,
                  child: Container(
                    width: 90,
                    child: TextButton(
                        onPressed: () {},
                        style: TextButton.styleFrom(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8)),
                          backgroundColor: const Color(0xFF088395),
                          elevation: 8,
                          shadowColor: Colors.grey,
                        ),
                        child: const Text(
                          'Lưu', style: TextStyle(color: Colors.white),)
                    ),
                  ),
                ),
              ],
            ),
          )
      ),
    );
  }
}