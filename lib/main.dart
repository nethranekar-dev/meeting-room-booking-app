import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_options.dart';
import 'screens/login_screen.dart';
import 'screens/booking_screen.dart';
import 'screens/admin_dashboard.dart';
import 'screens/manage_rooms_screen.dart';
import 'screens/all_bookings_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Meeting Room Booking',
      theme: ThemeData(
        primarySwatch: Colors.indigo,
        useMaterial3: true,
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ),
      routes: {
        "/login": (context) => const LoginScreen(),
        "/home": (context) => const BookingScreen(),
        "/admin": (context) => const AdminDashboard(),
        "/rooms": (context) => const ManageRoomsScreen(),
        "/bookings": (context) => const AllBookingsScreen(),
      },
      initialRoute: "/login",
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }
          if (snapshot.hasData) {
            return const BookingScreen();
          }
          return const LoginScreen();
        },
      ),
    );
  }
}
