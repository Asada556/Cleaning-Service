import 'package:cleaning_service/constants/colors.dart';
import 'package:cleaning_service/constants/room.dart';
import 'package:cleaning_service/models/order.dart';
import 'package:cleaning_service/models/user.dart';
import 'package:cleaning_service/screens/user/booking/payment.dart';
import 'package:cleaning_service/shared/Input.dart';
import 'package:cleaning_service/shared/button.dart';
import 'package:cleaning_service/store/order.dart';
import 'package:cleaning_service/store/user.dart';
import 'package:cleaning_service/utils/calculate_cleaing_cost.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class BookingConfirmScreen extends StatefulWidget {
  const BookingConfirmScreen({Key? key}) : super(key: key);

  @override
  _BookingConfirmScreenState createState() => _BookingConfirmScreenState();
}

class _BookingConfirmScreenState extends State<BookingConfirmScreen> {
  OrderModel orderState = OrderModel();
  UserModel userState = UserModel();
  bool loading = true;

  @override
  void initState() {
    WidgetsBinding.instance?.addPostFrameCallback((_) {
      setState(() {
        orderState = context.read<OrderState>().order;
        userState = context.read<UserState>().user;
        loading = false;
      });
    });
    super.initState();
  }

  addressText() {
    final address = userState.userInfo!.address;
    return "${address!.dormitoryName} ห้อง ${address.dormitoryNumber} ชั้น ${address.dormitoryFloor} ตึก ${address.dormitoryBuilding}";
  }

  handleSubmit() {
    final cost = CalculateCleaningCost(roomType: orderState.roomType!);
    orderState.cleaningCost = cost.getCleaningCost();
    orderState.cleaningEquipmentCost = cost.getEquipmentCost();
    orderState.vatPercentage = cost.vatPercentage;
    orderState.cleaningRoomTypeCost = cost.getRoomTypeCost();
    context.read<OrderState>().setOrder(orderState);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BookingPaymentScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "ข้อมูลการจองบริการ",
          style: TextStyle(
            color: Colors.black,
          ),
        ),
        backgroundColor: Colors.white,
        iconTheme: IconThemeData(color: Colors.black),
        elevation: 0,
        centerTitle: false,
      ),
      body: loading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                child: Column(
                  children: [
                    SizedBox(height: 24),
                    Input(
                      labelText: "ชื่อ-นามสกุล",
                      enable: false,
                      backgroundColor: Colors.white,
                      initialValue: userState.name,
                    ),
                    SizedBox(height: 24),
                    Input(
                      labelText: "หมายเลขเบอร์โทรศัพท์",
                      enable: false,
                      backgroundColor: Colors.white,
                      initialValue: userState.phoneNumber,
                    ),
                    SizedBox(height: 24),
                    Input(
                      labelText: "สถานที่ในการทำความสะอาด",
                      enable: false,
                      backgroundColor: Colors.white,
                      initialValue: addressText(),
                    ),
                    SizedBox(height: 24),
                    Input(
                      labelText: "ประเภทที่พัก",
                      enable: false,
                      backgroundColor: Colors.white,
                      initialValue: Room.getType(orderState.roomType!)["value"],
                    ),
                    SizedBox(height: 24),
                    Input(
                      labelText: "เวลาที่ใช้บริการ",
                      enable: false,
                      backgroundColor: Colors.white,
                      initialValue: orderState.startTime,
                    ),
                    SizedBox(height: 24),
                    Input(
                      labelText: "ที่พักของคุณมีสัตว์เลี้ยงหรือไม่",
                      enable: false,
                      backgroundColor: Colors.white,
                      initialValue: orderState.petRemark,
                    ),
                    SizedBox(height: 24),
                    Input(
                        labelText: "หมายเหตุ - พื้นที่ที่อยาก ให้เน้นเป็นพิเศษ",
                        enable: false,
                        backgroundColor: Colors.white,
                        initialValue: orderState.cleaningRemark),
                    SizedBox(height: 24),
                    Center(
                      child: Button(
                        onTap: handleSubmit,
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
                    SizedBox(height: 24),
                  ],
                ),
              ),
            ),
    );
  }
}
