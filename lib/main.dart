import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_application_1/screens/E-Ticket_Page.dart';
import 'screens/login_page.dart';
import 'screens/register_page.dart';
import 'screens/dashboard_page.dart';
import 'screens/User_Details_Page.dart';
import 'screens/Routes_Schedules_Page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Bus Ticket App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case '/login':
            return MaterialPageRoute(builder: (_) => const LoginPage());
          case '/register':
            return MaterialPageRoute(builder: (_) => const RegisterPage());
          case '/dashboard':
            final username = settings.arguments as String?;
            return MaterialPageRoute(
                builder: (_) => DashboardPage(username: username ?? ""));
          case '/userDetails':
            return MaterialPageRoute(builder: (_) => const UserDetailsPage());
          case '/routesSchedules':
            return MaterialPageRoute(builder: (_) => const RoutesSchedulesPage());
          case '/eticket':
            return MaterialPageRoute(builder: (_) => const ETicketPage());
          default:
            return MaterialPageRoute(builder: (_) => const LocalDataTestPage());
        }
      },
      initialRoute: '/login',
    );
  }
}

/// Test page to demonstrate saving data locally per user
class LocalDataTestPage extends StatefulWidget {
  const LocalDataTestPage({super.key});

  @override
  State<LocalDataTestPage> createState() => _LocalDataTestPageState();
}

class _LocalDataTestPageState extends State<LocalDataTestPage> {
  String message = "Testing local storage with SharedPreferences...";
  late SharedPreferences prefs;

  final String username = "test_user"; // Example user, normally dynamic

  @override
  void initState() {
    super.initState();
    _saveAndLoadData();
  }

  Future<void> _saveAndLoadData() async {
    prefs = await SharedPreferences.getInstance();

    // Example: save some booking data for this user
    List<String> userBookings =
        prefs.getStringList("${username}_bookings") ?? [];

    userBookings.add("Booking at ${DateTime.now()}");

    await prefs.setStringList("${username}_bookings", userBookings);

    // Read back the data
    List<String> loadedBookings =
        prefs.getStringList("${username}_bookings") ?? [];

    setState(() {
      message = "✅ Saved & loaded ${loadedBookings.length} booking(s) for $username:\n${loadedBookings.join('\n')}";
    });

    // Auto-navigate to login after 2 seconds
    Future.delayed(const Duration(seconds: 2), () {
      Navigator.pushReplacementNamed(context, '/login');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Local Data Test")),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 18),
          ),
        ),
      ),
    );
  }
}

/*
import 'package:flutter/material.dart';
import 'package:flutter_application_1/screens/E-Ticket_Page.dart';
import 'screens/login_page.dart';
import 'screens/register_page.dart';
import 'screens/dashboard_page.dart';
import 'screens/User_Details_Page.dart';
import 'screens/Routes_Schedules_Page.dart';
import 'package:backendless_sdk/backendless_sdk.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Backendless
  await Backendless.initApp(
    applicationId: "232B7F72-6041-4E59-A8FB-DD2B0C2DDF59",
    androidApiKey: "57C9BC4A-526F-43CB-A59F-49F766CEAA78",
    iosApiKey: "BA148202-A074-40E0-B3DC-1DC8D91A9590",
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Bus Ticket App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      // Use onGenerateRoute to handle routes with arguments
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case '/login':
            return MaterialPageRoute(builder: (_) => const LoginPage());
          case '/register':
            return MaterialPageRoute(builder: (_) => const RegisterPage());
          case '/dashboard':
            final username = settings.arguments as String;
            return MaterialPageRoute(
                builder: (_) => DashboardPage(username: username));
          case '/userDetails':
            return MaterialPageRoute(builder: (_) => const UserDetailsPage());
          case '/routesSchedules':
            return MaterialPageRoute(builder: (_) => const RoutesSchedulesPage());
          case '/eticket':
            return MaterialPageRoute(builder: (_) => const ETicketPage());
          default:
            return MaterialPageRoute(
                builder: (_) => const BackendlessTestPage());
        }
      },
      initialRoute: '/login',
    );
  }
}

class BackendlessTestPage extends StatefulWidget {
  const BackendlessTestPage({super.key});

  @override
  State<BackendlessTestPage> createState() => _BackendlessTestPageState();
}

class _BackendlessTestPageState extends State<BackendlessTestPage> {
  String message = "Testing Backendless connection...";

  @override
  void initState() {
    super.initState();
    _testBackendless();
  }

  Future<void> _testBackendless() async {
    try {
      Map<String, dynamic> data = {
        "name": "Test Record",
        "created_at": DateTime.now().toString(),
      };

      await Backendless.data.of("test_table").save(data);

      final response = await Backendless.data.of("test_table").find();

      setState(() {
        message =
            "✅ Connected!\nSaved & fetched ${response?.length ?? 0} record(s).";
      });

      // Auto-navigate to login after 2 seconds
      Future.delayed(const Duration(seconds: 2), () {
        Navigator.pushReplacementNamed(context, '/login');
      });
    } catch (e) {
      setState(() {
        message = "❌ Connection failed: $e";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Backendless Test")),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 18),
          ),
        ),
      ),
    );
  }
}
*/
