import 'package:cleaning_service/constants/room.dart';
import 'package:cleaning_service/utils/helpers.dart';

class CalculateCleaningCost {
  final double vatPercentage = 7.0;
  final String roomType;

  CalculateCleaningCost({
    required this.roomType,
  });

  double getRoomTypeCost() {
    return Room.getType(roomType)["price"]! as double;
  }

  double getCleaningCost() {
    return 300.0;
  }

  double getEquipmentCost() {
    return 50.0;
  }

  getSubTotal() {
    return this.getEquipmentCost() +
        this.getCleaningCost() +
        this.getRoomTypeCost();
  }

  getVat() {
    return Helpers.toFixed(this.getSubTotal() * (this.vatPercentage / 100), 2);
  }

  getTotalCost() {
    return this.getSubTotal() + this.getVat();
  }
}
