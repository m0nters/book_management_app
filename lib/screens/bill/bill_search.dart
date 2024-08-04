import 'package:flutter/material.dart';
import 'package:dotted_line/dotted_line.dart';
import 'package:intl/intl.dart';

import 'bill_edit.dart';

List <Map<String, dynamic>> DanhSachPhieu = [
  {'maphieu': 'PTT12059512', 'tenkhachhang': 'Trịnh Anh Tài', 'ngaythutien': DateTime(2024, 4, 3), 'sotienthu':200000},
  {'maphieu': 'PTT15436315', 'tenkhachhang': 'Trần Nhật Huy', 'ngaythutien': DateTime(2024, 2, 5), 'sotienthu':32000},
  {'maphieu': 'PTT2421537', 'tenkhachhang': 'Nguyễn Quốc Thuần', 'ngaythutien': DateTime(2023,1,16), 'sotienthu':1000000},
];

class BillSearch extends StatefulWidget {
  final VoidCallback backContextSwitcher;
  final Function(Widget) internalScreenContextSwitcher;

  const BillSearch({
    super.key,
    required this.backContextSwitcher,
    required this.internalScreenContextSwitcher
  });
  @override
  State<StatefulWidget> createState() => _BillSearchState();
}

class _BillSearchState extends State<BillSearch> {
  DateTime? _selectedDate;

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
          "Tìm kiếm phếu thu tiền",
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
                SizedBox(height: 10,),
                Container(
                  margin: EdgeInsets.only(left: 10),
                  decoration: const BoxDecoration(
                    borderRadius: BorderRadius.only(topLeft: Radius.circular(8), topRight: Radius.circular(8)),
                    color: Color(0xFF088395),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Padding(
                        padding: EdgeInsets.all(10.0),
                        child: Text('Nhập thông tin', style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.w500),),
                      )
                    ],
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(left: 10),
                  color: Color(0xFFFCFFEB),
                  child:  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Padding(
                          padding: EdgeInsets.only(left: 15.0, top: 8.0),
                          child: Text('Tên khách hàng', textAlign: TextAlign.left,)
                      ),
                      Container(
                        height: 35,
                        margin: const EdgeInsets.only(left: 15, right: 15),
                        child: const TextField(
                          cursorColor: Colors.grey,
                          textAlignVertical: TextAlignVertical.bottom,
                          decoration: InputDecoration(
                            hintText: 'Họ và tên...',
                            hintStyle: TextStyle(color: Color(0xFFA3A3A3), fontWeight: FontWeight.w500),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: Colors.grey,  // Màu xám cho border khi focus
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: Colors.grey,  // Màu xám cho border khi không focus
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
                                    hintStyle: TextStyle(color: Color(0xFFA3A3A3), fontWeight: FontWeight.w500),
                                    focusedBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                        color: Colors.grey,  // Màu xám cho border khi focus
                                      ),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                        color: Colors.grey,  // Màu xám cho border khi không focus
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
                                    hintStyle: TextStyle(color: Color(0xFFA3A3A3), fontWeight: FontWeight.w500),
                                    focusedBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                        color: Colors.grey,  // Màu xám cho border khi focus
                                      ),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                        color: Colors.grey,  // Màu xám cho border khi không focus
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
                            hintStyle: TextStyle(color: Color(0xFFA3A3A3), fontWeight: FontWeight.w500),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: Colors.grey,  // Màu xám cho border khi focus
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: Colors.grey,  // Màu xám cho border khi không focus
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
                        padding: const EdgeInsets.only(left: 15.0, right: 15.0, bottom: 20.0),
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
                                  onPressed: () async => _pickDate(context: context),
                                  child: Row(
                                    children: [
                                      Text(
                                        _selectedDate != null
                                            ? '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}'
                                            : '../../..',
                                        style: const TextStyle(fontSize: 16, color: Colors.grey, fontWeight: FontWeight.w500),
                                      ),
                                      const Spacer(),
                                      const Icon(Icons.calendar_month, color: Colors.grey, size: 20,),
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
                                    hintStyle: TextStyle(color: Color(0xFFA3A3A3), fontWeight: FontWeight.w500),
                                    focusedBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                        color: Colors.grey,  // Màu xám cho border khi focus
                                      ),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                        color: Colors.grey,  // Màu xám cho border khi không focus
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
                    width: 120,
                    child: TextButton(
                        onPressed: () {},
                        style: TextButton.styleFrom(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          backgroundColor: const Color(0xFF088395),
                          elevation: 8,
                          shadowColor: Colors.grey,
                        ),
                        child: const Text('Tìm kiếm', style: TextStyle(color: Colors.white),)
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                const Padding(
                  padding: EdgeInsets.only(left: 8.0),
                  child: Text('Đã tìm thấy 3 kết quả', style: TextStyle(fontSize: 20),),

                ),
                Container(
                  height: 300,
                  child: ListView.builder(
                      itemCount: DanhSachPhieu.length,
                      itemBuilder: (context, index) {
                        final dateFormat = DateFormat('dd/MM/yyyy');
                        final formattedDate = dateFormat.format(DanhSachPhieu[index]['ngaythutien']);
                        return Padding(
                          padding: const EdgeInsets.only(left: 8.0, bottom: 20.0),
                          child: GestureDetector(
                            onTap: () {
                              widget.internalScreenContextSwitcher(
                                BillEdit(
                                  backContextSwitcher: widget.backContextSwitcher,
                                ),
                              );
                            },
                            child: Container(
                              padding: EdgeInsets.only(left: 15, right: 15),
                              height: 85,
                              width: 351,
                              decoration: const BoxDecoration(
                                  image: DecorationImage(image: AssetImage('assets/images/book_entry_form_ticket.png'),fit: BoxFit.cover),
                                  boxShadow: [
                                    BoxShadow(
                                        color: Colors.grey,
                                        blurRadius: 3,
                                        offset: Offset(0,3)
                                    )
                                  ]
                              ),
                              child: Column(
                                children: [
                                  const Row(
                                    children: [
                                      Expanded(
                                          child: Text('Mã phiếu')
                                      ),
                                      Expanded(
                                          child: Text('Tên khách hàng', textAlign: TextAlign.right,)
                                      )
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      Expanded(
                                          child: Text('${DanhSachPhieu[index]['maphieu']}', style: TextStyle(color: Color(0xFF858585)),)
                                      ),
                                      Expanded(
                                          child: Text('${DanhSachPhieu[index]['tenkhachhang']}', textAlign: TextAlign.right,style: TextStyle(color: Color(0xFF858585)))
                                      )
                                    ],
                                  ),
                                  const DottedLine(
                                    dashLength: 10,
                                    dashGapLength: 10,
                                  ),
                                  const Row(
                                    children: [
                                      Expanded(
                                          child: Text('Ngày thu tiền')
                                      ),
                                      Expanded(
                                          child: Text('Số tiền thu', textAlign: TextAlign.right,)
                                      )
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      Expanded(
                                          child: Text(formattedDate, style: TextStyle(color: Color(0xFF858585)),)
                                      ),
                                      Expanded(
                                          child: Text('${DanhSachPhieu[index]['sotienthu']} VNĐ', textAlign: TextAlign.right,style: TextStyle(color: Color(0xFF858585)))
                                      )
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }
                  ),
                ),
              ],
            ),
          )
      ),
    );
  }
}