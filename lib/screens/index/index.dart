import 'package:cleaning_service/api/auth.dart';
import 'package:cleaning_service/constants/colors.dart';
import 'package:cleaning_service/models/user.dart';
import 'package:cleaning_service/screens/login/login.dart';
import 'package:cleaning_service/screens/maid/home/home.dart';
import 'package:cleaning_service/screens/user/home/home.dart';
import 'package:cleaning_service/shared/button.dart';
import 'package:cleaning_service/store/user.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class IndexScreen extends StatefulWidget {
  const IndexScreen({Key? key}) : super(key: key);

  @override
  State<IndexScreen> createState() => _IndexScreenState();
}

class _IndexScreenState extends State<IndexScreen> {
  isLogin() async {
    final result = AuthAPI.isLogin();
    if (result == null) return;
    final user = await UserModel.findById(result.uid);

    if (user == null) return;

    WidgetsBinding.instance?.addPostFrameCallback((_) {
      context.read<UserState>().setUser(user);
    });

    switch (user.role) {
      case "maid":
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => MaidHomeScreen(),
          ),
        );
        break;

      default:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => UserHomeScreen(),
          ),
        );
        break;
    }
  }

  @override
  void initState() {
    isLogin();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 24,
            vertical: 12,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Cleaning Service",
                style: GoogleFonts.rancho(
                  fontSize: 64,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Image.asset(
                "assets/images/index-bg.png",
                width: double.infinity,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Text(
                  "ง่ายต่อระบบการทำความสะอาดของคุณ",
                  style: TextStyle(
                    fontSize: 24,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              Button(
                color: kLightBlue,
                padding: const EdgeInsets.symmetric(vertical: 12),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => LoginScreen(),
                    ),
                  );
                },
                child: Text(
                  "Login",
                  style: TextStyle(
                    fontSize: 24,
                  ),
                ),
              ),
              SizedBox(height: 12)
            ],
          ),
        ),
      ),
    );
  }
}
