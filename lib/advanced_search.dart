import 'package:flutter/material.dart';
import 'package:untitled2/advanced_search_widget.dart';
import 'overall_screen_context_controller.dart';
import 'mutual_widgets.dart';

List<Widget> contentColumn = [
  const SearchCard(
      orderNum: 1,
      title: "Có hai con mèo ngồi bên cửa sổ",
      genre: "Tiểu thuyết",
      author: "Nguyễn Nhật Ánh",
      quantity: 100,
      price: 82000,
  ),
  const SizedBox(height: 15,),
  const SearchCard(
    orderNum: 2,
    title: "Đi qua hoa cúc",
    genre: "Tiểu thuyết",
    author: "Nguyễn Nhật Ánh",
    quantity: 20,
    price: 32800,
  ),
  const SizedBox(height: 15,),
  const SearchCard(
    orderNum: 3,
    title: "Đi qua hoa cúc",
    genre: "Tiểu thuyết",
    author: "Nguyễn Nhật Ánh",
    quantity: 0,
    price: 32800,
  ),
  const SizedBox(height: 15,),
  const SearchCard(
    orderNum: 4,
    title: "Đi qua hoa cúc",
    genre: "Tiểu thuyết",
    author: "Nguyễn Nhật Ánh",
    quantity: 20,
    price: 32800,
  ),
  const SizedBox(height: 15,),
  const SearchCard(
    orderNum: 5,
    title: "Đi qua hoa cúc",
    genre: "Tiểu thuyết",
    author: "Nguyễn Nhật Ánh",
    quantity: 20,
    price: 32800,
  ),
  const SizedBox(height: 15,),const SearchCard(
    orderNum: 6,
    title: "Đi qua hoa cúc",
    genre: "Tiểu thuyết",
    author: "Nguyễn Nhật Ánh",
    quantity: 20,
    price: 32800,
  ),
  const SizedBox(height: 15,),
  const SearchCard(
    orderNum: 7,
    title: "Đi qua hoa cúc",
    genre: "Tiểu thuyết",
    author: "Nguyễn Nhật Ánh",
    quantity: 20,
    price: 32800,
  ),
  const SizedBox(height: 15,),
];

class AdvancedSearchForm extends StatefulWidget {
  final Color titleBarColor;
  final Color titleColor;
  final Color contentAreaColor;
  final Color contentTitleColor;
  final Color contentInputColor;
  final Color contentInputFormFillColor;
  final Color textFieldBorderColor;

  const AdvancedSearchForm({
    super.key,
    required this.titleBarColor,
    required this.titleColor,
    required this.contentAreaColor,
    required this.contentTitleColor,
    required this.contentInputColor,
    required this.contentInputFormFillColor,
    required this.textFieldBorderColor,
  });

  @override
  createState() => _AdvancedSearchFormState();
}

class _AdvancedSearchFormState extends State<AdvancedSearchForm> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _authorController = TextEditingController();
  String genreController = '';
  String priceRangeController = '';

  final List<String> genres = [
    'Tiểu thuyết thanh thiếu niên',
    'Tiểu thuyết phiêu lưu',
    'Khoa học viễn tưởng',
    'Văn học cổ điển',
    // Add more genres as needed
  ];

  final List<String> priceRanges = [
    '0đ - 150.000đ',
    '150.000đ - 300.000đ',
    '300.000đ - 500.000đ',
    '500.000đ - 700.000đ',
    '700.000đ trở lên',
    // Add more price ranges as needed
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _authorController.dispose();
    super.dispose();
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
                  topLeft: Radius.circular(8), topRight: Radius.circular(8))),
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
                    bottomRight: Radius.circular(8))),
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
                            action: (genre) => genreController = genre ?? '',
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
                              Icon(Icons.monetization_on,
                                  color: widget.contentTitleColor),
                              const SizedBox(width: 4),
                              Text('Giá',
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: widget.contentTitleColor)),
                            ],
                          ),
                          const SizedBox(height: 4),
                          CustomDropdownMenu(
                            options: priceRanges,
                            action: (priceRange) =>
                            priceRangeController = priceRange ?? '',
                            fillColor: widget.contentInputFormFillColor,
                            width: double.infinity,
                            hintText: 'Chọn một mức giá',
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ))
      ],
    );
  }
}

class SearchResults extends StatelessWidget {
  final List<Widget> resultCards;

  const SearchResults({super.key, required this.resultCards});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Kết quả: ${resultCards.length ~/ 2} kết quả',
          style: const TextStyle(
            fontSize: 25,
            fontWeight: FontWeight.bold,
            color: Color.fromRGBO(7, 25, 82, 1),
          ),
        ),
        const SizedBox(height: 15,),
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
              options: const ['Bán chạy tháng', 'Mới nhất', 'Giá từ thấp tới cao', 'Giá từ cao tới thấp'],
              action: (selected) {},
              fillColor: Colors.white,
              width: 150,
              initialValue: 'Bán chạy tháng',
              fontSize: 14,
            ),
            const Spacer(),
            CustomDropdownMenu(
              options: const ['Tất cả', 'Còn hàng', 'Hết hàng'],
              action: (selected) {},
              fillColor: Colors.white,
              width: 100,
              initialValue: 'Tất cả',
              fontSize: 14,
            ),
          ],
        ),
        const SizedBox(height: 15,),
        Expanded(
          child: Material(
            child: ListView.builder(
              itemCount: resultCards.length,
              itemBuilder: (context, index) {
                return resultCards[index];
              },
            ),
          ),
        ),
      ],
    );
  }
}

class AdvancedSearch extends StatefulWidget {
  final Function(int) overallScreenContextSwitcher;
  const AdvancedSearch({super.key, required this.overallScreenContextSwitcher});

  @override
  State<AdvancedSearch> createState() => _AdvancedSearchState();
}

class _AdvancedSearchState extends State<AdvancedSearch> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(235, 244, 246, 1),
      appBar: AppBar(
        backgroundColor: const Color.fromRGBO(235, 244, 246, 1),
        foregroundColor: const Color.fromRGBO(7, 25, 82, 1),
        title: const Text("Tìm kiếm nâng cao", style: TextStyle(
            fontWeight: FontWeight.w400, color: Color.fromRGBO(7, 25, 82, 1)),),
        leading: IconButton(
          onPressed: () {
            widget.overallScreenContextSwitcher(OverallScreenContexts.mainFunctions.index);
          },
          icon: const Icon(Icons.arrow_back),
          color: const Color.fromRGBO(7, 25, 82, 1),),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 0.0),
        child: Column(
          children: [
            const SizedBox(height: 15,),
            const AdvancedSearchForm(
                titleBarColor: Color.fromRGBO(7, 25, 82, 1),
                titleColor: Color.fromRGBO(238, 237, 235, 1),
                contentAreaColor: Color.fromRGBO(55, 183, 195, 1),
                contentTitleColor: Color.fromRGBO(7, 25, 82, 1),
                contentInputColor: Color.fromRGBO(7, 25, 82, 1),
                contentInputFormFillColor: Colors.white,
                textFieldBorderColor: Colors.grey
            ),
            const SizedBox(height: 36,),
            Center(
              child: CustomRoundedButton(
                  backgroundColor: const Color.fromRGBO(7, 25, 82, 1),
                  foregroundColor: const Color.fromRGBO(235, 244, 246, 1),
                  title: "Tìm kiếm",
                  height: 45,
                  width: 165,
                  fontSize: 16,
                  onPressed: () {},
              ),
            ),
            const SizedBox(height: 36,),
            Expanded(child: SearchResults(resultCards: contentColumn)),
          ],
        ),
      )
    );
  }
}
