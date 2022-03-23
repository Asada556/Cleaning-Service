import 'package:cleaning_service/api/order.dart';
import 'package:cleaning_service/constants/colors.dart';
import 'package:cleaning_service/models/order.dart';
import 'package:cleaning_service/models/user.dart';
import 'package:cleaning_service/shared/Input.dart';
import 'package:cleaning_service/shared/button.dart';
import 'package:cleaning_service/shared/modal.dart';
import 'package:cleaning_service/shared/radio_group.dart';
import 'package:flutter/material.dart';

class CancelOrder {
  final BuildContext context;

  CancelOrder(this.context);

  Future<String?> show({
    required UserModel user,
    required OrderModel order,
  }) async {
    String cancelReason = "";

    final size = MediaQuery.of(context).size;

    final resultConfirm = await Modal().show(
      context,
      width: size.width,
      height: 250,
      title: "ยกเลิกการจอง",
      body: Text("ท่านต้องการยกเลิกใช่หรือไม่"),
      actions: [
        Button(
          padding: EdgeInsets.symmetric(vertical: 8),
          color: kRed,
          width: 120,
          onTap: () {
            Navigator.pop(context, true);
          },
          child: Text(
            "ใช่",
            style: TextStyle(
              fontSize: 18,
              color: Colors.white,
            ),
          ),
        ),
        Button(
          padding: EdgeInsets.symmetric(vertical: 8),
          color: Colors.grey[400],
          width: 120,
          onTap: () {
            Navigator.pop(context, false);
          },
          child: Text(
            "ยกเลิก",
            style: TextStyle(
              fontSize: 18,
            ),
          ),
        ),
      ],
    );

    if (!resultConfirm) return null;

    String cancelResonInput = "";
    final reasonConfirm = await Modal().show(
      context,
      width: size.width,
      height: 450,
      title: "ยกเลิกการจอง",
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("ท่านต้องการยกเลิกเพราะเหตุใด"),
          SizedBox(height: 12),
          RadioGroup(
            selectedValue: "ไม่สะดวกหรือไม่ว่างกะทันหัน",
            onChange: (v) {
              cancelReason = v;
            },
            options: [
              RadioOption(
                label: "ไม่สะดวกหรือไม่ว่างกะทันหัน",
                value: "ไม่สะดวกหรือไม่ว่างกะทันหัน",
              ),
              RadioOption(
                label: "จองผิดเวลา",
                value: "จองผิดเวลา",
              ),
              // RadioOption(
              //   label: "อื่นๆโปรดระบุ",
              //   value: "อื่นๆโปรดระบุ",
              // ),
            ],
          ),
          SizedBox(height: 12),
          // Input(
          //   onChange: (v) {
          //     cancelResonInput = v;
          //   },
          //   backgroundColor: Colors.white,
          //   keyboardType: TextInputType.multiline,
          //   minLines: 3,
          //   maxLines: 3,
          // ),
        ],
      ),
      actionMainAxisAlignment: MainAxisAlignment.center,
      actions: [
        Button(
          padding: EdgeInsets.symmetric(vertical: 8),
          color: kRed,
          width: 120,
          onTap: () {
            Navigator.pop(context, true);
          },
          child: Text(
            "ยืนยัน",
            style: TextStyle(
              fontSize: 18,
              color: Colors.white,
            ),
          ),
        ),
      ],
    );

    if (!reasonConfirm) return null;

    await OrderAPI.cancelOrder(user, order, cancelReason);

    await order.update();
    await Modal().show(
      context,
      title: "ยกเลิกการจอง",
      height: 250,
      body: Text(
        "เราได้รับคำขอยกเลิกจากท่านแล้ว",
      ),
      duration: Duration(seconds: 3),
      actionMainAxisAlignment: MainAxisAlignment.center,
      actions: [
        Button(
          padding: EdgeInsets.symmetric(vertical: 8),
          color: kRed,
          width: 120,
          onTap: () {
            Navigator.pop(context, true);
          },
          child: Text(
            "ยืนยัน",
            style: TextStyle(
              fontSize: 18,
              color: Colors.white,
            ),
          ),
        ),
      ],
    );

    return cancelReason;
  }
}
