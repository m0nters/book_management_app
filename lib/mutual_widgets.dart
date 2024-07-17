import 'package:dotted_line/dotted_line.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

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
// ============================================================================

class CustomDropdownMenu extends StatefulWidget {
  final List<String> options;
  final Function(String?) action;
  final double fontSize;
  final double width;
  final Color fillColor;
  final String hintText;

  /// A customizable dropdown menu widget for Flutter.
  ///
  /// This widget provides a visually consistent dropdown menu with customizable options, actions, and styling.
  ///
  /// **Key Features:**
  ///
  /// * **Required Options:** A list of `options` (strings) to be displayed in the dropdown.
  /// * **Required Action Callback:** A function `action` that is called when an option is selected, passing the selected value as a parameter.
  /// * **Customizable Font Size:** Adjust the `fontSize` of the dropdown text.
  /// * **Customizable Width:** Control the `width` of the dropdown (defaults to full width).
  /// * **Customizable Fill Color:** Change the background `fillColor` of the dropdown.
  /// * **Customizable Hint Text:** Provide a `hintText` to guide the user when no option is selected.
  ///
  /// **Usage:**
  ///
  /// ```dart
  /// CustomDropdownMenu(
  ///   options: ['Option 1', 'Option 2', 'Option 3'],
  ///   action: (value) {
  ///     // Handle the selected value (e.g., update state)
  ///   },
  ///   fontSize: 18.0,  // Larger font size
  ///   fillColor: Colors.grey[200], // Light grey background
  ///   hintText: 'Select an option',
  /// ),
  /// ```
  const CustomDropdownMenu({
    super.key,
    required this.options,
    required this.action,
    this.fontSize = 16,
    this.fillColor = Colors.white,
    this.width = double.infinity,
    this.hintText = 'Chọn một tùy chọn',
  });

  @override
  createState() => _CustomDropdownMenuState();
}

class _CustomDropdownMenuState extends State<CustomDropdownMenu> {
  String? _selectedOption;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: widget.width,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade400),
        color: widget.fillColor,
        borderRadius: BorderRadius.circular(4),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedOption,
          hint: Text(
            widget.hintText,
            style: TextStyle(fontSize: widget.fontSize),
            overflow: TextOverflow.ellipsis,
          ),
          items: widget.options.map((String option) {
            return DropdownMenuItem<String>(
              value: option,
              child: Text(
                option,
                style: TextStyle(fontSize: widget.fontSize),
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

  const DatePickerBox({super.key,
    required this.initialDate, // input Date(year,day,month)
    required this.onDateChanged,
    this.backgroundColor = Colors.white,
    this.foregroundColor = Colors.black,
    this.borderColor = Colors.grey});

  @override
  createState() => _DatePickerBoxState();
}

class _DatePickerBoxState extends State<DatePickerBox> {
  late DateTime _selectedDate;

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.initialDate;
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
    final isToday = _selectedDate.year == DateTime
        .now()
        .year &&
        _selectedDate.month == DateTime
            .now()
            .month &&
        _selectedDate.day == DateTime
            .now()
            .day;
    final todayLabel = isToday ? ' (hôm nay)' : '';

    return InkWell(
      onTap: () => _selectDate(context),
      borderRadius: BorderRadius.circular(8),
      child: Ink(
        padding: const EdgeInsets.all(10), // Adjust padding
        decoration: BoxDecoration(
          color: widget.backgroundColor, // Background color
          border: Border.all(color: widget.borderColor, width: 1.5),
          borderRadius: BorderRadius.circular(8), // Border radius
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('$formattedDate$todayLabel',
                style: TextStyle(fontSize: 16, color: widget.foregroundColor)),
            const SizedBox(width: 8), // Spacing
            const Icon(Icons.calendar_month_sharp), // Calendar icon
          ],
        ),
      ),
    );
  }
}
// ============================================================================
