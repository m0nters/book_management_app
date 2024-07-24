import 'package:flutter/material.dart';
import 'overall_screen_context_controller.dart';

bool hasShadow = false;

class Setting extends StatefulWidget {
  final Function(int) overallScreenContextSwitcher;

  const Setting({super.key, required this.overallScreenContextSwitcher});

  @override
  createState() => _SettingState();
}

class _SettingState extends State<Setting> {
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
                const Text(
                  "Bật/tắt hiệu ứng đổ bóng",
                  style: TextStyle(fontSize: 18),
                ),
                IconButton( // Info button with icon
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text("Thông tin"),
                        content: const Text("Mặc định tắt để tối ưu hiệu năng."),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text("Đóng"),
                          ),
                        ],
                      ),
                    );
                  },
                  icon: const Icon(Icons.info_outline), // Or any suitable info icon
                  constraints: const BoxConstraints(maxHeight: 24), // Control icon size
                  padding: EdgeInsets.zero, // Remove default padding
                ),
                const Spacer(),
                Switch(
                  value: hasShadow,
                  onChanged: (value) {
                    setState(() {
                      hasShadow = value;
                    });
                  },
                  activeTrackColor: Colors.lightGreenAccent,
                  activeColor: Colors.green,
                ),
              ],
            ),
          ]),
        ));
  }
}
