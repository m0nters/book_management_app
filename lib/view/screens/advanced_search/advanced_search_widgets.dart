import 'package:diacritic/diacritic.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../model/book.dart';
import '../../../repository/book_repository.dart';
import '../mutual_widgets.dart';
import '../setting/setting.dart';
import 'advanced_search.dart';
import 'package:http/http.dart' as http;

bool hasSearchedForTheFirstTime =
    false; // use for displaying UI "nothing's here yet, please search something..."
bool isShowingSnackBar = false;
bool isTapped = false;

class AvailabilityLabel extends StatelessWidget {
  final String text;
  final Color backgroundColor;
  final Color foregroundColor;
  final String message;

  const AvailabilityLabel(
      {super.key,
      required this.text,
      required this.backgroundColor,
      this.foregroundColor = const Color.fromRGBO(245, 245, 245, 1),
      this.message =
          '' // meaning there's no hint text event when long press by default
      });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: message,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          text,
          style: TextStyle(color: foregroundColor, fontSize: 14),
        ),
      ),
    );
  }
}

class InStockLabel extends AvailabilityLabel {
  InStockLabel({super.key})
      : super(
            text: 'Còn hàng',
            backgroundColor: const Color.fromRGBO(8, 131, 149, 1),
            message: "Số lượng từ $lowOnStockThreshold trở lên");
}

class LowStockLabel extends AvailabilityLabel {
  LowStockLabel({super.key})
      : super(
            text: 'Còn ít hàng',
            backgroundColor: const Color.fromRGBO(239, 156, 102, 1),
            message: "Số lượng ít hơn $lowOnStockThreshold");
}

class OutOfStockLabel extends AvailabilityLabel {
  const OutOfStockLabel({super.key})
      : super(
          text: 'Hết hàng',
          backgroundColor: const Color.fromRGBO(255, 105, 105, 1),
        );
}

// =============================================================================

class SearchCardUICoreData {
  final String title;
  final String genre;
  final String author;
  final int quantity;
  final int price;
  String coverImageLink;
  final int monthlySalesCountTotal; // for "Bán chạy tháng" sort
  final DateTime latestImportedDate; // for "Mới nhất" sort

  SearchCardUICoreData({
    required this.title,
    required this.genre,
    required this.author,
    required this.quantity,
    required this.price,
    this.coverImageLink = 'https://via.placeholder.com/80',
    this.monthlySalesCountTotal = 0,
    required this.latestImportedDate,
  });
}

// =============================================================================

class SearchCardUI extends StatefulWidget {
  final int orderNum;
  final String title;
  final String genres;
  final String authors;
  final int quantity;
  final int price;
  final int hasSold;
  late String coverImageUrl;

  SearchCardUI({
    super.key,
    required this.orderNum,
    required this.title,
    required this.genres,
    required this.authors,
    required this.quantity,
    required this.price,
    required this.hasSold,
    this.coverImageUrl = "https://via.placeholder.com/80",
  });

  @override
  createState() => _SearchCardUIState();
}

class _SearchCardUIState extends State<SearchCardUI> {
  TextStyle contentStyle = const TextStyle(
    fontSize: 14,
    color: Color.fromRGBO(235, 244, 246, 1),
  );
  TextStyle contentTitleStyle = const TextStyle(
    fontSize: 14,
    color: Color.fromRGBO(235, 244, 246, 1),
    fontWeight: FontWeight.bold,
  );
  TextStyle titleStyle = const TextStyle(
    fontSize: 18,
    color: Color.fromRGBO(235, 244, 246, 1),
    fontWeight: FontWeight.bold,
  );

  @override
  void initState() {
    super.initState();
    widget.coverImageUrl = widget.coverImageUrl.isNotEmpty
        ? widget.coverImageUrl
        : "https://via.placeholder.com/80";
    _checkImageUrlValidity(widget.coverImageUrl).then((isValid) {
      if (!isValid) {
        setState(() {
          widget.coverImageUrl = "https://via.placeholder.com/80";
        });
      }
    });
  }

  Future<bool> _checkImageUrlValidity(String url) async {
    try {
      final response =
          await http.head(Uri.parse(url)).timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final contentType = response.headers['content-type'];
        if (contentType != null && contentType.startsWith('image/')) {
          return true;
        }
      } else if (response.isRedirect) {
        final redirectedUrl = response.headers['location'];
        if (redirectedUrl != null) {
          return _checkImageUrlValidity(redirectedUrl);
        }
      } else if (response.statusCode == 403) {
        // Access denied, treat as invalid
        return false;
      }
    } catch (e) {
      // Handle network issues, timeouts, etc.
    }
    return false;
  }

  double _measureTextWidth(String text, TextStyle style) {
    final TextPainter textPainter = TextPainter(
      text: TextSpan(text: text, style: style),
      maxLines: 1,
      textDirection: TextDirection.ltr,
    )..layout(minWidth: 0, maxWidth: double.infinity);
    return textPainter.size.width;
  }

  String _formatText(String text, {required textStyle, int maxWidth = 120}) {
    // maxWidth in pixels
    double textWidth = _measureTextWidth(text, textStyle);
    if (textWidth > maxWidth) {
      String truncatedText = text;
      do {
        truncatedText = truncatedText.substring(0, truncatedText.length - 1);
        textWidth = _measureTextWidth('$truncatedText...', textStyle);
      } while (textWidth > maxWidth);
      return '$truncatedText...';
    }
    return text;
  }

  Widget _getStockLabelWidget() {
    if (widget.quantity == 0) {
      return const OutOfStockLabel();
    } else if (widget.quantity < lowOnStockThreshold) {
      return LowStockLabel();
    } else {
      return InStockLabel();
    }
  }

  void showMessage({required String text}) {
    if (isShowingSnackBar) return; // Prevent spamming button

    isShowingSnackBar = true; // Set saving state to true

    ScaffoldMessenger.of(context)
        .showSnackBar(
          SnackBar(
            content: Text(text,
                style:
                    const TextStyle(color: Color.fromRGBO(235, 244, 246, 1))),
            backgroundColor: const Color.fromRGBO(8, 131, 149, 1),
            duration: const Duration(seconds: 2),
          ),
        )
        .closed
        .then((reason) {
      isShowingSnackBar = false; // Reset saving state after snack bar is closed
    });
  }

  void _showBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return GestureDetector(
          behavior: HitTestBehavior.opaque, // Ensures taps outside are detected
          onTap: () {
            Navigator.of(context).pop(); // Close the bottom sheet
          },
          child: GestureDetector(
            onTap: () {},
            // Prevents the bottom sheet itself from closing on tap
            child: DraggableScrollableSheet(
              initialChildSize: 0.5,
              minChildSize: 0.3,
              maxChildSize: 1.0,
              builder: (context, scrollController) {
                return Container(
                  decoration: const BoxDecoration(
                    color: Color.fromRGBO(7, 25, 82, 1),
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(25.0),
                    ),
                  ),
                  child: ListView(
                    controller: scrollController,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              "Thông tin chi tiết: ${widget.title}",
                              style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white),
                            ),
                            const SizedBox(height: 15),
                            Column(
                              children: [
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(20.0),
                                      child: SizedBox(
                                          height: 100,
                                          width: 100,
                                          child: Image.network(
                                            fit: BoxFit.cover,
                                            widget.coverImageUrl,
                                          )),
                                    ),
                                    const SizedBox(
                                      width: 15,
                                    ),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        SelectableText.rich(
                                          TextSpan(
                                            text: "Tồn kho: ",
                                            style: titleStyle.copyWith(
                                              fontFamily:
                                                  "Archivo", // Set to "Archivo"
                                            ),
                                            children: [
                                              TextSpan(
                                                text:
                                                    "${stdNumFormat.format(widget.quantity)} cuốn",
                                                style: titleStyle.copyWith(
                                                  fontWeight: FontWeight.normal,
                                                  fontFamily:
                                                      "Archivo", // Set to "Archivo"
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(height: 15),
                                        SelectableText(
                                          "Tình trạng còn hàng: ",
                                          style: titleStyle.copyWith(
                                            fontFamily:
                                                "Archivo", // Set to "Archivo"
                                          ),
                                        ),
                                        const SizedBox(
                                          height: 5,
                                        ),
                                        _getStockLabelWidget(),
                                      ],
                                    )
                                  ],
                                ),
                                const SizedBox(height: 15),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    SelectableText.rich(
                                      TextSpan(
                                        text: "Tác giả: ",
                                        style: titleStyle.copyWith(
                                          fontFamily:
                                              "Archivo", // Set to "Archivo"
                                        ),
                                        children: [
                                          TextSpan(
                                            text: widget.authors,
                                            style: titleStyle.copyWith(
                                              fontWeight: FontWeight.normal,
                                              fontFamily:
                                                  "Archivo", // Set to "Archivo"
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: 15),
                                    SelectableText.rich(
                                      TextSpan(
                                        text: "Thể loại: ",
                                        style: titleStyle.copyWith(
                                          fontFamily:
                                              "Archivo", // Set to "Archivo"
                                        ),
                                        children: [
                                          TextSpan(
                                            text: widget.genres,
                                            style: titleStyle.copyWith(
                                              fontWeight: FontWeight.normal,
                                              fontFamily:
                                                  "Archivo", // Set to "Archivo"
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: 15),
                                    SelectableText.rich(
                                      TextSpan(
                                        text: "Đơn giá: ",
                                        style: titleStyle.copyWith(
                                          fontFamily:
                                              "Archivo", // Set to "Archivo"
                                        ),
                                        children: [
                                          TextSpan(
                                            text:
                                                "${stdNumFormat.format(widget.price)} VND",
                                            style: titleStyle.copyWith(
                                              fontWeight: FontWeight.normal,
                                              fontFamily:
                                                  "Archivo", // Set to "Archivo"
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: 15),
                                    SelectableText.rich(
                                      TextSpan(
                                        text: "Đã bán: ",
                                        style: titleStyle.copyWith(
                                          fontFamily:
                                              "Archivo", // Set to "Archivo"
                                        ),
                                        children: [
                                          TextSpan(
                                            text:
                                                "${stdNumFormat.format(widget.hasSold)} cuốn",
                                            style: titleStyle.copyWith(
                                              fontWeight: FontWeight.normal,
                                              fontFamily:
                                                  "Archivo", // Set to "Archivo"
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(25),
      onTap: () async {
        if (isTapped) return;
        isTapped = true;
        await Future.delayed(const Duration(milliseconds: 200));
        isTapped = false;
        _showBottomSheet(context);
      },
      onLongPress: () {
        Clipboard.setData(ClipboardData(text: widget.title));
        showMessage(text: "Đã sao chép tên sách vào bộ nhớ tạm.");
      },
      child: Ink(
        height: 190,
        decoration: BoxDecoration(
          color: const Color.fromRGBO(7, 25, 82, 1),
          borderRadius: const BorderRadius.all(Radius.circular(25)),
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
        child: Stack(
          children: [
            Positioned(
              top: 7,
              left: 14,
              child: Text(
                widget.orderNum.toString(),
                style: const TextStyle(
                  color: Color.fromRGBO(235, 244, 246, 1),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ), // STT
            Positioned(
              top: 50,
              left: 30,
              child: Column(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(20.0),
                    child: SizedBox(
                        height: 80,
                        width: 80,
                        child: Image.network(
                          fit: BoxFit.cover,
                          widget.coverImageUrl,
                        )),
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                  _getStockLabelWidget(),
                ],
              ),
            ), // avatar
            Positioned(
              left: 30,
              top: 20,
              child: Text(
                _formatText(widget.title, textStyle: titleStyle, maxWidth: 305),
                style: titleStyle,
              ),
            ), // title
            Positioned(
              top: 50,
              left: 147,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        "Tác giả:",
                        style: contentTitleStyle,
                      ),
                      const SizedBox(width: 25),
                      Text(
                        _formatText(
                          widget.authors,
                          textStyle: contentStyle,
                        ),
                        style: contentStyle,
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Text(
                        "Thể loại:",
                        style: contentTitleStyle,
                      ),
                      const SizedBox(width: 20),
                      Text(
                        _formatText(widget.genres, textStyle: contentStyle),
                        style: contentStyle,
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Text(
                        "Số lượng:",
                        style: contentTitleStyle,
                      ),
                      const SizedBox(width: 15),
                      Text(
                        _formatText(
                          stdNumFormat.format(widget.quantity),
                          textStyle: contentStyle,
                        ),
                        style: contentStyle,
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Text(
                        "Đơn giá:",
                        style: contentTitleStyle,
                      ),
                      const SizedBox(width: 22),
                      Text(
                        "${_formatText(stdNumFormat.format(widget.price), textStyle: contentStyle, maxWidth: 100)} VND",
                        style: contentStyle,
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Text(
                        "Đã bán:",
                        style: contentTitleStyle,
                      ),
                      const SizedBox(width: 26),
                      Text(
                        _formatText(stdNumFormat.format(widget.hasSold),
                            textStyle: contentStyle, maxWidth: 100),
                        style: contentStyle,
                      ),
                    ],
                  ),
                ],
              ),
            ), // content
          ],
        ),
      ),
    );
  }
}

// =============================================================================

class AdvancedSearchForm extends StatefulWidget {
  final Color titleBarColor;
  final Color titleColor;
  final Color contentAreaColor;
  final Color contentTitleColor;
  final Color contentInputColor;
  final Color contentInputFormFillColor;
  final Color textFieldBorderColor;
  final Future<void> Function() fetchSearchData;

  const AdvancedSearchForm({
    super.key,
    this.titleBarColor = const Color.fromRGBO(7, 25, 82, 1),
    this.titleColor = const Color.fromRGBO(238, 237, 235, 1),
    this.contentAreaColor = const Color.fromRGBO(55, 183, 195, 1),
    this.contentTitleColor = const Color.fromRGBO(7, 25, 82, 1),
    this.contentInputColor = const Color.fromRGBO(7, 25, 82, 1),
    this.contentInputFormFillColor = Colors.white,
    this.textFieldBorderColor = Colors.grey,
    required this.fetchSearchData,
  });

  @override
  createState() => _AdvancedSearchFormState();
}

class _AdvancedSearchFormState extends State<AdvancedSearchForm> {
  final TextEditingController _bookNameController = TextEditingController();
  final TextEditingController _authorsController = TextEditingController();
  final TextEditingController _genresController = TextEditingController();
  bool isSearching = false;

  @override
  void dispose() {
    _bookNameController.dispose();
    _authorsController.dispose();
    _genresController.dispose();
    super.dispose();
  }

  String removeRedundantSpaces(String str) {
    // Replace multiple spaces with a single space
    return str.trim().replaceAll(RegExp(r'\s+'), ' ');
  }

  String formatNamesString(String str) {
    // Replace multiple spaces with a single space
    String cleanedStr = str.trim().replaceAll(RegExp(r'\s+'), ' ');

    // Remove any spaces before commas and ensure one space after each comma
    cleanedStr = cleanedStr.replaceAll(RegExp(r'\s*,\s*'), ', ');

    // Remove redundant commas (e.g., ",,," or leading/trailing commas)
    cleanedStr = cleanedStr.replaceAll(RegExp(r'(,\s*)+'), ', ').trim();
    if (cleanedStr.startsWith(',')) cleanedStr = cleanedStr.substring(1).trim();
    if (cleanedStr.endsWith(',')) {
      cleanedStr = cleanedStr.substring(0, cleanedStr.length - 1).trim();
    }

    return cleanedStr;
  }

  void search() async {
    if (isSearching) {
      return;
    }
    setState(() {
      isSearching = true;
    });
    hasSearchedForTheFirstTime = true;
    serverUploadedTitleInputData =
        removeRedundantSpaces(_bookNameController.text);
    serverUploadedGenresInputData = formatNamesString(_genresController.text);
    serverUploadedAuthorsInputData = formatNamesString(_authorsController.text);

    _bookNameController.text = serverUploadedTitleInputData;
    _genresController.text = serverUploadedGenresInputData;
    _authorsController.text = serverUploadedAuthorsInputData;

    await widget.fetchSearchData();

    if (mounted) {
      setState(() {
        isSearching = false;
      });
    }
  }

  Future<bool> autoFill(String bookName) async {
    bookName = removeRedundantSpaces(bookName);
    final bookRepo = BookRepository();
    final targetList = await bookRepo.getBooksByTitle(bookName);

    if (!mounted) return false;

    if (targetList.isEmpty) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text("Nhập không thành công",
                style: TextStyle(color: Color.fromRGBO(34, 12, 68, 1))),
            content: Text(
              "Không tồn tại sách nào có tên như vậy trong cơ sở dữ liệu! Tiếp tục tìm kiếm sẽ không có kết quả.",
              style: TextStyle(color: Colors.grey[700]),
            ),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Close the dialog
                },
                child: const Text("Đã hiểu",
                    style: TextStyle(color: Color.fromRGBO(255, 105, 105, 1))),
              ),
            ],
          );
        },
      );
      return false; // Return false if the targetList is empty
    }

    Book targetBookEntity = targetList[0];
    _bookNameController.text = bookName;
    _genresController.text = targetBookEntity.genres.join(', ');
    _authorsController.text = targetBookEntity.authors.join(', ');

    return true; // Return true if the targetList is not empty
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
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 180,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 33.0),
                        child: Row(
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
                      ),
                      const SizedBox(height: 4),
                      TextField(
                        onSubmitted: (text) {
                          autoFill(text).then((isValidName) {
                            if (isValidName) {
                              search();
                            }
                          });
                        },
                        controller: _bookNameController,
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
                                color: widget.textFieldBorderColor, width: 1.0),
                          ),
                        ),
                        style: TextStyle(color: widget.contentInputColor),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16.0),
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
                              Material(
                                color: Colors.transparent,
                                // Make the material transparent
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(100),
                                  // Ensure the splash is contained
                                  onTap: () {
                                    showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return AlertDialog(
                                          title: Text(
                                            "Thông tin",
                                            style: TextStyle(
                                                color: widget.titleBarColor),
                                          ),
                                          content: Text(
                                            "Trong trường hợp điền nhiều tên tác giả khác nhau, mỗi tên tác giả phải được phân cách nhau bằng dấu phẩy (,).",
                                            style: TextStyle(
                                                color: Colors.grey[700]),
                                          ),
                                          actions: <Widget>[
                                            TextButton(
                                              onPressed: () {
                                                Navigator.of(context).pop();
                                              },
                                              child: const Text(
                                                "Đã hiểu",
                                                style: TextStyle(
                                                  color: Color.fromRGBO(
                                                      255, 105, 105, 1),
                                                ),
                                              ),
                                            ),
                                          ],
                                        );
                                      },
                                    );
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.all(4),
                                    // Add padding to control the size
                                    child: Icon(
                                      Icons.info_outline,
                                      size: 20,
                                      color: widget.contentTitleColor,
                                    ),
                                  ),
                                ),
                              )
                            ],
                          ),
                          TextField(
                            controller: _authorsController,
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
                              Icon(Icons.category,
                                  color: widget.contentTitleColor),
                              const SizedBox(width: 4),
                              Text('Thể loại',
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: widget.contentTitleColor)),
                              Material(
                                color: Colors.transparent,
                                // Make the material transparent
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(100),
                                  // Ensure the splash is contained
                                  onTap: () {
                                    showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return AlertDialog(
                                          title: Text(
                                            "Thông tin",
                                            style: TextStyle(
                                                color: widget.titleBarColor),
                                          ),
                                          content: Text(
                                            "Trong trường hợp điền nhiều thể loại khác nhau, mỗi thể loại phải được phân cách nhau bằng dấu phẩy (,).",
                                            style: TextStyle(
                                                color: Colors.grey[700]),
                                          ),
                                          actions: <Widget>[
                                            TextButton(
                                              onPressed: () {
                                                Navigator.of(context).pop();
                                              },
                                              child: const Text(
                                                "Đã hiểu",
                                                style: TextStyle(
                                                  color: Color.fromRGBO(
                                                      255, 105, 105, 1),
                                                ),
                                              ),
                                            ),
                                          ],
                                        );
                                      },
                                    );
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.all(4),
                                    // Add padding to control the size
                                    child: Icon(
                                      Icons.info_outline,
                                      size: 20,
                                      color: widget.contentTitleColor,
                                    ),
                                  ),
                                ),
                              )
                            ],
                          ),
                          TextField(
                            controller: _genresController,
                            decoration: InputDecoration(
                              isDense: true,
                              filled: true,
                              fillColor: widget.contentInputFormFillColor,
                              hintText: "Nhập thể loại",
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
              search();
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
  final ScrollController totalScrollController;
  final ScrollController searchResultScrollController;

  const SearchResult(
      {super.key,
      required this.searchResultScrollController,
      required this.totalScrollController});

  @override
  State<SearchResult> createState() => _SearchResultState();
}

class _SearchResultState extends State<SearchResult> {
  String? sortOptionSelected;
  String? filterOptionSelected;

  List<Widget> buildResultCardsUI(List<SearchCardUICoreData> sortedList) {
    return sortedList
        .asMap() // Convert list to a map with indices
        .entries // Get the entries (key-value pairs)
        .expand((entry) => [
              SearchCardUI(
                orderNum: entry.key + 1,
                // Use the index as orderNum
                title: entry.value.title,
                genres: entry.value.genre,
                authors: entry.value.author,
                quantity: entry.value.quantity,
                price: entry.value.price,
                hasSold: entry.value.monthlySalesCountTotal,
                coverImageUrl: entry.value.coverImageLink,
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
  }

  void bestToWorstSellerSort() {
    processedDataList.sort((a, b) {
      int comparison =
          a.monthlySalesCountTotal.compareTo(b.monthlySalesCountTotal);
      if (comparison == 0) {
        return removeDiacritics(a.title).compareTo(removeDiacritics(b.title));
      } else {
        return -comparison;
      }
    });
  }

  void newestToOldestSort() {
    processedDataList.sort((a, b) {
      int comparison = a.latestImportedDate.compareTo(b.latestImportedDate);
      if (comparison == 0) {
        return removeDiacritics(a.title).compareTo(removeDiacritics(b.title));
      } else {
        return -comparison;
      }
    });
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
    // filter first, sort later
    if (filterOptionSelected != null) {
      filterStatus(filterOptionSelected);
    }
    if (sortOptionSelected != null) {
      sortOption(sortOptionSelected);
    }

    if (rawDataList.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        widget.totalScrollController.animateTo(
          widget.totalScrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      });
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
        if (hasSearchedForTheFirstTime) ...[
          Text(
            // number of results
            'Kết quả: ${processedDataList.length} kết quả',
            style: const TextStyle(
              fontSize: 25,
              fontWeight: FontWeight.bold,
              color: Color.fromRGBO(7, 25, 82, 1),
            ),
          ), // number of results
          const SizedBox(
            height: 15,
          ),
          Row(
            // sort, filter
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
          ), // sort, filter
          const SizedBox(
            height: 15,
          ),
          Expanded(
            child: Builder(
              builder: (context) {
                if (rawDataList.isNotEmpty) {
                  // if there're some results for the query
                  if (processedDataList.isNotEmpty) {
                    // and the current filter has results
                    return Material(
                      // use this to fix `InkWell` bug of elements in the list
                      color: const Color.fromRGBO(235, 244, 246, 1),
                      // don't use `SingleScrollChildView` because it's extremely
                      // laggy for large list, `ListView.builder` has built-in optimized
                      // methods for performance stuff.
                      child: ListView.builder(
                        controller: widget.searchResultScrollController,
                        itemCount: buildResultCardsUI(processedDataList).length,
                        itemBuilder: (context, index) {
                          return buildResultCardsUI(processedDataList)[index];
                        },
                      ),
                    );
                  } else {
                    // there's no result for current filter
                    return const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        NotFound(
                          errorText: "Không có kết quả",
                          paddingLeftPic: 20,
                          paddingTop: 65,
                        ),
                      ],
                    );
                  }
                } else {
                  // if there're no results at all
                  return const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      NotFound(
                        errorText: "Không có kết quả",
                        paddingLeftPic: 20,
                        paddingTop: 50,
                      ),
                    ],
                  ); // Placeholder if rawDataList is empty
                }
              },
            ),
          )
        ] else ...[
          const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              NotFound(
                errorText: "     Chưa có gì ở đây...\n Hãy bắt đầu tìm gì đó!",
                paddingLeftPic: 20,
                paddingTop: 50,
              ),
            ],
          )
        ],
      ],
    );
  }
}
