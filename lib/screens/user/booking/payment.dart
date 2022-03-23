import 'package:cleaning_service/constants/colors.dart';
import 'package:cleaning_service/constants/room.dart';
import 'package:cleaning_service/models/order.dart';
import 'package:cleaning_service/screens/user/booking/booking.dart';
import 'package:cleaning_service/screens/user/booking/success.dart';
import 'package:cleaning_service/shared/button.dart';
import 'package:cleaning_service/store/order.dart';
import 'package:cleaning_service/utils/calculate_cleaing_cost.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class BookingPaymentScreen extends StatefulWidget {
  const BookingPaymentScreen({Key? key}) : super(key: key);

  @override
  _BookingPaymentScreenState createState() => _BookingPaymentScreenState();
}

class _BookingPaymentScreenState extends State<BookingPaymentScreen> {
  String selectedPayment = "cash";
  OrderModel orderState = OrderModel();
  late CalculateCleaningCost? cost;
  bool loading = true;

  @override
  void initState() {
    WidgetsBinding.instance?.addPostFrameCallback((_) {
      setState(() {
        orderState = context.read<OrderState>().order;
        cost = CalculateCleaningCost(roomType: orderState.roomType!);
        loading = false;
      });
    });
    super.initState();
  }

  handleSubmit() async {
    await OrderModel(
      id: uuid.v4(),
      userId: orderState.userId,
      roomType: orderState.roomType,
      cleaningCost: orderState.cleaningCost,
      cleaningEquipmentCost: orderState.cleaningEquipmentCost,
      cleaningRemark: orderState.cleaningRemark,
      petRemark: orderState.petRemark,
      vatPercentage: orderState.vatPercentage,
      cleaningRoomTypeCost: orderState.cleaningRoomTypeCost,
      startTime: orderState.startTime,
      status: "pending",
      paymentMethod: selectedPayment,
    ).create();

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BookingSuccessScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "ข้อมูลการจองบริการ",
          style: TextStyle(
            color: Colors.black,
          ),
        ),
        backgroundColor: Colors.white,
        iconTheme: IconThemeData(color: Colors.black),
        elevation: 0,
        centerTitle: false,
      ),
      backgroundColor: Colors.white,
      body: loading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("ค่าทำความสะอาด"),
                        Text("${orderState.cleaningCost}"),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("ค่าอุปกรณ์ทำความสะอาด"),
                        Text("${orderState.cleaningEquipmentCost}"),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                            "ค่า ${Room.getType(orderState.roomType!)['value']}"),
                        Text("${orderState.cleaningRoomTypeCost} บาท"),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("ภาษีมูลค่าเพื่ม ${orderState.vatPercentage} %"),
                        Text("${cost?.getVat()} บาท"),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("รวมทั้งสิ้น"),
                        Text("${cost?.getTotalCost()} บาท"),
                      ],
                    ),
                    SizedBox(height: 32),
                    Text(
                      "หมายเหตุ *",
                      style: TextStyle(color: Colors.red),
                    ),
                    Text(
                        "ราคานี้รวม ค่าอุปกรณ์และน้ำยาทำความสะอาด ค่าเดินทางและประกันความเสียหายที่เกิดขึ้นระหว่าง ทำความสะอาดในวงเงินไม่เกิน 10000 บาท"),
                    SizedBox(height: 32),
                    Text(
                      "เลือกวิธีการชำระเงิน",
                      style: TextStyle(fontSize: 18),
                    ),
                    SizedBox(height: 12),
                    Button(
                      color: kLightBlue,
                      child: ListTile(
                        title: Text("ชำระเงินด้วยเงินสด"),
                        trailing: Radio(
                          value: "cash",
                          groupValue: selectedPayment,
                          onChanged: (value) {},
                        ),
                      ),
                    ),
                    SizedBox(height: 12),
                    Button(
                      color: Colors.grey[300],
                      child: ListTile(
                        title: Text(
                          "ชำระเงินผ่าน Mobile Banking",
                          style: TextStyle(
                            color: Colors.grey[500],
                          ),
                        ),
                        trailing: Radio(
                          value: "mobile_banking",
                          groupValue: selectedPayment,
                          onChanged: (value) {},
                        ),
                      ),
                    ),
                    SizedBox(height: 12),
                    Button(
                      color: Colors.grey[300],
                      child: ListTile(
                        title: Text(
                          "ชำระเงินผ่านทรูมันนี่วอลเล็ตต์",
                          style: TextStyle(
                            color: Colors.grey[500],
                          ),
                        ),
                        trailing: Radio(
                          value: "true_money_wallet",
                          groupValue: selectedPayment,
                          onChanged: (value) {},
                        ),
                      ),
                    ),
                    SizedBox(height: 32),
                    Center(
                      child: Button(
                        onTap: handleSubmit,
                        child: Text(
                          "ยืนยัน",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                          ),
                        ),
                        width: 150,
                        color: kGreen,
                        padding: EdgeInsets.symmetric(
                          vertical: 8,
                        ),
                      ),
                    ),
                    SizedBox(height: 24),
                  ],
                ),
              ),
            ),
    );
  }
}
