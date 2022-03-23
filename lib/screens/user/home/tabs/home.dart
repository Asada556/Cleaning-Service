import 'package:cleaning_service/screens/user/booking/booking.dart';
import 'package:flutter/material.dart';
import 'package:cleaning_service/constants/colors.dart';
import 'package:cleaning_service/shared/button.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:google_fonts/google_fonts.dart';

class UserHomeTabScreen extends StatefulWidget {
  final void Function(int) onChangePage;
  const UserHomeTabScreen({
    Key? key,
    required this.onChangePage,
  }) : super(key: key);

  @override
  _UserHomeTabScreenState createState() => _UserHomeTabScreenState();
}

class _UserHomeTabScreenState extends State<UserHomeTabScreen> {
  final CarouselController _controller = CarouselController();
  int _current = 0;
  List<Widget> _images = [
    Image.asset("assets/images/index-bg.png"),
    Image.asset("assets/images/login-bg.png")
  ];

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Cleaning Service",
          style: GoogleFonts.rancho(
            fontSize: 32,
            color: Colors.black,
            fontWeight: FontWeight.w600,
          ),
        ),
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          child: Container(
            height: size.height - 200,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  children: [
                    SizedBox(height: 24),
                    Center(
                      child: Text(
                        " Welcome !!!",
                        style: TextStyle(
                          fontSize: 18,
                        ),
                      ),
                    ),
                    SizedBox(height: 24),
                    CarouselSlider(
                      carouselController: _controller,
                      items: _images,
                      options: CarouselOptions(
                        autoPlay: true,
                        enlargeCenterPage: true,
                        aspectRatio: 2.0,
                        onPageChanged: (index, reason) {
                          setState(() {
                            _current = index;
                          });
                        },
                      ),
                    ),
                    SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding:
                              EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            color: Colors.grey[300],
                          ),
                          child: Row(
                            children: [
                              for (int i = 0; i < _images.length; i++)
                                GestureDetector(
                                  onTap: () => _controller.animateToPage(i),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 3),
                                    child: Icon(
                                      i == _current
                                          ? Icons.circle
                                          : Icons.circle_outlined,
                                      color: Colors.white,
                                      size: 16,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                SizedBox(height: 24),
                Column(
                  children: [
                    Button(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => BookingScreen(),
                          ),
                        );
                      },
                      color: kLightBlue,
                      padding: EdgeInsets.symmetric(vertical: 8),
                      child: Text(
                        "จองบริการ",
                        style: TextStyle(
                          fontSize: 24,
                        ),
                      ),
                    ),
                    SizedBox(height: 24),
                    Button(
                      onTap: () {
                        widget.onChangePage(1);
                      },
                      color: kLightGreen,
                      padding: EdgeInsets.symmetric(vertical: 8),
                      child: Text(
                        "สถานะ",
                        style: TextStyle(
                          fontSize: 24,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
