import 'package:flutter/material.dart';
import 'overall_screen_context_controller.dart';
import '../screens/home/home.dart';
import '../screens/book_entry_form/book_entry_form.dart';
import '../screens/book_sale_invoice/book_sale_invoice.dart';
import '../screens/bill/bill.dart';
import '../screens/monthly_report/outstanding_report/outstanding_report.dart';

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
  late Map<int, List<Widget>> navigationStack;
  late Widget _currentContext;

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
    navigationStack = {
      MainFunctionsContexts.home.index: [Home(
        mainScreenContextSwitcher: externalContextSwitcher,
        overallScreenContextSwitcher: widget.overallScreenContextSwitcher,
      )],
      MainFunctionsContexts.bookEntryForm.index: [BookEntryForm(
        backContextSwitcher: goBack,
        reloadContext: forceRestartToFirstScreen,
        internalScreenContextSwitcher: internalContextSwitcher,
      )],
      MainFunctionsContexts.bookSaleInvoice.index: [BookSaleInvoice(
        backContextSwitcher: goBack,
        reloadContext: forceRestartToFirstScreen,
        internalScreenContextSwitcher: internalContextSwitcher,
      )],
      MainFunctionsContexts.bill.index: [Bill(
        backContextSwitcher: goBack,
        reloadContext: forceRestartToFirstScreen,
        internalScreenContextSwitcher: internalContextSwitcher,
      )],
      MainFunctionsContexts.outstandingReport.index: [OutstandingReport(
        backContextSwitcher: goBack,
        reloadContext: forceRestartToFirstScreen,
        internalScreenContextSwitcher: internalContextSwitcher,
      )],
    };

    _currentContext = navigationStack[_selectedIndex]!.removeLast();
  }

  // this function is only for bottom bar navigation externally
  void externalContextSwitcher(int index) {
    setState(() {
      // Clicking the current item will result in no action
      if (index != _selectedIndex) {
        navigationStack[_selectedIndex]!.add(_currentContext);
        _selectedIndex = index;
        _currentContext = navigationStack[_selectedIndex]!.removeLast();
      }
    });
  }

  void goBack() {
    setState(() {
      _currentContext = navigationStack[_selectedIndex]!.removeLast();
    });
  }

  // this function is only for switching screens in one selected index internally
  void internalContextSwitcher(Widget screen) {
    setState(() {
      navigationStack[_selectedIndex]!.add(_currentContext);
      _currentContext = screen;
    });
  }

  void forceRestartToFirstScreen({int? index}) {
    setState(() {
      final currentIndex = index ?? _selectedIndex; // guard to check whether user double taps on other item or not

      if (currentIndex == _selectedIndex) {
        _currentContext = navigationStack[_selectedIndex]!.first;
        navigationStack[_selectedIndex] = [_currentContext];
      }
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
                        onDoubleTap: () => forceRestartToFirstScreen(index: index), // double tap on other item will result nothing
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

  // can't use switch case since it only accepts `const int`, while these are `final` type
  // we have to compensate the speed for the extensibility of the program, if we
  // really have to use switch case, there won't be thing like `MainFunctionsContexts.home.index`
  // but rather just magic number like `0`
  Widget getIconForIndex(int index) {
    if (index == MainFunctionsContexts.home.index) {
      return const Icon(Icons.home);
    }
    else if (index == MainFunctionsContexts.bookEntryForm.index) {
      return const Icon(Icons.input);
    }
    else if (index == MainFunctionsContexts.bookSaleInvoice.index) {
      return const Icon(Icons.receipt);
    }
    else if (index == MainFunctionsContexts.bill.index) {
      return const Icon(Icons.monetization_on_outlined);
    }
    else if (index == MainFunctionsContexts.outstandingReport.index) {
      return const Icon(Icons.assignment);
    }
    else {
      return const Icon(Icons.error);
    }
  }

  String getLabelForIndex(int index) {
    if (index == MainFunctionsContexts.home.index) {
      return 'Trang chủ';
    }
    else if (index == MainFunctionsContexts.bookEntryForm.index) {
      return 'Nhập sách';
    }
    else if (index == MainFunctionsContexts.bookSaleInvoice.index) {
      return 'Hóa đơn';
    }
    else if (index == MainFunctionsContexts.bill.index) {
      return 'Thu tiền';
    }
    else if (index == MainFunctionsContexts.outstandingReport.index) {
      return 'Báo cáo';
    }
    else {
      return 'Chưa cài đặt';
    }
  }
}
