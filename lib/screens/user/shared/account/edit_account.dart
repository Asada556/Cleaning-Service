import 'dart:io';

import 'package:cleaning_service/constants/colors.dart';
import 'package:cleaning_service/models/user.dart';
import 'package:cleaning_service/shared/Input.dart';
import 'package:cleaning_service/shared/button.dart';
import 'package:cleaning_service/store/user.dart';
import 'package:cleaning_service/utils/helpers.dart';
import 'package:cleaning_service/utils/image_picker_helper.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

class EditAccountScreen extends StatefulWidget {
  const EditAccountScreen({Key? key}) : super(key: key);

  @override
  _AccountScreenState createState() => _AccountScreenState();
}

class _AccountScreenState extends State<EditAccountScreen> {
  bool facebook = true;
  bool google = false;
  final ImagePicker _picker = ImagePicker();
  final _file = ImagePickerHelper();
  bool loading = true;
  UserModel userState = UserModel();
  final nameController = TextEditingController();
  final phoneNumberController = TextEditingController();
  final maidAddressContoller = TextEditingController();

  final userDormitoryNameController = TextEditingController();
  final userDormitoryNumberController = TextEditingController();
  final userDormitoryFloorController = TextEditingController();
  final userDormitoryBuildingController = TextEditingController();

  @override
  initState() {
    WidgetsBinding.instance?.addPostFrameCallback((_) {
      setState(() {
        userState = context.read<UserState>().user;
        nameController.text = userState.name!;
        phoneNumberController.text = userState.phoneNumber!;
        if (userState.role == "maid") {
          maidAddressContoller.text = userState.maidInfo!.address!;
        } else {
          userDormitoryNameController.text =
              userState.userInfo!.address!.dormitoryName!;
          userDormitoryNumberController.text =
              userState.userInfo!.address!.dormitoryNumber!;
          userDormitoryFloorController.text =
              userState.userInfo!.address!.dormitoryFloor!;
          userDormitoryBuildingController.text =
              userState.userInfo!.address!.dormitoryBuilding!;
        }
        loading = false;
      });
    });
    super.initState();
  }

  selectImage() async {
    final XFile? _image = await _picker.pickImage(source: ImageSource.gallery);
    if (_image != null) {
      setState(() {
        _file.addXFile(_image);
      });
    }
  }

  Widget getAddress() {
    switch (userState.role) {
      case "maid":
        return Input(
          labelText: "ที่อยู่",
          controller: maidAddressContoller,
          enable: true,
          validator: (value) {
            if (value == null ||
                value.isEmpty ||
                !Helpers.addressRegExp(value)) {
              return 'กรุณากรอก ที่อยู่ ให้ถูกต้อง';
            }
            return null;
          },
        );

      default:
        return Column(
          children: [
            Input(
              labelText: "ชื่อหอพัก",
              controller: userDormitoryNameController,
              enable: true,
              validator: (value) {
                if (value == null ||
                    value.isEmpty ||
                    !Helpers.alphanumericRegExp(value)) {
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
                    labelText: "เลขที่ห้อง",
                    controller: userDormitoryNumberController,
                    enable: true,
                    validator: (value) {
                      if (value == null ||
                          value.isEmpty ||
                          !Helpers.alphanumericRegExp(value)) {
                        return 'กรุณากรอก เลขที่ห้อง ให้ถูกต้อง';
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
                        labelText: "ชั้น",
                        controller: userDormitoryFloorController,
                        enable: true,
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
                        labelText: "ตึก",
                        controller: userDormitoryBuildingController,
                        enable: true,
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
          ],
        );
    }
  }

  handleSubmit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final _user = UserModel.fromJSON(userState.toJSON());
    _user.name = nameController.text;
    _user.phoneNumber = phoneNumberController.text;

    if (_user.role == "maid") {
      _user.maidInfo!.address = maidAddressContoller.text;
    } else {
      _user.userInfo!.address = UserAddress(
        dormitoryName: userDormitoryNameController.text,
        dormitoryNumber: userDormitoryNumberController.text,
        dormitoryFloor: userDormitoryFloorController.text,
        dormitoryBuilding: userDormitoryBuildingController.text,
      );
    }

    if (!_file.isEmpty()) {
      _user.avatar = await _file.uploadToStorage("avatars");
    }

    context.read<UserState>().setUser(_user);
    await _user.update();

    Navigator.pop(context);
  }

  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Profile",
          style: TextStyle(
            color: Colors.black,
          ),
        ),
        centerTitle: false,
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.black),
      ),
      body: loading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      Container(
                        height: 150,
                        child: Stack(
                          children: [
                            Center(
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(99),
                                child: _file.file != null
                                    ? _file.render(
                                        width: 120,
                                        height: 120,
                                        fit: BoxFit.cover,
                                      )
                                    : Image.network(
                                        userState.avatar!,
                                        width: 120,
                                        height: 120,
                                        fit: BoxFit.cover,
                                      ),
                              ),
                            ),
                            Positioned(
                              top: 120,
                              left: (size.width / 2),
                              child: InkWell(
                                borderRadius: BorderRadius.circular(99),
                                onTap: selectImage,
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Icon(
                                    Icons.edit,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 36),
                      Input(
                        labelText: "ชื่อ-สกุล",
                        controller: nameController,
                        validator: (value) {
                          if (value == null ||
                              value.isEmpty ||
                              !Helpers.allStringRegExp(value)) {
                            return 'กรุณากรอก ชื่อ-นาม สกุล ให้ถูกต้อง';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 24),
                      Input(
                        labelText: "หมายเลขเบอร์โทรศัพท์",
                        controller: phoneNumberController,
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
                      getAddress(),
                      SizedBox(height: 24),
                      Input(
                        labelText: "E-Mail",
                        initialValue: "${userState.email}",
                        enable: false,
                      ),
                      SizedBox(height: 24),
                      Button(
                        onTap: handleSubmit,
                        padding: EdgeInsets.symmetric(vertical: 12),
                        color: kGreen,
                        child: Text(
                          "ยืนยัน",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                          ),
                        ),
                      ),
                      SizedBox(height: 48),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}
