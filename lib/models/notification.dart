import 'package:cleaning_service/models/order.dart';
import 'package:cleaning_service/models/user.dart';
import 'package:cleaning_service/screens/user/booking/booking.dart';
import 'package:cleaning_service/utils/helpers.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationModel {
  late String? id;
  late String? orderId;
  late OrderModel? orderInfo;
  late List<MessageModel>? messagesInfo;
  late MessageModel? currentMessage;
  late DateTime? createdAt;
  late DateTime? updatedAt;
  late UserModel? userInfo;
  late UserModel? maidInfo;
  late List<String>? userIds;
  late String? currentMessageId;

  static final notificationCollection =
      FirebaseFirestore.instance.collection("notifications");

  NotificationModel({
    this.id,
    this.orderId,
    this.orderInfo,
    this.createdAt,
    this.updatedAt,
    this.userIds,
    this.currentMessageId,
  });

  static Future<NotificationModel?> findById(String id) async {
    final res = await NotificationModel.notificationCollection.doc(id).get();
    if (!res.exists) {
      return null;
    }
    return NotificationModel.fromJSON(res.data());
  }

  static Future<NotificationModel?> findByOrderId(String id) async {
    final res = await NotificationModel.notificationCollection
        .where("orderId", isEqualTo: id)
        .get();

    if (res.docs.isEmpty) {
      return null;
    }

    return NotificationModel.fromJSON(res.docs.first.data());
  }

  Future<NotificationModel> create() async {
    this.createdAt = DateTime.now();
    this.updatedAt = DateTime.now();
    await notificationCollection.doc(this.id).set(this.toJSON());
    return this;
  }

  Future<NotificationModel> update() async {
    this.updatedAt = DateTime.now();
    await NotificationModel.notificationCollection
        .doc(this.id)
        .set(this.toJSON());

    return this;
  }

  factory NotificationModel.fromJSON(dynamic json) {
    return NotificationModel(
      id: json["id"],
      orderId: json["orderId"],
      userIds: Helpers.toList<String>(json["userIds"]),
      currentMessageId: json["currentMessageId"],
      createdAt: Helpers.toDate(json["createdAt"]),
      updatedAt: Helpers.toDate(json["updatedAt"]),
    );
  }

  toJSON() {
    return {
      "id": this.id,
      "orderId": this.orderId,
      "userIds": this.userIds,
      "currentMessageId": this.currentMessageId,
      "createdAt": this.createdAt.toString(),
      "updatedAt": this.updatedAt.toString(),
    };
  }
}

class MessageModel {
  late String? id;
  late String? notificationId;
  late String? text;
  late String? type;
  late String? uid;
  late DateTime? createdAt;
  late DateTime? updatedAt;
  late UserModel? userInfo;

  static final messageCollection =
      FirebaseFirestore.instance.collection("messages");
  MessageModel({
    this.id,
    this.notificationId,
    this.uid,
    this.text,
    this.type,
    this.createdAt,
    this.updatedAt,
  });

  static Future<List<MessageModel>?> findAllByNotificationId(String id) async {
    final res = await messageCollection
        .where("notificationId", isEqualTo: id)
        .orderBy("createdAt", descending: true)
        .get();
    final messages =
        res.docs.map((e) => MessageModel.fromJSON(e.data())).toList();

    return messages;
  }

  Future<MessageModel> create() async {
    this.createdAt = DateTime.now();
    this.updatedAt = DateTime.now();
    await messageCollection.doc(this.id).set(this.toJSON());
    return this;
  }

  factory MessageModel.fromJSON(dynamic json) {
    return MessageModel(
      id: json["id"],
      notificationId: json["notificationId"],
      type: json["type"],
      text: json["text"],
      uid: json["uid"],
      createdAt: Helpers.toDate(json["createdAt"]),
      updatedAt: Helpers.toDate(json["updatedAt"]),
    );
  }

  toJSON() {
    return {
      "id": this.id,
      "notificationId": this.notificationId,
      "type": this.type,
      "text": this.text,
      "uid": this.uid,
      "createdAt": this.createdAt.toString(),
      "updatedAt": this.updatedAt.toString(),
    };
  }
}
