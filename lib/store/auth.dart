import 'package:flutter/material.dart';

class AuthState extends ChangeNotifier {
  String? _id;
  String? _avatar;
  String? _email;
  String _role = "user";

  get id => _id;
  get avatar => _avatar;
  get role => _role;
  get email => _email;

  setLoginData({required String id, required String avatar, required email}) {
    this._id = id;
    this._avatar = avatar;
    this._email = email;
    ChangeNotifier();
  }

  setUserRole(String type) {
    this._role = type;
  }
}
