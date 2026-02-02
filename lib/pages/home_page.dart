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

  Future<void> bookRoom() async {
    if (_roomController.text.trim().isEmpty) {
      return;
    }

    await FirebaseFirestore.instance.collection('bookings').add({
      'roomName': _roomController.text.trim(),
      'timestamp': FieldValue.serverTimestamp(),
      'userEmail': FirebaseAuth.instance.currentUser!.email,
      'status': 'confirmed'
    });

    _roomController.clear();
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
        child: Column(
          children: [
            TextField(
              controller: _roomController,
              decoration: const InputDecoration(labelText: 'Room Name'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: bookRoom,
              child: const Text('Book Room'),
            ),
            const SizedBox(height: 20),
            const Divider(),
            const Text('Live Bookings', style: TextStyle(fontSize: 18)),
            const SizedBox(height: 10),
            StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection('bookings')
                  .orderBy('timestamp', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const CircularProgressIndicator();
                }

                final docs = snapshot.data!.docs;

                return ListView.builder(
                  shrinkWrap: true,
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Text(docs[index]['roomName']),
                      subtitle: Text(
                        (docs[index]['timestamp'] as Timestamp)
                            .toDate()
                            .toString(),
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () {
                          docs[index].reference.delete();
                        },
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
