import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final List<String> rooms = [
    "Meeting Room A",
    "Meeting Room B",
    "Conference Room A",
    "Conference Room B"
  ];

  String selectedRoom = "Meeting Room A";
  DateTime? selectedDate;
  String startTime = "";
  String endTime = "";

  Future pickStartTime() async {
    TimeOfDay? time =
        await showTimePicker(context: context, initialTime: TimeOfDay.now());

    if (time != null) {
      setState(() {
        startTime = time.format(context);
      });
    }
  }

  Future pickEndTime() async {
    TimeOfDay? time =
        await showTimePicker(context: context, initialTime: TimeOfDay.now());

    if (time != null) {
      setState(() {
        endTime = time.format(context);
      });
    }
  }

  void bookRoom() async {
    if (selectedDate == null || startTime.isEmpty || endTime.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill all fields")),
      );
      return;
    }

    // Format date for Firestore
    final dateStr = "${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}";

    // Check for double booking
    final existingBookings = await FirebaseFirestore.instance
        .collection("bookings")
        .where("room", isEqualTo: selectedRoom)
        .where("date", isEqualTo: dateStr)
        .get();

    if (existingBookings.docs.isNotEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Room already booked for this date!")),
      );
      return;
    }

    await FirebaseFirestore.instance.collection("bookings").add({
      "room": selectedRoom,
      "date": dateStr,
      "startTime": startTime,
      "endTime": endTime,
      "createdAt": Timestamp.now(),
    });

    setState(() {
      selectedDate = null;
      startTime = "";
      endTime = "";
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Room booked successfully!")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Meeting Room Booking"),
        backgroundColor: Colors.indigo,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              if (!mounted) return;
              Navigator.pushReplacementNamed(context, "/login");
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Book a Room",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
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
                labelText: "Select Room",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 15),
            ElevatedButton(
              onPressed: () async {
                DateTime? picked = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime.now(),
                  lastDate: DateTime(2030),
                );

                if (picked != null) {
                  setState(() {
                    selectedDate = picked;
                  });
                }
              },
              child: Text(
                selectedDate == null
                    ? "Pick a Date"
                    : "${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}",
              ),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: pickStartTime,
              child: Text(
                startTime.isEmpty ? "Start Time" : "Start: $startTime",
              ),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: pickEndTime,
              child: Text(
                endTime.isEmpty ? "End Time" : "End: $endTime",
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: bookRoom,
                child: const Text("Book Room"),
              ),
            ),
            const SizedBox(height: 30),
            const Text(
              "Live Bookings",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection("bookings")
                  .orderBy("createdAt", descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const CircularProgressIndicator();
                }

                final bookings = snapshot.data!.docs;

                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: bookings.length,
                  itemBuilder: (context, index) {
                    var booking = bookings[index];
                    final data = (booking.data() as Map<String, dynamic>?) ?? <String, dynamic>{};
                    final room = data['room'] ?? data['roomName'] ?? 'Room not found';
                    final date = data['date'] ?? data['startTime'] ?? 'Date not set';
                    final startTime = data['startTime'] ?? 'N/A';
                    final endTime = data['endTime'] ?? 'N/A';

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
                          room is String ? room : room.toString(),
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          "$date | $startTime - $endTime",
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () {
                            FirebaseFirestore.instance
                                .collection("bookings")
                                .doc(booking.id)
                                .delete();
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
    );
  }
}
