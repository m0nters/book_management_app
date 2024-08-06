import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../controllers/main_screen_context_controller.dart';

class DebtReport extends StatefulWidget {
  final VoidCallback backContextSwitcher;
  final VoidCallback reloadContext;
  final Function(Widget) internalScreenContextSwitcher;

  const DebtReport(
      {super.key,
      required this.backContextSwitcher,
      required this.reloadContext,
      required this.internalScreenContextSwitcher});

  @override
  State<DebtReport> createState() => _DebtReportState();
}

class _DebtReportState extends State<DebtReport> {
  @override
  void initState() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(225, 227, 234, 1),
      appBar: AppBar(
        backgroundColor: const Color.fromRGBO(225, 227, 234, 1),
        foregroundColor: const Color.fromRGBO(47, 54, 69, 1),
        title: const Text(
          "Báo cáo tồn",
          style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Color.fromRGBO(47, 54, 69, 1)),
        ),
        actions: [
          IconButton(
              onPressed: () {},
              icon: const Icon(
                Icons.search,
                size: 29,
              )),
        ],
      ),
    );
  }
}
