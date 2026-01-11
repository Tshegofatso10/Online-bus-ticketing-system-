import 'package:flutter/material.dart';
import 'Booking_Page.dart';
import 'E-Ticket_Page.dart';
import 'User_Details_Page.dart';
import 'History_Page.dart';
import 'Routes_Schedules_Page.dart';
import 'Notifications_Page.dart';

class DashboardPage extends StatefulWidget {
  final String username;
  const DashboardPage({super.key, required this.username});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  bool showWhatsNew = false;
  bool showHowToUse = false;
  bool showBenefits = false;
  bool showRules = false;

  final panelColors = [
    Colors.lightBlue.shade50,
    Colors.green.shade50,
    Colors.orange.shade50,
    Colors.purple.shade50,
  ];

  final panelIcons = [
    Icons.new_releases,
    Icons.info,
    Icons.thumb_up,
    Icons.rule,
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Drawer(
        child: ListView(
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(color: Colors.blue),
              child: GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const UserDetailsPage()),
                  );
                },
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    widget.username,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ),
            ),
            ListTile(
              title: const Text("Booking"),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => BookingPage()),
              ),
            ),
            ListTile(
              title: const Text("History booking"),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => HistoryBookingPage()),
              ),
            ),
            ListTile(
              title: const Text("Routes & Schedules"),
              onTap: () => Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const RoutesSchedulesPage())),
            ),
            ListTile(
              title: const Text("Notifications"),
              onTap: () => Navigator.push(
                  context, MaterialPageRoute(builder: (_) => const NotificationsPage())),
            ),
            ListTile(
              title: const Text("MY E-TICKET"),
              onTap: () => Navigator.push(
                  context, MaterialPageRoute(builder: (_) => const ETicketPage())),
            ),
            Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () => Navigator.pushReplacementNamed(context, '/login'),
                  child: const Text(
                    "LOGOUT",
                    style: TextStyle(
                        color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: Text(widget.username),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Welcome to your Dashboard!",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 15),
            ExpansionPanelList(
              expansionCallback: (int index, bool isExpanded) {
                setState(() {
                  switch (index) {
                    case 0:
                      showWhatsNew = !showWhatsNew;
                      break;
                    case 1:
                      showHowToUse = !showHowToUse;
                      break;
                    case 2:
                      showBenefits = !showBenefits;
                      break;
                    case 3:
                      showRules = !showRules;
                      break;
                  }
                });
              },
              children: [
                _buildPanel(
                  index: 0,
                  isExpanded: showWhatsNew,
                  title: "What's New",
                  content: "• Easy online bus ticket booking.\n"
                      "• Real-time notifications for delays and schedules.\n"
                      "• Track your booking history and e-tickets.",
                ),
                _buildPanel(
                  index: 1,
                  isExpanded: showHowToUse,
                  title: "How to Use the App",
                  content: "1. Book your trip from the 'Booking' menu.\n"
                      "2. Check your tickets in 'My E-Ticket'.\n"
                      "3. View your previous trips in 'History booking'.\n"
                      "4. Check schedules in 'Routes & Schedules'.",
                ),
                _buildPanel(
                  index: 2,
                  isExpanded: showBenefits,
                  title: "Benefits",
                  content: "• Convenient, cashless transactions.\n"
                      "• Keep all tickets in one place.\n"
                      "• Extend or amend bookings easily.\n"
                      "• Stay updated with notifications.",
                ),
                _buildPanel(
                  index: 3,
                  isExpanded: showRules,
                  title: "Rules & Trip Packages",
                  content: "• Choose Single or Return trips.\n"
                      "• Packages available for 5, 10, or 30 days.\n"
                      "• Amendments may incur a fee.\n"
                      "• Cancelations are charged minimally.",
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  ExpansionPanel _buildPanel(
      {required int index,
      required bool isExpanded,
      required String title,
      required String content}) {
    return ExpansionPanel(
      canTapOnHeader: true,
      headerBuilder: (context, isExpanded) {
        return Container(
          color: panelColors[index],
          child: ListTile(
            leading: Icon(panelIcons[index], color: Colors.blueAccent),
            title: Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        );
      },
      body: Container(
        color: panelColors[index].withOpacity(0.3),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Text(
          content,
          style: const TextStyle(fontSize: 15),
        ),
      ),
      isExpanded: isExpanded,
    );
  }
}
