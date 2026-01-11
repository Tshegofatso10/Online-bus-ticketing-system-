import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class BookingDetailsPage extends StatefulWidget {
  final Map<String, dynamic>? existingBooking;
  const BookingDetailsPage({super.key, this.existingBooking});

  @override
  State<BookingDetailsPage> createState() => _BookingDetailsPageState();
}

class _BookingDetailsPageState extends State<BookingDetailsPage> {
  DateTime? fromDate;
  DateTime? tillDate;
  bool isSingleTrip = false;
  String? selectedLocation;
  String? selectedDestination;
  String? selectedPackage; // '5', '10', '30'
  double totalCost = 0.0;

  final List<String> locations = [
    'Bloemfontein',
    'Botshabelo',
    'Thaba Nchu',
    'Bloemfontein Local',
    'Botshabelo Local',
    'Thaba Nchu Local'
  ];

  final List<String> destinations = ['Bloemfontein', 'Botshabelo', 'Thaba Nchu'];
  final List<String> packages = ['5', '10', '30'];

  @override
  void initState() {
    super.initState();
    if (widget.existingBooking != null) {
      _loadExistingBooking(widget.existingBooking!);
    }
  }

  void _loadExistingBooking(Map<String, dynamic> booking) {
    setState(() {
      fromDate = _parseDate(booking['fromDate']);
      tillDate = _parseDate(booking['tillDate']);
      isSingleTrip = booking['tripType'] == 'Single Trip';
      selectedLocation = booking['location'];
      selectedDestination = booking['destination'] ?? '-';
      selectedPackage = booking['package'] != 'Single Trip' ? booking['package'] : null;
    });
  }

  DateTime? _parseDate(String? dateStr) {
    if (dateStr == null || dateStr == '-') return null;
    final parts = dateStr.split('/');
    if (parts.length != 3) return null;
    return DateTime(int.parse(parts[2]), int.parse(parts[1]), int.parse(parts[0]));
  }

  double calculateCost() {
    if (selectedLocation == null) return 0.0;

    String destination = selectedDestination ?? '';
    if (selectedLocation!.contains('Local')) {
      destination = selectedLocation!.replaceAll(' Local', '');
      selectedDestination = destination;
    }

    Map<String, Map<String, Map<String, double>>> pricing = {
      'Thaba Nchu': {
        'Bloemfontein': {'single': 35, '5': 208, '10': 416, '30': 1210},
        'Botshabelo': {'single': 17, '5': 98, '10': 196, '30': 970},
        'Thaba Nchu': {'single': 0, '5': 0, '10': 0, '30': 0},
      },
      'Botshabelo': {
        'Bloemfontein': {'single': 37, '5': 210, '10': 420, '30': 1216},
        'Thaba Nchu': {'single': 17, '5': 98, '10': 196, '30': 970},
        'Botshabelo': {'single': 0, '5': 0, '10': 0, '30': 0},
      },
      'Bloemfontein': {
        'Thaba Nchu': {'single': 35, '5': 208, '10': 416, '30': 1210},
        'Botshabelo': {'single': 37, '5': 210, '10': 420, '30': 1216},
        'Bloemfontein': {'single': 0, '5': 0, '10': 0, '30': 0},
      },
      'Thaba Nchu Local': {'Thaba Nchu': {'5': 122, '10': 244, '30': 832}},
      'Botshabelo Local': {'Botshabelo': {'5': 125, '10': 250, '30': 840}},
      'Bloemfontein Local': {'Bloemfontein': {'5': 135, '10': 275, '30': 900}},
    };

    String package = 'single';
    if (isSingleTrip) {
      package = 'single';
    } else if (selectedPackage != null) {
      package = selectedPackage!;
    } else if (selectedLocation!.contains('Local')) {
      package = '5';
    } else if (fromDate != null && tillDate != null) {
      final days = tillDate!.difference(fromDate!).inDays + 1;
      if (days >= 30) package = '30';
      else if (days >= 10) package = '10';
      else if (days >= 5) package = '5';
      else package = 'single';
    }

    final locPricing = pricing[selectedLocation!];
    if (locPricing == null) return 0.0;
    final destPricing = locPricing[destination];
    if (destPricing == null) return 0.0;
    return destPricing[package] ?? 0.0;
  }

  Future<void> selectDate(BuildContext context, bool isFrom) async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: isFrom ? (fromDate ?? DateTime.now()) : (tillDate ?? fromDate ?? DateTime.now()),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (pickedDate != null) {
      setState(() {
        if (isFrom) {
          fromDate = pickedDate;
          if (isSingleTrip) tillDate = pickedDate;
        } else {
          tillDate = pickedDate;
        }
      });
    }
  }

  Future<void> completeBooking() async {
    if (fromDate == null || (!isSingleTrip && tillDate == null) || selectedLocation == null || (!selectedLocation!.contains('Local') && selectedDestination == null) || (!isSingleTrip && selectedPackage == null)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please complete all required fields.")),
      );
      return;
    }

    totalCost = calculateCost();
    if (totalCost == 0.0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Booking cannot have a cost of R0.")),
      );
      return;
    }

    final booking = {
      'fromDate': "${fromDate!.day}/${fromDate!.month}/${fromDate!.year}",
      'tillDate': tillDate != null ? "${tillDate!.day}/${tillDate!.month}/${tillDate!.year}" : "-",
      'tripType': isSingleTrip ? 'Single Trip' : 'Return Trip',
      'location': selectedLocation!,
      'destination': selectedDestination ?? '-',
      'package': isSingleTrip ? 'Single Trip' : selectedPackage ?? '-',
      'cost': totalCost.toStringAsFixed(2),
    };

    SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? loggedInUserEmail = prefs.getString('loggedInUserEmail');
    if (loggedInUserEmail != null) {
      final String? savedBookings = prefs.getString('bookings_$loggedInUserEmail');
      List<Map<String, dynamic>> bookings = [];
      if (savedBookings != null) {
        bookings = List<Map<String, dynamic>>.from(jsonDecode(savedBookings));
      }

      // If editing existing booking, update; else add new
      if (widget.existingBooking != null) {
        final index = bookings.indexWhere((b) => b['fromDate'] == widget.existingBooking!['fromDate'] && b['location'] == widget.existingBooking!['location']);
        if (index != -1) {
          bookings[index] = booking;
        } else {
          bookings.add(booking);
        }
      } else {
        bookings.add(booking);
      }

      await prefs.setString('bookings_$loggedInUserEmail', jsonEncode(bookings));
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Booking saved successfully!")),
    );

    Navigator.pop(context, booking); // Return to History page
  }

  @override
  Widget build(BuildContext context) {
    totalCost = calculateCost();

    return Scaffold(
      appBar: AppBar(title: const Text("Booking Details"), backgroundColor: Colors.blue),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // DATE PICKER
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: () => selectDate(context, true),
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(border: Border.all(color: Colors.grey), borderRadius: BorderRadius.circular(10)),
                          child: Text(fromDate == null ? "FROM" : "${fromDate!.day}/${fromDate!.month}/${fromDate!.year}"),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: InkWell(
                        onTap: isSingleTrip ? null : () => selectDate(context, false),
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                            borderRadius: BorderRadius.circular(10),
                            color: isSingleTrip ? Colors.grey[200] : Colors.white,
                          ),
                          child: Text(tillDate == null ? "TILL" : "${tillDate!.day}/${tillDate!.month}/${tillDate!.year}"),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // SINGLE TRIP CHECKBOX
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    const Text("SINGLE TRIP"),
                    Checkbox(
                      value: isSingleTrip,
                      onChanged: (val) {
                        setState(() {
                          isSingleTrip = val ?? false;
                          if (isSingleTrip) tillDate = fromDate;
                        });
                      },
                    ),
                  ],
                ),
              ),

              // LOCATION HEADER + DROPDOWN
              const Padding(
                padding: EdgeInsets.only(left: 16, bottom: 4),
                child: Text("Select Location", style: TextStyle(fontWeight: FontWeight.bold)),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: DropdownButtonFormField<String>(
                  value: selectedLocation,
                  items: locations.map((loc) => DropdownMenuItem(value: loc, child: Text(loc))).toList(),
                  decoration: InputDecoration(border: OutlineInputBorder(borderRadius: BorderRadius.circular(10))),
                  onChanged: (val) {
                    setState(() {
                      selectedLocation = val;
                      if (selectedLocation!.contains('Local')) selectedDestination = selectedLocation!.replaceAll(' Local', '');
                    });
                  },
                ),
              ),

              const SizedBox(height: 10),

              // DESTINATION HEADER + DROPDOWN
              const Padding(
                padding: EdgeInsets.only(left: 16, bottom: 4),
                child: Text("Select Destination", style: TextStyle(fontWeight: FontWeight.bold)),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: DropdownButtonFormField<String>(
                  value: selectedDestination,
                  items: destinations.map((dest) => DropdownMenuItem(value: dest, child: Text(dest))).toList(),
                  decoration: InputDecoration(border: OutlineInputBorder(borderRadius: BorderRadius.circular(10))),
                  onChanged: selectedLocation != null && selectedLocation!.contains('Local') ? null : (val) => setState(() => selectedDestination = val),
                ),
              ),

              const SizedBox(height: 10),

              // PACKAGE HEADER + DROPDOWN
              if (!isSingleTrip) ...[
                const Padding(
                  padding: EdgeInsets.only(left: 16, bottom: 4),
                  child: Text("Select Ticket Package", style: TextStyle(fontWeight: FontWeight.bold)),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: DropdownButtonFormField<String>(
                    value: selectedPackage,
                    items: packages.map((p) => DropdownMenuItem(value: p, child: Text("$p Days"))).toList(),
                    decoration: InputDecoration(border: OutlineInputBorder(borderRadius: BorderRadius.circular(10))),
                    onChanged: (val) => setState(() => selectedPackage = val),
                  ),
                ),
              ],

              const SizedBox(height: 20),

              // TOTAL COST
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text("TOTAL COST: R ${totalCost.toStringAsFixed(2)}", style: const TextStyle(fontSize: 16)),
              ),

              const SizedBox(height: 20),

              // SAVE/UPDATE BUTTON
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: ElevatedButton(
                  onPressed: completeBooking,
                  child: const Text("SAVE/UPDATE BOOKING"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
