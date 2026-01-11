import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'History_Page.dart'; // ✅ Make sure this import matches your actual file name

class BookingConfirmationPage extends StatefulWidget {
  final String username; // ✅ Add username here
  final String location;
  final String destination;
  final String tripType;
  final String fromDate;
  final String tillDate;
  final String cost;

  const BookingConfirmationPage({
    super.key,
    required this.username, // ✅ required username
    required this.location,
    required this.destination,
    required this.tripType,
    required this.fromDate,
    required this.tillDate,
    required this.cost,
  });

  @override
  State<BookingConfirmationPage> createState() =>
      _BookingConfirmationPageState();
}

class _BookingConfirmationPageState extends State<BookingConfirmationPage> {
  bool _bookingSaved = false;

  @override
  void initState() {
    super.initState();
    _saveBooking();
  }

  /// ✅ Save booking permanently in SharedPreferences (user-specific)
  Future<void> _saveBooking() async {
    if (_bookingSaved) return; // Prevent duplicate saving

    final newBooking = {
      "location": widget.location,
      "destination": widget.destination,
      "tripType": widget.tripType,
      "fromDate": widget.fromDate,
      "tillDate": widget.tillDate,
      "cost": widget.cost,
      "status": "Active",
    };

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? email = prefs.getString('loggedInUserEmail'); // use logged-in user
    if (email == null) return;

    List<String> storedBookings =
        prefs.getStringList('bookings_$email') ?? [];

    storedBookings.add(jsonEncode(newBooking));
    await prefs.setStringList('bookings_$email', storedBookings);

    setState(() {
      _bookingSaved = true;
    });
  }

  void _goToHistory() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => HistoryBookingPage(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Booking Confirmation")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Center(
              child: Icon(Icons.check_circle, color: Colors.green, size: 100),
            ),
            const SizedBox(height: 20),
            const Center(
              child: Text(
                "Booking Successful!",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 30),
            Text("📍 From: ${widget.location}",
                style: const TextStyle(fontSize: 16)),
            Text("🏁 To: ${widget.destination}",
                style: const TextStyle(fontSize: 16)),
            Text("🚌 Trip Type: ${widget.tripType}",
                style: const TextStyle(fontSize: 16)),
            Text("📅 From Date: ${widget.fromDate}",
                style: const TextStyle(fontSize: 16)),
            Text("📅 Till Date: ${widget.tillDate}",
                style: const TextStyle(fontSize: 16)),
            Text("💰 Cost: R${widget.cost}",
                style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 40),
            Center(
              child: ElevatedButton(
                onPressed: _goToHistory,
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    minimumSize: const Size(double.infinity, 50)),
                child: const Text("View Booking History"),
              ),
            ),
            const SizedBox(height: 10),
            Center(
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey,
                    minimumSize: const Size(double.infinity, 50)),
                child: const Text("Back to Dashboard"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
