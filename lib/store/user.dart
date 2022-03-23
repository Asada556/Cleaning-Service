import 'package:cleaning_service/models/user.dart';
import 'package:flutter/material.dart';

class UserState extends ChangeNotifier {
  UserModel _user = UserModel();

  UserModel get user => _user;

  setUser(UserModel user) {
    this._user = user;
  }
}
