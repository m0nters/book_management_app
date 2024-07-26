import 'package:flutter/material.dart';
import 'overall_screen_context_controller.dart';
import 'home.dart';
import 'book_entry_form.dart';
import 'book_sale_invoice.dart';
import 'bill.dart';
import 'debt_report.dart';

class MainFunctionsContextController extends StatefulWidget {
  final Function(int) overallScreenContextSwitcher;

  const MainFunctionsContextController(
      {required this.overallScreenContextSwitcher, super.key});

  @override
  createState() => _MainFunctionsContextControllerState();
}

class _MainFunctionsContextControllerState
    extends State<MainFunctionsContextController> {
  late int
      _selectedIndex; // ALWAYS need this to adjust selected item, colors,... for bottom bar's visualization
  late Widget _currentContext;
  List<Map<int, Widget>> backButtonScreensHistory =
      []; // what were all of the last screens to navigate back
  Map<int, Widget> bottomBarScreensHistory =
      {}; // what was the last screen of a specific item in bottom bar
  static List<Widget> _mainContextsFirstPage =
      []; // don't know whether we should use static or not, this MainFunctionsContextController object's only used 1 time in `over_screen_context_controller.dart` anyway

  static const List<Color> _scaffoldBackgroundColorOptions = [
    Color.fromRGBO(235, 244, 246, 1),
    Color.fromRGBO(225, 227, 234, 1),
    Color.fromRGBO(241, 248, 232, 1),
    Color.fromRGBO(235, 244, 246, 1),
    Color.fromRGBO(225, 227, 234, 1),
  ];

  static const List<Color> _selectedItemColorOptions = [
    Color.fromRGBO(33, 33, 33, 1),
    Color.fromRGBO(255, 105, 105, 1),
    Color.fromRGBO(239, 156, 102, 1),
    Color.fromRGBO(252, 255, 235, 1),
    Color.fromRGBO(167, 230, 255, 1),
  ];

  static const List<Color> _unselectedItemColorOptions = [
    Color.fromRGBO(71, 71, 73, 1),
    Color.fromRGBO(255, 245, 255, 1),
    Color.fromRGBO(120, 171, 168, 1),
    Color.fromRGBO(0, 0, 0, 1),
    Color.fromRGBO(255, 255, 255, 1),
  ];

  static const List<Color> _bottomNavigationBarBackgroundColorOptions = [
    Color.fromRGBO(194, 203, 194, 1),
    Color.fromRGBO(12, 24, 68, 1),
    Color.fromRGBO(200, 207, 160, 1),
    Color.fromRGBO(8, 131, 149, 1),
    Color.fromRGBO(5, 12, 156, 1),
  ];

  @override
  void initState() {
    super.initState();
    _selectedIndex = MainFunctionsContexts.home.index;

    // Initialize _contextOptions here to include the switchContext function
    _mainContextsFirstPage = [
      Home(
        mainScreenContextSwitcher: externalContextSwitcher,
        overallScreenContextSwitcher: widget.overallScreenContextSwitcher,
      ),
      BookEntryForm(
        backContextSwitcher: goBack,
        reloadContext: forceRestartToFirstScreenForInternalScreen,
        internalScreenContextSwitcher: internalContextSwitcher,
      ),
      BookSaleInvoice(
        backContextSwitcher: goBack,
        reloadContext: forceRestartToFirstScreenForInternalScreen,
        internalScreenContextSwitcher: internalContextSwitcher,
      ),
      Bill(
        backContextSwitcher: goBack,
        internalScreenContextSwitcher: internalContextSwitcher,
      ),
      DebtReport(
        backContextSwitcher: goBack,
      ),
    ];

    _currentContext = _mainContextsFirstPage[_selectedIndex];
  }

  // this function is only for bottom bar navigation externally
  void externalContextSwitcher(int index) {
    setState(() {
      if (index != _selectedIndex) {
        // in case user spams one item many times and it also saves in the history lol
        backButtonScreensHistory.add({_selectedIndex: _currentContext});

        bottomBarScreensHistory[_selectedIndex] = _currentContext;
      }

      _selectedIndex = index;

      // If the selected index has a screen history, use the last one
      if (bottomBarScreensHistory.containsKey(_selectedIndex)) {
        _currentContext = bottomBarScreensHistory[_selectedIndex]!;
      } else {
        _currentContext = _mainContextsFirstPage[_selectedIndex];
      }

      // because home screen doesn't have back button so every widget history
      // must be deleted to minimalize the space occupied
      if (index == MainFunctionsContexts.home.index) {
        backButtonScreensHistory.clear();
      }
    });
  }

  void goBack() {
    setState(() {
      var recentHistory = backButtonScreensHistory.removeLast();
      _selectedIndex = recentHistory.keys.first;
      _currentContext = recentHistory.values.first;

      // by logic, there's no way that when you back to home screen and the `backButtonScreensHistory` list still has elements
      // it all thanks to `externalContextSwitcher` function above
      // so no delete `backButtonScreensHistory` list here!
    });
  }

  // this function is only for switching screen in one selected index internally
  void internalContextSwitcher(Widget screen) {
    setState(() {
      backButtonScreensHistory.add({_selectedIndex: _currentContext});
      _currentContext = screen;
    });
  }

  void forceRestartToFirstScreenForBottomBar(int index) {
    // in case there's many widget histories and you can't go back to first page
    setState(() {
      // double tap other item will result nothing
      if (index == _selectedIndex) {
        _currentContext = _mainContextsFirstPage[_selectedIndex];
        bottomBarScreensHistory.remove(index);
      }
    });
  }

  void forceRestartToFirstScreenForInternalScreen() {
    setState(() {
      _currentContext = _mainContextsFirstPage[_selectedIndex];
      bottomBarScreensHistory.remove(_selectedIndex);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _currentContext,
      bottomNavigationBar: Container(
        color: _scaffoldBackgroundColorOptions[_selectedIndex],
        height: 73,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.all(Radius.circular(100)),
              child: Container(
                height: 57,
                width: 360,
                decoration: BoxDecoration(
                  color: _bottomNavigationBarBackgroundColorOptions[
                      _selectedIndex],
                  borderRadius: const BorderRadius.all(Radius.circular(100)),
                ),
                child: BottomNavigationBar(
                  elevation: 0,
                  items: List.generate(5, (index) {
                    return BottomNavigationBarItem(
                      icon: GestureDetector(
                        onDoubleTap: () =>
                            forceRestartToFirstScreenForBottomBar(index),
                        child: getIconForIndex(index),
                      ),
                      label: getLabelForIndex(index),
                    );
                  }),
                  currentIndex: _selectedIndex,
                  selectedItemColor: _selectedItemColorOptions[_selectedIndex],
                  unselectedItemColor:
                      _unselectedItemColorOptions[_selectedIndex],
                  type: BottomNavigationBarType.fixed,
                  backgroundColor: Colors.transparent,
                  // don't need since we override the outer container for this
                  onTap: externalContextSwitcher,
                  showUnselectedLabels: true,
                  showSelectedLabels: true,
                  unselectedIconTheme: const IconThemeData(size: 20),
                  selectedIconTheme: const IconThemeData(size: 28),
                  selectedFontSize: 12.0,
                  unselectedFontSize: 9.0,
                ),
              ),
            ),
            const SizedBox(
              height: 16,
            )
          ],
        ),
      ),
    );
  }

  Widget getIconForIndex(int index) {
    switch (index) {
      case 0: // unfortunate we can't use `MainFunctionsContexts.home.index` since dart doesn't consider it as a `const`, in fact, it's `final`, please also notice this place too when changing order
        return const Icon(Icons.home);
      case 1:
        return const Icon(Icons.input);
      case 2:
        return const Icon(Icons.receipt);
      case 3:
        return const Icon(Icons.monetization_on_outlined);
      case 4:
        return const Icon(Icons.assignment);
      default:
        return const Icon(Icons.home);
    }
  }

  String getLabelForIndex(int index) {
    switch (index) {
      case 0:
        return 'Trang chủ';
      case 1:
        return 'Nhập sách';
      case 2:
        return 'Hóa đơn';
      case 3:
        return 'Thu tiền';
      case 4:
        return 'Báo cáo';
      default:
        return 'Trang chủ';
    }
  }
}
