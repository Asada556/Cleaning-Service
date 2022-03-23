import 'package:cleaning_service/constants/colors.dart';
import 'package:cleaning_service/models/user.dart';
import 'package:cleaning_service/screens/login/login.dart';
import 'package:cleaning_service/screens/user/home/home.dart';
import 'package:cleaning_service/shared/Input.dart';
import 'package:cleaning_service/shared/button.dart';
import 'package:cleaning_service/shared/radio_group.dart';
import 'package:cleaning_service/store/auth.dart';
import 'package:cleaning_service/store/user.dart';
import 'package:cleaning_service/utils/helpers.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import "package:provider/provider.dart";

class RegisterFormUser extends StatefulWidget {
  const RegisterFormUser({Key? key}) : super(key: key);

  @override
  _RegisterFormUserState createState() => _RegisterFormUserState();
}

class _RegisterFormUserState extends State<RegisterFormUser> {
  handleSubmit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    final authState = context.read<AuthState>();
    final userState = context.read<UserState>();

    final _user = await UserModel(
      id: authState.id,
      avatar: authState.avatar,
      role: authState.role,
      name: nameController.text,
      email: authState.email,
      phoneNumber: phoneNumberController.text,
      gender: gender,
      userInfo: UserInfo(
        address: UserAddress(
          dormitoryName: dormitoryNameController.text,
          dormitoryNumber: dormitoryNumberController.text,
          dormitoryBuilding: dormitoryBuidingController.text,
          dormitoryFloor: dormitoryFloorController.text,
        ),
      ),
    ).create();

    userState.setUser(_user);

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => LoginScreen(),
      ),
    );
  }

  final nameController = TextEditingController();
  final phoneNumberController = TextEditingController();
  final dormitoryNameController = TextEditingController();
  final dormitoryNumberController = TextEditingController();
  final dormitoryFloorController = TextEditingController();
  final dormitoryBuidingController = TextEditingController();

  String gender = "male";

  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  Text(
                    "Cleaning Service",
                    style: GoogleFonts.rancho(
                      fontSize: 64,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 12),
                  Text(
                    "สมัครเป็นส่วนหนึ่งของเรา",
                    style: TextStyle(fontSize: 24),
                  ),
                  SizedBox(height: 12),
                  Input(
                    enable: false,
                    initialValue: context.read<AuthState>().email,
                    labelText: "อีเมล",
                  ),
                  SizedBox(height: 12),
                  Input(
                    controller: nameController,
                    labelText: "ชื่อ-สกุล",
                    validator: (value) {
                      if (value == null ||
                          value.isEmpty ||
                          !Helpers.allStringRegExp(value)) {
                        return 'กรุณากรอก ชื่อ-นาม สกุล ให้ถูกต้อง';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 12),
                  RadioGroup(
                    labelText: "เพศ",
                    selectedValue: gender,
                    onChange: (val) {
                      setState(() {
                        gender = val;
                      });
                    },
                    options: [
                      RadioOption(label: "ชาย", value: "male"),
                      RadioOption(label: "หญิง", value: "female"),
                    ],
                  ),
                  SizedBox(height: 12),
                  Input(
                    labelText: "คุณต้องการใช้บริการที่ไหน ",
                    hintText: "ชื่อหอพัก",
                    controller: dormitoryNameController,
                    validator: (value) {
                      if (value == null ||
                          value.isEmpty ||
                          !Helpers.allStringRegExp(value)) {
                        return 'กรุณากรอก ชื่อหอพัก ให้ถูกต้อง';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        width: 100,
                        child: Input(
                          controller: dormitoryNumberController,
                          labelText: "ระบุห้อง ",
                          validator: (value) {
                            if (value == null ||
                                value.isEmpty ||
                                !Helpers.alphanumericRegExp(value)) {
                              return 'กรุณากรอก ห้อง ให้ถูกต้อง';
                            }
                            return null;
                          },
                        ),
                      ),
                      Row(
                        children: [
                          Container(
                            width: 80,
                            child: Input(
                              controller: dormitoryFloorController,
                              labelText: "ระบุชั้น ",
                              validator: (value) {
                                if (value == null ||
                                    value.isEmpty ||
                                    !Helpers.allNumberRegExp(value)) {
                                  return 'กรุณากรอก ชั้น ให้ถูกต้อง';
                                }
                                return null;
                              },
                            ),
                          ),
                          SizedBox(width: 12),
                          Container(
                            width: 80,
                            child: Input(
                              controller: dormitoryBuidingController,
                              labelText: "ระบุตึก ",
                              validator: (value) {
                                if (value == null ||
                                    value.isEmpty ||
                                    !Helpers.alphanumericRegExp(value)) {
                                  return 'กรุณากรอก ตึก ให้ถูกต้อง';
                                }
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: 12),
                  Input(
                    controller: phoneNumberController,
                    labelText: "เบอร์โทรศัพท์",
                    validator: (value) {
                      if (value == null ||
                          value.isEmpty ||
                          !Helpers.phoneNumberRegExp(value)) {
                        return 'กรุณากรอก เบอร์โทรศัพท์ ให้ถูกต้อง';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 24),
                  Button(
                    child: Text(
                      "ยืนยัน",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                      ),
                    ),
                    color: kGreen,
                    padding: EdgeInsets.symmetric(vertical: 8),
                    onTap: handleSubmit,
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
