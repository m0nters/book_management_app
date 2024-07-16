import 'package:flutter/material.dart';
import 'overall_screen_context_controller.dart';

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
        leading: IconButton(onPressed: (){
          widget.overallScreenContextSwitcher(OverallScreenContexts.home.index);
        }, icon: const Icon(Icons.arrow_back)),
      ),
    );
  }

}