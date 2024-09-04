import 'package:flutter/material.dart';
import '../../../controller/book_order_controller.dart';
import '../../../controller/goods_receipt_controller.dart';
import '../../../model/book.dart';
import '../../../repository/book_order_repository.dart';
import '../../../repository/book_repository.dart';
import '../../../repository/goods_receipt_repository.dart';
import '../../routing/overall_screen_routing.dart';
import 'advanced_search_widgets.dart';
import 'package:flutter/services.dart'; // Import for FilteringTextInputFormatter

late String serverUploadedTitleInputData;
late String serverUploadedGenresInputData;
late String serverUploadedAuthorsInputData;

// Fetch data from server to this list here
List<SearchCardUICoreData> rawDataList =
    []; // we don't work frontend here since the filter functionality may delete one of the objects

// ============================================================================

// do not make copy since we aren't gonna change anything in `processedDataList`
// it will save performance A LOT!
List<SearchCardUICoreData> processedDataList =
    []; // work frontend here, can filter things

class AdvancedSearch extends StatefulWidget {
  final Function(int) overallScreenContextSwitcher;

  const AdvancedSearch({super.key, required this.overallScreenContextSwitcher});

  @override
  State<AdvancedSearch> createState() => _AdvancedSearchState();
}

class _AdvancedSearchState extends State<AdvancedSearch> {
  final ScrollController _totalScrollController = ScrollController();
  final ScrollController _searchResultsListScrollController =
      ScrollController();

  bool _isLoading = false;

  Future<void> fetchSearchData() async {
    setState(() {
      _isLoading = true;
    });

    final bookRepo = BookRepository();
    final goodsReceiptController =
        GoodsReceiptController(GoodsReceiptRepository());
    final bookOrderController = BookOrderController(BookOrderRepository());
    rawDataList.clear();

    // Function to fetch additional data for a list of books
    Future<List<SearchCardUICoreData>> fetchBookData(List<Book> bookList) async {
      List<SearchCardUICoreData> dataList = [];
      List<Future<void>> fetchBookDataFutures = [];

      for (Book book in bookList) {
        fetchBookDataFutures.add(Future.wait([
          goodsReceiptController.getLatestBookReceiptDate(book),
          bookOrderController.getBookSoldCurrentMonth(book),
        ]).then((results) {
          DateTime latestDateReceived =
              results[0] as DateTime? ?? DateTime(2000, 1, 1);
          int soldThisMonth = results[1] as int? ?? 0;

          dataList.add(SearchCardUICoreData(
            title: book.title,
            genre: book.genres.join(', '),
            author: book.authors.join(', '),
            quantity: book.stockQuantity,
            price: book.price as int,
            coverImageLink: book.coverImageLink,
            latestImportedDate: latestDateReceived,
            monthlySalesCountTotal: soldThisMonth,
          ));
        }));
      }

      await Future.wait(fetchBookDataFutures);
      return dataList;
    }

    if (serverUploadedTitleInputData == '' &&
        serverUploadedAuthorsInputData == '' &&
        serverUploadedGenresInputData == '') {
      // Case: No filters applied, fetch all books
      final allBooks = await bookRepo.getAllBooks();
      rawDataList = await fetchBookData(allBooks);
    } else if (serverUploadedTitleInputData.isNotEmpty) {
      // Case: Search by title
      final listBookByTitle =
          await bookRepo.getBooksByTitle(serverUploadedTitleInputData);
      if (listBookByTitle.isEmpty) {
        setState(() {
          _isLoading = false;
        });
        rawDataList.clear();
        processedDataList.clear();
        return;
      }
      Book targetBookEntity = listBookByTitle[0];

      final latestDateReceived = await goodsReceiptController
          .getLatestBookReceiptDate(targetBookEntity) ?? DateTime(2000, 1, 1);
      final soldThisMonth =
          await bookOrderController.getBookSoldCurrentMonth(targetBookEntity);

      rawDataList.add(SearchCardUICoreData(
        title: targetBookEntity.title,
        genre: targetBookEntity.genres.join(', '),
        author: targetBookEntity.authors.join(', '),
        quantity: targetBookEntity.stockQuantity,
        price: targetBookEntity.price as int,
        coverImageLink: targetBookEntity.coverImageLink,
        latestImportedDate: latestDateReceived,
        monthlySalesCountTotal: soldThisMonth,
      ));
    } else {
      // Case: Search by genre, author
      List<Book> finalBookList = [];

      if (serverUploadedGenresInputData.isNotEmpty &&
          serverUploadedAuthorsInputData.isNotEmpty) {
        final listBookByGenre =
            await bookRepo.getBooksByGenres(serverUploadedGenresInputData);
        final listBookByAuthor =
            await bookRepo.getBooksByAuthors(serverUploadedAuthorsInputData);

        Set<String> genreBookIDs =
            listBookByGenre.map((book) => book.bookID).toSet();
        finalBookList = listBookByAuthor
            .where((book) => genreBookIDs.contains(book.bookID))
            .toList();
      } else if (serverUploadedGenresInputData.isNotEmpty) {
        finalBookList =
            await bookRepo.getBooksByGenres(serverUploadedGenresInputData);
      } else if (serverUploadedAuthorsInputData.isNotEmpty) {
        finalBookList =
            await bookRepo.getBooksByAuthors(serverUploadedAuthorsInputData);
      }

      if (finalBookList.isEmpty) {
        setState(() {
          _isLoading = false;
        });
        rawDataList.clear();
        processedDataList.clear();
        return;
      }

      rawDataList = await fetchBookData(finalBookList);
    }

    processedDataList = rawDataList;

    setState(() {
      _isLoading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    // Listen to scroll changes in the result list view
    _searchResultsListScrollController.addListener(() {
      if (_searchResultsListScrollController.position.atEdge) {
        if (_searchResultsListScrollController.position.pixels != 0) {
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

    hasSearchedForTheFirstTime = false;

    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
  }

  @override
  void dispose() {
    _totalScrollController.dispose();
    _searchResultsListScrollController.dispose();
    rawDataList.clear();
    processedDataList.clear();
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
          actions: [
            IconButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: const Text(
                          "TÍNH NĂNG",
                          style: TextStyle(color: Color.fromRGBO(7, 25, 82, 1)),
                        ),
                        content: Text(
                          "Để trống tất cả các trường và bấm tìm kiếm để trả về tất cả sách mà nhà sách hỗ trợ.",
                          style: TextStyle(color: Colors.grey[700]),
                        ),
                        actions: <Widget>[
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: const Text(
                              "Đã hiểu",
                              style: TextStyle(
                                color: Color.fromRGBO(255, 105, 105, 1),
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  );
                },
                icon: const Icon(Icons.info))
          ],
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
                  fetchSearchData: fetchSearchData,
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
                    totalScrollController: _totalScrollController,
                    searchResultScrollController:
                        _searchResultsListScrollController,
                  ),
                ),
            ],
          ),
        ));
  }
}
