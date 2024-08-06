import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:permission_handler/permission_handler.dart';
import '../mutual_widgets.dart';
import '../setting/setting.dart';

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
  const InStockLabel({super.key})
      : super(
      text: 'Còn hàng',
      backgroundColor: const Color.fromRGBO(8, 131, 149, 1),
      message: "Số lượng từ 100 trở lên");
}

class LowStockLabel extends AvailabilityLabel {
  const LowStockLabel({super.key})
      : super(
      text: 'Còn ít hàng',
      backgroundColor: const Color.fromRGBO(239, 156, 102, 1),
      message: "Số lượng ít hơn 100");
}

class OutOfStockLabel extends AvailabilityLabel {
  const OutOfStockLabel({super.key})
      : super(
      text: 'Hết hàng',
      backgroundColor: const Color.fromRGBO(255, 105, 105, 1),);
}

// =============================================================================
// WE ONLY USE 2 BELOW

class SearchCard extends StatefulWidget {
  final int orderNum;
  final String title;
  final String genre;
  final String author;
  final int quantity;
  final int price;
  final String imageUrl;

  const SearchCard({
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
  createState() => _SearchCardState();
}

class _SearchCardState extends State<SearchCard> {
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
    } else if (widget.quantity < 100) {
      return const LowStockLabel();
    } else {
      return const InStockLabel();
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
