import 'package:cleaning_service/models/user.dart';
import 'package:cleaning_service/screens/login/login.dart';
import 'package:cleaning_service/screens/maid/home/home.dart';
import 'package:cleaning_service/store/auth.dart';
import 'package:cleaning_service/utils/helpers.dart';
import 'package:cleaning_service/utils/image_picker_helper.dart';
import 'package:cleaning_service/constants/colors.dart';
import 'package:cleaning_service/shared/Input.dart';
import 'package:cleaning_service/shared/button.dart';
import 'package:cleaning_service/shared/radio_group.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import "package:provider/provider.dart";
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;

class RegisterFormMaid extends StatefulWidget {
  const RegisterFormMaid({Key? key}) : super(key: key);

  @override
  _RegisterFormMaidState createState() => _RegisterFormMaidState();
}

class _RegisterFormMaidState extends State<RegisterFormMaid> {
  final ImagePicker _picker = ImagePicker();
  final imageFileFront = ImagePickerHelper();
  final imageFileBack = ImagePickerHelper();

  final nameController = TextEditingController();
  final addressController = TextEditingController();
  final phoneNumberController = TextEditingController();
  final highestQualificationController = TextEditingController();

  String gender = "male";
  String jobType = "full_time";

  final ref =
      firebase_storage.FirebaseStorage.instance.ref().child("maid_id_cards");

  handleSubmit() async {
    if (imageFileFront.isEmpty()) {
      setState(() {
        validateFront = false;
      });
    } else {
      setState(() {
        validateFront = true;
      });
    }

    if (imageFileBack.isEmpty()) {
      setState(() {
        validateBack = false;
      });
    } else {
      setState(() {
        validateBack = true;
      });
    }

    if (!_formKey.currentState!.validate() || !validateFront || !validateBack) {
      return;
    }

    final dirname = "maid_id_cards";
    final authState = context.read<AuthState>();

    await UserModel(
      id: authState.id,
      email: authState.email,
      avatar: authState.avatar,
      name: nameController.text,
      phoneNumber: phoneNumberController.text,
      role: "maid",
      maidInfo: MaidInfo(
        address: addressController.text,
        jobType: jobType,
        backIdCardImage: await imageFileFront.uploadToStorage(dirname),
        fronIdCardImage: await imageFileFront.uploadToStorage(dirname),
        highestQualification: highestQualificationController.text,
      ),
    ).create();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => LoginScreen(),
      ),
    );
  }

  final _formKey = GlobalKey<FormState>();
  bool validateFront = true;
  bool validateBack = true;

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
                crossAxisAlignment: CrossAxisAlignment.start,
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
                    selectedValue: gender,
                    onChange: (v) {
                      setState(() {
                        gender = v;
                      });
                    },
                    labelText: "เพศ",
                    options: [
                      RadioOption(label: "ชาย", value: "male"),
                      RadioOption(label: "หญิง", value: "female"),
                    ],
                  ),
                  SizedBox(height: 12),
                  Input(
                    controller: addressController,
                    labelText: "ที่อยู่ของคุณ",
                    validator: (value) {
                      if (value == null ||
                          value.isEmpty ||
                          !Helpers.addressRegExp(value)) {
                        return 'กรุณากรอก ที่อยู่ของคุณ ให้ถูกต้อง';
                      }
                      return null;
                    },
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
                  SizedBox(height: 12),
                  Input(
                    controller: highestQualificationController,
                    labelText: "วุฒิการศึกษาสูงสุด",
                    validator: (value) {
                      if (value == null ||
                          value.isEmpty ||
                          !Helpers.allStringRegExp(value)) {
                        return 'กรุณากรอก วุฒิการศึกษาสูงสุด ให้ถูกต้อง';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 24),
                  RadioGroup(
                    selectedValue: jobType,
                    onChange: (v) {
                      setState(() {
                        jobType = v;
                      });
                    },
                    labelText: "ลักษณะงานที่ต้องการ",
                    options: [
                      RadioOption(label: "งานประจำ", value: "full_time"),
                      RadioOption(label: "งานนอกเวลา", value: "part_time"),
                    ],
                  ),
                  SizedBox(height: 24),
                  Text(
                    "ถ่ายรูปบัตรประชาชน",
                    style: TextStyle(
                      fontSize: 20,
                    ),
                  ),
                  SizedBox(height: 12),
                  Button(
                    color: kLightBlue,
                    onTap: () async {
                      final XFile? _image =
                          await _picker.pickImage(source: ImageSource.gallery);

                      if (_image != null) {
                        setState(() {
                          imageFileFront.addXFile(_image);
                        });
                      }
                    },
                    padding: EdgeInsets.all(12),
                    child: imageFileFront.file != null
                        ? imageFileFront.render(fit: BoxFit.cover)
                        : Padding(
                            padding: const EdgeInsets.symmetric(vertical: 36),
                            child: Icon(
                              Icons.note_add_outlined,
                              size: 96,
                              color: Colors.grey[400],
                            ),
                          ),
                  ),
                  !validateFront
                      ? Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            "กรุณาอัปโหลดรูปหน้าบัตรประชาชน",
                            style: TextStyle(
                              color: Colors.red,
                            ),
                          ),
                        )
                      : SizedBox(),
                  SizedBox(height: 12),
                  Button(
                    color: kLightBlue,
                    onTap: () async {
                      final XFile? _image =
                          await _picker.pickImage(source: ImageSource.gallery);

                      if (_image != null) {
                        setState(() {
                          imageFileBack.addXFile(_image);
                        });
                      }
                    },
                    padding: EdgeInsets.all(12),
                    child: imageFileBack.file != null
                        ? imageFileBack.render()
                        : Padding(
                            padding: const EdgeInsets.symmetric(vertical: 36),
                            child: Icon(
                              Icons.note_add_outlined,
                              size: 96,
                              color: Colors.grey[400],
                            ),
                          ),
                  ),
                  !validateBack
                      ? Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            "กรุณาอัปโหลดรูปหลังบัตรประชาชน",
                            style: TextStyle(
                              color: Colors.red,
                            ),
                          ),
                        )
                      : SizedBox(),
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
