import 'package:cleaning_service/constants/colors.dart';
import 'package:cleaning_service/models/notification.dart';
import 'package:cleaning_service/models/user.dart';
import 'package:cleaning_service/screens/chat/chat_by_id.dart';
import 'package:cleaning_service/shared/button.dart';
import 'package:cleaning_service/store/user.dart';
import 'package:cleaning_service/utils/helpers.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class NotificationTabScreen extends StatefulWidget {
  const NotificationTabScreen({Key? key}) : super(key: key);

  @override
  State<NotificationTabScreen> createState() => _NotificationTabScreenState();
}

class _NotificationTabScreenState extends State<NotificationTabScreen> {
  UserModel userState = UserModel();
  List<NotificationModel> notifications = [];
  bool loading = true;

  @override
  initState() {
    WidgetsBinding.instance?.addPostFrameCallback((timeStamp) async {
      userState = context.read<UserState>().user;

      setState(() {
        loading = false;
      });
    });
    super.initState();
  }

  @override
  dispose() {
    setState(() {
      notifications = [];
    });
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "แจ้งเตือน",
          style: TextStyle(
            color: Colors.black,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      backgroundColor: Colors.white,
      body: loading
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: StreamBuilder<QuerySnapshot<NotificationModel>>(
                stream: NotificationModel.notificationCollection
                    .where("userIds", arrayContains: userState.id)
                    .withConverter(
                        fromFirestore: (s, _) =>
                            NotificationModel.fromJSON(s.data()),
                        toFirestore: (NotificationModel d, _) => d.toJSON())
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }

                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return SizedBox();
                  }

                  final List<NotificationModel> _notifications = [];

                  snapshot.data!.docs.forEach((e) {
                    _notifications.add(e.data());
                  });
                  _notifications
                      .sort((a, b) => b.updatedAt!.compareTo(a.updatedAt!));

                  return ListView(
                    children: [
                      for (var n in _notifications)
                        ChatType(
                          notification: n,
                          user: userState,
                          messageId: n.currentMessageId!,
                        ),
                    ],
                  );
                },
              )),
    );
  }
}

Map<String, MessageModel> messageCache = {};
Map<String, UserModel> userCache = {};

class ChatType extends StatelessWidget {
  final NotificationModel notification;
  final UserModel user;
  final String messageId;
  ChatType({
    Key? key,
    required this.notification,
    required this.user,
    required this.messageId,
  }) : super(key: key);

  Future<MessageModel> getCurrentMessage() async {
    if (messageCache[messageId] != null) {
      return messageCache[messageId]!;
    }
    final res = await MessageModel.messageCollection.doc(messageId).get();
    final _message = MessageModel.fromJSON(res.data());
    messageCache[messageId] = _message;
    return _message;
  }

  Future<List<UserModel>> getUsers() async {
    final _users = [];
    if (userCache[notification.userIds![0]] != null) {
      _users.add(userCache[notification.userIds![0]]!);
    }

    if (userCache[notification.userIds![1]] != null) {
      _users.add(userCache[notification.userIds![1]]!);
    }

    final res = await Future.wait([
      UserModel.findById(notification.userIds![0]),
      UserModel.findById(notification.userIds![1]),
    ]);

    userCache[res[0]!.id!] = res[0]!;
    userCache[res[1]!.id!] = res[1]!;

    return [
      userCache[res[0]!.id!]!,
      userCache[res[1]!.id!]!,
    ];
  }

  Future<List<Object>> fetchMessageData() async {
    final res = await Future.wait([
      getCurrentMessage(),
      getUsers(),
    ]);

    return res;
  }

  isMe(String uid) {
    return uid == user.id;
  }

  UserModel getChatFriend(List<UserModel> users) {
    return Helpers.getChatUser(user, users, "friend");
  }

  messageCard(MessageModel message, List<UserModel> users) {
    final String msgType = message.type!;
    final _isMe = isMe(message.uid!);
    String text = "";
    Color textColor = Colors.black;
    bool showDot = false;
    final _chat = getChatFriend(users);

    switch (msgType) {
      case "accepted":
        text = "การจองบริการได้ยืนยันแล้ว";
        textColor = kGreen;
        showDot = true;
        break;
      case "text":
        text = message.text!;
        break;
      case "done":
        text = "การจองบริการทำงานเสร็จแล้ว";
        textColor = kGreen;
        showDot = true;
        break;
      case "canceled":
        text = "การจองได้ทำการยกเลิกแล้ว";
        textColor = kRed;
        showDot = true;
        break;
      default:
        text =
            "Unexpected message type; got ${message.type}, id: ${message.id} ";
        textColor = kRed;
        break;
    }

    return ChatCard(
      id: notification.id!,
      image: Image.network(
        "${_chat.avatar}",
        width: 64,
        height: 64,
        fit: BoxFit.cover,
      ),
      name: "${_chat.name}",
      text: "${_isMe ? 'คุณ: ' : ''} $text",
      textColor: textColor,
      showDot: showDot,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (messageCache[messageId] != null) {
      final message = messageCache[messageId]!;
      final users = [
        userCache[notification.userIds![0]]!,
        userCache[notification.userIds![1]]!,
      ];
      return messageCard(
        message,
        users,
      );
    }

    return FutureBuilder<List<Object>>(
      future: fetchMessageData(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        final message = snapshot.data![0] as MessageModel;

        final users = snapshot.data![1] as List<UserModel>;
        return messageCard(
          message,
          users,
        );
      },
    );
  }
}

class ChatCard extends StatelessWidget {
  final String id;
  final Image image;
  final String name;
  final String text;
  final Color? textColor;
  final bool showDot;

  const ChatCard({
    Key? key,
    required this.id,
    required this.image,
    required this.name,
    required this.text,
    this.textColor = Colors.black,
    this.showDot = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Button(
      padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      color: Colors.white,
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChatByIdScreen(id: id),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(99),
              child: image,
            ),
            SizedBox(width: 12),
            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: TextStyle(
                      fontSize: 20,
                    ),
                  ),
                  Container(
                    width: double.infinity,
                    child: Text(
                      text,
                      style: TextStyle(
                        fontSize: 16,
                        color: textColor,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
            showDot
                ? Padding(
                    padding: const EdgeInsets.only(left: 12),
                    child: Icon(
                      Icons.circle,
                      size: 24,
                      color: textColor,
                    ),
                  )
                : SizedBox(),
          ],
        ),
      ),
    );
  }
}
