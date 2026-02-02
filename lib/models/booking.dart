import 'package:cloud_firestore/cloud_firestore.dart';

class Booking {
  final String id;
  final String room;
  final String name;
  final DateTime time;
  final String? userEmail;
  final String? status;

  Booking({
    required this.id,
    required this.room,
    required this.name,
    required this.time,
    this.userEmail,
    this.status,
  });

  factory Booking.fromMap(String id, Map<String, dynamic> data) {
    return Booking(
      id: id,
      room: data['room'] ?? data['roomName'] ?? '',
      name: data['name'] ?? '',
      time: data['time'] != null
          ? (data['time'] as Timestamp).toDate()
          : (data['timestamp'] as Timestamp).toDate(),
      userEmail: data['userEmail'],
      status: data['status'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'room': room,
      'name': name,
      'time': time,
      'userEmail': userEmail,
      'status': status,
    };
  }
}
