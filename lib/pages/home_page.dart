import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _roomController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _startTimeController = TextEditingController();
  final TextEditingController _endTimeController = TextEditingController();

  Future<void> bookRoom(
    String room,
    String date,
    String startTime,
    String endTime,
  ) async {
    final bookingsRef = FirebaseFirestore.instance.collection('bookings');

    try {
      final existing = await bookingsRef
          .where('room', isEqualTo: room)
          .where('date', isEqualTo: date)
          .get();

      for (var doc in existing.docs) {
        final existingStart = doc['startTime'];
        final existingEnd = doc['endTime'];

        if (_isOverlapping(startTime, endTime, existingStart, existingEnd)) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                "This room is already booked for selected time.",
              ),
            ),
          );
          return;
        }
      }

      await bookingsRef.add({
        'room': room,
        'date': date,
        'startTime': startTime,
        'endTime': endTime,
        'userEmail': FirebaseAuth.instance.currentUser?.email,
        'createdAt': Timestamp.now(),
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Room booked successfully')),
      );

      _roomController.clear();
      _dateController.clear();
      _startTimeController.clear();
      _endTimeController.clear();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Booking failed: $e')),
      );
    }
  }

  bool _isOverlapping(
    String start1,
    String end1,
    String start2,
    String end2,
  ) {
    final s1 = _convertToMinutes(start1);
    final e1 = _convertToMinutes(end1);
    final s2 = _convertToMinutes(start2);
    final e2 = _convertToMinutes(end2);

    return s1 < e2 && s2 < e1;
  }

  int _convertToMinutes(String time) {
    final parts = time.split(":");
    return int.parse(parts[0]) * 60 + int.parse(parts[1]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Meeting Room Booking'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Book a Room',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 15),
              TextField(
                controller: _roomController,
                decoration: const InputDecoration(
                  labelText: 'Room Name',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _dateController,
                decoration: const InputDecoration(
                  labelText: 'Date (YYYY-MM-DD)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _startTimeController,
                decoration: const InputDecoration(
                  labelText: 'Start Time (HH:MM)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _endTimeController,
                decoration: const InputDecoration(
                  labelText: 'End Time (HH:MM)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (_roomController.text.isEmpty ||
                      _dateController.text.isEmpty ||
                      _startTimeController.text.isEmpty ||
                      _endTimeController.text.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Please fill all fields')),
                    );
                    return;
                  }

                  bookRoom(
                    _roomController.text.trim(),
                    _dateController.text.trim(),
                    _startTimeController.text.trim(),
                    _endTimeController.text.trim(),
                  );
                },
                child: const Text('Book Room'),
              ),
              const SizedBox(height: 30),
              const Divider(),
              const Text(
                'Live Bookings',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('bookings')
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Center(
                      child: Text('Error loading bookings: ${snapshot.error}'),
                    );
                  }
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final docs = snapshot.data?.docs ?? [];
                  if (docs.isEmpty) {
                    return const Center(child: Text('No bookings yet'));
                  }

                  return ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: docs.length,
                    itemBuilder: (context, index) {
                      final data = docs[index];
                      return Card(
                        elevation: 2,
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        child: ListTile(
                          title: Text(data['room'] ?? 'Unknown'),
                          subtitle: Text(
                            "${data['date'] ?? 'N/A'} | ${data['startTime'] ?? '--'} - ${data['endTime'] ?? '--'}",
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () async {
                              try {
                                await docs[index].reference.delete();
                                if (!mounted) return;
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Deleted')),
                                );
                              } catch (e) {
                                if (!mounted) return;
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Delete failed: $e')),
                                );
                              }
                            },
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
