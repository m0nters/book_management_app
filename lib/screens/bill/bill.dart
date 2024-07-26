import 'package:flutter/material.dart';
import '../../controllers/main_screen_context_controller.dart';

class Bill extends StatefulWidget {
  final VoidCallback backContextSwitcher;
  final Function(Widget) internalScreenContextSwitcher;
  const Bill({super.key, required this.backContextSwitcher, required this.internalScreenContextSwitcher});

  @override
  State<Bill> createState() => _BillState();
}

class _BillState extends State<Bill> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(235, 244, 246, 1),
      appBar: AppBar(
        backgroundColor: const Color.fromRGBO(235, 244, 246, 1),
        foregroundColor: const Color.fromRGBO(8, 131, 149, 1),
        title: const Text("Phiếu thu tiền", style: TextStyle(fontWeight: FontWeight.w400, color: Color.fromRGBO(8, 131, 149, 1)),),
        leading: IconButton(onPressed: (){
          widget.backContextSwitcher();
        }, icon: const Icon(Icons.arrow_back), color: const Color.fromRGBO(8, 131, 149, 1),),
        actions: [
          IconButton(onPressed: (){}, icon: const Icon(Icons.search,size: 29,)),
        ],
      ),
    );
  }
}