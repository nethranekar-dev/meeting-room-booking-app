import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class BookingScreen extends StatefulWidget {
  const BookingScreen({super.key});

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  String selectedRoom = "Meeting Room A";
  DateTime? selectedDate;
  TimeOfDay? selectedTime;
  bool _isLoading = false;

  final List<String> rooms = [
    "Meeting Room A",
    "Meeting Room B",
    "Conference Room A",
    "Conference Room B"
  ];

  Future<void> bookRoom() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You must be logged in to book a room')),
      );
      return;
    }

    if (selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a date')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Check for double booking
      final existingBookings = await FirebaseFirestore.instance
          .collection('bookings')
          .where('room', isEqualTo: selectedRoom)
          .where('date', isEqualTo: selectedDate.toString().split(' ')[0])
          .get();

      if (existingBookings.docs.isNotEmpty) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Room already booked for this date!')),
        );
        setState(() => _isLoading = false);
        return;
      }

      // Save booking
      await FirebaseFirestore.instance.collection('bookings').add({
        'room': selectedRoom,
        'date': selectedDate.toString().split(' ')[0],
        'time': selectedTime?.format(context) ?? 'Not specified',
        'timestamp': FieldValue.serverTimestamp(),
        'userEmail': user.email,
        'status': 'confirmed'
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Room booked successfully!')),
      );

      // Reset form
      setState(() {
        selectedDate = null;
        selectedTime = null;
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Booking failed: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Meeting Room Booking'),
        backgroundColor: Colors.indigo,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              Navigator.pushReplacementNamed(context, "/login");
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Room Dropdown
            DropdownButtonFormField<String>(
              initialValue: selectedRoom,
              items: rooms.map((room) {
                return DropdownMenuItem(
                  value: room,
                  child: Text(room),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedRoom = value!;
                });
              },
              decoration: const InputDecoration(
                labelText: 'Select Room',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 15),
            // Date Picker
            ElevatedButton.icon(
              icon: const Icon(Icons.calendar_today),
              label: Text(selectedDate == null
                  ? 'Pick a Date'
                  : selectedDate.toString().split(' ')[0]),
              onPressed: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime.now(),
                  lastDate: DateTime(2025, 12, 31),
                );
                if (picked != null) {
                  setState(() => selectedDate = picked);
                }
              },
            ),
            const SizedBox(height: 15),
            // Time Picker
            ElevatedButton.icon(
              icon: const Icon(Icons.access_time),
              label: Text(selectedTime == null
                  ? 'Pick a Time'
                  : selectedTime!.format(context)),
              onPressed: () async {
                final picked = await showTimePicker(
                  context: context,
                  initialTime: TimeOfDay.now(),
                );
                if (picked != null) {
                  setState(() => selectedTime = picked);
                }
              },
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _isLoading ? null : bookRoom,
              child: _isLoading
                  ? const CircularProgressIndicator()
                  : const Text('Book Room'),
            ),
            const SizedBox(height: 20),
            const Divider(),
            const Text('Live Bookings', style: TextStyle(fontSize: 18)),
            const SizedBox(height: 10),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('bookings')
                    .orderBy('timestamp', descending: true)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
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
                    itemCount: docs.length,
                    itemBuilder: (context, index) {
                      try {
                        final doc = docs[index];
                        final bookingData = (doc.data() as Map<String, dynamic>?) ?? <String, dynamic>{};
                        final roomName = bookingData['room'] ?? bookingData['roomName'] ?? 'Room not found';
                        final date = bookingData['date'] ?? 'N/A';
                        final time = bookingData['time'] ?? bookingData['startTime'] ?? 'N/A';
                        
                        return Card(
                          elevation: 4,
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: ListTile(
                            leading: const Icon(
                              Icons.meeting_room,
                              color: Colors.indigo,
                              size: 28,
                            ),
                            title: Text(
                              roomName is String ? roomName : roomName.toString(),
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            subtitle: Text(
                              'Date: $date | Time: $time',
                            ),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () {
                                FirebaseFirestore.instance
                                    .collection('bookings')
                                    .doc(doc.id)
                                    .delete();
                              },
                            ),
                          ),
                        );
                      } catch (e) {
                        return Card(
                          elevation: 4,
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          child: ListTile(
                            title: const Text('Invalid Booking Data'),
                            subtitle: Text('Error: $e'),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () {
                                FirebaseFirestore.instance
                                    .collection('bookings')
                                    .doc(docs[index].id)
                                    .delete();
                              },
                            ),
                          ),
                        );
                      }
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
