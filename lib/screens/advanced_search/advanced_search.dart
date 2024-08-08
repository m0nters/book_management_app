import 'package:flutter/material.dart';
import '../../routing/overall_screen_routing.dart';
import 'advanced_search_widgets.dart';
import 'package:flutter/services.dart'; // Import for FilteringTextInputFormatter

late String serverUploadedTitleInputData;
late String serverUploadedGenreInputData;
late String serverUploadedAuthorInputData;
late int serverUploadedQuantityInputData;

// Fetch data from server to this list here
List<SearchCardCoreData> rawDataList = [
  SearchCardCoreData(
    title: "Có hai con mèo ngồi bên cửa sổ",
    genre: "Tiểu thuyết",
    author: "Nguyễn Nhật Ánh",
    quantity: 100,
    price: 82000,
    lastImportDate: DateTime(2024, 6, 25),
  ),
  SearchCardCoreData(
    title: "Đi qua hoa cúc",
    genre: "Tiểu thuyết",
    author: "Nguyễn Nhật Ánh",
    quantity: 20,
    price: 32800,
    lastImportDate: DateTime(2024, 6, 30),
  ),
  SearchCardCoreData(
    title: "Tư Duy Ngược",
    genre: "Tiểu thuyết",
    author: "Nguyễn Anh Dũng",
    quantity: 0,
    price: 69500,
    lastImportDate: DateTime(2024, 6, 28),
  ),
  SearchCardCoreData(
    title: "38 Bức Thư Rockefeller Gửi Cho Con Trai",
    genre: "Tiểu thuyết",
    author: "Thanh Hương biên dịch",
    quantity: 214,
    price: 32800,
    lastImportDate: DateTime(2024, 7, 12),
  ),
  SearchCardCoreData(
    title:
        "Nói Chuyện Là Bản Năng, Giữ Miệng Là Tu Dưỡng, Im Lặng Là Trí Tuệ (Tái Bản)",
    genre: "Tiểu thuyết",
    author: "Trương Tiếu Hằng",
    quantity: 12,
    price: 141750,
    lastImportDate: DateTime(2024, 7, 20),
  ),
  SearchCardCoreData(
    title: "Góc Nhỏ Có Nắng",
    genre: "Tiểu thuyết",
    author: "Little Rainbow",
    quantity: 250,
    price: 55760,
    lastImportDate: DateTime(2024, 7, 21),
  ),
  SearchCardCoreData(
    title: "Cây Cam Ngọt Của Tôi",
    genre: "Tiểu thuyết",
    author: "José Mauro de Vasconcelos",
    quantity: 125,
    price: 86400,
    lastImportDate: DateTime(2024, 7, 22),
  ),
  SearchCardCoreData(
    title: "Ghi Chép Pháp Y - Những Thi Thể Không Hoàn Chỉnh",
    genre: "Tiểu thuyết",
    author: "Lưu Bát Bách",
    quantity: 54,
    price: 97500,
    lastImportDate: DateTime(2024, 7, 23),
  ),
  SearchCardCoreData(
    title: "Hai Số Phận",
    genre: "Tiểu thuyết",
    author: "Jeffrey Archer",
    quantity: 86,
    price: 141000,
    lastImportDate: DateTime(2024, 7, 24),
  ),
  SearchCardCoreData(
    title: "Hai Số Phận",
    genre: "Tiểu thuyết",
    author: "Jeffrey Archer",
    quantity: 86,
    price: 141000,
    lastImportDate: DateTime(2024, 7, 24),
  ),
]; // we don't work frontend here since the filter functionality may delete one of the objects

// ============================================================================

// do not make copy since we aren't gonna change anything in `processedDataList`
// it will save performance A LOT!
List<SearchCardCoreData> processedDataList =
    rawDataList; // work frontend here, can filter things

class AdvancedSearch extends StatefulWidget {
  final Function(int) overallScreenContextSwitcher;

  const AdvancedSearch({super.key, required this.overallScreenContextSwitcher});

  @override
  State<AdvancedSearch> createState() => _AdvancedSearchState();
}

class _AdvancedSearchState extends State<AdvancedSearch> {
  final ScrollController _totalScrollController = ScrollController();
  final ScrollController _searchResultScrollController = ScrollController();

  bool _isLoading = false;

  void fetchSearchData() async {
    setState(() {
      _isLoading = true;
    });

    // Simulate a network call with a delay
    await Future.delayed(const Duration(milliseconds: 200));

    // Fetch your data here
    // For example, update rawDataList
    // rawDataList = await fetchFromServer();
    rawDataList.removeLast();

    setState(() {
      _isLoading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    // Listen to scroll changes in the result list view
    _searchResultScrollController.addListener(() {
      if (_searchResultScrollController.position.atEdge) {
        if (_searchResultScrollController.position.pixels != 0) {
          // If at the bottom, scroll the search form to the bottom as well
          _totalScrollController.animateTo(
            _totalScrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            // Adjust speed if needed
            curve: Curves.easeOut,
          );
        } else {
          // If at the top, scroll the search form to the top as well
          _totalScrollController.animateTo(
            _totalScrollController.position.minScrollExtent,
            duration: const Duration(milliseconds: 300),
            // Adjust speed if needed
            curve: Curves.easeOut,
          );
        }
      }
    });

    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
  }

  @override
  void dispose() {
    _totalScrollController.dispose();
    _searchResultScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: const Color.fromRGBO(235, 244, 246, 1),
        appBar: AppBar(
          backgroundColor: const Color.fromRGBO(235, 244, 246, 1),
          foregroundColor: const Color.fromRGBO(7, 25, 82, 1),
          title: const Text(
            "Tìm kiếm nâng cao",
            style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Color.fromRGBO(7, 25, 82, 1)),
          ),
          leading: IconButton(
            onPressed: () {
              widget.overallScreenContextSwitcher(
                  OverallScreenContexts.mainFunctions.index);
            },
            icon: const Icon(Icons.arrow_back),
            color: const Color.fromRGBO(7, 25, 82, 1),
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 0.0),
          child: ListView(
            controller: _totalScrollController,
            children: [
              SizedBox(
                height: 330,
                // some phones get render overflowed if the value is below this
                child: AdvancedSearchForm(
                  fetchDataFunction: () {
                    setState(() {
                      fetchSearchData();
                    });
                  },
                ),
              ),
              if (_isLoading)
                const Padding(
                    padding: EdgeInsets.symmetric(vertical: 150),
                    child: Center(child: CircularProgressIndicator()))
              else
                SizedBox(
                  height: MediaQuery.of(context).size.height - 330,
                  child: SearchResult(
                    searchResultScrollController: _searchResultScrollController,
                  ),
                ),
            ],
          ),
        ));
  }
}
