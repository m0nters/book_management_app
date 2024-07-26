import 'package:dotted_line/dotted_line.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../screens/setting/setting.dart';

List<String> genres = [
  'Tình cảm',
  'Bí ẩn',
  'Giả tưởng và khoa học viễn tưởng',
  'Khoa học công nghệ',
  'Kinh dị, giật gân',
  'Kinh tế',
  'Truyền cảm hứng',
  'Tiểu thuyết',
  'Tiểu sử, tự truyện và hồi ký',
  'Truyện ngắn',
  'Lịch sử',
]; // backend fetch "Thể loại" from server to this list

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

  /// A customizable rounded button widget for Flutter.
  ///
  /// This widget provides a visually appealing button with rounded corners and customizable styling. It uses an ElevatedButton for its base functionality.
  ///
  /// **Key Features:**
  ///
  /// * Customizable `backgroundColor` and `foregroundColor`.
  /// * Customizable `title` text and `fontSize`.
  /// * Customizable `borderRadius` for the button's corners.
  /// * Customizable `height` and `width` to control the button's size (if set to 0.0, uses the default size of the text).
  /// * Customizable `padding` for the button's content.
  /// * Required `onPressed` callback function triggered when the button is pressed.
  ///
  /// **Usage:**
  ///
  /// ```dart
  /// CustomRoundedButton(
  ///   backgroundColor: Colors.blue,
  ///   foregroundColor: Colors.white,
  ///   title: 'Press Me',
  ///   borderRadius: 25.0, // More pronounced rounding
  ///   onPressed: () {
  ///     // Handle button press
  ///   },
  /// ),
  /// ```
  ///
  /// **Note:**
  /// * The button will expand to fit its content if `height` and `width` are set to 0.0.
  /// * If you require more complex button behavior, consider extending this widget.
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
        elevation: hasShadow ? 5 : 0,
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
// ============================================================================

/// A customizable ticket-shaped widget for displaying information in a visually appealing way.
///
/// This widget is designed to resemble a ticket, with a background image and a series of title-content pairs arranged in rows. It's ideal for showcasing key details in a compact format.
///
/// **Key Features:**
///
/// - **Background Image:** Custom background image (`backgroundImage`) to set the ticket's theme.
/// - **Title-Content Pairs:** Accepts a list of maps (`fields`) where each map contains a `title` and `content` string pair.
/// - **OnTap Action:** Triggers a custom action (`onTap`) when the ticket is tapped. You can pass `(){} ` if you need no ontap actions.
/// - **Customizable Colors:** Optional `titleColor` and `contentColor` to tailor the text appearance.
/// - **Responsive Design:** Dynamically adjusts the layout based on the number of fields and the available space.
///
/// **Usage:**
///
/// ```dart
/// InfoTicket(
///   fields: [
///     {'title': 'Mã phiếu', 'content': 'PNS0124512'},
///     {'title': 'Tên sách', 'content': 'Mắt biếc'},
///     {'title': 'Tác giả', 'content': 'Nguyễn Nhật Ánh'},
///     // ... more fields
///   ],
///   backgroundImage: 'assets/images/ticket_background.png',
///   onTap: () {
///     // Handle ticket tap
///   },
/// ),
/// ```
///
/// **Note:**
///
/// - The widget automatically formats long text to fit within the ticket's boundaries.
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
        padding: const EdgeInsets.symmetric(horizontal: 21, vertical: 4),
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage(backgroundImage),
            fit: BoxFit.fill,
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
          children: _buildFieldRows(fields),
        ),
      ),
    );
  }

  String _formatText(String str) {
    if (str.length >= 17) {
      return "${str.substring(0, 12)}...";
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
// ============================================================================

class CustomDropdownMenu extends StatefulWidget {
  final List<String> options;
  final Function(String?) action;
  final double fontSize;
  final double width;
  final double height;
  final Color borderColor;
  final Color contentColor;
  final Color fillColor;
  final String hintText;
  final String? initialValue;

  const CustomDropdownMenu({
    super.key,
    required this.options,
    required this.action,
    this.fontSize = 16,
    this.borderColor = Colors.grey,
    this.contentColor = const Color.fromRGBO(12, 24, 68, 1),
    this.fillColor = Colors.white,
    this.width = double.infinity,
    this.height =
        46.5, // fit with the height of TextField when `isDense` property is `true`
    this.hintText = 'Chọn một tùy chọn',
    this.initialValue = "",
  });

  @override
  createState() => _CustomDropdownMenuState();
}

class _CustomDropdownMenuState extends State<CustomDropdownMenu> {
  String? _selectedOption;

  @override
  void initState() {
    super.initState();
    _selectedOption = widget.initialValue == "" ? null : widget.initialValue;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: widget.width,
      height: widget.height,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        border: Border.all(color: widget.borderColor),
        color: widget.fillColor,
        borderRadius: BorderRadius.circular(4),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedOption,
          hint: Text(
            widget.hintText,
            style: TextStyle(fontSize: widget.fontSize),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          items: widget.options.map((String option) {
            return DropdownMenuItem<String>(
              value: option,
              child: Text(
                option,
                style: TextStyle(
                    fontSize: widget.fontSize, color: widget.contentColor),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            );
          }).toList(),
          onChanged: (String? newValue) {
            setState(() {
              _selectedOption = newValue;
            });
            widget.action(newValue);
          },
          isExpanded: true,
          dropdownColor: widget.fillColor,
        ),
      ),
    );
  }
}
// ============================================================================

class DatePickerBox extends StatefulWidget {
  final DateTime initialDate; // Initial selected date
  final ValueChanged<DateTime> onDateChanged; // Callback for date changes
  final Color backgroundColor;
  final Color foregroundColor;
  final Color borderColor;
  final double fontSize;
  final double iconSize;
  final double borderRadius;

  /// A customizable date picker widget for Flutter.
  ///
  /// This widget provides a visually appealing box that, when tapped, opens a date picker dialog. It displays the selected date in a formatted string and optionally indicates if the date is today.
  ///
  /// **Key Features:**
  ///
  /// - **Initial Date:** Sets the `initialDate` to be displayed when the widget is first rendered.
  /// - **On Date Changed Callback:** Triggers the `onDateChanged` callback function whenever the user selects a new date, passing the selected `DateTime` as an argument.
  /// - **Customizable Colors:** Allows you to customize the `backgroundColor`, `foregroundColor`, and `borderColor` of the box.
  /// - **Customizable Font and Icon Size:** Adjust the size of the displayed date and the calendar icon using `fontSize` and `iconSize`.
  /// - **Formatted Date Display:** Shows the selected date in the format 'dd/MM/yyyy' and appends "(hôm nay)" if it's the current date.
  /// - **Calendar Icon:** Includes a calendar icon for visual clarity.
  ///
  /// **Usage:**
  ///
  /// ```dart
  /// DatePickerBox(
  ///   initialDate: DateTime.now(),
  ///   onDateChanged: (selectedDate) {
  ///     // Handle the selected date (e.g., update state)
  ///   },
  ///   backgroundColor: Colors.blue[100],  // Light blue background
  ///   foregroundColor: Colors.blue[900], // Dark blue text
  ///   borderColor: Colors.blue,           // Blue border
  ///   fontSize: 18.0,                     // Larger font size for the date
  ///   iconSize: 24.0,                     // Larger calendar icon
  /// ),
  /// ```
  ///
  /// **Note:**
  ///
  /// - The `firstDate` and `lastDate` of the date picker can be adjusted within the widget's code to restrict the user's selection range.
  /// - The widget uses `InkWell` for tap interactions, providing visual feedback (ripples) when tapped.
  /// - You can further customize the appearance using additional `BoxDecoration` properties (e.g., shadows).
  /// - The `fontSize` and `iconSize` are passed down to the Text and Icon widgets, respectively.
  const DatePickerBox({
    super.key,
    required this.initialDate, // input Date(year,day,month)
    required this.onDateChanged,
    this.backgroundColor = Colors.white,
    this.foregroundColor = Colors.black,
    this.borderColor = Colors.grey,
    this.fontSize = 16,
    this.iconSize = 20,
    this.borderRadius = 4,
  });

  @override
  createState() => _DatePickerBoxState();
}

class _DatePickerBoxState extends State<DatePickerBox> {
  late DateTime _selectedDate;

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.initialDate;

    // ensure the system automatically record the today as selected date right at the beginning
    // otherwise you need to tap into the date picker (formally), while do nothing then but
    // that's the only way for the system to know your selected date
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.onDateChanged(_selectedDate);
    });
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(1900), // Adjust if needed
      lastDate: DateTime(2100), // Adjust if needed
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        widget.onDateChanged(picked);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final formattedDate = DateFormat('dd/MM/yyyy').format(_selectedDate);
    final isToday = _selectedDate.year == DateTime.now().year &&
        _selectedDate.month == DateTime.now().month &&
        _selectedDate.day == DateTime.now().day;
    final todayLabel = isToday ? ' (hôm nay)' : '';

    return InkWell(
      onTap: () => _selectDate(context),
      borderRadius: BorderRadius.circular(widget.borderRadius),
      child: Ink(
        padding: const EdgeInsets.all(10), // Adjust padding
        decoration: BoxDecoration(
          color: widget.backgroundColor,
          // Background color
          border: Border.all(color: widget.borderColor, width: 1),
          borderRadius: BorderRadius.circular(widget.borderRadius),
          // Border radius
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
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('$formattedDate$todayLabel',
                style: TextStyle(
                    fontSize: widget.fontSize, color: widget.foregroundColor)),
            const SizedBox(width: 4), // Spacing
            Icon(
              Icons.calendar_month_sharp,
              size: widget.iconSize,
              color: widget.foregroundColor,
            ), // Calendar icon
          ],
        ),
      ),
    );
  }
}
// ============================================================================
