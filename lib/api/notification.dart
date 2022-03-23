import 'package:cleaning_service/models/notification.dart';
import 'package:cleaning_service/models/user.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationAPI {
  late UserModel user;
  NotificationAPI({required this.user});

  Stream<QuerySnapshot<NotificationModel>> findNotificationsStream() {
    return NotificationModel.notificationCollection
        .where("userIds", arrayContains: user.id)
        // .orderBy("updatedAt", descending: true)
        .withConverter(
            fromFirestore: (s, _) => NotificationModel.fromJSON(s.data()),
            toFirestore: (NotificationModel d, _) => d.toJSON())
        .snapshots();
  }

  MessageAPI message() {
    return MessageAPI(user: user);
  }
}

class MessageAPI {
  late UserModel user;
  MessageAPI({required this.user});

  Stream<QuerySnapshot<MessageModel>> findMessagesByNotifictionIdStream(
      String id) {
    return MessageModel.messageCollection
        .where("notificationId", isEqualTo: id)
        .orderBy("createdAt", descending: true)
        .withConverter(
            fromFirestore: (s, _) => MessageModel.fromJSON(s.data()),
            toFirestore: (MessageModel d, _) => d.toJSON())
        .snapshots();
  }

  Future<void> sendMessage(MessageModel message) async {
    final _message = await message.create();

    await NotificationModel.notificationCollection
        .doc(_message.notificationId)
        .update({
      "currentMessageId": _message.id,
      "updatedAt": DateTime.now(),
    });
  }
}
