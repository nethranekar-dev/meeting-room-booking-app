import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/firestore_service.dart';

class BookingScreen extends StatefulWidget {
  const BookingScreen({super.key});

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  String? selectedRoomId;
  String? selectedRoomName;

  DateTime? selectedDate;
  TimeOfDay? startTime;
  TimeOfDay? endTime;

  bool loading = false;

  DateTime _combine(DateTime date, TimeOfDay time) {
    return DateTime(date.year, date.month, date.day, time.hour, time.minute);
  }

  Future<void> pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      firstDate: now,
      lastDate: DateTime(now.year + 2),
      initialDate: now,
    );
    if (picked != null) {
      setState(() => selectedDate = picked);
    }
  }

  Future<void> pickStartTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) setState(() => startTime = picked);
  }

  Future<void> pickEndTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) setState(() => endTime = picked);
  }

  Future<void> bookRoom() async {
    if (selectedRoomId == null ||
        selectedRoomName == null ||
        selectedDate == null ||
        startTime == null ||
        endTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill all fields.")),
      );
      return;
    }

    final start = _combine(selectedDate!, startTime!);
    final end = _combine(selectedDate!, endTime!);

    if (!end.isAfter(start)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("End time must be after start time.")),
      );
      return;
    }

    setState(() => loading = true);

    try {
      await FirestoreService().addBookingWithConflictCheck(
        roomId: selectedRoomId!,
        roomName: selectedRoomName!,
        startTime: start,
        endTime: end,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Booking successful ✅")),
      );

      setState(() {
        selectedDate = null;
        startTime = null;
        endTime = null;
        selectedRoomId = null;
        selectedRoomName = null;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    } finally {
      setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Meeting Room Booking"),
        backgroundColor: Colors.indigo,
        actions: [
          FutureBuilder<DocumentSnapshot>(
            future: FirebaseFirestore.instance
                .collection("users")
                .doc(user!.uid)
                .get(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) return const SizedBox();
              final role = snapshot.data!.get("role") ?? "user";
              if (role != "admin") return const SizedBox();

              return IconButton(
                icon: const Icon(Icons.admin_panel_settings),
                onPressed: () {
                  Navigator.pushNamed(context, "/admin");
                },
              );
            },
          ),
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Book a Room",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            StreamBuilder<QuerySnapshot>(
              stream:
                  FirebaseFirestore.instance.collection("rooms").snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final rooms = snapshot.data!.docs;

                return DropdownButtonFormField<String>(
                  value: selectedRoomId,
                  decoration: const InputDecoration(
                    labelText: "Select Room",
                    border: OutlineInputBorder(),
                  ),
                  items: rooms.map((doc) {
                    return DropdownMenuItem(
                      value: doc.id,
                      child: Text(doc["name"]),
                    );
                  }).toList(),
                  onChanged: (val) {
                    final roomDoc =
                        rooms.firstWhere((element) => element.id == val);
                    setState(() {
                      selectedRoomId = val;
                      selectedRoomName = roomDoc["name"];
                    });
                  },
                );
              },
            ),
            const SizedBox(height: 12),
            OutlinedButton(
              onPressed: pickDate,
              child: Text(selectedDate == null
                  ? "Pick Date"
                  : "${selectedDate!.year}-${selectedDate!.month}-${selectedDate!.day}"),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: pickStartTime,
                    child: Text(startTime == null
                        ? "Start Time"
                        : startTime!.format(context)),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: OutlinedButton(
                    onPressed: pickEndTime,
                    child: Text(endTime == null
                        ? "End Time"
                        : endTime!.format(context)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: loading ? null : bookRoom,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.indigo,
                ),
                child: loading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text("Book Room"),
              ),
            ),
            const SizedBox(height: 20),
            const Divider(),
            const SizedBox(height: 10),
            const Text("Live Bookings",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
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
                    return const Center(child: Text("No bookings yet."));
                  }

                  return ListView.builder(
                    itemCount: bookings.length,
                    itemBuilder: (context, index) {
                      final b = bookings[index];
                      final start = (b["startTime"] as Timestamp).toDate();
                      final end = (b["endTime"] as Timestamp).toDate();

                      return Card(
                        child: ListTile(
                          title: Text(b["roomName"]),
                          subtitle: Text(
                              "${start.toString().substring(0, 16)} → ${end.toString().substring(0, 16)}"),
                        ),
                      );
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
