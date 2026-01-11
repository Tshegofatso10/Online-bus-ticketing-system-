import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class BookingInfoPage extends StatefulWidget {
  final Map<String, dynamic> booking;
  final int index;
  final String userEmail;

  const BookingInfoPage({
    super.key,
    required this.booking,
    required this.index,
    required this.userEmail,
  });

  @override
  State<BookingInfoPage> createState() => _BookingInfoPageState();
}

class _BookingInfoPageState extends State<BookingInfoPage> {
  late Map<String, dynamic> booking;

  @override
  void initState() {
    super.initState();
    booking = Map<String, dynamic>.from(widget.booking);
  }

  Future<void> _saveBooking() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? storedBookings = prefs.getString('bookings_${widget.userEmail}');
    List<Map<String, dynamic>> bookingsList = [];

    if (storedBookings != null) {
      bookingsList = List<Map<String, dynamic>>.from(jsonDecode(storedBookings));
      bookingsList[widget.index] = booking;
    } else {
      bookingsList.add(booking);
    }

    await prefs.setString('bookings_${widget.userEmail}', jsonEncode(bookingsList));
    Navigator.pop(context, booking); // Return updated booking to History page
  }

  String _formatDate(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      return "${date.day}/${date.month}/${date.year}";
    } catch (e) {
      return dateStr;
    }
  }

  Future<void> _amendBooking() async {
    DateTime initialDate = DateTime.tryParse(booking['fromDate']) ?? DateTime.now();

    DateTime? newFromDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );

    if (newFromDate != null) {
      bool confirm = await _showChargeConfirmation(
          "Amend Booking", "Amending will cost R20. Proceed?");
      if (!confirm) return;

      setState(() {
        booking['fromDate'] = newFromDate.toIso8601String();
      });

      await _saveBooking();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Booking amended successfully (R20 charged).")),
      );
    }
  }

  Future<void> _extendBooking() async {
    setState(() {
      DateTime till = DateTime.tryParse(booking['tillDate']) ?? DateTime.now();
      till = till.add(const Duration(days: 2)); // Extend by 2 days
      booking['tillDate'] = till.toIso8601String();
    });

    await _saveBooking();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Booking extended by 2 days (Free).")),
    );
  }

  Future<void> _cancelBooking() async {
    bool confirm = await _showChargeConfirmation(
        "Cancel Booking", "Canceling will cost R26. Proceed?");
    if (!confirm) return;

    setState(() {
      booking['status'] = 'cancelled';
    });

    await _saveBooking();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Booking cancelled (R26 charged).")),
    );
  }

  Future<bool> _showChargeConfirmation(String title, String message) async {
    bool confirmed = false;
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              confirmed = false;
              Navigator.pop(context);
            },
            child: const Text("No"),
          ),
          TextButton(
            onPressed: () {
              confirmed = true;
              Navigator.pop(context);
            },
            child: const Text("Yes"),
          ),
        ],
      ),
    );
    return confirmed;
  }

  @override
  Widget build(BuildContext context) {
    final isCancelled = booking['status'] == 'cancelled';
    return Scaffold(
      appBar: AppBar(title: const Text("Booking Details"), backgroundColor: Colors.blue),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("📍 From: ${booking['location']}", style: const TextStyle(fontSize: 16)),
            Text("🏁 To: ${booking['destination']}", style: const TextStyle(fontSize: 16)),
            Text("🚌 Trip Type: ${booking['tripType']}", style: const TextStyle(fontSize: 16)),
            Text("📅 From Date: ${_formatDate(booking['fromDate'])}", style: const TextStyle(fontSize: 16)),
            Text("📅 Till Date: ${_formatDate(booking['tillDate'])}", style: const TextStyle(fontSize: 16)),
            Text("💰 Cost: R${booking['cost']}", style: const TextStyle(fontSize: 16)),
            Text("📄 Status: ${booking['status']}", style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 30),
            if (!isCancelled) ...[
              ElevatedButton(
                onPressed: _amendBooking,
                style: ElevatedButton.styleFrom(backgroundColor: Colors.orange, minimumSize: const Size(double.infinity, 50)),
                child: const Text("Amend Booking (R20)"),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: _extendBooking,
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green, minimumSize: const Size(double.infinity, 50)),
                child: const Text("Extend Booking by 2 days (Free)"),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: _cancelBooking,
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red, minimumSize: const Size(double.infinity, 50)),
                child: const Text("Cancel Booking (R26)"),
              ),
            ],
          ],
        ),
      ),
    );
  }
}


