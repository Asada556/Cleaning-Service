import 'package:cleaning_service/api/auth.dart';
import 'package:cleaning_service/constants/colors.dart';
import 'package:cleaning_service/models/user.dart';
import 'package:cleaning_service/screens/index/index.dart';
import 'package:cleaning_service/screens/user/shared/account/edit_account.dart';
import 'package:cleaning_service/shared/Input.dart';
import 'package:cleaning_service/shared/button.dart';
import 'package:cleaning_service/store/user.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AccountScreen extends StatefulWidget {
  const AccountScreen({Key? key}) : super(key: key);

  @override
  _AccountScreenState createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  UserModel userState = UserModel();
  bool loading = true;

  @override
  void initState() {
    WidgetsBinding.instance?.addPostFrameCallback((_) {
      setState(() {
        userState = context.read<UserState>().user;
        loading = false;
      });
    });
    super.initState();
  }

  Widget getAddress() {
    switch (userState.role) {
      case "maid":
        return Input(
          labelText: "ที่อยู่",
          initialValue: userState.maidInfo?.address,
          enable: false,
        );

      default:
        return Column(
          children: [
            Input(
              labelText: "ชื่อหอพัก",
              initialValue: userState.userInfo?.address?.dormitoryName,
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
                    initialValue: userState.userInfo?.address?.dormitoryNumber,
                    enable: false,
                  ),
                ),
                Row(
                  children: [
                    Container(
                      width: 80,
                      child: Input(
                        labelText: "ชั้น",
                        initialValue:
                            userState.userInfo?.address?.dormitoryFloor,
                        enable: false,
                      ),
                    ),
                    SizedBox(width: 12),
                    Container(
                      width: 80,
                      child: Input(
                        labelText: "ตึก",
                        initialValue:
                            userState.userInfo?.address?.dormitoryBuilding,
                        enable: false,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Profile",
          style: TextStyle(
            color: Colors.black,
          ),
        ),
        centerTitle: true,
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: loading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                child: Column(
                  children: [
                    Center(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(99),
                        child: Image.network(
                          userState.avatar!,
                          width: 120,
                          height: 120,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    SizedBox(height: 36),
                    Input(
                      labelText: "ชื่อ-สกุล",
                      initialValue: userState.name,
                      enable: false,
                    ),
                    SizedBox(height: 24),
                    Input(
                      labelText: "หมายเลขเบอร์โทรศัพท์",
                      initialValue: userState.phoneNumber,
                      enable: false,
                    ),
                    SizedBox(height: 24),
                    getAddress(),
                    // Input(
                    //   labelText: "ที่อยู่",
                    //   initialValue: ,
                    //   enable: false,
                    // ),
                    SizedBox(height: 24),
                    Input(
                      labelText: "E-Mail",
                      initialValue: userState.email,
                      enable: false,
                    ),
                    SizedBox(height: 48),
                    Button(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => EditAccountScreen(),
                          ),
                        );
                      },
                      padding: EdgeInsets.symmetric(vertical: 12),
                      color: kGreen,
                      child: Text(
                        "แก้ไขโปรไฟล์",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                        ),
                      ),
                    ),
                    SizedBox(height: 24),
                    Button(
                      onTap: () async {
                        await AuthAPI.logout();
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => IndexScreen(),
                          ),
                        );
                      },
                      padding: EdgeInsets.symmetric(vertical: 12),
                      color: kRed,
                      child: Text(
                        "ออกจากระบบ",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
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
