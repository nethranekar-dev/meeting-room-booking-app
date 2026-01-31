class Booking {
  final String id;
  final String room;
  final String name;
  final DateTime time;

  Booking({
    required this.id,
    required this.room,
    required this.name,
    required this.time,
  });

  factory Booking.fromMap(String id, Map<String, dynamic> data) {
    return Booking(
      id: id,
      room: data['room'],
      name: data['name'],
      time: data['time'].toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {'room': room, 'name': name, 'time': time};
  }
}
