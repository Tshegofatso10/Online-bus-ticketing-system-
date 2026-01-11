import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:qr_flutter/qr_flutter.dart';

class ETicketPage extends StatefulWidget {
  const ETicketPage({super.key});

  @override
  State<ETicketPage> createState() => _ETicketPageState();
}

class _ETicketPageState extends State<ETicketPage> {
  Map<String, dynamic>? latestBooking;
  String? currentUserEmail;

  @override
  void initState() {
    super.initState();
    _loadLatestBooking();
  }

  /// ✅ Load the most recent booking for the currently logged-in user
  Future<void> _loadLatestBooking() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    // Get logged-in user's email
    currentUserEmail = prefs.getString('loggedInUserEmail');
    if (currentUserEmail == null) return;

    // Get this user's bookings
    String? savedBookings = prefs.getString('bookings_$currentUserEmail');
    if (savedBookings == null) return;

    List<dynamic> bookingsList = jsonDecode(savedBookings);
    if (bookingsList.isEmpty) return;

    // Get the latest booking
    setState(() {
      latestBooking = Map<String, dynamic>.from(bookingsList.last);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (latestBooking == null) {
      return Scaffold(
        appBar: AppBar(title: const Text("E-Ticket")),
        body: const Center(
          child: Text(
            "No active e-ticket found.\nPlease make a booking first.",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text("My E-Ticket")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Card(
          elevation: 5,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: QrImageView(
                    data: jsonEncode(latestBooking),
                    version: QrVersions.auto,
                    size: 200.0,
                    backgroundColor: Colors.white,
                  ),
                ),
                const SizedBox(height: 10),
                const Center(
                  child: Text(
                    "E-Ticket",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
                const Divider(height: 30, thickness: 1),
                Text("📍 From: ${latestBooking!['location']}", style: const TextStyle(fontSize: 16)),
                Text("🏁 To: ${latestBooking!['destination']}", style: const TextStyle(fontSize: 16)),
                Text("🚌 Trip Type: ${latestBooking!['tripType']}", style: const TextStyle(fontSize: 16)),
                Text("📅 From Date: ${latestBooking!['fromDate']}", style: const TextStyle(fontSize: 16)),
                Text("📅 Till Date: ${latestBooking!['tillDate']}", style: const TextStyle(fontSize: 16)),
                Text("💰 Cost: R${latestBooking!['cost']}", style: const TextStyle(fontSize: 16)),
                const SizedBox(height: 20),
                Text("📄 Status: ${latestBooking!['status']}", style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const Spacer(),
                /*Center(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("QR code scanning feature coming soon!")),
                      );
                    },
                    icon: const Icon(Icons.qr_code),
                    label: const Text("Scan Ticket"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      minimumSize: const Size(double.infinity, 50),
                    ),
                  ),
                ),*/
              ],
            ),
          ),
        ),
      ),
    );
  }
}
