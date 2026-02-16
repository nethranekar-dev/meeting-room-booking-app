import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/booking.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Check for time conflicts in a room
  Future<bool> checkTimeConflict(
      String roomId, DateTime startTime, DateTime endTime) async {
    final snapshot = await _db
        .collection("bookings")
        .where("roomId", isEqualTo: roomId)
        .get();

    for (var doc in snapshot.docs) {
      final data = doc.data() as Map<String, dynamic>;
      final existingStart = (data["startTime"] as Timestamp).toDate();
      final existingEnd = (data["endTime"] as Timestamp).toDate();

      // Conflict if: new start is before existing end AND new end is after existing start
      if (startTime.isBefore(existingEnd) && endTime.isAfter(existingStart)) {
        return true; // Conflict detected
      }
    }

    return false; // No conflict
  }

  /// Add a booking with conflict checking
  Future<void> addBookingWithConflictCheck({
    required String roomId,
    required String roomName,
    required DateTime startTime,
    required DateTime endTime,
  }) async {
    bool conflict = await checkTimeConflict(roomId, startTime, endTime);

    if (conflict) {
      throw Exception("This room is already booked for this time slot.");
    }

    final user = _auth.currentUser;
    if (user == null) {
      throw Exception("User not authenticated");
    }

    await _db.collection("bookings").add({
      "roomId": roomId,
      "roomName": roomName,
      "userId": user.uid,
      "userEmail": user.email,
      "startTime": Timestamp.fromDate(startTime),
      "endTime": Timestamp.fromDate(endTime),
      "status": "confirmed",
      "createdAt": Timestamp.now(),
    });
  }

  /// Cancel a booking
  Future<void> cancelBooking(String bookingId) {
    return _db.collection("bookings").doc(bookingId).delete();
  }

  /// Add a room (admin only)
  Future<void> addRoom(String name) async {
    await _db.collection("rooms").add({
      "name": name,
      "createdAt": Timestamp.now(),
    });
  }

  /// Delete a room (admin only)
  Future<void> deleteRoom(String roomId) {
    return _db.collection("rooms").doc(roomId).delete();
  }

  /// Stream of bookings for current user
  Stream<List<Booking>> getUserBookings() {
    final user = _auth.currentUser;
    if (user == null) {
      return Stream.value([]);
    }

    return _db
        .collection('bookings')
        .where('userId', isEqualTo: user.uid)
        .orderBy('startTime', descending: false)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => Booking.fromMap(doc.id, doc.data()))
              .toList(),
        );
  }

  /// Stream of all bookings
  Stream<List<Booking>> getBookings() {
    return _db
        .collection('bookings')
        .orderBy('startTime', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => Booking.fromMap(doc.id, doc.data()))
              .toList(),
        );
  }

  Future<void> addBooking(Booking booking) {
    return _db.collection('bookings').add(booking.toMap());
  }
}
