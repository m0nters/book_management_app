import 'package:flutter/material.dart';

class NoInternetConnection extends StatelessWidget {
  const NoInternetConnection({super.key,});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
        backgroundColor: Color.fromRGBO(59, 73, 100, 1),
        body: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 0.0),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.signal_wifi_connected_no_internet_4_rounded,
                  size: 250,
                  color: Color.fromRGBO(165, 171, 183, 1),
                ),
                SizedBox(
                  height: 50,
                ),
                Text(
                  "Ooops!",
                  style: TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                      color: Color.fromRGBO(165, 171, 183, 1)),
                ),
                SizedBox(
                  height: 30,
                ),
                Text(
                  "Không có mạng, vui lòng kiểm tra lại kết nối.",
                  style: TextStyle(
                      fontSize: 16 , color: Color.fromRGBO(165, 171, 183, 1)),
                  textAlign: TextAlign.center,
                ),
                SizedBox(
                  height: 10,
                ),
                Text(
                  "Khi có kết nối mạng trở lại, hệ thống sẽ tự động tải lại trang",
                  style: TextStyle(
                      fontSize: 20, color: Color.fromRGBO(165, 171, 183, 1)),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ));
  }
}
