import 'package:flutter/material.dart';
import '../../controllers/overall_screen_context_controller.dart';
import '../mutual_widgets.dart';
import '../setting/setting.dart';
import 'advanced_search_widgets.dart';
import 'package:diacritic/diacritic.dart';
import 'package:flutter/services.dart'; // Import for FilteringTextInputFormatter


late String serverUploadedTitleInputData;
late String serverUploadedGenreInputData;
late String serverUploadedAuthorInputData;
late int serverUploadedQuantityInputData;

class SearchCardData {
  int orderNum;
  final String title;
  final String genre;
  final String author;
  final int quantity;
  final int price;
  final int monthlySalesCountTotal; // for "Bán chạy tháng" sort
  final DateTime lastImportDate; // for "Mới nhất" sort

  SearchCardData({
    required this.orderNum,
    required this.title,
    required this.genre,
    required this.author,
    required this.quantity,
    required this.price,
    this.monthlySalesCountTotal = 0,
    required this.lastImportDate,
  });
}

// Fetch data from server to this list here
List<SearchCardData> rawDataList = [
  SearchCardData(
    orderNum: 1,
    title: "Có hai con mèo ngồi bên cửa sổ",
    genre: "Tiểu thuyết",
    author: "Nguyễn Nhật Ánh",
    quantity: 100,
    price: 82000,
    lastImportDate: DateTime(2024, 6, 25),
  ),
  SearchCardData(
    orderNum: 2,
    title: "Đi qua hoa cúc",
    genre: "Tiểu thuyết",
    author: "Nguyễn Nhật Ánh",
    quantity: 20,
    price: 32800,
    lastImportDate: DateTime(2024, 6, 30),
  ),
  SearchCardData(
    orderNum: 3,
    title: "Tư Duy Ngược",
    genre: "Tiểu thuyết",
    author: "Nguyễn Anh Dũng",
    quantity: 0,
    price: 69500,
    lastImportDate: DateTime(2024, 6, 28),
  ),
  SearchCardData(
    orderNum: 4,
    title: "38 Bức Thư Rockefeller Gửi Cho Con Trai",
    genre: "Tiểu thuyết",
    author: "Thanh Hương biên dịch",
    quantity: 214,
    price: 32800,
    lastImportDate: DateTime(2024, 7, 12),
  ),
  SearchCardData(
    orderNum: 5,
    title:
    "Nói Chuyện Là Bản Năng, Giữ Miệng Là Tu Dưỡng, Im Lặng Là Trí Tuệ (Tái Bản)",
    genre: "Tiểu thuyết",
    author: "Trương Tiếu Hằng",
    quantity: 12,
    price: 141750,
    lastImportDate: DateTime(2024, 7, 20),
  ),
  SearchCardData(
    orderNum: 6,
    title: "Góc Nhỏ Có Nắng",
    genre: "Tiểu thuyết",
    author: "Little Rainbow",
    quantity: 250,
    price: 55760,
    lastImportDate: DateTime(2024, 7, 21),
  ),
  SearchCardData(
    orderNum: 7,
    title: "Cây Cam Ngọt Của Tôi",
    genre: "Tiểu thuyết",
    author: "José Mauro de Vasconcelos",
    quantity: 125,
    price: 86400,
    lastImportDate: DateTime(2024, 7, 22),
  ),
  SearchCardData(
    orderNum: 8,
    title: "Ghi Chép Pháp Y - Những Thi Thể Không Hoàn Chỉnh",
    genre: "Tiểu thuyết",
    author: "Lưu Bát Bách",
    quantity: 54,
    price: 97500,
    lastImportDate: DateTime(2024, 7, 23),
  ),
  SearchCardData(
    orderNum: 9,
    title: "Hai Số Phận",
    genre: "Tiểu thuyết",
    author: "Jeffrey Archer",
    quantity: 86,
    price: 141000,
    lastImportDate: DateTime(2024, 7, 24),
  ),
  SearchCardData(
    orderNum: 10,
    title: "Hai Số Phận",
    genre: "Tiểu thuyết",
    author: "Jeffrey Archer",
    quantity: 86,
    price: 141000,
    lastImportDate: DateTime(2024, 7, 24),
  ),
]; // we don't work frontend here

// ============================================================================

List<SearchCardData> processedDataList = rawDataList; // work frontend here

// ============================================================================

class AdvancedSearchForm extends StatefulWidget {
  final Color titleBarColor;
  final Color titleColor;
  final Color contentAreaColor;
  final Color contentTitleColor;
  final Color contentInputColor;
  final Color contentInputFormFillColor;
  final Color textFieldBorderColor;
  final VoidCallback fetchDataFunction;

  const AdvancedSearchForm({
    super.key,
    required this.titleBarColor,
    required this.titleColor,
    required this.contentAreaColor,
    required this.contentTitleColor,
    required this.contentInputColor,
    required this.contentInputFormFillColor,
    required this.textFieldBorderColor,
    required this.fetchDataFunction,
  });

  @override
  createState() => _AdvancedSearchFormState();
}

class _AdvancedSearchFormState extends State<AdvancedSearchForm> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _authorController = TextEditingController();
  String _genreController = '';
  final TextEditingController _quantityController = TextEditingController();

  final List<String> genres = [
    'Tình cảm',
    'Bí ẩn',
    'Giả tưởng và khoa học viễn tưởng',
    'Kinh dị, giật gân',
    'Truyền cảm hứng',
    'Tiểu sử, tự truyện và hồi ký',
    'Truyện ngắn',
    'Lịch sử',
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _authorController.dispose();
    _quantityController.dispose();
    super.dispose();
  }

  void uploadDataToServer() {
    // your backend here
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          // title bar
          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
          decoration: BoxDecoration(
            color: widget.titleBarColor,
            borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(8), topRight: Radius.circular(8)),
            boxShadow: hasShadow
                ? const [
              BoxShadow(
                offset: Offset(0, 4),
                color: Colors.grey,
                blurRadius: 4,
              )
            ]
                : null,
          ),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Điền ít nhất một trong những thông tin sau',
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: widget.titleColor),
            ),
          ),
        ),
        Container(
          // content area
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: widget.contentAreaColor,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(8),
                bottomRight: Radius.circular(8),
              ),
              boxShadow: hasShadow
                  ? const [
                BoxShadow(
                  offset: Offset(0, 4),
                  color: Colors.grey,
                  blurRadius: 4,
                )
              ]
                  : null,
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.book, color: widget.contentTitleColor),
                              const SizedBox(width: 4),
                              Text('Tên sách',
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: widget.contentTitleColor)),
                            ],
                          ),
                          const SizedBox(height: 4),
                          TextField(
                            controller: _titleController,
                            decoration: InputDecoration(
                              isDense: true,
                              filled: true,
                              fillColor: widget.contentInputFormFillColor,
                              hintText: "Nhập tên sách",
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(4),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                    color: widget.textFieldBorderColor,
                                    width: 1.0),
                              ),
                            ),
                            style: TextStyle(color: widget.contentInputColor),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.category,
                                  color: widget.contentTitleColor),
                              const SizedBox(width: 4),
                              Text('Thể loại',
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: widget.contentTitleColor)),
                            ],
                          ),
                          const SizedBox(height: 4),
                          CustomDropdownMenu(
                            options: genres,
                            action: (genre) => _genreController = genre ?? '',
                            fillColor: widget.contentInputFormFillColor,
                            width: double.infinity,
                            hintText: 'Chọn một thể loại',
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 28),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.person,
                                  color: widget.contentTitleColor),
                              const SizedBox(width: 4),
                              Text('Tác giả',
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: widget.contentTitleColor)),
                            ],
                          ),
                          const SizedBox(height: 4),
                          TextField(
                            controller: _authorController,
                            decoration: InputDecoration(
                              isDense: true,
                              filled: true,
                              fillColor: widget.contentInputFormFillColor,
                              hintText: "Nhập tác giả",
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(4),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                    color: widget.textFieldBorderColor,
                                    width: 1.0),
                              ),
                            ),
                            style: TextStyle(color: widget.contentInputColor),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.production_quantity_limits,
                                  color: widget.contentTitleColor),
                              const SizedBox(width: 4),
                              Text('Số lượng',
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: widget.contentTitleColor)),
                            ],
                          ),
                          const SizedBox(height: 4),
                          TextField(
                            controller: _quantityController,
                            keyboardType: TextInputType.number,
                            inputFormatters: <TextInputFormatter>[
                              FilteringTextInputFormatter.allow(RegExp(r'[0-9]')), // Allow only digits
                            ],
                            decoration: InputDecoration(
                              isDense: true,
                              filled: true,
                              fillColor: widget.contentInputFormFillColor,
                              hintText: "Chọn số lượng",
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(4),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                    color: widget.textFieldBorderColor,
                                    width: 1.0),
                              ),
                            ),
                            style: TextStyle(color: widget.contentInputColor),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            )),
        const Spacer(),
        Center(
          child: CustomRoundedButton(
            backgroundColor: const Color.fromRGBO(7, 25, 82, 1),
            foregroundColor: const Color.fromRGBO(235, 244, 246, 1),
            title: "Tìm kiếm",
            height: 45,
            width: 165,
            fontSize: 16,
            onPressed: () {
              serverUploadedTitleInputData = _titleController.text;
              serverUploadedGenreInputData = _genreController;
              serverUploadedAuthorInputData = _authorController.text;
              serverUploadedQuantityInputData = _quantityController.text == '' ? 0 : int.parse(_quantityController.text);

              uploadDataToServer();
              widget.fetchDataFunction();
            },
          ),
        ),
        const Spacer(),
      ],
    );
  }
}

// ============================================================================

class SearchResult extends StatefulWidget {
  final ScrollController searchResultScrollController;
  const SearchResult({super.key, required this.searchResultScrollController});

  @override
  State<SearchResult> createState() => _SearchResultState();
}

class _SearchResultState extends State<SearchResult> {
  String? sortOptionSelected;
  String? filterOptionSelected;

  List<Widget> buildResultCardsUI(List<SearchCardData> sortedList) {
    return sortedList
        .expand((element) => [
      SearchCard(
        orderNum: element.orderNum,
        title: element.title,
        genre: element.genre,
        author: element.author,
        quantity: element.quantity,
        price: element.price,
      ),
      const SizedBox(height: 15),
    ])
        .toList();
  }

  void sortPrices({required bool ascending}) {
    processedDataList.sort((a, b) {
      int priceComparison = a.price.compareTo(b.price);
      if (priceComparison == 0) {
        // If prices are equal, sort by name (always ascending)
        // by default Dart doesn't sort Unicode letters so I have to write like this (install `diacritic` library)
        return removeDiacritics(a.title).compareTo(removeDiacritics(b.title));
      } else {
        return ascending ? priceComparison : -priceComparison;
      }
    });
    for (int i = 0; i < processedDataList.length; i++) {
      processedDataList[i].orderNum = i + 1;
    }
  }

  void bestToWorstSellerSort() {
    processedDataList.sort((a, b) {
      int comparison =
      a.monthlySalesCountTotal.compareTo(b.monthlySalesCountTotal);
      if (comparison == 0) {
        return removeDiacritics(a.title).compareTo(removeDiacritics(b.title));
      } else {
        return -comparison; // Ascending order
      }
    });
    for (int i = 0; i < processedDataList.length; i++) {
      processedDataList[i].orderNum = i + 1;
    }
  }

  void newestToOldestSort() {
    processedDataList.sort((a, b) {
      int comparison = a.lastImportDate.compareTo(b.lastImportDate);
      if (comparison == 0) {
        return removeDiacritics(a.title).compareTo(removeDiacritics(b.title));
      } else {
        return -comparison; // Ascending order
      }
    });
    for (int i = 0; i < processedDataList.length; i++) {
      processedDataList[i].orderNum = i + 1;
    }
  }

  void filterStatus(String? status) {
    if (status == 'Tất cả') {
      // Show all items
      processedDataList = rawDataList;
    } else if (status == 'Còn hàng') {
      // Show only items with quantity > 0
      processedDataList =
          rawDataList.where((item) => item.quantity > 0).toList();
    } else if (status == 'Hết hàng') {
      // Show only items with quantity == 0
      processedDataList =
          rawDataList.where((item) => item.quantity == 0).toList();
    }
  }

  void sortOption(String? optionSelected) {
    if (sortOptionSelected == "Bán chạy tháng") {
      bestToWorstSellerSort();
    } else if (sortOptionSelected == "Mới nhất") {
      newestToOldestSort();
    } else if (sortOptionSelected == "Giá từ thấp tới cao") {
      sortPrices(ascending: true);
    } else if (sortOptionSelected == "Giá từ cao tới thấp") {
      sortPrices(ascending: false);
    }
  }

  void rebuildResultData() {
    if (filterOptionSelected != null) {
      filterStatus(filterOptionSelected);
    }
    if (sortOptionSelected != null) {
      sortOption(sortOptionSelected);
    }
  }

  @override
  void initState() {
    super.initState();
    sortOptionSelected = "Bán chạy tháng";
    filterOptionSelected = "Tất cả";
    rebuildResultData();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Kết quả: ${processedDataList.length} kết quả',
          style: const TextStyle(
            fontSize: 25,
            fontWeight: FontWeight.bold,
            color: Color.fromRGBO(7, 25, 82, 1),
          ),
        ),
        const SizedBox(
          height: 15,
        ),
        Row(
          children: [
            const Text(
              'Sắp xếp theo: ',
              style: TextStyle(
                fontSize: 16,
                color: Color.fromRGBO(7, 25, 82, 1),
                fontWeight: FontWeight.bold,
              ),
            ),
            CustomDropdownMenu(
              options: const [
                'Bán chạy tháng',
                'Mới nhất',
                'Giá từ thấp tới cao',
                'Giá từ cao tới thấp'
              ],
              initialValue: sortOptionSelected,
              action: (selected) {
                setState(() {
                  sortOptionSelected = selected;
                  rebuildResultData();
                });
              },
              fillColor: Colors.white,
              width: 140,
              fontSize: 14,
            ),
            const Spacer(),
            CustomDropdownMenu(
              options: const ['Tất cả', 'Còn hàng', 'Hết hàng'],
              initialValue: filterOptionSelected,
              action: (status) {
                setState(() {
                  filterOptionSelected = status;
                  rebuildResultData();
                });
              },
              fillColor: Colors.white,
              width: 110,
              fontSize: 14,
            ),
          ],
        ),
        const SizedBox(
          height: 15,
        ),
        Expanded(
          child: Material(
            color: const Color.fromRGBO(235, 244, 246, 1),
            child: ListView.builder(
              controller: widget.searchResultScrollController,
              itemCount: buildResultCardsUI(processedDataList).length,
              itemBuilder: (context, index) {
                return buildResultCardsUI(processedDataList)[index];
              },
            ),
          ),
        ),
      ],
    );
  }
}

// ============================================================================

class AdvancedSearch extends StatefulWidget {
  final Function(int) overallScreenContextSwitcher;

  const AdvancedSearch({super.key, required this.overallScreenContextSwitcher});

  @override
  State<AdvancedSearch> createState() => _AdvancedSearchState();
}

class _AdvancedSearchState extends State<AdvancedSearch> {
  final ScrollController _totalScrollController = ScrollController();
  final ScrollController _searchResultScrollController = ScrollController();
  void fetchDataFromServer() {
    processedDataList.removeLast();
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
        }
        else {
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
                height: 330, // some phones get render overflowed if the value is below this
                child: AdvancedSearchForm(
                  titleBarColor: const Color.fromRGBO(7, 25, 82, 1),
                  titleColor: const Color.fromRGBO(238, 237, 235, 1),
                  contentAreaColor: const Color.fromRGBO(55, 183, 195, 1),
                  contentTitleColor: const Color.fromRGBO(7, 25, 82, 1),
                  contentInputColor: const Color.fromRGBO(7, 25, 82, 1),
                  contentInputFormFillColor: Colors.white,
                  textFieldBorderColor: Colors.grey,
                  fetchDataFunction: () {
                    setState(() {
                      fetchDataFromServer();
                    });
                  },
                ),
              ),
              SizedBox(
                  height: MediaQuery.of(context).size.height - 330,
                  child: SearchResult(searchResultScrollController: _searchResultScrollController,)),
            ],
          ),
        ));
  }
}
