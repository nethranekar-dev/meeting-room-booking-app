import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/booking.dart';

class MyBookingsPage extends StatelessWidget {
  const MyBookingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final userEmail = FirebaseAuth.instance.currentUser!.email;

    return Scaffold(
      appBar: AppBar(title: const Text("My Bookings")),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('bookings')
            .where('userEmail', isEqualTo: userEmail)
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final bookingDocs = snapshot.data!.docs;

          if (bookingDocs.isEmpty) {
            return const Center(child: Text("No bookings yet"));
          }

          return ListView.builder(
            itemCount: bookingDocs.length,
            itemBuilder: (context, index) {
              final data = bookingDocs[index].data() as Map<String, dynamic>;
              final booking = Booking.fromMap(bookingDocs[index].id, data);

              return ListTile(
                title: Text(booking.room),
                subtitle: Text(
                  "${booking.name} — ${booking.time.toLocal().toString().substring(0, 16)}",
                ),
                trailing: Chip(
                  label: Text(booking.status ?? "Scheduled"),
                  backgroundColor: booking.status == "Cancelled"
                      ? Colors.red[100]
                      : Colors.green[100],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
