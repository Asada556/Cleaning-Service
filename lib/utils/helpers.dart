import 'package:cleaning_service/models/user.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Helpers {
  static double toFixed(double d, int p) {
    final String str = d.toStringAsFixed(p);
    return double.parse(str);
  }

  static String prefixZero(int num) {
    return num < 10 ? "0$num" : "$num";
  }

  static String dateTimeFormat(DateTime date) {
    return "${prefixZero(date.hour)}:${prefixZero(date.minute)} น. ${prefixZero(date.day)}/${prefixZero(date.month)}/${date.year + 543}";
  }

  static DateTime toDate(dynamic date) {
    DateTime _date;
    switch (date.runtimeType) {
      case Timestamp:
        _date = (date as Timestamp).toDate();
        break;
      case String:
        _date = DateTime.parse(date);
        break;
      default:
        _date = date as DateTime;
    }
    return _date;
  }

  static UserModel getChatUser(UserModel currentUser, List<UserModel> users,
      [String type = "me"]) {
    final me = users.firstWhere((e) => e.id == currentUser.id);
    final friend = users.firstWhere((e) => e.id != currentUser.id);

    if (type == "me") {
      return me;
    } else {
      return friend;
    }
  }

  static List<T> toList<T>(List<dynamic>? list) {
    if (list == null) return [];
    final List<T> newList = [];
    for (var l in list) {
      newList.add(l);
    }
    return newList;
  }

  static bool allStringRegExp(String? text) {
    final isNumber = RegExp(r'[0-9]').hasMatch(text ?? "");
    final isSymbol =
        RegExp(r'''[%&/\\*\(\)\#\$\@\!\^\.\,\+\=\_\-\?\<\>\[\]\{\}\"\']''')
            .hasMatch(text ?? "");
    return !isNumber && !isSymbol;
  }
  static bool addressRegExp(String? text) {
    
    final isSymbol =
        RegExp(r'''[%&\*\#\$\@\!\^\+\=\_\-\?\<\>\[\]\{\}\"\']''')
            .hasMatch(text ?? "");
    return  !isSymbol;
  }

  static bool allNumberRegExp(String? text) {
    final isNumber = RegExp(r'^[0-9]').hasMatch(text ?? "");
    return isNumber;
  }

  static bool phoneNumberRegExp(String? text) {
    final isNumber = allNumberRegExp(text);
    return isNumber && text?.length == 10;
  }

  static bool alphanumericRegExp(String? text) {
    final alphanumeric = RegExp(r'^[a-zA-Z0-9]');
    return alphanumeric.hasMatch(text ?? "");
  }
  
}