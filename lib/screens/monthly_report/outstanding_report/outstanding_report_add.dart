import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:month_year_picker/month_year_picker.dart';

class OutstandingReportAdd extends StatefulWidget {
  final VoidCallback backContextSwitcher;

  const OutstandingReportAdd({
    super.key,
    required this.backContextSwitcher,
  });

  @override
  State<StatefulWidget> createState() => _OutstandingReportAddState();
}

class _OutstandingReportAddState extends State<OutstandingReportAdd> {
  List<DateTime?> _selectedDates = [];

  @override
  void initState() {
    super.initState();

    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);

    _addItem();
  }

  void _addItem() {
    setState(() {
      _selectedDates.add(null);
    });
  }

  Future<void> _pickDate({
    required BuildContext context,
    required int index,
  }) async {
    final selected = await showMonthYearPicker(
      context: context,
      initialDate: _selectedDates[index] ?? DateTime.now(),
      firstDate: DateTime(2004),
      lastDate: DateTime(2030),
    );
    if (selected != null) {
      setState(() {
        _selectedDates[index] = selected;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE1E3EA),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildAppBar(),
          const SizedBox(height: 30),
          Expanded(
            child: ListView.builder(
              itemCount: _selectedDates.length + 1,
              itemBuilder: (context, index) {
                if (index == _selectedDates.length) {
                  return IconButton(
                    onPressed: _addItem,
                    icon: const Icon(Icons.add),
                  );
                } else {
                  return _buildItem(index);
                }
              },
            ),
          ),
          _buildSaveButton(),
        ],
      ),
    );
  }

  Widget _buildAppBar() {
    return AppBar(
      backgroundColor: const Color(0xFFE1E3EA),
      foregroundColor: const Color(0xFF050C9C),
      title: const Text(
        "Tạo mẫu báo cáo tồn",
        style: TextStyle(
          fontWeight: FontWeight.bold,
        ),
      ),
      leading: IconButton(
        onPressed: () {
          widget.backContextSwitcher();
        },
        icon: const Icon(Icons.arrow_back),
      ),
    );
  }

  Widget _buildSaveButton() {
    return Align(
      alignment: Alignment.center,
      child: Container(
        width: 100,
        child: TextButton(
          onPressed: () {},
          style: TextButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(0),
            ),
            backgroundColor: const Color(0xFF050C9C),
            elevation: 8,
            shadowColor: Colors.grey,
          ),
          child: const Text(
            'Lưu',
            style: TextStyle(color: Colors.white),
          ),
        ),
      ),
    );
  }

  Widget _buildItem(int index) {
    return Dismissible(
      key: UniqueKey(),
      direction: DismissDirection.endToStart,
      onDismissed: (direction) {
        setState(() {
          _selectedDates.removeAt(index);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Item dismissed')),
        );
      },
      background: Container(
        color: Colors.red,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20.0),
        child: const Icon(
          Icons.delete,
          color: Colors.white,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.only(bottom: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildItemHeader(index),
            _buildItemContent(),
          ],
        ),
      ),
    );
  }

  Widget _buildItemHeader(int index) {
    return Container(
      margin: const EdgeInsets.only(left: 10, right: 10),
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(8),
          topRight: Radius.circular(8),
        ),
        color: Color(0xFF050C9C),
      ),
      child: Row(
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 8),
            child: Text(
              'STT ${index + 1}',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w500,
                fontSize: 18,
              ),
            ),
          ),
          const Spacer(),
          const Text('Tháng, Năm:', style: TextStyle(color: Colors.white)),
          TextButton(
            onPressed: () async => _pickDate(context: context, index: index),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: const Color(0xFF3572EF),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.5),
                    blurRadius: 7,
                    offset: const Offset(0, 3),
                  )
                ],
                borderRadius: BorderRadius.circular(4),
              ),
              child: Row(
                children: [
                  Text(
                    _selectedDates[index] != null
                        ? '${_selectedDates[index]!.month}/${_selectedDates[index]!.year}'
                        : 'Chọn tháng, năm',
                    style: const TextStyle(fontSize: 16, color: Colors.white),
                  ),
                  const SizedBox(width: 10),
                  const Icon(Icons.calendar_month, color: Colors.white, size: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItemContent() {
    return Container(
      margin: const EdgeInsets.only(left: 10),
      color: const Color(0xFFFFF5E1),
      child: Column(
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
            child: Row(
              children: [
                Expanded(child: Text('Tên Sách')),
                Expanded(child: Text('Tác giả')),
              ],
            ),
          ),
          _buildBookInfoRow(),
          const SizedBox(height: 30),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 8.0),
            child: Row(
              children: [
                Expanded(flex: 1, child: Text('Tồn đầu')),
                Expanded(flex: 2, child: Text('Phát sinh nhập', textAlign: TextAlign.center)),
                Expanded(flex: 2, child: Text('Phát sinh xuất', textAlign: TextAlign.center)),
                Expanded(flex: 1, child: Text('Tồn cuối')),
              ],
            ),
          ),
          _buildInputFields(),
        ],
      ),
    );
  }

  Widget _buildBookInfoRow() {
    return Row(
      children: [
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0xFFCECEC9),
              borderRadius: BorderRadius.circular(8),
            ),
            margin: const EdgeInsets.symmetric(horizontal: 8.0),
            padding: const EdgeInsets.all(8.0),
            child: const Text('Mắt biếc', overflow: TextOverflow.ellipsis),
          ),
        ),
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0xFFCECEC9),
              borderRadius: BorderRadius.circular(8),
            ),
            margin: const EdgeInsets.only(right: 8.0),
            padding: const EdgeInsets.all(8.0),
            child: const Text('Nguyễn Nhật Ánh', overflow: TextOverflow.ellipsis),
          ),
        ),
      ],
    );
  }

  Widget _buildInputFields() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 20.0),
      child: Row(
        children: [
          _buildInputField(flex: 1),
          _buildInputField(flex: 2),
          _buildInputField(flex: 2),
          _buildInputField(flex: 1),
        ],
      ),
    );
  }

  Widget _buildInputField({required int flex}) {
    return Expanded(
      flex: flex,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8.0),
        height: 35,
        child: const TextField(
          textAlign: TextAlign.center,
          textAlignVertical: TextAlignVertical.top,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(),
          ),
        ),
      ),
    );
  }
}
