import 'package:flutter/material.dart';
import 'main_screen_context_controller.dart';
import 'advanced_search.dart';
import 'setting.dart';

enum MainFunctionsContexts {
  home,
  bookEntryForm,
  bookSaleInvoice,
  bill,
  debtReport,
  advancedSearch
}

enum OverallScreenContexts { mainFunctions, advancedSearch, setting }

class MainScreenContextController extends StatefulWidget {
  const MainScreenContextController({super.key});

  @override
  createState() => _OverallScreenContextControllerState();
}

class _OverallScreenContextControllerState
    extends State<MainScreenContextController> {
  late int _selectedIndex;

  static List<Widget> _contextOptions = [];

  @override
  void initState() {
    super.initState();
    _selectedIndex = OverallScreenContexts.mainFunctions.index;

    // Initialize _contextOptions here to include the switchContext function
    _contextOptions = [
      MainFunctionsContextController(
          overallScreenContextSwitcher: switchContext),
      AdvancedSearch(overallScreenContextSwitcher: switchContext),
      Setting(
        overallScreenContextSwitcher: switchContext,
      ),
    ];
  }

  void switchContext(int index) {
    setState(() => _selectedIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return _contextOptions[_selectedIndex];
  }
}
