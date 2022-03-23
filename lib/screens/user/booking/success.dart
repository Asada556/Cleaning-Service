import 'package:cleaning_service/api/order.dart';
import 'package:cleaning_service/constants/colors.dart';
import 'package:cleaning_service/models/order.dart';
import 'package:cleaning_service/models/user.dart';
import 'package:cleaning_service/screens/user/home/home.dart';
import 'package:cleaning_service/shared/Input.dart';
import 'package:cleaning_service/shared/button.dart';
import 'package:cleaning_service/shared/modal.dart';
import 'package:cleaning_service/shared/radio_group.dart';
import 'package:cleaning_service/store/user.dart';
import 'package:cleaning_service/utils/cancel_order.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class BookingSuccessScreen extends StatefulWidget {
  const BookingSuccessScreen({Key? key}) : super(key: key);

  @override
  State<BookingSuccessScreen> createState() => _BookingSuccessScreenState();
}

class _BookingSuccessScreenState extends State<BookingSuccessScreen> {
  bool loading = true;
  UserModel userState = UserModel();
  OrderModel? order = OrderModel();
  String cancelReason = "";
  handleCancel(BuildContext context) async {
    await CancelOrder(context).show(user: userState, order: order!);
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => UserHomeScreen(),
      ),
    );
  }

  @override
  void initState() {
    WidgetsBinding.instance?.addPostFrameCallback((timeStamp) async {
      userState = context.read<UserState>().user;
      order = await OrderAPI.user(userState).findCurrentOrder();
      setState(() {
        loading = false;
      });

      await Future.delayed(Duration(seconds: 1));
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => UserHomeScreen(
            pageIndex: 1,
          ),
        ),
      );
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return loading
        ? Center(child: CircularProgressIndicator())
        : Scaffold(
            body: SafeArea(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Center(
                      child: Text(
                        "การจองเสร็จสิ้น",
                        style: TextStyle(
                          fontSize: 36,
                        ),
                      ),
                    ),
                    SizedBox(height: 24),
                    Image.asset(
                      "assets/icons/check.png",
                      width: size.width * 0.4,
                    ),
                    SizedBox(height: 24),
                    Text(
                        "คุณได้ทำการจองแม่บ้านของเราเวลา ${order!.startTime} น."),
                    SizedBox(height: 24),
                    Text("ราคา 435 บาท"),
                    SizedBox(height: 24),
                    Text(
                        "คุณสามารถยกเลิกการจองได้ไม่เกิน 1 ช.ม. ถ้าเกินกว่าเวลาที่กำหนดจะยกเลิกไม่ได้"),
                    SizedBox(height: 24),
                    Button(
                      onTap: () {
                        handleCancel(context);
                      },
                      color: kLightBlue,
                      padding: EdgeInsets.symmetric(vertical: 12),
                      child: Text(
                        "ต้องการยกเลิกหรือเลื่อนเวลาคลิกที่นี่",
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.red,
                        ),
                      ),
                    ),
                    SizedBox(height: 24),
                    Text("ขอบคุณที่ไว้วางใจในการใช้บริการของเรา"),
                    SizedBox(height: 24),
                    Center(
                      child: Button(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => UserHomeScreen(),
                            ),
                          );
                        },
                        child: Text(
                          "ยืนยัน",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                          ),
                        ),
                        width: 150,
                        color: kGreen,
                        padding: EdgeInsets.symmetric(
                          vertical: 8,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
  }
}
