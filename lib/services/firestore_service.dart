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

  Future<void> addBooking(Booking booking) {
    return _db.collection('bookings').add(booking.toMap());
  }

  Future<void> deleteBooking(String id) {
    return _db.collection('bookings').doc(id).delete();
  }
}
