import 'package:dotted_line/dotted_line.dart';
import 'package:flutter/material.dart';

class CustomRoundedButton extends StatelessWidget {
  final Color backgroundColor;
  final Color foregroundColor;
  final String title;
  final double borderRadius;
  final double fontSize;
  final double height;
  final double width;
  final EdgeInsetsGeometry padding;
  final VoidCallback onPressed;

  const CustomRoundedButton({
    super.key,
    required this.backgroundColor,
    required this.foregroundColor,
    required this.title,
    this.borderRadius = 10.0,
    this.fontSize = 16.0,
    this.height = 0.0,
    this.width = 0.0,
    this.padding = const EdgeInsets.symmetric(vertical: 8, horizontal: 24),
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        padding: padding,
        backgroundColor: backgroundColor,
        foregroundColor: foregroundColor,
        minimumSize: Size(width, height),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius),
        ),
      ),
      child: Text(
        title,
        style: TextStyle(fontSize: fontSize),
      ),
    );
  }
}

class InfoTicket extends StatelessWidget {
  final List<Map<String, String>>
      fields; // Required list of title-content pairs
  final String backgroundImage; // Required background image for the ticket
  final VoidCallback
      onTap; // Required onTap event's function, pass (){} for nothing
  final Color titleColor;
  final Color contentColor;

  const InfoTicket({
    super.key,
    required this.fields,
    required this.backgroundImage,
    required this.onTap,
    this.titleColor = const Color.fromRGBO(12, 24, 68, 1),
    this.contentColor = const Color.fromRGBO(133, 133, 133, 1),
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Ink(
        height: 95,
        padding: const EdgeInsets.symmetric(horizontal: 21, vertical: 4),
        decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage(backgroundImage),
              fit: BoxFit.fill,
            ),
            boxShadow: const [
              BoxShadow(
                offset: Offset(0, 4),
                color: Colors.grey,
                blurRadius: 4,
              )
            ]),
        child: Column(
          children: _buildFieldRows(fields),
        ),
      ),
    );
  }

  String _formatText(String str) {
    if (str.length >= 20) {
      return "${str.substring(0, 15)}...";
    }
    return str;
  }

  List<Widget> _buildFieldRows(List<Map<String, String>> fields) {
    List<Widget> resultColumnChildren = [];
    for (int i = 0; i < fields.length; i += 3) {
      // extracts elements from index i to i + 3. If i + 3 exceeds the length of the list, the end of the list is used.
      List<Map<String, String>> sublist =
          fields.sublist(i, i + 3 > fields.length ? fields.length : i + 3);
      resultColumnChildren.add(
        Row(
          // row of each 3 title-content pairs aligned vertically
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          // The `asMap()` method converts the list into a map where the keys are
          // the indices of the list elements, and the values are the elements themselves.
          // For example, if sublist is:
          // [
          //   {'title': 'Mã phiếu', 'content': 'PNS0124512'},
          //   {'title': 'Tên sách', 'content': 'Mắt biếc'},
          //   {'title': 'Tác giả', 'content': 'Nguyễn Nhật Ánh'}
          // ]
          // sublist.asMap() will be:
          // {
          //   0: {'title': 'Mã phiếu', 'content': 'PNS0124512'},
          //   1: {'title': 'Tên sách', 'content': 'Mắt biếc'},
          //   2: {'title': 'Tác giả', 'content': 'Nguyễn Nhật Ánh'}
          // }
          // The `entries` property is called on the map created by `asMap()`. This
          // returns an iterable of map entries, where each entry contains a key-value pair.
          // example, `sublist.asMap().entries` will be an iterable of:
          // [
          //   MapEntry(0, {'title': 'Mã phiếu', 'content': 'PNS0124512'}),
          //   MapEntry(1, {'title': 'Tên sách', 'content': 'Mắt biếc'}),
          //   MapEntry(2, {'title': 'Tác giả', 'content': 'Nguyễn Nhật Ánh'})
          // ]
          // Next, the `map` method is called on the iterable of entries applies
          // a function to each entry in the iterable, transforming it into another
          // type. In this case, each entry is transformed into a widget by calling _buildField.
          children: sublist.asMap().entries.map((entry) {
            int index = entry.key;
            Map<String, String> field = entry.value;
            CrossAxisAlignment alignment;
            if (index == 0) {
              alignment = CrossAxisAlignment.start;
            } else if (index == sublist.length - 1) {
              // this can be 2 (row has 3 items) or 1 (row has 2 items)
              alignment = CrossAxisAlignment.end;
            } else {
              alignment = CrossAxisAlignment.center;
            }
            return _buildField(field['title']!, field['content']!, alignment);
          }).toList(),
        ),
      );
      if (i + 3 < fields.length) {
        resultColumnChildren.add(const SizedBox(height: 4));
        resultColumnChildren.add(
          DottedLine(
            dashColor: titleColor,
            lineThickness: 1,
            dashLength: 10,
            dashGapLength: 2,
          ),
        );
        resultColumnChildren.add(const SizedBox(height: 4));
      }
    }
    return resultColumnChildren;
  }

  Widget _buildField(
      String title, String content, CrossAxisAlignment alignment) {
    return Column(
      crossAxisAlignment: alignment,
      children: [
        Text(
          _formatText(title),
          style: TextStyle(
              fontWeight: FontWeight.bold, fontSize: 16, color: titleColor),
        ),
        Text(_formatText(content),
            style: TextStyle(fontSize: 14, color: contentColor)),
      ],
    );
  }
}