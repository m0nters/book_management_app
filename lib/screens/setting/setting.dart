import 'package:flutter/material.dart';
import '../../controllers/overall_screen_context_controller.dart';

bool hasShadow = true;

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
