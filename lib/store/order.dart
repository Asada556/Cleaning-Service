import 'package:cleaning_service/models/order.dart';
import 'package:flutter/material.dart';

class OrderState extends ChangeNotifier {
  OrderModel _order = OrderModel();
  OrderModel get order => _order;

  setOrder(OrderModel order) {
    this._order = order;
  }

  clear() {
    this._order = OrderModel();
  }
}
