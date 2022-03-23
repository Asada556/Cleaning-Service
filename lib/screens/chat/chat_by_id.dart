import 'package:cleaning_service/api/notification.dart';
import 'package:cleaning_service/constants/colors.dart';
import 'package:cleaning_service/constants/enums.dart';
import 'package:cleaning_service/models/notification.dart';
import 'package:cleaning_service/models/order.dart';
import 'package:cleaning_service/models/user.dart';
import 'package:cleaning_service/screens/user/booking/booking.dart';
import 'package:cleaning_service/screens/user/shared/status.dart';
import 'package:cleaning_service/shared/Input.dart';
import 'package:cleaning_service/shared/button.dart';
import 'package:cleaning_service/shared/modal.dart';
import 'package:cleaning_service/store/user.dart';
import 'package:cleaning_service/utils/helpers.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ChatByIdScreen extends StatefulWidget {
  final String id;
  const ChatByIdScreen({
    Key? key,
    required this.id,
  }) : super(key: key);

  @override
  _ChatByIdScreenState createState() => _ChatByIdScreenState();
}

class _ChatByIdScreenState extends State<ChatByIdScreen> {
  UserModel userState = UserModel();
  OrderModel order = OrderModel();
  bool loading = true;
  NotificationModel notification = NotificationModel();
  List<UserModel> users = [];
  final messageTextController = TextEditingController();
  ScrollController _scrollController = new ScrollController();

  @override
  void initState() {
    WidgetsBinding.instance?.addPostFrameCallback((timeStamp) async {
      userState = context.read<UserState>().user;
      notification = (await NotificationModel.findById(widget.id))!;

      OrderModel.orderCollection
          .doc(notification.orderId)
          .snapshots()
          .listen((event) async {
        final _users = await Future.wait([
          UserModel.findById(notification.userIds![0]),
          UserModel.findById(notification.userIds![1]),
        ]);

        users.add(_users[0]!);
        users.add(_users[1]!);

        setState(() {
          loading = false;
          order = OrderModel.fromJSON(event.data());
        });
      });
    });
    super.initState();
  }

  bool canSendMessage() {
    return order.status != OrderStatus.done.name &&
        order.status != OrderStatus.canceled.name;
  }

  UserModel getChatFriend() {
    return Helpers.getChatUser(userState, users, "friend");
  }

  isMe(String uid) {
    return uid == userState.id;
  }

  getMessageType(MessageModel message) {
    String img;

    final _isMe = isMe(message.uid!);

    if (_isMe) {
      img = userState.avatar!;
    } else {
      img = getChatFriend().avatar!;
    }

    switch (message.type) {
      case "accepted":
        return AcceptedMessageCard(
          image: Image.network(
            img,
            width: 64,
            height: 64,
            fit: BoxFit.cover,
          ),
          isMe: _isMe,
          order: this.order,
        );
      case "text":
        return TextMessageCard(
          image: Image.network(
            img,
            width: 64,
            height: 64,
            fit: BoxFit.cover,
          ),
          isMe: _isMe,
          text: message.text!,
        );
      case "done":
        if (order.status != "done") {
          return SizedBox();
        }
        return DoneMessageCard(
          image: Image.network(
            img,
            width: 64,
            height: 64,
            fit: BoxFit.cover,
          ),
          images: order.proofImages!.map((e) => Image.network(e)).toList(),
          isMe: _isMe,
        );
      case "canceled":
        if (order.status != "canceled") {
          return SizedBox();
        }
        return CancelMessageCard(
          image: Image.network(
            img,
            width: 64,
            height: 64,
            fit: BoxFit.cover,
          ),
          reason: order.cancelReason!,
          isMe: _isMe,
          date: order.canceledAt!,
        );
      default:
        return Text(
            "unexpected message type; got type:${message.type}, id: ${message.id}");
    }
  }

  handleSendMessage() async {
    final newMessage = MessageModel(
      id: uuid.v4(),
      notificationId: notification.id,
      uid: userState.id,
      type: "text",
      text: messageTextController.text,
    );

    await NotificationAPI(user: userState).message().sendMessage(newMessage);

    messageTextController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return loading
        ? Center(child: CircularProgressIndicator())
        : Scaffold(
            appBar: AppBar(
              title: Text(
                "${getChatFriend().name}",
                style: TextStyle(
                  color: Colors.black,
                ),
              ),
              backgroundColor: Colors.white,
              elevation: 0,
              centerTitle: false,
              iconTheme: IconThemeData(color: Colors.black),
              actions: [
                InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => StatusTabScreen(
                          backButton: true,
                          orderId: order.id,
                        ),
                      ),
                    );
                  },
                  child: Icon(Icons.info),
                ),
                SizedBox(width: 24),
              ],
            ),
            body: Padding(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
              child: StreamBuilder<QuerySnapshot<MessageModel>>(
                stream: NotificationAPI(user: userState)
                    .message()
                    .findMessagesByNotifictionIdStream(widget.id),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }
                  if (!snapshot.hasData) return SizedBox();

                  final List<MessageModel> _messages = [];
                  snapshot.data?.docs.forEach((e) {
                    _messages.add(e.data());
                  });

                  return ListView(
                    controller: _scrollController,
                    reverse: true,
                    children: [
                      canSendMessage()
                          ? SizedBox()
                          : Padding(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 36, horizontal: 48),
                              child: Image.asset(
                                "assets/icons/brush.png",
                              ),
                            ),
                      for (var m in _messages) getMessageType(m),
                    ],
                  );
                },
              ),
            ),
            bottomNavigationBar: canSendMessage()
                ? Padding(
                    padding: const EdgeInsets.only(bottom: 24),
                    child: Container(
                        padding:
                            EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        child: Input(
                          controller: messageTextController,
                          hintText: "พิมพ์ข้อความ ...",
                          suffixIcon: InkWell(
                            borderRadius: BorderRadius.circular(99),
                            child: Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Image.asset(
                                "assets/icons/send.png",
                                width: 32,
                                height: 32,
                              ),
                            ),
                            onTap: handleSendMessage,
                          ),
                        )),
                  )
                : SizedBox(),
          );
  }
}

class AcceptedMessageCard extends StatelessWidget {
  final Image image;
  final bool isMe;
  final OrderModel order;
  const AcceptedMessageCard({
    Key? key,
    required this.image,
    required this.isMe,
    required this.order,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          isMe
              ? SizedBox(width: 36)
              : Padding(
                  padding: const EdgeInsets.only(right: 12.0),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(99),
                    child: image,
                  ),
                ),
          Flexible(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: kLightBlue,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [
                  Text(
                    "การจองบริการได้ยืนยันแล้ว",
                    style: TextStyle(
                      fontSize: 18,
                    ),
                  ),
                  SizedBox(height: 12),
                  Button(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => StatusTabScreen(
                            backButton: true,
                            orderId: order.id,
                          ),
                        ),
                      );
                    },
                    padding: EdgeInsets.symmetric(vertical: 8),
                    color: kGreen,
                    child: Text(
                      "ดูข้อมูลการจอง",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          isMe
              ? Padding(
                  padding: const EdgeInsets.only(left: 12),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(99),
                    child: image,
                  ),
                )
              : SizedBox(width: 36),
        ],
      ),
    );
  }
}

class TextMessageCard extends StatelessWidget {
  final Image image;
  final String text;
  final bool isMe;
  const TextMessageCard({
    Key? key,
    required this.image,
    required this.isMe,
    required this.text,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment:
            isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          isMe
              ? SizedBox(width: 36)
              : Padding(
                  padding: const EdgeInsets.only(right: 12.0),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(99),
                    child: image,
                  ),
                ),
          Flexible(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: kLightBlue,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                text,
                style: TextStyle(
                  fontSize: 18,
                ),
              ),
            ),
          ),
          isMe
              ? Padding(
                  padding: const EdgeInsets.only(left: 12),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(99),
                    child: image,
                  ),
                )
              : SizedBox(width: 36),
        ],
      ),
    );
  }
}

class CancelMessageCard extends StatelessWidget {
  final Image image;
  final String reason;
  final bool isMe;
  final DateTime date;

  const CancelMessageCard({
    Key? key,
    required this.image,
    required this.reason,
    required this.isMe,
    required this.date,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          isMe
              ? SizedBox(width: 36)
              : ClipRRect(
                  borderRadius: BorderRadius.circular(99),
                  child: image,
                ),
          SizedBox(width: 12),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 24),
                  decoration: BoxDecoration(
                    color: kLightBlue,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Image.asset(
                          "assets/icons/cancel.png",
                          width: 150,
                          height: 150,
                        ),
                      ),
                      SizedBox(height: 24),
                      Center(
                        child: Text(
                          "การจองของคุณได้รับการยกเลิกเเล้ว",
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.red,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      SizedBox(height: 12),
                      Text(
                        "เหตุผล *",
                        style: TextStyle(fontSize: 14),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 24),
                        child: Text(
                          reason,
                          style: TextStyle(fontSize: 14),
                        ),
                      ),
                    ],
                  ),
                ),
                Text("ยกเลิกเมื่อเวลา ${Helpers.dateTimeFormat(date)}")
              ],
            ),
          ),
          isMe
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(99),
                  child: image,
                )
              : SizedBox(width: 36),
        ],
      ),
    );
  }
}

class DoneMessageCard extends StatelessWidget {
  final Image image;
  final bool isMe;
  final List<Image> images;

  const DoneMessageCard({
    Key? key,
    required this.image,
    required this.isMe,
    required this.images,
  }) : super(key: key);

  _crossAxisCount() {
    if (images.length < 3) {
      return images.length;
    } else {
      return 3;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          isMe
              ? SizedBox(width: 36)
              : ClipRRect(
                  borderRadius: BorderRadius.circular(99),
                  child: image,
                ),
          SizedBox(width: 12),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 24),
                  decoration: BoxDecoration(
                    color: kLightBlue,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Image.asset(
                          "assets/icons/done.png",
                          width: 150,
                          height: 150,
                        ),
                      ),
                      SizedBox(height: 24),
                      Center(
                        child: Text(
                          "ทำงานเสร็จแล้ว",
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Color.fromRGBO(55, 170, 36, 1),
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      SizedBox(height: 12),
                      images.isEmpty
                          ? SizedBox()
                          : GridView.count(
                              physics: NeverScrollableScrollPhysics(),
                              shrinkWrap: true,
                              crossAxisCount: _crossAxisCount(),
                              mainAxisSpacing: 6,
                              crossAxisSpacing: 6,
                              children: [
                                for (var img in images)
                                  GestureDetector(
                                    onTap: () {
                                      Modal().viewImage(context, image);
                                    },
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(6),
                                      child: img,
                                    ),
                                  ),
                              ],
                            )
                    ],
                  ),
                ),
                Text("เสร็จสิ้นเมื่อเวลา 09:10 น.")
              ],
            ),
          ),
          isMe
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(99),
                  child: image,
                )
              : SizedBox(width: 36),
        ],
      ),
    );
  }
}
