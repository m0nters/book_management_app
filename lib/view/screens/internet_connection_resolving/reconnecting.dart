import 'package:flutter/material.dart';

class Reconnecting extends StatelessWidget {
  const Reconnecting({super.key,});

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
                  Text(
                    "Đã nhận được tín hiệu Internet, hệ thống đang tiến hành kết nối lại vào máy chủ.",
                    style: TextStyle(
                        fontSize: 20, color: Color.fromRGBO(165, 171, 183, 1)),
                    textAlign: TextAlign.center,
                  ),
                Text(
                  "Vui lòng chờ đợi trong giây lát (đôi khi có thể mất hơn 1 phút)...",
                  style: TextStyle(
                      fontSize: 20, color: Color.fromRGBO(165, 171, 183, 1)),
                  textAlign: TextAlign.center,
                ),
                  SizedBox(height: 30,),
                  Center(
                    child: CircularProgressIndicator(
                        color: Color.fromRGBO(255, 105, 105, 1)),
                  )
                ]
            ),
          ),
        ));
  }
}
