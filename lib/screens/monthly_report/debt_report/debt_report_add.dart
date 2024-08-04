import 'package:flutter/material.dart';
import 'package:month_year_picker/month_year_picker.dart';

class DebtReportAdd extends StatefulWidget {
  final VoidCallback backContextSwitcher;

  const DebtReportAdd({
    super.key,
    required this.backContextSwitcher,
  });

  @override
  State<StatefulWidget> createState() => _DebtReportAddState();
}

class _DebtReportAddState extends State<DebtReportAdd> {
  List<DateTime?> _selectedDates = [];

  @override
  void initState() {
    super.initState();
    _addItem();
  }

  Future<void> _pickDate(BuildContext context, int index) async {
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

  void _addItem() {
    setState(() {
      _selectedDates.add(null); // Add a new entry for the new item
    });
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
          _buildListView(),
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
        "Tạo mẫu báo cáo công nợ",
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

  Widget _buildListView() {
    return Expanded(
      child: ListView.builder(
        itemCount: _selectedDates.length + 1,
        itemBuilder: (context, index) {
          if (index == _selectedDates.length) {
            return _buildAddButton();
          } else {
            return _buildItem(index);
          }
        },
      ),
    );
  }

  Widget _buildAddButton() {
    return Column(
      children: [
        IconButton(
          onPressed: _addItem,
          icon: const Icon(Icons.add),
        ),
      ],
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
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(0)),
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
          const SnackBar(content: Text('Item dismissed')),
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
            _buildItemBody(index),
          ],
        ),
      ),
    );
  }

  Widget _buildItemHeader(int index) {
    return Container(
      margin: const EdgeInsets.only(left: 10),
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
          const Text(
            'Tháng, Năm:',
            style: TextStyle(color: Colors.white),
          ),
          TextButton(
            onPressed: () async => _pickDate(context, index),
            child: Container(
              padding: const EdgeInsets.only(
                left: 10,
                right: 10,
                top: 5,
                bottom: 5,
              ),
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
                  const Icon(
                    Icons.calendar_month,
                    color: Colors.white,
                    size: 20,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItemBody(int index) {
    return Container(
      margin: const EdgeInsets.only(left: 10),
      color: const Color(0xFFFFF5E1),
      child: Column(
        children: [
          const Padding(
            padding: EdgeInsets.only(left: 8.0, top: 8.0, right: 8.0),
            child: Row(
              children: [
                Expanded(child: Text('Mã khách hàng')),
                Expanded(child: Text('Tên khách hàng')),
              ],
            ),
          ),
          Row(
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFFCECEC9),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  margin: const EdgeInsets.only(left: 8.0, right: 8.0),
                  padding: const EdgeInsets.all(8.0),
                  child: const Text(
                    'KH05238481',
                    overflow: TextOverflow.ellipsis,
                  ),
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
                  child: const Text(
                    'Nguyễn Thiện Nhân',
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 30),
          const Padding(
            padding: EdgeInsets.only(left: 8.0, right: 8.0),
            child: Row(
              children: [
                Expanded(child: Text('Nợ đầu', textAlign: TextAlign.center)),
                Expanded(child: Text('Nợ phát sinh', textAlign: TextAlign.center)),
                Expanded(child: Text('Nợ cuối', textAlign: TextAlign.center)),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(
              left: 8.0,
              right: 8.0,
              bottom: 20.0,
            ),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.only(left: 10, right: 10),
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
                ),
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.only(left: 8, right: 8),
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
                ),
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.only(left: 10, right: 10),
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
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
