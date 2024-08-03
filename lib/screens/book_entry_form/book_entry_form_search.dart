import 'package:flutter/material.dart';

class BookEntryFormSearch extends StatefulWidget {
  const BookEntryFormSearch({super.key});

  @override
  createState() => _BookEntryFormSearchState();
}

class _BookEntryFormSearchState extends State<BookEntryFormSearch> {
  final List<EntryDataForForm> _entryDataList = [
    EntryDataForForm(
        title: 'Tôi thấy hoa vàng ở trên cỏ xanh',
        category: 'Tiểu thuyết',
        author: 'Nguyễn Nhật Ánh',
        quantity: 29),
    EntryDataForForm(
        title: 'Cho tôi biển mặn',
        category: 'Truyện ngắn',
        author: 'Việt',
        quantity: 12),
  ];

  final List<bool> _selectedItems = [false, false];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tra cứu phiếu nhập sách'),
        backgroundColor: Colors.blueGrey,
      ),
      body: Column(
        children: [
          // Date picker row
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Phiếu nhập sách ngày',
                    style: TextStyle(fontSize: 18)),
                ElevatedButton(
                  onPressed: () {
                    // Here you would implement the date picker and search function
                  },
                  child: Row(
                    children: const [
                      Text('30/06/2024 (gần nhất)',
                          style: TextStyle(fontSize: 16)),
                      SizedBox(width: 8),
                      Icon(Icons.calendar_today),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Result count
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: RichText(
              text: TextSpan(
                text: 'Phiếu nhập sách ngày ',
                style: DefaultTextStyle.of(context).style,
                children: const <TextSpan>[
                  TextSpan(
                      text: '30/06/2024',
                      style: TextStyle(
                          color: Colors.red, fontWeight: FontWeight.bold)),
                  TextSpan(text: ': 2 kết quả'),
                ],
              ),
            ),
          ),
          // Table header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Container(
              color: Colors.blue[900],
              child: Row(
                children: const [
                  SizedBox(width: 40, child: Center(child: Text(''))),
                  Expanded(
                      flex: 1,
                      child: Center(
                          child: Text('STT',
                              style: TextStyle(color: Colors.white)))),
                  Expanded(
                      flex: 3,
                      child: Center(
                          child: Text('Tên sách',
                              style: TextStyle(color: Colors.white)))),
                  Expanded(
                      flex: 2,
                      child: Center(
                          child: Text('Thể loại',
                              style: TextStyle(color: Colors.white)))),
                  Expanded(
                      flex: 2,
                      child: Center(
                          child: Text('Tác giả',
                              style: TextStyle(color: Colors.white)))),
                  Expanded(
                      flex: 1,
                      child: Center(
                          child: Text('Số lượng',
                              style: TextStyle(color: Colors.white)))),
                ],
              ),
            ),
          ),
          // Table rows
          Expanded(
            child: ListView.builder(
              itemCount: _entryDataList.length,
              itemBuilder: (context, index) {
                return Container(
                  color: index.isEven ? Colors.white : Colors.blue[50],
                  child: Row(
                    children: [
                      SizedBox(
                        width: 40,
                        child: Checkbox(
                          value: _selectedItems[index],
                          onChanged: (bool? value) {
                            setState(() {
                              _selectedItems[index] = value!;
                            });
                          },
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: Center(child: Text((index + 1).toString())),
                      ),
                      Expanded(
                        flex: 3,
                        child: Center(child: Text(_entryDataList[index].title)),
                      ),
                      Expanded(
                        flex: 2,
                        child:
                            Center(child: Text(_entryDataList[index].category)),
                      ),
                      Expanded(
                        flex: 2,
                        child:
                            Center(child: Text(_entryDataList[index].author)),
                      ),
                      Expanded(
                        flex: 1,
                        child: Center(
                            child: Text(
                                _entryDataList[index].quantity.toString())),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          // Edit and Delete buttons
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit, color: Colors.blue),
                  onPressed: () {
                    // Implement edit function
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () {
                    setState(() {
                    });
                    // Implement delete function (with server communication)
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class EntryDataForForm {
  String title;
  String category;
  String author;
  int quantity;

  EntryDataForForm({
    required this.title,
    required this.category,
    required this.author,
    required this.quantity,
  });
}
