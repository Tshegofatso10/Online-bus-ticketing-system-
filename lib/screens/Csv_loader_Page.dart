import 'package:flutter/services.dart' show rootBundle;
import 'package:csv/csv.dart';
import 'dart:convert';

class BusRoute {
  final int routeId;
  final List<int> stops;
  final List<int> schedule;
  final int capacity;
  final double fare;

  BusRoute({
    required this.routeId,
    required this.stops,
    required this.schedule,
    required this.capacity,
    required this.fare,
  });

  @override
  String toString() {
    return 'Route $routeId: stops=$stops, schedule=$schedule, capacity=$capacity, fare=$fare';
  }
}

/// ✅ Load bus routes from CSV
Future<List<BusRoute>> loadBusRoutesFromCSV() async {
  final rawData = await rootBundle.loadString('assets/data/bus_routes.csv');

  // Convert CSV to list of lists
  List<List<dynamic>> csvData = const CsvToListConverter().convert(rawData, eol: '\n');

  List<BusRoute> routes = [];

  for (var i = 1; i < csvData.length; i++) { // skip header row
    int routeId = csvData[i][0];
    List<int> stops = List<int>.from(jsonDecode(csvData[i][1]));
    List<int> schedule = List<int>.from(jsonDecode(csvData[i][2]));
    int capacity = csvData[i][3];
    double fare = csvData[i][4].toDouble();

    routes.add(BusRoute(
      routeId: routeId,
      stops: stops,
      schedule: schedule,
      capacity: capacity,
      fare: fare,
    ));
  }

  return routes;
}
