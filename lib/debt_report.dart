import 'package:flutter/material.dart';
import 'main_screen_context_controller.dart';

class DebtReport extends StatefulWidget {
  final VoidCallback backContextSwitcher;
  const DebtReport({super.key, required this.backContextSwitcher});

  @override
  State<DebtReport> createState() => _DebtReportState();
}

class _DebtReportState extends State<DebtReport> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(225, 227, 234, 1),
      appBar: AppBar(
        backgroundColor: const Color.fromRGBO(225, 227, 234, 1),
        foregroundColor: const Color.fromRGBO(47, 54, 69, 1),
        title: const Text("Báo cáo tồn", style: TextStyle(fontWeight: FontWeight.w400, color: Color.fromRGBO(47, 54, 69, 1)),),
        leading: IconButton(onPressed: (){
          widget.backContextSwitcher();
        }, icon: const Icon(Icons.arrow_back), color: const Color.fromRGBO(47, 54, 69, 1),),
        actions: [
          IconButton(onPressed: (){}, icon: const Icon(Icons.search,size: 29,)),
        ],
      ),
    );
  }
}