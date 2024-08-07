import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'home_widgets.dart';
import '../../routing/overall_screen_routing.dart';

class Home extends StatefulWidget {
  final Function(int) mainScreenContextSwitcher;
  final Function(int) overallScreenContextSwitcher;

  const Home({super.key, required this.mainScreenContextSwitcher, required this.overallScreenContextSwitcher});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
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
      backgroundColor: const Color.fromRGBO(235, 244, 246, 1),
      appBar: AppBar(
        backgroundColor: const Color.fromRGBO(235, 244, 246, 1),
        actions: [
          IconButton(onPressed: (){
            widget.overallScreenContextSwitcher(OverallScreenContexts.setting.index);
          }, icon: const Icon(Icons.settings)),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 0.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              HomeSearchBar(mainFunctionsContextSwitcher: widget.mainScreenContextSwitcher, mainScreenContextSwitcher: widget.overallScreenContextSwitcher,),
              const SizedBox(height: 20.0),
              const Text(
                'CHỨC NĂNG CHÍNH',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16.0),
              HomeFunctionButton(
                text: 'Phiếu nhập sách',
                onPressed: () {
                  widget.mainScreenContextSwitcher(MainFunctionsContexts.bookEntryForm.index);
                },
              ),
              const SizedBox(height: 16.0),
              HomeFunctionButton(
                text: 'Hóa đơn bán sách',
                onPressed: () {
                  widget.mainScreenContextSwitcher(MainFunctionsContexts.bookSaleInvoice.index);
                },
              ),
              const SizedBox(height: 16.0),
              HomeFunctionButton(
                text: 'Phiếu thu tiền',
                onPressed: () {
                  widget.mainScreenContextSwitcher(MainFunctionsContexts.bill.index);
                },
              ),
              const SizedBox(height: 16.0),
              HomeFunctionButton(
                text: 'Báo cáo tháng',
                onPressed: () {
                  widget.mainScreenContextSwitcher(MainFunctionsContexts.outstandingReport.index);
                },
              ),
              const SizedBox(height: 36.0),
              const Text(
                'TÙY CHỈNH',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16.0),
              HomeFunctionButton(
                text: 'Thay đổi quy định',
                onPressed: () {
                  widget.overallScreenContextSwitcher(OverallScreenContexts.editRegulation.index);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
