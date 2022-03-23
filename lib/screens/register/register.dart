import 'package:cleaning_service/constants/colors.dart';
import 'package:cleaning_service/screens/index/term_and_conditions.dart';
import 'package:cleaning_service/screens/register/user/form.dart';
import 'package:cleaning_service/shared/button.dart';
import 'package:cleaning_service/store/auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class RegisterScreen extends StatefulWidget {
  RegisterScreen({Key? key}) : super(key: key);

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  String selectUserType = "user";

  bool isSelect(String type) {
    return selectUserType == type;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 24,
          vertical: 12,
        ),
        child: SafeArea(
          child: SingleChildScrollView(
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
                SizedBox(height: 24),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 36),
                  child: Column(
                    children: [
                      Button(
                        padding: const EdgeInsets.all(12.0),
                        width: double.infinity,
                        onTap: () {
                          setState(() {
                            selectUserType = "user";
                          });
                        },
                        color: isSelect("user") ? kPurple : kLightBlue,
                        child: Column(
                          children: [
                            Image.asset(
                              "assets/icons/user.png",
                              height: 150,
                            ),
                            SizedBox(height: 12),
                            Text(
                              "ผู้ใช้ทั่วไป",
                              style: TextStyle(fontSize: 20),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 48),
                      Button(
                        padding: const EdgeInsets.all(12.0),
                        width: double.infinity,
                        onTap: () {
                          setState(() {
                            selectUserType = "maid";
                          });
                        },
                        color: isSelect("maid") ? kPurple : kLightBlue,
                        child: Column(
                          children: [
                            Image.asset(
                              "assets/icons/maid.png",
                              height: 150,
                            ),
                            SizedBox(height: 12),
                            Text(
                              "แม่บ้าน",
                              style: TextStyle(fontSize: 20),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: Container(
        padding: EdgeInsets.only(bottom: 32, right: 70, left: 70),
        height: 90,
        child: Button(
          padding: const EdgeInsets.all(12.0),
          child: Text(
            "หน้าต่อไป",
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
            ),
            textAlign: TextAlign.center,
          ),
          color: kGreen,
          onTap: () {
            context.read<AuthState>().setUserRole(selectUserType);
            switch (selectUserType) {
              case "user":
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => RegisterFormUser(),
                  ),
                );
                break;
              case "maid":
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => RegisterTermAndConditionsScreen(),
                  ),
                );
                break;
            }
          },
        ),
      ),
    );
  }
}
