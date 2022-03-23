import 'package:cleaning_service/api/auth.dart';
import 'package:cleaning_service/constants/colors.dart';
import 'package:cleaning_service/models/user.dart';
import 'package:cleaning_service/screens/maid/home/home.dart';
import 'package:cleaning_service/screens/register/register.dart';
import 'package:cleaning_service/screens/user/home/home.dart';
import 'package:cleaning_service/shared/button.dart';
import 'package:cleaning_service/store/auth.dart';
import 'package:cleaning_service/store/user.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Image.asset(
                "assets/images/login-bg.png",
                height: size.height * 0.4,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Welcome back",
                          style: TextStyle(
                            fontSize: 18,
                          ),
                        ),
                        SizedBox(height: 12),
                        Center(
                          child: Text(
                            "เข้าสู่ระบบด้วย",
                            style: TextStyle(
                              fontSize: 24,
                            ),
                          ),
                        ),
                      ],
                    ),
                    Column(
                      children: [
                        SizedBox(height: 20),
                        Button(
                          onTap: () async {
                            final result = await AuthAPI.signInWithGoogle();
                            final existUser =
                                await UserModel.findById(result.user!.uid);

                            if (existUser == null) {
                              context.read<AuthState>().setLoginData(
                                    id: result.user!.uid,
                                    avatar: result.user!.photoURL!,
                                    email: result.user!.email!,
                                  );

                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => RegisterScreen(),
                                ),
                              );
                              return;
                            }

                            context.read<UserState>().setUser(existUser);

                            if (existUser.role == "user") {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => UserHomeScreen(),
                                ),
                              );
                            } else {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => MaidHomeScreen(),
                                ),
                              );
                            }
                          },
                          color: kGreen,
                          child: ListTile(
                            leading: Image.asset(
                              "assets/images/google.png",
                              width: 36,
                            ),
                            title: Text(
                              "Google",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            textColor: Colors.white,
                          ),
                        ),
                        SizedBox(height: 30),
                      ],
                    ),
                    Center(
                      child: Text("If our room is clean, our mind is clean."),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
