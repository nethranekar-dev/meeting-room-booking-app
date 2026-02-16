import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/firestore_service.dart';

class AllBookingsScreen extends StatelessWidget {
  const AllBookingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("All Bookings"),
        backgroundColor: Colors.indigo,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection("bookings")
            .orderBy("startTime", descending: false)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final bookings = snapshot.data!.docs;

          if (bookings.isEmpty) {
            return const Center(child: Text("No bookings found."));
          }

          return ListView.builder(
            itemCount: bookings.length,
            itemBuilder: (context, index) {
              final b = bookings[index];
              final start = (b["startTime"] as Timestamp).toDate();
              final end = (b["endTime"] as Timestamp).toDate();

              return Card(
                margin: const EdgeInsets.all(10),
                child: ListTile(
                  title: Text(b["roomName"]),
                  subtitle: Text(
                    "User: ${b["userEmail"]}\n"
                    "Start: ${start.toString().substring(0, 16)}\n"
                    "End: ${end.toString().substring(0, 16)}",
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () async {
                      await FirestoreService().cancelBooking(b.id);
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
