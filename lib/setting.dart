import 'package:flutter/material.dart';
import 'overall_screen_context_controller.dart';
import 'mutual_widgets.dart';

class Setting extends StatefulWidget {
  final Function(int) overallScreenContextSwitcher;

  const Setting({super.key, required this.overallScreenContextSwitcher});

  @override
  createState() => _SettingState();
}

class _SettingState extends State<Setting> {
  List<String> startScreenOption = [
    "Trang chủ",
    "Phiếu nhập sách",
    "Hóa đơn bán sách",
    "Phiếu thu tiền",
    "Báo cáo công nợ"
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("Cài đặt"),
          leading: IconButton(
              onPressed: () {
                widget.overallScreenContextSwitcher(
                    OverallScreenContexts.mainFunctions.index);
              },
              icon: const Icon(Icons.arrow_back)),
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 0.0),
          child: Column(children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                  const Expanded (
                    child: Text(
                      "Màn hình bắt đầu: ",
                      style: TextStyle(fontSize: 18),
                    ),
                  ),
                  const SizedBox(
                    width: 20,
                  ),
                  Expanded(
                    child: CustomDropdownMenu(
                      options: startScreenOption,
                      width: 180,
                      hintText: "Chọn một thể loại vừa sức",
                      action: (String? selectedOption) {
                        print('Selected option: $selectedOption');
                      },
                    ),
                  ),
              ],
            ),
          ]),
        ));
  }
}