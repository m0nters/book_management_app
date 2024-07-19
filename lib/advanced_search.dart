import 'package:flutter/material.dart';
import 'overall_screen_context_controller.dart';

class AdvancedSearch extends StatefulWidget {
  final Function(int) overallScreenContextSwitcher;
  const AdvancedSearch({super.key, required this.overallScreenContextSwitcher});

  @override
  State<AdvancedSearch> createState() => _AdvancedSearchState();
}

class _AdvancedSearchState extends State<AdvancedSearch> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(235, 244, 246, 1),
      appBar: AppBar(
        backgroundColor: const Color.fromRGBO(235, 244, 246, 1),
        foregroundColor: const Color.fromRGBO(7, 25, 82, 1),
        title: const Text("Tìm kiếm nâng cao", style: TextStyle(
            fontWeight: FontWeight.w400, color: Color.fromRGBO(7, 25, 82, 1)),),
        leading: IconButton(
          onPressed: () {
            widget.overallScreenContextSwitcher(OverallScreenContexts.mainFunctions.index);
          },
          icon: const Icon(Icons.arrow_back),
          color: const Color.fromRGBO(7, 25, 82, 1),),
      ),
    );
  }
}