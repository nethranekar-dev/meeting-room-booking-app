import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/booking.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Stream<List<Booking>> getBookings() {
    return _db
        .collection('bookings')
        .orderBy('time', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => Booking.fromMap(doc.id, doc.data()))
              .toList(),
        );
  }

  Future<bool> checkTimeConflict(
      String roomId, DateTime startTime, DateTime endTime) async {
    final snapshot = await _db
        .collection("bookings")
        .where("room", isEqualTo: roomId)
        .get();

    for (var doc in snapshot.docs) {
      final data = doc.data() as Map<String, dynamic>;
      final existingStart = (data["startTime"] as Timestamp).toDate();
      final existingEnd = (data["endTime"] as Timestamp).toDate();

      if (startTime.isBefore(existingEnd) && endTime.isAfter(existingStart)) {
        return true; // Conflict detected
      }
    }

    return false; // No conflict
  }

  Future<void> addBooking(Booking booking) {
    return _db.collection('bookings').add(booking.toMap());
  }

  Future<void> addBookingWithConflictCheck(
      String roomId, DateTime startTime, DateTime endTime, Booking booking) async {
    bool conflict = await checkTimeConflict(roomId, startTime, endTime);

    if (conflict) {
      throw Exception("This room is already booked for selected time.");
    }

    return _db.collection('bookings').add(booking.toMap());
  }

  Future<void> deleteBooking(String id) {
    return _db.collection('bookings').doc(id).delete();
  }
}
