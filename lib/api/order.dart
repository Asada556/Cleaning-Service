import 'package:cleaning_service/constants/enums.dart';
import 'package:cleaning_service/models/notification.dart';
import 'package:cleaning_service/models/order.dart';
import 'package:cleaning_service/models/user.dart';
import 'package:cleaning_service/screens/user/booking/booking.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class OrderAPI {
  static MaidOrderAPI maid(UserModel user) {
    return MaidOrderAPI(user: user);
  }

  static UserOrderAPI user(UserModel user) {
    return UserOrderAPI(user: user);
  }

  static Future<void> cancelOrder(
      UserModel user, OrderModel order, String reason) async {
    final prevStatus = order.status;
    order.status = OrderStatus.canceled.name;
    order.canceledAt = DateTime.now();
    order.cancelReason = reason;

    if (prevStatus != OrderStatus.pending.name) {
      final _notification = (await NotificationModel.findByOrderId(order.id!))!;

      final newMessage = MessageModel(
        id: uuid.v4(),
        type: OrderStatus.canceled.name,
        uid: user.id,
        notificationId: _notification.id,
      );

      _notification.currentMessageId = newMessage.id;

      await Future.wait([
        newMessage.create(),
        _notification.update(),
        order.update(),
      ]);
    } else {
      order.update();
    }
  }
}

class MaidOrderAPI {
  final UserModel user;
  MaidOrderAPI({
    required this.user,
  });

  Future<OrderModel> accepetedJob(OrderModel order) async {
    // order
    order.maidId = user.id;
    order.acceptedAt = DateTime.now();
    order.status = OrderStatus.accepted.name;

    // notification
    final _notification = NotificationModel(
      id: uuid.v4(),
      orderId: order.id,
      userIds: [order.userId!, user.id!],
    );
    // message
    final _message = MessageModel(
      id: uuid.v4(),
      notificationId: _notification.id,
      type: OrderStatus.accepted.name,
      uid: user.id,
    );

    _notification.currentMessageId = _message.id;

    // save
    await Future.wait([
      _notification.create(),
      _message.create(),
      order.update(),
    ]);

    return order;
  }

  Future<void> jobDone(OrderModel order) async {
    order.status = OrderStatus.done.name;
    await order.update();

    final _notification = (await NotificationModel.findByOrderId(order.id!))!;

    final newMessage = MessageModel(
      id: uuid.v4(),
      type: OrderStatus.done.name,
      notificationId: _notification.id,
      uid: user.id,
    );

    _notification.currentMessageId = newMessage.id;

    await Future.wait([
      order.update(),
      newMessage.create(),
      _notification.update(),
    ]);
  }

  Stream<QuerySnapshot<OrderModel>> findJobStream() {
    return OrderModel.orderCollection
        .where("status", isEqualTo: OrderStatus.pending.name)
        .withConverter(
          fromFirestore: (s, _) => OrderModel.fromJSON(s.data()),
          toFirestore: (OrderModel d, _) => d.toJSON(),
        )
        .snapshots();
  }

  Future<OrderModel?> findCurrentJob() async {
    final res = await OrderModel.orderCollection
        .where("maidId", isEqualTo: user.id)
        .where("status", isEqualTo: OrderStatus.accepted.name)
        .orderBy("createdAt")
        .limitToLast(1)
        .get();
    if (res.docs.isEmpty) {
      return null;
    }

    return OrderModel.fromJSON(res.docs.first.data());
  }

  Stream<QuerySnapshot<OrderModel>> getCurrentOrderStream() {
    return OrderModel.orderCollection
        .where("maidId", isEqualTo: user.id)
        .where(
          "status",
          isEqualTo: OrderStatus.accepted.name,
        )
        .orderBy("createdAt")
        .limitToLast(1)
        .withConverter(
          fromFirestore: (s, _) => OrderModel.fromJSON(s.data()),
          toFirestore: (OrderModel d, _) => d.toJSON(),
        )
        .snapshots();
  }
}

class UserOrderAPI {
  final UserModel user;
  UserOrderAPI({
    required this.user,
  });

  Stream<QuerySnapshot<OrderModel>> getCurrentOrderStream() {
    return OrderModel.orderCollection
        .where("userId", isEqualTo: user.id)
        .where(
          "status",
          whereIn: [
            OrderStatus.pending.name,
            OrderStatus.accepted.name,
          ],
        )
        .orderBy("createdAt")
        .limitToLast(1)
        .withConverter(
          fromFirestore: (s, _) => OrderModel.fromJSON(s.data()),
          toFirestore: (OrderModel d, _) => d.toJSON(),
        )
        .snapshots();
  }

  Future<OrderModel?> findCurrentOrder() async {
    final res = await OrderModel.orderCollection
        .where("userId", isEqualTo: user.id)
        .where("status", whereIn: ["accepted", "pending"])
        .orderBy("createdAt")
        .limitToLast(1)
        .get();

    if (res.docs.isEmpty) return null;
    return OrderModel.fromJSON(res.docs.first.data());
  }
}
