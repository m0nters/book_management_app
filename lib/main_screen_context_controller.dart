import 'package:flutter/material.dart';
import 'overall_screen_context_controller.dart';
import 'home.dart';
import 'book_entry_form.dart';
import 'book_sale_invoice.dart';
import 'bill.dart';
import 'debt_report.dart';
import 'dart:collection';

Queue<int> previousContexts = Queue<int>(); // for the back button in every context in main screen

class MainFunctionsContextController extends StatefulWidget {
  final int startPage;
  final Function(int) overallScreenContextSwitcher;

  const MainFunctionsContextController(
      {required this.startPage,
      required this.overallScreenContextSwitcher,
      super.key});

  @override
  createState() => _MainFunctionsContextControllerState();
}

class _MainFunctionsContextControllerState
    extends State<MainFunctionsContextController> {
  late int _selectedIndex;

  static List<Widget> _contextOptions = [];

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.startPage;

    // Initialize _contextOptions here to include the switchContext function
    _contextOptions = [
      Home(
        mainScreenContextSwitcher: switchContext,
        overallScreenContextSwitcher: widget.overallScreenContextSwitcher,
      ),
      BookEntryForm(mainScreenContextSwitcher: goBack,),
      BookSaleInvoice(mainScreenContextSwitcher: goBack,),
      Bill(mainScreenContextSwitcher: goBack,),
      DebtReport(mainScreenContextSwitcher: goBack,),
    ];
  }

  static const List<Color> _bottomNavigationBarBackgroundColorOptions = [
    Color.fromRGBO(194, 203, 194, 1),
    Color.fromRGBO(12, 24, 68, 1),
    Color.fromRGBO(200, 207, 160, 1),
    Color.fromRGBO(8, 131, 149, 1),
    Color.fromRGBO(5, 12, 156, 1),
  ];

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

  void switchContext(int index) {
    setState((){
      previousContexts.add(_selectedIndex);
      _selectedIndex = index;
      if (index == MainFunctionsContexts.home.index){
        previousContexts.clear();
      }
    });
  }

  void goBack(){
    setState(() => _selectedIndex = previousContexts.removeLast());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _contextOptions[_selectedIndex],
      bottomNavigationBar: Container(
        color: _scaffoldBackgroundColorOptions[_selectedIndex],
        height: 72,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.all(Radius.circular(100)),
              child: Container(
                height: 56,
                width: 360,
                decoration: BoxDecoration(
                  color: _bottomNavigationBarBackgroundColorOptions[
                      _selectedIndex],
                  borderRadius: const BorderRadius.all(Radius.circular(100)),
                ),
                child: BottomNavigationBar(
                  elevation: 0,
                  items: const <BottomNavigationBarItem>[
                    BottomNavigationBarItem(
                      icon: Icon(Icons.home),
                      label: 'Trang chủ',
                    ),
                    BottomNavigationBarItem(
                      icon: Icon(Icons.input),
                      label: 'Nhập sách',
                    ),
                    BottomNavigationBarItem(
                      icon: Icon(Icons.receipt),
                      label: 'Hóa đơn',
                    ),
                    BottomNavigationBarItem(
                      icon: Icon(Icons.monetization_on_outlined),
                      label: 'Tiền',
                    ),
                    BottomNavigationBarItem(
                      icon: Icon(Icons.assignment),
                      label: 'Báo cáo',
                    ),
                  ],
                  currentIndex: _selectedIndex,
                  selectedItemColor: _selectedItemColorOptions[_selectedIndex],
                  unselectedItemColor:
                      _unselectedItemColorOptions[_selectedIndex],
                  type: BottomNavigationBarType.fixed,
                  backgroundColor: Colors.transparent,
                  // don't need since we override the outer container for this
                  onTap: switchContext,
                  showUnselectedLabels: true,
                  showSelectedLabels: true,
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
}
