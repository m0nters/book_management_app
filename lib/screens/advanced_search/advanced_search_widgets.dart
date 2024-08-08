import 'package:diacritic/diacritic.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:permission_handler/permission_handler.dart';
import '../mutual_widgets.dart';
import '../setting/setting.dart';
import 'advanced_search.dart';

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
        this.message = '' // meaning there's no hint text event when long press by default
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
      backgroundColor: const Color.fromRGBO(255, 105, 105, 1),);
}

// =============================================================================

class SearchCardCoreData {
  final String title;
  final String genre;
  final String author;
  final int quantity;
  final int price;
  final int monthlySalesCountTotal; // for "Bán chạy tháng" sort
  final DateTime lastImportDate; // for "Mới nhất" sort

  SearchCardCoreData({
    required this.title,
    required this.genre,
    required this.author,
    required this.quantity,
    required this.price,
    this.monthlySalesCountTotal = 0,
    required this.lastImportDate,
  });
}

// =============================================================================

class SearchCardUI extends StatefulWidget {
  final int orderNum;
  final String title;
  final String genre;
  final String author;
  final int quantity;
  final int price;
  final String imageUrl;

  const SearchCardUI({
    super.key,
    required this.orderNum,
    required this.title,
    required this.genre,
    required this.author,
    required this.quantity,
    required this.price,
    this.imageUrl = "https://via.placeholder.com/80",
  });

  @override
  createState() => _SearchCardUIState();
}

class _SearchCardUIState extends State<SearchCardUI> {
  File? _image;
  TextStyle contentStyle = const TextStyle(
    fontSize: 14,
    color: Color.fromRGBO(235, 244, 246, 1),
  );
  TextStyle titleStyle = const TextStyle(
    fontSize: 18,
    color: Color.fromRGBO(235, 244, 246, 1),
    fontWeight: FontWeight.bold,
  );

  Future<void> _pickImage() async {
    final status = await Permission.storage.request();

    if (status.isGranted) {
      final pickedFile = await ImagePicker().pickImage(
          source: ImageSource.gallery);
      setState(() {
        if (pickedFile != null) {
          _image = File(pickedFile.path);
        }
      });
    } else if (status.isPermanentlyDenied) {
      // Handle permanently denied permission (guide user to app settings)
      showDialog(
        context: context,
        builder: (context) =>
            AlertDialog(
              title: const Text('Yêu cầu quyền truy cập'),
              content: const Text(
                  'Quyền truy cập vào thư viện ảnh là bắt buộc nếu bạn muốn sử dụng tính năng này. Vui lòng cấp quyền trong cài đặt ứng dụng.'),
              actions: [
                TextButton(
                  onPressed: () => openAppSettings(),
                  child: const Text('Mở cài đặt'),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Hủy'),
                ),
              ],
            ),
      );
    } else {
      // Show custom dialog for permission request
      showDialog(
        context: context,
        builder: (context) =>
            AlertDialog(
              title: const Text('Yêu cầu quyền truy cập'),
              content: const Text(
                  'Ứng dụng này yêu cầu quyền truy cập vào thư viện, bạn có đồng ý cung cấp quyền này cho ứng dụng?'),
              actions: [
                TextButton(
                  onPressed: () async {
                    Navigator.pop(context); // Close the dialog
                    final status = await Permission.storage
                        .request(); // Request again
                    if (status.isGranted) {
                      _pickImage(); // Retry picking image if granted
                    }
                  },
                  child: const Text('Có'),
                ), TextButton(
                  onPressed: () {
                    Navigator.pop(context); // Close the dialog
                  },
                  child: const Text('Không'),
                ),
              ],
            ),
      );
    }
  }

  double _measureTextWidth(String text, TextStyle style) {
    final TextPainter textPainter = TextPainter(
      text: TextSpan(text: text, style: style),
      maxLines: 1,
      textDirection: TextDirection.ltr,
    )
      ..layout(minWidth: 0, maxWidth: double.infinity);
    return textPainter.size.width;
  }

  String _formatText(String text, TextStyle textStyle, {int maxWidth = 130}) {
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

  Widget _getStockLabel() {
    if (widget.quantity == 0) {
      return const OutOfStockLabel();
    } else if (widget.quantity < lowOnStockThreshold) {
      return LowStockLabel();
    } else {
      return InStockLabel();
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(25),
      onTap: () {},
      child: Ink(
        height: 190,
        decoration: BoxDecoration(
          color: const Color.fromRGBO(7, 25, 82, 1),
          borderRadius: const BorderRadius.all(Radius.circular(25)),
          boxShadow: hasShadow ? const [
            BoxShadow(
              offset: Offset(0, 4),
              color: Colors.grey,
              blurRadius: 4,
            )
          ] : null,
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
            ),
            Positioned(
              top: 20,
              left: 20,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20.0),
                child: SizedBox(
                  height: 80,
                  width: 80,
                  child: _image == null
                      ? Image.network(
                    fit: BoxFit.cover,
                    widget.imageUrl,
                  )
                      : Image.file(
                    _image!,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            Positioned(
              top: 70,
              left: 70,
              child: IconButton(
                icon: const Icon(Icons.photo_library, color: Colors.white),
                onPressed: _pickImage,
              ),
            ),
            Positioned(
              top: 16,
              left: 147,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        "Thể loại:",
                        style: contentStyle,
                      ),
                      const SizedBox(width: 20),
                      Text(
                        _formatText(widget.genre, contentStyle),
                        style: contentStyle,
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Text(
                        "Tác giả:",
                        style: contentStyle,
                      ),
                      const SizedBox(width: 25),
                      Text(
                        _formatText(widget.author, contentStyle,),
                        style: contentStyle,
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Text(
                        "Số lượng:",
                        style: contentStyle,
                      ),
                      const SizedBox(width: 15),
                      Text(
                        _formatText(stdNumFormat.format(widget.quantity), contentStyle,),
                        style: contentStyle,
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Text(
                        "Đơn giá:",
                        style: contentStyle,
                      ),
                      const SizedBox(width: 22),
                      Text(
                        "${_formatText(stdNumFormat.format(widget.price), contentStyle,
                            maxWidth: 100)} VND",
                        style: contentStyle,
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  _getStockLabel(),
                ],
              ),
            ),
            Positioned(
              left: 16,
              bottom: 10,
              child: Text(
                _formatText(widget.title, titleStyle, maxWidth: 330),
                style: titleStyle,
              ),
            ),
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
  final VoidCallback fetchDataFunction;

  const AdvancedSearchForm({
    super.key,
    this.titleBarColor = const Color.fromRGBO(7, 25, 82, 1),
    this.titleColor = const Color.fromRGBO(238, 237, 235, 1),
    this.contentAreaColor = const Color.fromRGBO(55, 183, 195, 1),
    this.contentTitleColor = const Color.fromRGBO(7, 25, 82, 1),
    this.contentInputColor = const Color.fromRGBO(7, 25, 82, 1),
    this.contentInputFormFillColor = Colors.white,
    this.textFieldBorderColor = Colors.grey,
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

  @override
  void dispose() {
    _titleController.dispose();
    _authorController.dispose();
    _quantityController.dispose();
    super.dispose();
  }

  void uploadDataToServer() {
    // your backend here, do something with `serverUploadedTitleInputData`, `serverUploadedGenreInputData`,...
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
                            inputFormatters: [
                              ThousandsSeparatorInputFormatter(),
                              // Apply custom formatter
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
              serverUploadedQuantityInputData = _quantityController.text == ''
                  ? 0
                  : int.parse(_quantityController.text);

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

  List<Widget> buildResultCardsUI(List<SearchCardCoreData> sortedList) {
    return sortedList
        .asMap() // Convert list to a map with indices
        .entries // Get the entries (key-value pairs)
        .expand((entry) => [
      SearchCardUI(
        orderNum: entry.key + 1,
        // Use the index as orderNum
        title: entry.value.title,
        genre: entry.value.genre,
        author: entry.value.author,
        quantity: entry.value.quantity,
        price: entry.value.price,
        imageUrl:
        "https://cdn.britannica.com/25/74225-050-7F97DCE4/second-jetliners-terrorists-al-Qaeda-smoke-billows-crash-Sept-11-2001.jpg",
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
        return -comparison; // Ascending order
      }
    });
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
          mainAxisAlignment: MainAxisAlignment.center,
          children: rawDataList.isNotEmpty
              ? [
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
          ]
              : [const NotFound()],
        ),
        const SizedBox(
          height: 15,
        ),
        Expanded(
          child: Builder(
            builder: (context) {
              if (rawDataList.isNotEmpty) {
                if (processedDataList.isNotEmpty) {
                  return Material(
                    color: const Color.fromRGBO(235, 244, 246, 1),
                    child: ListView.builder(
                      controller: widget.searchResultScrollController,
                      itemCount: buildResultCardsUI(processedDataList).length,
                      itemBuilder: (context, index) {
                        return buildResultCardsUI(processedDataList)[index];
                      },
                    ),
                  );
                } else {
                  return const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      NotFound(
                        paddingLeft: 25,
                        paddingTop: 40,
                      ),
                    ],
                  );
                }
              } else {
                return const SizedBox(); // Placeholder if rawDataList is empty
              }
            },
          ),
        )
      ],
    );
  }
}
