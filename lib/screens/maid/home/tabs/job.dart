import 'package:cleaning_service/api/order.dart';
import 'package:cleaning_service/constants/colors.dart';
import 'package:cleaning_service/constants/room.dart';
import 'package:cleaning_service/models/order.dart';
import 'package:cleaning_service/models/user.dart';
import 'package:cleaning_service/screens/user/shared/status.dart';
import 'package:cleaning_service/shared/button.dart';
import 'package:cleaning_service/store/user.dart';
import 'package:cleaning_service/utils/calculate_cleaing_cost.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';

class MaidJobScreen extends StatefulWidget {
  const MaidJobScreen({Key? key}) : super(key: key);

  @override
  State<MaidJobScreen> createState() => _MaidJobScreenState();
}

class _MaidJobScreenState extends State<MaidJobScreen> {
  UserModel userState = UserModel();
  bool loading = true;
  bool hasCurrentJob = false;

  @override
  void initState() {
    WidgetsBinding.instance?.addPostFrameCallback((_) async {
      userState = context.read<UserState>().user;

      final order = await OrderAPI.maid(userState).findCurrentJob();

      setState(() {
        hasCurrentJob = order != null;
        loading = false;
      });
    });
    super.initState();
  }

  int idx = 0;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    if (hasCurrentJob) return StatusTabScreen();

    return Scaffold(
      body: loading
          ? Center(child: CircularProgressIndicator())
          : SafeArea(
              child: SingleChildScrollView(
                child: StreamBuilder<QuerySnapshot<OrderModel>>(
                  stream: OrderAPI.maid(userState).findJobStream(),
                  builder: (BuildContext context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    }
                    final _jobs =
                        snapshot.data!.docs.map((e) => e.data()).toList();

                    if (snapshot.data!.docs.isEmpty || _jobs.length <= idx) {
                      return Container(
                        height: size.height,
                        child: Center(
                          child: Text(
                            "ไม่มีผู้ใช้เรียกใช้บริการขณะนี้",
                            style: TextStyle(fontSize: 24),
                          ),
                        ),
                      );
                    }

                    return JobCard(
                      order: _jobs[idx],
                      onCancel: () {
                        setState(() {
                          idx++;
                        });
                      },
                      onSubmit: (_) async {
                        final res =
                            await OrderAPI.maid(userState).findCurrentJob();
                        setState(() {
                          hasCurrentJob = res != null;
                        });
                      },
                    );
                  },
                ),
              ),
            ),
    );
  }
}

class JobCard extends StatefulWidget {
  final OrderModel order;
  final void Function() onCancel;
  final void Function(OrderModel order) onSubmit;
  JobCard({
    Key? key,
    required this.order,
    required this.onCancel,
    required this.onSubmit,
  }) : super(key: key);

  @override
  State<JobCard> createState() => _JobCardState();
}

class _JobCardState extends State<JobCard> {
  @override
  Widget build(BuildContext context) {
    final cost = CalculateCleaningCost(roomType: widget.order.roomType!);

    return FutureBuilder<UserModel?>(
        future: UserModel.findById(widget.order.userId!),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          final _user = snapshot.data;

          return Padding(
            padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      children: [
                        Text(
                          "THB",
                          style: TextStyle(
                            fontSize: 24,
                          ),
                        ),
                        Text(
                          "${cost.getTotalCost()}",
                          style: TextStyle(
                            fontSize: 24,
                            color: kPurple,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    InkWell(
                      onTap: () {
                        widget.onCancel();
                      },
                      borderRadius: BorderRadius.circular(99),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Icon(Icons.close),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 24),
                Text(
                  "ชำระผ่าน เงินสด",
                  style: TextStyle(
                    fontSize: 20,
                  ),
                ),
                SizedBox(height: 24),
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: kLightBlue,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Cleanning Service",
                        style: TextStyle(
                          fontSize: 20,
                          color: kGreen,
                        ),
                      ),
                      ListTile(
                        leading: FaIcon(
                          FontAwesomeIcons.solidUser,
                          color: Colors.black,
                        ),
                        title: Text("${_user?.name}"),
                      ),
                      ListTile(
                        leading: FaIcon(
                          FontAwesomeIcons.phone,
                          color: Colors.black,
                        ),
                        title: Text("${_user?.phoneNumber}"),
                      ),
                      ListTile(
                        leading: FaIcon(
                          FontAwesomeIcons.mapMarked,
                          color: Colors.black,
                        ),
                        title: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                                "${_user?.userInfo?.address?.toAddressText()}"),
                            Text(
                                "${Room.getType(widget.order.roomType!)['value']}"),
                          ],
                        ),
                      ),
                      ListTile(
                        leading: FaIcon(
                          FontAwesomeIcons.clock,
                          color: Colors.black,
                        ),
                        title: Text("${widget.order.startTime}"),
                      ),
                      ListTile(
                        leading: FaIcon(
                          FontAwesomeIcons.ring,
                          color: Colors.black,
                        ),
                        title: Text("${widget.order.petRemark}"),
                      ),
                      SizedBox(height: 24),
                      Text(
                        "หมายเหตุ - พื้นที่ที่อยาก ให้เน้นเป็นพิเศษ",
                        style: TextStyle(
                          fontSize: 18,
                        ),
                      ),
                      SizedBox(height: 12),
                      Padding(
                        padding: const EdgeInsets.only(left: 12.0),
                        child: Text(
                          "${widget.order.cleaningRemark}",
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.red,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 36),
                Button(
                  onTap: () async {
                    final userState = context.read<UserState>().user;
                    await OrderAPI.maid(userState).accepetedJob(widget.order);
                    widget.onSubmit(widget.order);
                  },
                  padding: EdgeInsets.symmetric(vertical: 12),
                  color: kGreen,
                  child: Text(
                    "รับงาน",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                    ),
                  ),
                )
              ],
            ),
          );
        });
  }
}
