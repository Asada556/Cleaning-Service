import 'package:cleaning_service/utils/helpers.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  late String? id;
  late String? name;
  late String? avatar;
  late String? email;
  late String? phoneNumber;
  late String? gender;
  late String? role;
  late MaidInfo? maidInfo;
  late UserInfo? userInfo;
  late DateTime? createdAt;
  late DateTime? updatedAt;

  static final userCollection = FirebaseFirestore.instance.collection("users");

  UserModel({
    this.id,
    this.name,
    this.avatar,
    this.role,
    this.email,
    this.gender,
    this.phoneNumber,
    this.maidInfo,
    this.userInfo,
    this.createdAt,
    this.updatedAt,
  });

  factory UserModel.fromJSON(dynamic json) {
    return UserModel(
      id: json["id"],
      name: json["name"],
      avatar: json["avatar"],
      role: json["role"],
      email: json["email"],
      gender: json["gender"],
      phoneNumber: json["phoneNumber"],
      maidInfo: MaidInfo.fromJSON(json["maidInfo"]),
      userInfo: UserInfo.fromJSON(json["userInfo"]),
      createdAt: Helpers.toDate(json["createdAt"]),
      updatedAt: Helpers.toDate(json["updatedAt"]),
    );
  }

  static Future<UserModel?> findById(String id) async {
    final res = await userCollection.doc(id).get();
    if (!res.exists) return null;
    return UserModel.fromJSON(res.data());
  }

  Future<UserModel> create() async {
    this.createdAt = DateTime.now();
    this.updatedAt = DateTime.now();
    await userCollection.doc(id).set(this.toJSON());

    return UserModel.fromJSON(this.toJSON());
  }

  update() async {
    this.updatedAt = DateTime.now();
    await userCollection.doc(id).set(this.toJSON());
    return this;
  }

  delete() {}

  toJSON() {
    return {
      "id": this.id,
      "name": this.name,
      "avatar": this.avatar,
      "role": this.role,
      "email": this.email,
      "phoneNumber": this.phoneNumber,
      "gender": this.gender,
      "maidInfo": this.maidInfo?.toJSON(),
      "userInfo": this.userInfo?.toJSON(),
      "createdAt": this.createdAt.toString(),
      "updatedAt": this.updatedAt.toString(),
    };
  }
}

class UserInfo {
  late UserAddress? address;

  UserInfo({
    this.address,
  });

  factory UserInfo.fromJSON(dynamic json) {
    if (json == null) return UserInfo();
    return UserInfo(
      address: UserAddress.fromJSON(json["address"]),
    );
  }

  toJSON() {
    return {
      "address": this.address?.toJSON(),
    };
  }
}

class UserAddress {
  late String? dormitoryName;
  late String? dormitoryNumber;
  late String? dormitoryFloor;
  late String? dormitoryBuilding;

  UserAddress({
    this.dormitoryName,
    this.dormitoryNumber,
    this.dormitoryBuilding,
    this.dormitoryFloor,
  });

  factory UserAddress.fromJSON(dynamic json) {
    if (json == null) return UserAddress();
    return UserAddress(
      dormitoryName: json["dormitoryName"],
      dormitoryNumber: json["dormitoryNumber"],
      dormitoryBuilding: json["dormitoryBuilding"],
      dormitoryFloor: json["dormitoryFloor"],
    );
  }

  toAddressText() {
    return "$dormitoryName, ห้อง $dormitoryNumber, ชั้น $dormitoryFloor, ตึก $dormitoryBuilding";
  }

  toJSON() {
    return {
      "dormitoryName": this.dormitoryName,
      "dormitoryNumber": this.dormitoryNumber,
      "dormitoryBuilding": this.dormitoryBuilding,
      "dormitoryFloor": this.dormitoryFloor,
    };
  }
}

class MaidInfo {
  late String? address;
  late String? highestQualification;
  late String? jobType;
  late String? fronIdCardImage;
  late String? backIdCardImage;

  MaidInfo({
    this.address,
    this.backIdCardImage,
    this.fronIdCardImage,
    this.highestQualification,
    this.jobType,
  });

  factory MaidInfo.fromJSON(dynamic json) {
    if (json == null) return MaidInfo();
    return MaidInfo(
      address: json["address"],
      highestQualification: json["highestQualification"],
      jobType: json["jobType"],
      fronIdCardImage: json["fronIdCardImage"],
      backIdCardImage: json["backIdCardImage"],
    );
  }

  toJSON() {
    return {
      "address": this.address,
      "highestQualification": this.highestQualification,
      "jobType": this.jobType,
      "fronIdCardImage": this.fronIdCardImage,
      "backIdCardImage": this.backIdCardImage,
    };
  }
}
