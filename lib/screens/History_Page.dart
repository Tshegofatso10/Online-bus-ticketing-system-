import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'BookingInfo_Page.dart';

class HistoryBookingPage extends StatefulWidget {
  const HistoryBookingPage({super.key});

  @override
  State<HistoryBookingPage> createState() => _HistoryBookingPageState();
}

class _HistoryBookingPageState extends State<HistoryBookingPage> {
  List<Map<String, dynamic>> _bookings = [];
  String? currentUserEmail;

  @override
  void initState() {
    super.initState();
    _loadUserAndBookings();
  }

  Future<void> _loadUserAndBookings() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    currentUserEmail = prefs.getString('loggedInUserEmail');

    if (currentUserEmail != null) {
      final String? savedBookings = prefs.getString('bookings_$currentUserEmail');

      if (savedBookings != null) {
        setState(() {
          _bookings = List<Map<String, dynamic>>.from(jsonDecode(savedBookings));
        });
      } else {
        setState(() {
          _bookings = [];
        });
      }
    }
  }

  Future<void> _saveBookings() async {
    if (currentUserEmail == null) return;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('bookings_$currentUserEmail', jsonEncode(_bookings));
  }

  String _formatDate(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      return "${date.day}/${date.month}/${date.year}";
    } catch (e) {
      return dateStr;
    }
  }

  void _openBookingPage(int index) async {
    final updatedBooking = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BookingInfoPage(
          booking: Map<String, dynamic>.from(_bookings[index]),
          index: index,
          userEmail: currentUserEmail!,
        ),
      ),
    );

    if (updatedBooking != null) {
      setState(() {
        _bookings[index] = updatedBooking;
      });
      _saveBookings();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Booking History"),
        backgroundColor: Colors.blue,
      ),
      body: _bookings.isEmpty
          ? const Center(
              child: Text("No bookings yet.", style: TextStyle(fontSize: 18)),
            )
          : ListView.builder(
              itemCount: _bookings.length,
              itemBuilder: (context, index) {
                final booking = _bookings[index];
                final isCancelled = booking['status'] == 'cancelled';
                return Card(
                  color: isCancelled ? Colors.grey[300] : Colors.white,
                  margin: const EdgeInsets.all(10),
                  child: ListTile(
                    title: Text(
                      "Route: ${booking['location']} → ${booking['destination']}",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: isCancelled ? Colors.grey : Colors.black,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "From: ${_formatDate(booking['fromDate'])}",
                          style: TextStyle(color: isCancelled ? Colors.grey : Colors.black),
                        ),
                        Text(
                          "Till: ${_formatDate(booking['tillDate'])}",
                          style: TextStyle(color: isCancelled ? Colors.grey : Colors.black),
                        ),
                        Text(
                          "Cost: R${booking['cost']}",
                          style: TextStyle(color: isCancelled ? Colors.grey : Colors.black),
                        ),
                      ],
                    ),
                    onTap: () => _openBookingPage(index),
                  ),
                );
              },
            ),
    );
  }
}



/*
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'BookingInfo_Page.dart';

class HistoryBookingPage extends StatefulWidget {
  final String username;
  const HistoryBookingPage({super.key, required this.username});

  @override
  State<HistoryBookingPage> createState() => _HistoryBookingPageState();
}

class _HistoryBookingPageState extends State<HistoryBookingPage> {
  List<Map<String, dynamic>> _bookings = [];
  String? currentUserEmail;

  @override
  void initState() {
    super.initState();
    _loadUserAndBookings();
  }

  Future<void> _loadUserAndBookings() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    currentUserEmail = prefs.getString('loggedInUserEmail');

    if (currentUserEmail != null) {
      final String? savedBookings =
          prefs.getString('bookings_$currentUserEmail');

      if (savedBookings != null) {
        setState(() {
          _bookings = List<Map<String, dynamic>>.from(jsonDecode(savedBookings));
        });
      } else {
        setState(() {
          _bookings = [];
        });
      }
    }
  }

  Future<void> _saveBookings() async {
    if (currentUserEmail == null) return;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('bookings_$currentUserEmail', jsonEncode(_bookings));
  }

  String _formatDate(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      return "${date.day}/${date.month}/${date.year}";
    } catch (e) {
      return dateStr;
    }
  }

  void _openBookingPage(int index) async {
    final updatedBooking = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BookingInfoPage(
          booking: Map<String, dynamic>.from(_bookings[index]),
          index: index,
          userEmail: currentUserEmail!,
        ),
      ),
    );

    if (updatedBooking != null) {
      setState(() {
        _bookings[index] = updatedBooking;
      });
      _saveBookings();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Booking History"),
        backgroundColor: Colors.blue,
      ),
      body: _bookings.isEmpty
          ? const Center(
              child: Text("No bookings yet.", style: TextStyle(fontSize: 18)),
            )
          : ListView.builder(
              itemCount: _bookings.length,
              itemBuilder: (context, index) {
                final booking = _bookings[index];
                final isCancelled = booking['status'] == 'cancelled';
                return Card(
                  color: isCancelled ? Colors.grey[300] : Colors.white,
                  margin: const EdgeInsets.all(10),
                  child: ListTile(
                    title: Text(
                      "Route: ${booking['location']} → ${booking['destination']}",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: isCancelled ? Colors.grey : Colors.black,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "From: ${_formatDate(booking['fromDate'])}",
                          style: TextStyle(color: isCancelled ? Colors.grey : Colors.black),
                        ),
                        Text(
                          "Till: ${_formatDate(booking['tillDate'])}",
                          style: TextStyle(color: isCancelled ? Colors.grey : Colors.black),
                        ),
                        Text(
                          "Cost: R${booking['cost']}",
                          style: TextStyle(color: isCancelled ? Colors.grey : Colors.black),
                        ),
                      ],
                    ),
                    onTap: () => _openBookingPage(index),
                  ),
                );
              },
            ),
    );
  }
}
*/