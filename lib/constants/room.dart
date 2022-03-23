class Room {
  static final List<Map<String, dynamic>> types = [
    {
      "key": "room_small",
      "value": "หอพัก 1 ห้องนอน(ไม่เกิน 30 ตร.ม.)",
      "price": 30,
    },
    {
      "key": "room_medium",
      "value": "หอพัก 1 ห้องนอน(30 - 50 ตร.ม.)",
      "price": 50,
    },
    {
      "key": "room_large",
      "value": "หอพัก 1 ห้องนอน(55 ตร.ม.)",
      "price": 89,
    },
  ];

  static getType(String key) {
    return types.firstWhere((element) => element["key"] == key);
  }
}
