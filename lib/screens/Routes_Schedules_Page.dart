import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:csv/csv.dart';

class RoutesSchedulesPage extends StatefulWidget {
  const RoutesSchedulesPage({super.key});

  @override
  State<RoutesSchedulesPage> createState() => _RoutesSchedulesPageState();
}

class _RoutesSchedulesPageState extends State<RoutesSchedulesPage> {
  List<Map<String, dynamic>> _events = [];

  @override
  void initState() {
    super.initState();
    _loadCSV();
  }

  Future<void> _loadCSV() async {
    try {
      final rawData = await rootBundle.loadString('assets/data/bus_routes.csv');
      List<List<dynamic>> listData = const CsvToListConverter().convert(rawData);

      if (listData.isEmpty) return;

      final headers = listData[0].map((e) => e.toString()).toList();
      final rows = listData.sublist(1);

      List<Map<String, dynamic>> parsedEvents = rows.map((row) {
        Map<String, dynamic> map = {};
        for (int i = 0; i < headers.length; i++) {
          map[headers[i]] = row[i];
        }
        return map;
      }).toList();

      setState(() {
        _events = parsedEvents;
      });
    } catch (e) {
      print("Error loading CSV: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Bus Routes & Schedules"),
        backgroundColor: Colors.blue,
      ),
      body: _events.isEmpty
          ? const Center(child: Text("No routes found", style: TextStyle(fontSize: 16)))
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: _events.length,
              itemBuilder: (context, index) {
                final event = _events[index];
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 6),
                  elevation: 3,
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Date: ${event['Date']}, Route: ${event['Route']}, Time: ${event['Time']}",
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 5),
                        Text("Day: ${event['Day']}"),
                        Text("Location: ${event['Location']}"),
                        Text("Incident: ${event['Incident']}"),
                        Text("Min Delay: ${event['Min Delay']} | Min Gap: ${event['Min Gap']}"),
                        Text("Direction: ${event['Direction']}"),
                        Text("Vehicle: ${event['Vehicle']}"),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
