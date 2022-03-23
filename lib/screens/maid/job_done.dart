import 'package:cleaning_service/api/order.dart';
import 'package:cleaning_service/models/notification.dart';
import 'package:cleaning_service/models/order.dart';
import 'package:cleaning_service/screens/maid/home/home.dart';
import 'package:cleaning_service/shared/modal.dart';
import 'package:cleaning_service/store/user.dart';
import 'package:cleaning_service/utils/image_picker_helper.dart';
import 'package:cleaning_service/constants/colors.dart';
import 'package:cleaning_service/shared/button.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

class MaidJobDoneScreen extends StatefulWidget {
  const MaidJobDoneScreen({Key? key}) : super(key: key);

  @override
  _MaidJobDoneScreenState createState() => _MaidJobDoneScreenState();
}

class _MaidJobDoneScreenState extends State<MaidJobDoneScreen> {
  final ImagePicker _picker = ImagePicker();
  final maxImageCount = 5;
  List<ImagePickerHelper> _files =
      List.generate(5, (index) => ImagePickerHelper());

  bool validateImages = true;

  selectImage() async {
    try {
      final _image = await _picker.pickImage(source: ImageSource.gallery);
      final currentIndex = fileCounts();
      if (_image != null) {
        setState(() {
          _files[currentIndex].addXFile(_image);
        });
      }
    } catch (e) {
      print("error => ${e.toString()}");
    }
  }

  editSelectImage(int index) async {
    try {
      final _image = await _picker.pickImage(source: ImageSource.gallery);
      if (_image != null) {
        setState(() {
          _files[index].addXFile(_image);
        });
      }
    } catch (e) {
      print("error => ${e.toString()}");
    }
  }

  handleDone() async {
    final _userState = context.read<UserState>().user;

    final maidOrderAPI = OrderAPI.maid(_userState);

    final _order = (await maidOrderAPI.findCurrentJob())!;

    _order.proofImages = [];

    for (var f in _files) {
      final url = await f.uploadToStorage("job_done");
      if (url != null) {
        _order.proofImages!.add(url);
      }
    }

    if (_order.proofImages!.isEmpty) {
      setState(() {
        validateImages = false;
      });
      return;
    }

    await maidOrderAPI.jobDone(_order);

    await Modal().show(
      context,
      duration: Duration(seconds: 3),
      body: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(
            "assets/icons/done.png",
            width: 120,
          ),
          SizedBox(height: 12),
          Text(
            "ทำงานเสร็จแล้ว",
            style: TextStyle(
              color: Color.fromRGBO(55, 170, 36, 1),
              fontSize: 24,
            ),
          ),
        ],
      ),
    );

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => MaidHomeScreen(),
      ),
    );
  }

  fileCounts() {
    int counts = 0;
    for (var _file in _files) {
      if (_file.file != null) {
        counts++;
      }
    }

    return counts;
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "ยืนยันการทำงาน",
          style: TextStyle(color: Colors.black),
        ),
        iconTheme: IconThemeData(color: Colors.black),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "แนบรูปหลักฐาน",
              style: TextStyle(fontSize: 18),
            ),
            Container(
              width: size.width,
              height: 120,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  fileCounts() < maxImageCount
                      ? Container(
                          width: 150,
                          padding: const EdgeInsets.symmetric(vertical: 12.0),
                          child: Button(
                            onTap: () {
                              selectImage();
                            },
                            color: kLightBlue,
                            child: Icon(
                              Icons.note_add_outlined,
                              color: Colors.grey[500],
                              size: 48,
                            ),
                          ),
                        )
                      : SizedBox(),
                  for (int i = 0; i < fileCounts(); i++)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Container(
                        width: 150,
                        padding: const EdgeInsets.symmetric(vertical: 12.0),
                        child: Button(
                          onTap: () {
                            editSelectImage(i);
                          },
                          color: kLightBlue,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: _files[i].render(),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            !validateImages
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        "กรุณาอัปโหลดรูปหลักฐาน",
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                  )
                : SizedBox(),
            SizedBox(height: 36),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Button(
                  onTap: handleDone,
                  color: kGreen,
                  padding: EdgeInsets.symmetric(vertical: 6, horizontal: 32),
                  child: Text(
                    "ยืนยัน",
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.white,
                    ),
                  ),
                ),
                Button(
                  color: Colors.grey[300],
                  padding: EdgeInsets.symmetric(vertical: 6, horizontal: 32),
                  child: Text(
                    "ยกเลิก",
                    style: TextStyle(
                      fontSize: 18,
                    ),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
