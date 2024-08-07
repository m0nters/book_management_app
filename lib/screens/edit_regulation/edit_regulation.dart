import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/services.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import '../../routing/overall_screen_routing.dart';

class EditRegulation extends StatelessWidget {
  final Function(int) overallScreenContextSwitcher;
  const EditRegulation({super.key, required this.overallScreenContextSwitcher});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        home: ChinhSuaCarousel(
          overallScreenContextSwitcher: overallScreenContextSwitcher,
        ),
      ),
    );
  }
}

class ChinhSuaCarousel extends StatefulWidget {
  final Function(int) overallScreenContextSwitcher;
  const ChinhSuaCarousel({super.key, required this.overallScreenContextSwitcher});

  @override
  _ChinhSuaCarouselState createState() => _ChinhSuaCarouselState();
}

class _ChinhSuaCarouselState extends State<ChinhSuaCarousel> {
  final CarouselController buttonCarouselController = CarouselController();
  int currentIndex = 0;
  late List<Widget> containers;

  @override
  void initState() {
    super.initState();

    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);

    containers = [NhapHang(), BanHang_ThuTien()];
  }

  Future<List<Widget>> getMyFavData() async {
    return Future.value(containers);
  }

  Widget NhapHang() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            blurRadius: 7,
            offset: Offset(0, 3), // changes position of shadow
          ),
        ],
      ),
      margin: const EdgeInsets.only(top: 30),
      width: 300,
      height: 500,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.max,
        children: [
          const SizedBox(height: 50),
          Container(
            padding: const EdgeInsets.only(top: 8),
            width: 134,
            height: 38,
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.only(
                bottomRight: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
              color: Color(0xFF5A639C),
            ),
            child: const Text(
              'Nhập hàng',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 40),
          Padding(
            padding: const EdgeInsets.only(left: 10),
            child: Column(
              mainAxisSize: MainAxisSize.max,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Số lượng nhập tối thiểu:', style: TextStyle(fontSize: 16)),
                const SizedBox(height: 10),
                SizedBox(
                  height: 45,
                  width: 270,
                  child: TextField(
                    textAlign: TextAlign.center,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: const Color(0xFFF0DDF4),
                      suffix: const Text(
                        'quyển',
                        style: TextStyle(
                          color: Color(0xFF5A639C),
                          fontSize: 14,
                          fontWeight: FontWeight.w300,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 50),
                const Text('Lượng tồn tối thiểu trước khi nhập', style: TextStyle(fontSize: 16)),
                const SizedBox(height: 10),
                SizedBox(
                  height: 45,
                  width: 270,
                  child: TextField(
                    textAlign: TextAlign.center,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: const Color(0xFFF0DDF4),
                      suffix: const Text(
                        'quyển',
                        style: TextStyle(
                          color: Color(0xFF5A639C),
                          fontSize: 14,
                          fontWeight: FontWeight.w300,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  void showInfoDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Container(
            height: 200,
            width: 300,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  const Text('Thông tin chi tiết'),
                  const SizedBox(height: 20),
                  const Text(
                    'Ràng buộc này nhằm đảm bảo khi lập phiếu thu tiền, số tiền thu phải không được vượt quá số tiền mà khách hàng đang nợ giúp đảm bảo tính chính xác và công bằng trong giao dịch.',
                    style: TextStyle(fontSize: 16),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const Text('Đóng'),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  bool _isDismissed = false;
  Widget BanHang_ThuTien() {
    return Container(
      margin: const EdgeInsets.only(top: 30),
      width: 300,
      height: 500,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            blurRadius: 7,
            offset: const Offset(0, 3), // changes position of shadow
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.max,
        children: [
          const SizedBox(height: 50),
          Container(
            padding: const EdgeInsets.only(top: 8),
            width: 195,
            height: 38,
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.only(
                bottomRight: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
              color: Color(0xFF5A639C),
            ),
            child: const Text(
              'Bán hàng / Thu tiền',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 40),
          Padding(
            padding: const EdgeInsets.only(left: 10),
            child: Column(
              mainAxisSize: MainAxisSize.max,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Tiền nợ tối đa khách hàng có thể mua:', style: TextStyle(fontSize: 16)),
                const SizedBox(height: 10),
                SizedBox(
                  height: 45,
                  width: 270,
                  child: TextField(
                    textAlign: TextAlign.center,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: const Color(0xFFF0DDF4),
                      suffix: const Text(
                        'đ',
                        style: TextStyle(
                          color: Color(0xFF5A639C),
                          fontSize: 14,
                          fontWeight: FontWeight.w300,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 50),
                const Text('Lượng tồn tối thiểu sau khi bán', style: TextStyle(fontSize: 16)),
                const SizedBox(height: 10),
                SizedBox(
                  height: 45,
                  width: 270,
                  child: TextField(
                    textAlign: TextAlign.center,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: const Color(0xFFF0DDF4),
                      suffix: const Text(
                        'quyển',
                        style: TextStyle(
                          color: Color(0xFF5A639C),
                          fontSize: 14,
                          fontWeight: FontWeight.w300,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Image.asset(
                      "assets/images/chain.png",
                      width: 24.0, // Chỉ định chiều rộng
                      height: 24.0, // Chỉ định chiều cao
                    ),
                    const Text('Ràng buộc điều kiện', style: TextStyle(fontSize: 16)),
                  ],
                ),
                const SizedBox(height: 10),
                _isDismissed
                    ? IconButton(
                  icon: Icon(Icons.add),
                  onPressed: () {
                    setState(() {
                      _isDismissed = false;
                    });
                  },
                )
                    : Dismissible(
                  key: UniqueKey(),
                  direction: DismissDirection.endToStart,
                  onDismissed: (direction) {
                    setState(() {
                      _isDismissed = true;
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Item dismissed')),
                    );
                  },
                  background: Container(
                    color: Colors.red,
                    alignment: Alignment.centerRight,
                    padding: EdgeInsets.only(right: 20.0),
                    child: Icon(
                      Icons.delete,
                      color: Colors.white,
                    ),
                  ),
                  child: Container(
                    height: 45,
                    width: 270,
                    color: const Color(0xFFF0DDF4),
                    child: Row(
                      children: [
                        const Padding(
                          padding: EdgeInsets.only(left: 10, right: 10),
                          child: Text('Thu không vượt nợ khách hàng'),
                        ),
                        IconButton(
                          onPressed: () {
                            showInfoDialog(context);
                          },
                          icon: const Icon(Icons.info, color: Color(0xFF5A639C)),
                        ),
                      ],
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            widget.overallScreenContextSwitcher(OverallScreenContexts.mainFunctions.index);
          },
          icon: const Icon(Icons.arrow_back),
        ),
        title: const Text('Chỉnh sửa quy định'),
      ),
      body: FutureBuilder(
        future: getMyFavData(),
        builder: (context, AsyncSnapshot<List<Widget>> snapshot) {
          if (snapshot.data == null) {
            return const Center(
              child: CircularProgressIndicator(backgroundColor: Colors.red),
            );
          } else {
            List<Widget> containers = [NhapHang(), BanHang_ThuTien()];
            return Stack(
              children: <Widget>[
                SingleChildScrollView(
                  child: Column(
                    children: [
                      CarouselSlider(
                        items: containers,
                        carouselController: buttonCarouselController,
                        options: CarouselOptions(
                          height: 600,
                          pageSnapping: true,
                          autoPlay: false,
                          enlargeCenterPage: true,
                          viewportFraction: 0.9,
                          onPageChanged: (index, reason) {
                            setState(() {
                              currentIndex = index;
                            });
                          },
                        ),
                      ),
                      Container(
                        width: 139,
                        child: TextButton(
                          onPressed: () {},
                          style: TextButton.styleFrom(
                            backgroundColor: const Color(0xFF536A9C),
                            foregroundColor: Colors.white,
                          ),
                          child: const Text('Lưu'),
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  children: [
                    const SizedBox(height: 40),
                    Center(
                      child: SmoothPageIndicator(
                        controller: PageController(initialPage: currentIndex),
                        count: containers.length,
                        effect: const ExpandingDotsEffect(
                          activeDotColor: Color(0xFF9797FF),
                          dotColor: Color(0xFFF0F0FF),
                          dotHeight: 15,
                        ),
                        onDotClicked: (index) {
                          buttonCarouselController.animateToPage(index);
                        },
                      ),
                    ),
                  ],
                ),
              ],
            );
          }
        },
      ),
    );
  }
}