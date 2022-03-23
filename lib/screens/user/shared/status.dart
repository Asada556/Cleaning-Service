import 'package:cleaning_service/api/order.dart';
import 'package:cleaning_service/constants/colors.dart';
import 'package:cleaning_service/constants/enums.dart';
import 'package:cleaning_service/constants/room.dart';
import 'package:cleaning_service/models/order.dart';
import 'package:cleaning_service/models/user.dart';
import 'package:cleaning_service/screens/maid/home/home.dart';
import 'package:cleaning_service/screens/maid/job_done.dart';
import 'package:cleaning_service/screens/user/home/home.dart';
import 'package:cleaning_service/shared/Input.dart';
import 'package:cleaning_service/shared/button.dart';
import 'package:cleaning_service/shared/modal.dart';
import 'package:cleaning_service/shared/radio_group.dart';
import 'package:cleaning_service/store/user.dart';
import 'package:cleaning_service/utils/calculate_cleaing_cost.dart';
import 'package:cleaning_service/utils/cancel_order.dart';
import 'package:cleaning_service/utils/helpers.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class StatusTabScreen extends StatefulWidget {
  final bool backButton;
  final String? orderId;
  const StatusTabScreen({
    this.backButton = false,
    this.orderId,
    Key? key,
  }) : super(key: key);

  @override
  State<StatusTabScreen> createState() => _StatusTabScreenState();
}

class _StatusTabScreenState extends State<StatusTabScreen> {
  bool loading = true;
  OrderModel? order;
  UserModel userState = UserModel();
  String cancelReason = "";

  @override
  void initState() {
    WidgetsBinding.instance?.addPostFrameCallback((_) async {
      setState(() {
        userState = context.read<UserState>().user;
        loading = false;
      });
    });
    super.initState();
  }

  isEmpty() {
    return order == null;
  }

  canAction() {
    return order!.status == OrderStatus.pending.name ||
        order!.status == OrderStatus.accepted.name;
  }

  handleCancel(BuildContext context) async {
    await CancelOrder(context).show(user: userState, order: order!);

    if (userState.role == "user") {
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
  }

  bool isMaid() {
    return userState.role == "maid";
  }

  orderStream() {
    if (widget.orderId != null) {
      return OrderModel.orderCollection
          .where("id", isEqualTo: widget.orderId)
          .withConverter(
              fromFirestore: (s, _) => OrderModel.fromJSON(s.data()),
              toFirestore: (OrderModel d, _) => d.toJSON())
          .snapshots();
    }
    if (userState.role == "maid") {
      return OrderAPI.maid(userState).getCurrentOrderStream();
    } else {
      return OrderAPI.user(userState).getCurrentOrderStream();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (loading) return Center(child: CircularProgressIndicator());
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
        automaticallyImplyLeading: widget.backButton,
        elevation: 0,
        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot<OrderModel>>(
          stream: orderStream(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            }

            if (snapshot.data!.docs.isEmpty) {
              return Scaffold(
                body: Center(
                  child: Text(
                    "ไม่มีข้อมูลจองงานบริการล่าสุด",
                    style: TextStyle(fontSize: 24),
                  ),
                ),
              );
            }

            order = snapshot.data!.docs.first.data();

            return Scaffold(
              body: SafeArea(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 24),
                      MaidSection(
                        order: order!,
                      ),
                      UserSection(
                        order: order!,
                      ),
                      PaymentSection(order: order!),
                      SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
              bottomNavigationBar: canAction()
                  ? isEmpty()
                      ? SizedBox()
                      : Padding(
                          padding: const EdgeInsets.only(bottom: 24.0),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 24),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                isMaid()
                                    ? Padding(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 12),
                                        child: Button(
                                          padding: EdgeInsets.symmetric(
                                              vertical: 12),
                                          onTap: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    MaidJobDoneScreen(),
                                              ),
                                            );
                                          },
                                          color: kGreen,
                                          child: Text(
                                            "ทำงานเสร็จแล้ว",
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 18,
                                            ),
                                          ),
                                        ),
                                      )
                                    : SizedBox(),
                                Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 12),
                                  child: Button(
                                    padding: EdgeInsets.symmetric(vertical: 12),
                                    onTap: () {
                                      handleCancel(context);
                                    },
                                    color: kRed,
                                    child: Text(
                                      "ต้องการยกเลิกหรือเลื่อนเวลาคลิกที่นี่",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 18,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                  : SizedBox(),
            );
          }),
    );
  }
}

class Section extends StatelessWidget {
  final String titleText;
  final Widget child;

  const Section({
    Key? key,
    required this.titleText,
    required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          color: kLightGrey,
          width: double.infinity,
          padding: EdgeInsets.symmetric(horizontal: 36, vertical: 12),
          child: Text(
            titleText,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 20,
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 24),
          width: double.infinity,
          color: Colors.white,
          child: child,
        ),
      ],
    );
  }
}

class MaidSection extends StatelessWidget {
  final OrderModel order;
  const MaidSection({
    Key? key,
    required this.order,
  }) : super(key: key);

  bool isPending() {
    return order.status == OrderStatus.pending.name;
  }

  Future<UserModel> getMaid() async {
    final res = await UserModel.findById(order.maidId ?? "");
    return res!;
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    if (isPending()) {
      return Column(
        children: [
          Center(
            child: Image.asset(
              "assets/icons/waiting.png",
              width: size.width * 0.8,
              fit: BoxFit.cover,
            ),
          ),
          SizedBox(height: 48),
          Center(
            child: Text(
              "กำลังรอแม่บ้านกดรับการจอง ...",
              style: TextStyle(fontSize: 24),
            ),
          ),
          SizedBox(height: 48),
        ],
      );
    }

    return Section(
      titleText: "ข้อมูลแม่บ้าน",
      child: FutureBuilder<UserModel>(
          future: getMaid(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            }

            final _maid = snapshot.data!;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "ชื่อ-นามสกุล",
                  style: TextStyle(
                    fontSize: 18,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 24),
                  child: Text(
                    "${_maid.name}",
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey[400],
                    ),
                  ),
                ),
                SizedBox(height: 24),
                Text(
                  "หมายเลขเบอร์โทรศัพท์ ",
                  style: TextStyle(
                    fontSize: 18,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 24),
                  child: Text(
                    "${_maid.phoneNumber}",
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey[400],
                    ),
                  ),
                ),
              ],
            );
          }),
    );
  }
}

class UserSection extends StatelessWidget {
  final OrderModel order;
  const UserSection({
    Key? key,
    required this.order,
  }) : super(key: key);
  Future<UserModel> getUser() async {
    final res = await UserModel.findById(order.userId!);
    return res!;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<UserModel>(
      future: getUser(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        if (snapshot.data == null) {
          return Text("Unknow data");
        }

        final _user = snapshot.data!;

        return Section(
          titleText: "ข้อมูลผู้ใช้บริการ",
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "ชื่อ-นามสกุล",
                style: TextStyle(
                  fontSize: 18,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 24),
                child: Text(
                  "${_user.name}",
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.grey[400],
                  ),
                ),
              ),
              SizedBox(height: 24),
              Text(
                "หมายเลขเบอร์โทรศัพท์ ",
                style: TextStyle(
                  fontSize: 18,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 24),
                child: Text(
                  "${_user.phoneNumber}",
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.grey[400],
                  ),
                ),
              ),
              SizedBox(height: 24),
              Text(
                "สถานที่ในการทำความสะอาด",
                style: TextStyle(
                  fontSize: 18,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 24),
                child: Text(
                  _user.userInfo?.address?.toAddressText(),
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.grey[400],
                  ),
                ),
              ),
              SizedBox(height: 24),
              Text(
                "ประเภทที่พัก",
                style: TextStyle(
                  fontSize: 18,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 24),
                child: Text(
                  Room.getType(order.roomType!)["value"],
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.grey[400],
                  ),
                ),
              ),
              SizedBox(height: 24),
              Text(
                "เวลาที่ใช้บริการ",
                style: TextStyle(
                  fontSize: 18,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 24),
                child: Text(
                  "${order.startTime}",
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.grey[400],
                  ),
                ),
              ),
              SizedBox(height: 24),
              Text(
                "ที่พักของคุณมีสัตว์เลี้ยงหรือไม่",
                style: TextStyle(
                  fontSize: 18,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 24),
                child: Text(
                  "${order.petRemark}",
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.grey[400],
                  ),
                ),
              ),
              SizedBox(height: 24),
              Text(
                "หมายเหตุ - พื้นที่ที่อยาก ให้เน้นเป็นพิเศษ",
                style: TextStyle(
                  fontSize: 18,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 24),
                child: Text(
                  "${order.cleaningRemark}",
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.grey[400],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class PaymentSection extends StatelessWidget {
  final OrderModel order;
  PaymentSection({
    Key? key,
    required this.order,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final cost = CalculateCleaningCost(roomType: order.roomType!);

    return Section(
      titleText: "ข้อมูลค่าใช้จ่าย",
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "ค่าทำความสะอาด",
                style: TextStyle(
                  fontSize: 18,
                ),
              ),
              Text(
                "${order.cleaningCost} บาท",
                style: TextStyle(
                  fontSize: 18,
                ),
              ),
            ],
          ),
          SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "ค่าอุปกรณ์ทำความสะอาด",
                style: TextStyle(
                  fontSize: 18,
                ),
              ),
              Text(
                "${order.cleaningEquipmentCost} บาท",
                style: TextStyle(
                  fontSize: 18,
                ),
              ),
            ],
          ),
          SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                Room.getType(order.roomType!)["value"],
                style: TextStyle(
                  fontSize: 18,
                ),
              ),
              Text(
                "${order.cleaningRoomTypeCost} บาท",
                style: TextStyle(
                  fontSize: 18,
                ),
              ),
            ],
          ),
          SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "ภาษีมูลค่าเพิ่ม ${order.vatPercentage} %",
                style: TextStyle(
                  fontSize: 18,
                ),
              ),
              Text(
                "${cost.getVat()} บาท",
                style: TextStyle(
                  fontSize: 18,
                ),
              ),
            ],
          ),
          SizedBox(height: 36),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "รวมทั้งสิ้น",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                "${cost.getTotalCost()} บาท",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: kPurple,
                ),
              ),
            ],
          ),
          SizedBox(height: 24),
          Text(
            "หมายเหตุ *",
            style: TextStyle(
              fontSize: 18,
              color: Colors.red,
            ),
          ),
          SizedBox(height: 12),
          Text(
            "ราคานี้รวม ค่าอุปกรณ์และน้ำยาทำความสะอาด ค่าเดินทางและประกันความเสียหายที่เกิดขึ้นระหว่างทำความสะอาดในวงเงินไม่เกิน 10000 บาท",
            style: TextStyle(
              fontSize: 18,
            ),
          ),
          SizedBox(height: 36),
          Text(
            "เลือกวิธีการชำระเงิน",
            style: TextStyle(
              fontSize: 18,
            ),
          ),
          SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: kLightBlue,
            ),
            child: Text(
              "ชำระเงินด้วยเงินสด",
              style: TextStyle(
                fontSize: 18,
              ),
            ),
          ),
          SizedBox(height: 36),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "จองเมื่อ",
                style: TextStyle(
                  fontSize: 18,
                ),
              ),
              Text(
                Helpers.dateTimeFormat(order.createdAt!),
                style: TextStyle(
                  fontSize: 18,
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "รับรายการเมื่อ",
                style: TextStyle(
                  fontSize: 18,
                ),
              ),
              Text(
                order.acceptedAt != null
                    ? Helpers.dateTimeFormat(order.acceptedAt!)
                    : "-",
                style: TextStyle(
                  fontSize: 18,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
