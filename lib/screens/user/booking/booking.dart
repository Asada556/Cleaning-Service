import 'package:cleaning_service/api/order.dart';
import 'package:cleaning_service/constants/colors.dart';
import 'package:cleaning_service/models/order.dart';
import 'package:cleaning_service/models/user.dart';
import 'package:cleaning_service/screens/user/booking/confirm.dart';
import 'package:cleaning_service/screens/user/shared/status.dart';
import 'package:cleaning_service/shared/Input.dart';
import 'package:cleaning_service/shared/button.dart';
import 'package:cleaning_service/shared/dropdonw.dart';
import 'package:cleaning_service/store/order.dart';
import 'package:cleaning_service/store/user.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

var uuid = Uuid();

class BookingScreen extends StatefulWidget {
  const BookingScreen({Key? key}) : super(key: key);

  @override
  _BookingScreenState createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  UserModel userState = UserModel();
  bool loading = true;

  @override
  void initState() {
    WidgetsBinding.instance?.addPostFrameCallback((_) async {
      userState = context.read<UserState>().user;
      final _order = await OrderAPI.user(userState).findCurrentOrder();
      if (_order != null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => StatusTabScreen(
              backButton: true,
            ),
          ),
        );
        return;
      }
      setState(() {
        loading = false;
      });
    });
    super.initState();
  }

  handleSubmit() {
    context.read<OrderState>().setOrder(
          OrderModel(
            userId: userState.id,
            roomType: roomType,
            startTime: startTime,
            petRemark: petRemarkController.text,
            cleaningRemark: cleaningRemarkController.text,
          ),
        );
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BookingConfirmScreen(),
      ),
    );
  }

  String roomType = "room_small";
  String startTime = "09:00";
  final petRemarkController = TextEditingController();
  final cleaningRemarkController = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "จองบริการ",
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
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 24),
                      Input(
                        enable: false,
                        labelText: "ผู้รับบริการ ชื่อ-นามสกุล",
                        initialValue: userState.name,
                      ),
                      SizedBox(height: 24),
                      Input(
                        labelText: "หมายเลขเบอร์โทรศัพท์ ",
                        enable: false,
                        initialValue: userState.phoneNumber,
                      ),
                      SizedBox(height: 24),
                      Input(
                        labelText: "ชื่อหอพัก",
                        initialValue:
                            userState.userInfo?.address?.dormitoryName,
                        enable: false,
                      ),
                      SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            width: 100,
                            child: Input(
                              labelText: "เลขที่ห้อง",
                              initialValue:
                                  userState.userInfo?.address?.dormitoryNumber,
                              enable: false,
                            ),
                          ),
                          Row(
                            children: [
                              Container(
                                width: 80,
                                child: Input(
                                  labelText: "ชั้น",
                                  initialValue: userState
                                      .userInfo?.address?.dormitoryFloor,
                                  enable: false,
                                ),
                              ),
                              SizedBox(width: 12),
                              Container(
                                width: 80,
                                child: Input(
                                  labelText: "ตึก",
                                  initialValue: userState
                                      .userInfo?.address?.dormitoryBuilding,
                                  enable: false,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      SizedBox(height: 24),
                      Text(
                        "เลือกประเภทที่พักเพื่อให้เราช่วยคุณประเมิน ระยะเวลาทำความสะอาดและค่าบริการ",
                        style: TextStyle(
                          fontSize: 18,
                        ),
                      ),
                      SizedBox(height: 24),
                      Text(
                        "หมายเหตุ *",
                        style: TextStyle(
                          color: Colors.red,
                          fontSize: 18,
                        ),
                      ),
                      Text(
                        "หอพัก 30 - 50 ตร.ม. ราคา 50 บาท",
                        style: TextStyle(
                          color: Colors.red,
                          fontSize: 18,
                        ),
                      ),
                      Text(
                        "หอพัก 55 ขึ้นไป ราคา 89 บาท",
                        style: TextStyle(
                          color: Colors.red,
                          fontSize: 18,
                          height: 1.0,
                        ),
                      ),
                      SizedBox(height: 24),
                      Dropdown(
                        selectValue: roomType,
                        onChange: (v) {
                          setState(() {
                            if (v != null) {
                              roomType = v;
                            }
                          });
                        },
                        options: [
                          DropdownOption(
                            title: "หอพัก 1 ห้องนอน(ไม่เกิน 30 ตร.ม.)",
                            value: "room_small",
                          ),
                          DropdownOption(
                            title: "หอพัก 1 ห้องนอน(30 - 50 ตร.ม.)",
                            value: "room_medium",
                          ),
                          DropdownOption(
                            title: "หอพัก 1 ห้องนอน(55 ตร.ม.)",
                            value: "room_large",
                          ),
                        ],
                      ),
                      SizedBox(height: 24),
                      Text(
                        "เลือกเวลาที่ต้องการใช้บริการ",
                        style: TextStyle(
                          fontSize: 20,
                        ),
                      ),
                      SizedBox(height: 12),
                      Container(
                        width: 100,
                        child: Dropdown(
                          selectValue: "09:00",
                          onChange: (v) {
                            setState(() {
                              if (v != null) {
                                startTime = v;
                              }
                            });
                          },
                          options: [
                            DropdownOption(title: "09:00", value: "09:00"),
                            DropdownOption(title: "10:00", value: "10:00"),
                            DropdownOption(title: "11:00", value: "11:00"),
                            DropdownOption(title: "12:00", value: "12:00"),
                            DropdownOption(title: "13:00", value: "13:00"),
                            DropdownOption(title: "14:00", value: "14:00"),
                            DropdownOption(title: "15:00", value: "15:00"),
                            DropdownOption(title: "16:00", value: "16:00"),
                          ],
                        ),
                      ),
                      SizedBox(height: 24),
                      Input(
                        labelText: "ที่พักของคุณมีสัตว์เลี้ยงหรือไม่ ",
                        controller: petRemarkController,
                      ),
                      SizedBox(height: 24),
                      Input(
                        labelText: "หมายเหตุ - พื้นที่ที่อยาก ให้เน้นเป็นพิเศษ",
                        controller: cleaningRemarkController,
                      ),
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
            ),
    );
  }
}
