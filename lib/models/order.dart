import 'package:cleaning_service/models/user.dart';
import 'package:cleaning_service/utils/helpers.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class OrderModel {
  late String? id;
  late String? userId;
  late String? maidId;
  late String? status;
  late String? roomType;
  late String? startTime;
  late String? petRemark;
  late String? cleaningRemark;
  late double? cleaningCost;
  late double? cleaningEquipmentCost;
  late double? cleaningRoomTypeCost;
  late double? vatPercentage;
  late String? paymentMethod;
  late String? cancelReason;
  late List<String>? proofImages;
  late DateTime? createdAt;
  late DateTime? updatedAt;
  late DateTime? canceledAt;
  late DateTime? acceptedAt;
  late UserModel? userInfo;
  late UserModel? maidInfo;

  static final orderCollection =
      FirebaseFirestore.instance.collection("orders");

  OrderModel({
    this.id,
    this.userId,
    this.userInfo,
    this.maidId,
    this.status,
    this.roomType,
    this.startTime,
    this.petRemark,
    this.cleaningRemark,
    this.cleaningCost,
    this.cleaningEquipmentCost,
    this.cleaningRoomTypeCost,
    this.vatPercentage,
    this.paymentMethod,
    this.cancelReason,
    this.proofImages,
    this.createdAt,
    this.updatedAt,
    this.canceledAt,
    this.acceptedAt,
    this.maidInfo,
  });

  static Future<OrderModel?> findById(String id) async {
    final res = await orderCollection.doc(id).get();

    if (res.exists) {
      return OrderModel.fromJSON(res.data());
    }

    return null;
  }

  Future<OrderModel> create() async {
    this.createdAt = DateTime.now();
    this.updatedAt = DateTime.now();
    await orderCollection.doc(this.id).set(this.toJSON());
    return this;
  }

  Future<OrderModel> update() async {
    this.updatedAt = DateTime.now();
    await orderCollection
        .doc(this.id)
        .set(this.toJSON(), SetOptions(merge: true));
    return this;
  }

  factory OrderModel.fromJSON(dynamic json) {
    if (json == null) return OrderModel();

    return OrderModel(
      id: json["id"],
      userId: json["userId"],
      maidId: json["maidId"],
      status: json["status"],
      roomType: json["roomType"],
      startTime: json["startTime"],
      petRemark: json["petRemark"],
      cleaningRemark: json["cleaningRemark"],
      cleaningCost: json["cleaningCost"],
      cleaningEquipmentCost: json["cleaningEquipmentCost"],
      cleaningRoomTypeCost: json["cleaningRoomTypeCost"],
      vatPercentage: json["vatPercentage"],
      paymentMethod: json["paymentMethod"],
      cancelReason: json["cancelReason"],
      proofImages: Helpers.toList<String>(json["proofImages"]),
      createdAt: Helpers.toDate(json["createdAt"]),
      updatedAt: Helpers.toDate(json["updatedAt"]),
      acceptedAt: json["acceptedAt"] != null
          ? Helpers.toDate(json["acceptedAt"])
          : null,
      canceledAt: json["canceledAt"] != null
          ? Helpers.toDate(json["canceledAt"])
          : null,
    );
  }

  toJSON() {
    return {
      "id": this.id,
      "userId": this.userId,
      "maidId": this.maidId,
      "status": this.status,
      "roomType": this.roomType,
      "startTime": this.startTime,
      "petRemark": this.petRemark,
      "cleaningRemark": this.cleaningRemark,
      "cleaningCost": this.cleaningCost,
      "cleaningEquipmentCost": this.cleaningEquipmentCost,
      "cleaningRoomTypeCost": this.cleaningRoomTypeCost,
      "vatPercentage": this.vatPercentage,
      "paymentMethod": this.paymentMethod,
      "cancelReason": this.cancelReason,
      "proofImages": this.proofImages,
      "createdAt": this.createdAt,
      "updatedAt": this.updatedAt,
      "acceptedAt": this.acceptedAt,
      "canceledAt": this.canceledAt,
    };
  }
}
