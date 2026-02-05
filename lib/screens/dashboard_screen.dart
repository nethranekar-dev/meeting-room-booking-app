import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/booking.dart';
import '../services/firestore_service.dart';
import '../pages/my_bookings_page.dart';
import 'login_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  void _showAddDialog(BuildContext context) {
    final roomController = TextEditingController();
    final nameController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Add Booking"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: roomController,
              decoration: const InputDecoration(labelText: "Room Name"),
            ),
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: "Your Name"),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              if (roomController.text.isNotEmpty &&
                  nameController.text.isNotEmpty) {
                final booking = Booking(
                  id: '',
                  room: roomController.text,
                  name: nameController.text,
                  time: DateTime.now(),
                );

                FirestoreService().addBooking(booking);
                Navigator.pop(context);
              }
            },
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Dashboard"),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              Navigator.pushReplacementNamed(context, '/login');
            },
          ),
        ],
      ),
      body: StreamBuilder<List<Booking>>(
        stream: FirestoreService().getBookings(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final bookings = snapshot.data!;

          if (bookings.isEmpty) {
            return const Center(
              child: Text("No bookings yet. Tap + to add one."),
            );
          }

          return ListView.builder(
            itemCount: bookings.length,
            itemBuilder: (context, index) {
              final b = bookings[index];

              return Dismissible(
                key: Key(b.id),
                onDismissed: (_) {
                  FirestoreService().deleteBooking(b.id);
                },
                child: ListTile(
                  title: Text(b.room),
                  subtitle: Text(
                    "${b.name} — ${b.time.toLocal().toString().substring(0, 16)}",
                  ),
                  trailing: Chip(
                    label: Text(b.status ?? "Scheduled"),
                    backgroundColor: b.status == "Cancelled"
                        ? Colors.red[100]
                        : Colors.green[100],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddDialog(context),
        child: const Icon(Icons.add),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ElevatedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const MyBookingsPage()),
            );
          },
          child: const Text("My Bookings"),
        ),
      ),
    );
  }
}
