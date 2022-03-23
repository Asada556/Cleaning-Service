import 'package:cleaning_service/constants/colors.dart';
import 'package:cleaning_service/screens/register/maid/form.dart';
import 'package:cleaning_service/shared/button.dart';
import 'package:cleaning_service/shared/radio_group.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class RegisterTermAndConditionsScreen extends StatefulWidget {
  const RegisterTermAndConditionsScreen({Key? key}) : super(key: key);

  @override
  State<RegisterTermAndConditionsScreen> createState() =>
      _RegisterTermAndConditionsScreenState();
}

class _RegisterTermAndConditionsScreenState
    extends State<RegisterTermAndConditionsScreen> {
  bool isAccept = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
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
              Container(
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                decoration: BoxDecoration(
                  color: kLightBlue,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  children: [
                    Text(
                      "ข้อกำหนดในการสมัครเป็นแม่บ้านของเรา",
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.red,
                      ),
                    ),
                    Text(
                      "กรุณาอ่านให้หมดก่อนทำการสมัคร",
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.red,
                      ),
                    ),
                    SizedBox(height: 12),
                    Text(
                        "ผู้สมัครสมาชิกตกลงยินยอมผูกพันตามข้อกําหนดและเงื่อนไขการใช้บริการร้องเรียนออนไลน์ของสํานักงานคณะกรรมการข้อมูลข่าวสารของราชการ ดังต่อไปนี้ 1.การสมัครสมาชิกสํานักงานคณะกรรมการข้อมูลข่าวสารของราชการไม่ต้องเสียค่าใช้จ่ายใดๆ ทั้งสิ้น 2.ผู้สมัครจะต้องกรอกข้อมูลรายละเอียดต่างๆตามจริงให้ครบถ้วนหากตรวจพบว่าข้อมูลของผู้สมัครไม่เป็นความจริงสํานักงานคณะกรรมการข้อมูลข่าวสารของราชการจะระงับการใช้งานของผู้สมัครโดยไม่ต้องแจ้งให้ทราบล่วงหน้า 3.ผู้สมัครจะต้องรักษารหัสผ่านหรือชื่อเข้าใช้งานในระบบสมาชิกเป็นความลับ 4.ข้อมูลส่วนบุคคลของผู้สมัครที่ได้ลงทะเบียน หรือผ่านการใช้งานของเว็บไซต์ของสํานักงานคณะกรรมการข้อมูลข่าวสารของราชการทั้งหมดนั้นผู้สมัครยอมรับและตกลงว่าเป็นสิทธิของสํานักงานคณะกรรมการข้อมูลข่าวสารของราชการซึ่งผู้สมัครต้องอนุญาตให้สํานักงานคณะกรรมการข้อมูลข่าวสารของราชการใช้ข้อมูลของผู้สมัครสมาชิกในงานที่เกี่ยวข้องกับสํานักงานคณะกรรมการข้อมูลข่าวสารของ ราชการ"),
                    RadioGroup(
                      toggleable: true,
                      onChange: (value) {
                        setState(() {
                          isAccept = value == null ? false : true;
                        });
                      },
                      options: [
                        RadioOption(label: "ยอมรับข้อกำหนด", value: true),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(height: 24),
              Button(
                width: 150,
                child: Text(
                  "ยืนยัน",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                  ),
                ),
                padding: EdgeInsets.symmetric(vertical: 8),
                color: kGreen,
                onTap: () {
                  if (!isAccept) return;

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => RegisterFormMaid(),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
