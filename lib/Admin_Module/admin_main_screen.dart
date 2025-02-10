import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fyp_v2/Admin_Module/crimestatistics.dart';
import 'package:fyp_v2/Admin_Module/missingfoundproperty_screen.dart';
import 'package:fyp_v2/Admin_Module/prefir_managment_screen.dart';
import 'package:fyp_v2/Admin_Module/redzone_screen.dart';
import 'package:fyp_v2/Admin_Module/staff_managment_screen.dart';
import 'package:fyp_v2/Admin_Module/users_management_screen.dart';
import 'package:fyp_v2/Citizen_Module/profile_screen.dart';
import 'package:fyp_v2/Citizen_Module/services_screen.dart';
import 'package:fyp_v2/Citizen_Module/settings_screen.dart';
import 'package:fyp_v2/Citizen_Module/soss_screen.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../Citizen_Module/crime_report_screen.dart';
import '../Citizen_Module/fir_tracking_screen.dart';
import '../Citizen_Module/jobwebcreenview.dart';
import '../Citizen_Module/login_screen.dart';

class AdminMainScreen extends StatefulWidget {
  const AdminMainScreen({super.key});

  @override
  State<AdminMainScreen> createState() => _AdminMainScreenState();
}

class _AdminMainScreenState extends State<AdminMainScreen> {
  final user = FirebaseAuth.instance.currentUser;

  Future<void> signOut(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
    );
  }

  final navigationKey = GlobalKey<CurvedNavigationBarState>();
  int index = 0;
  final screens = [
    AdminMainScreen(),
    ServicesScreen(),
    SossScreen(),
    SettingsScreen(),
    UserProfileScreen()
  ];
  String? userName;
  String? userCnic;

  @override
  void initState() {
    super.initState();
    _getUserInfo();
    _fetchTotalPreFIRs();
  }
  Future<void> _getUserInfo() async {
    User? user = FirebaseAuth.instance.currentUser; // Get logged-in user

    if (user != null) {
      DocumentSnapshot userData = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      setState(() {
        userName = userData['username'];
        userCnic = userData['cnic'];
      });
    }
  }

  final items = <Widget>[
    Icon(Icons.home, size: 30),
    Icon(Icons.miscellaneous_services, size: 30),
    Icon(Icons.sos, size: 30),
    Icon(Icons.settings, size: 30),
    Icon(Icons.person, size: 30),
  ];

  int totalFIRs = 0;
// Function to fetch total Pre-FIR count
  Future<void> _fetchTotalPreFIRs() async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('pre_fir') // Ensure the correct collection name
          .get();

      // Update total FIRs count in state
      if (mounted) {
        setState(() {
          totalFIRs = querySnapshot.size; // Get total number of documents
        });
      }
    } catch (error) {
      debugPrint("Error fetching FIR count: $error");
    }
  }



  @override
  Widget build(BuildContext context) {
    // System UI settings
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Color(0xFF2A489E),
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Colors.white,
      systemNavigationBarIconBrightness: Brightness.dark,
    ));

    // Get current date and time
    DateTime now = DateTime.now();
    String formattedDateTime =
    DateFormat('EEEE, yyyy-MM-dd, hh:mm:ss a').format(now);

    Future<void> makeCall() async {
      final String phoneNumber = "15"; // Phone number to dial
      // Check if the device can make a call
      final Uri phoneUri = Uri(scheme: 'tel', path: phoneNumber);
      if (await canLaunch(phoneUri.toString())) {
        await launch(phoneUri.toString()); // Open the dialer with the number
      } else {
        throw 'Could not launch $phoneNumber';
      }
    }

    return Scaffold(
      extendBody: true,
      bottomNavigationBar: Theme(
        data: Theme.of(context).copyWith(
          iconTheme: IconThemeData(color: Colors.white),
        ),
        child: CurvedNavigationBar(
          key: navigationKey,
          buttonBackgroundColor: Colors.red,
          color: Colors.blue.shade900,
          backgroundColor: Colors.transparent,
          animationCurve: Curves.easeInOut,
          animationDuration: Duration(milliseconds: 300),
          height: 60,
          index: index, // Corrected here
          items: items,
          onTap: (index) => setState(() => this.index = index),
        ),
      ),
      body: index == 0
          ? SingleChildScrollView(
        child: Center(
          child: Column(
            children: [
// Header Container
              Container(
                width: 390,
                height: 500,
                decoration: const BoxDecoration(
                  color: Color(0xFF2A489E),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(30),
                    bottomRight: Radius.circular(30),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.only(top: 33.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      const SizedBox(
                        height: 20.0,
                      ),
                      Text(
                        formattedDateTime,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontFamily: 'Barlow',
                          fontWeight: FontWeight.w700,
                          height: 1.5,
                          letterSpacing: 0.60,
                        ),
                      ),
                      const SizedBox(height: 13),
                      Row(
                        children: [
                          const SizedBox(width: 15),
                          Container(
                            height: 40.0,
                            width: 230.0,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10.0),
                            decoration: BoxDecoration(
                              color: Colors.transparent,
                              borderRadius: BorderRadius.circular(30.0),
                              border: Border.all(
                                  color: Colors.white, width: 1.5),
                            ),
                            child: Row(
                              children: [
                                GestureDetector(
                                  onTap: () {
                                    debugPrint("Search icon tapped");
                                  },
                                  child: const Icon(
                                    Icons.search,
                                    color: Colors.white,
                                    size: 20.0,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: TextField(
                                    style: const TextStyle(
                                        color: Colors.white),
                                    cursorColor: Colors.white,
                                    decoration: const InputDecoration(
                                      hintText: 'Search',
                                      hintStyle: TextStyle(
                                          color: Colors.white60),
                                      border: InputBorder.none,
                                      contentPadding:
                                      EdgeInsets.symmetric(
                                          vertical: 10),
                                    ),
                                    onChanged: (value) {
                                      debugPrint("Search text: $value");
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(
                              width:
                              10), // Space between search box and bell icon
                          GestureDetector(
                            onTap: () {
                              debugPrint("Bell icon tapped");
                            },
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors
                                    .white12, // Slight background for better visibility
                              ),
                              child: const Icon(
                                Icons.notifications,
                                color: Colors.white,
                                size: 24.0,
                              ),
                            ),
                          ),
                          const SizedBox(
                              width:
                              10), // Space between bell icon and menu icon
                          GestureDetector(
                            onTap: () {
                              debugPrint("Menu icon tapped");
                            },
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white12,
                              ),
                              child: const Icon(
                                Icons.menu,
                                color: Colors.white,
                                size: 24.0,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
// Texts on the left
                          Padding(
                            padding: const EdgeInsets.only(left: 20.0),
                            child: Column(
                              crossAxisAlignment:
                              CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'ADMIN',
                                  textAlign: TextAlign.left,
                                  style: TextStyle(
                                    color: Color(0xFFE22128),
                                    fontSize: 10,
                                    fontFamily: 'Barlow',
                                    fontWeight: FontWeight.w700,
                                    height: 1.2,
                                    letterSpacing: 0.50,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  userName ?? 'Loading...',
                                  textAlign: TextAlign.left,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontFamily: 'Barlow',
                                    fontWeight: FontWeight.w900,
                                    height: 1.2,
                                    letterSpacing: 0.50,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  userCnic ?? 'Loading...',
                                  textAlign: TextAlign.left,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontFamily: 'Barlow',
                                    fontWeight: FontWeight.w700,
                                    height: 1.2,
                                    letterSpacing: 0.50,
                                  ),
                                ),
                              ],
                            ),
                          ),
// Evaluate Button
                          Padding(
                            padding: const EdgeInsets.only(right: 20.0),
                            child: SizedBox(
                              width: 100, // Adjust size
                              height: 100,
                              child: Stack(
                                fit: StackFit.expand,
                                children: [
                                  CircularProgressIndicator(
                                    value: totalFIRs / 100, // Normalize value (Assume max FIRs = 100)
                                    backgroundColor: Colors.white38,
                                    valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFE22128)),
                                    strokeWidth: 8, // Thickness
                                  ),
                                  Center(
                                    child: Text(
                                      '$totalFIRs', // Display total FIR count
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 20,
                                        fontWeight: FontWeight.w900,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 20.0,
                      ),
                      Container(
                        width: 390,
                        decoration: BoxDecoration(
                          border: Border.all(
                              width: 1, color: const Color(0xB53F5FBC)),
                        ),
                      ), //Line Separator
                      const SizedBox(
                        height: 12.0,
                      ),
                      const Align(
                        alignment: Alignment.centerLeft,
                        child: Padding(
                          padding: EdgeInsets.only(left: 15.0),
                          child: Text(
                            'COMPLAINT DETAILS',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontFamily: 'Barlow',
                              fontWeight: FontWeight.w600,
                              height: 1.2,
                              letterSpacing: 0.6,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12.0),
// FIR details with progress bars
                      Container(
                        width: 350,
                        height: 66,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Colors.white.withAlpha((0.4 * 255).toInt()),
                              Colors.white.withAlpha((0.1 * 255).toInt()),
                            ],
                          ),
                          border: Border.all(
                            color: Colors.white,
                            width: 1.5,
                          ),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x33000000),
                              blurRadius: 24,
                              offset: Offset(0, 4),
                              spreadRadius: -1,
                            ),
                          ],
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10.0, vertical: 10.0),
                          child: Row(
                            mainAxisAlignment:
                            MainAxisAlignment.spaceBetween,
                            children: [
                              _buildFIRDetail(
                                  "Total FIRs", 0.8, "111 FIRs"),
                              _buildFIRDetail(
                                  "Pending FIRs", 0.5, "11 FIRs"),
                              _buildFIRDetail(
                                  "Resolved FIRs", 0.3, "90 FIRs"),
                              _buildFIRDetail(
                                  "Rejected FIRs", 0.4, " 10FIRs"),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 20.0),
                      Container(
                        width: 390,
                        decoration: BoxDecoration(
                          border: Border.all(
                              width: 1, color: const Color(0xB53F5FBC)),
                        ),
                      ),
                      const SizedBox(height: 17.0), //Line Separator
                      Column(
                        children: [
                          ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                    const PreFIRTrackingScreen()),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                              const Color(0xFF2A489E), // Button color
                              shape: const RoundedRectangleBorder(
                                borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(5),
                                  topRight: Radius.circular(11),
                                  bottomLeft: Radius.circular(11),
                                  bottomRight: Radius.circular(5),
                                ),
                                side: BorderSide(
                                    color: Colors.white,
                                    width: 1), // Rounded corners
                              ),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 10),
                            ),
                            child: const Text(
                              "View Details",
                              style: TextStyle(
                                fontSize: 13,
                                fontFamily: 'Barlow',
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          const SizedBox(height: 15.0),
                          const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.location_on, // Location icon
                                color: Colors.white,
                                size: 12, // Adjust the size of the icon
                              ),
                              SizedBox(
                                  width:
                                  5), // Add spacing between icon and text
                              Text(
                                'Naval Colony, Baldia Karachi, Hub Road.',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontFamily: 'Barlow',
                                  fontWeight: FontWeight.w600,
                                  height: 1.0, // Adjust as per your needs
                                  letterSpacing: 0.50,
                                ),
                              ),
                            ],
                          )
                        ],
                      )
                    ],
                  ),
                ),
              ),
              const SizedBox(
                height: 20.0,
              ),
              Container(
                width: 340,
                height: 215,
                decoration: ShapeDecoration(
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                    side: const BorderSide(
                        width: 1, color: Color(0x802A489E)),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  shadows: const [
                    BoxShadow(
                      color: Color(0x111F3982),
                      blurRadius: 30,
                      offset: Offset(0, 8),
                      spreadRadius: 10,
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
// First row with 4 boxes
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
// Box 1
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const UsersManagementScreen(),
                                  ),
                                );
                              },
                              child: Container(
                                width: 59,
                                height: 59,
                                margin: const EdgeInsets.all(4),
                                decoration: ShapeDecoration(
                                  color: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    side: const BorderSide(width: 1, color: Color(0x802A489E)),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  shadows: const [
                                    BoxShadow(
                                      color: Color(0x111F3982),
                                      blurRadius: 60,
                                      offset: Offset(0, 8),
                                      spreadRadius: 60,
                                    ),
                                  ],
                                ),
                                child: Center(
                                  child: ShaderMask(
                                    shaderCallback: (bounds) => LinearGradient(
                                     colors: [Colors.red, Color(0x802A489E)], // Gradient colors
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ).createShader(bounds),
                                    child: const Icon(
                                      Icons.manage_accounts, // User Management Icon
                                      size: 30, // Adjusted size for better visibility
                                      color: Colors.white, // This must be white for ShaderMask to work
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const Text(
                              'Users \n Management',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Color(0xFF2A489E),
                                fontSize: 11,
                                fontFamily: 'Barlow',
                                fontWeight: FontWeight.w400,
                                letterSpacing: 0.55,
                              ),
                            ),
                          ],
                        ),
// Box 2
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const StaffManagmentScreen(),
                                  ),
                                );
                              },
                              child: Container(
                                width: 59,
                                height: 59,
                                margin: const EdgeInsets.all(4),
                                decoration: ShapeDecoration(
                                  color: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    side: const BorderSide(width: 1, color: Color(0x802A489E)),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  shadows: const [
                                    BoxShadow(
                                      color: Color(0x111F3982),
                                      blurRadius: 60,
                                      offset: Offset(0, 8),
                                      spreadRadius: 60,
                                    ),
                                  ],
                                ),
                                child: Center(
                                  child: ShaderMask(
                                    shaderCallback: (bounds) => LinearGradient(
                                     colors: [Colors.red, Color(0x802A489E)], // Gradient colors
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ).createShader(bounds),
                                    child: const Icon(
                                      Icons.group, // User Management Icon
                                      size: 30, // Adjusted size for better visibility
                                      color: Colors.white, // This must be white for ShaderMask to work
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const Text(
                              'Staff \n Management',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Color(0xFF2A489E),
                                fontSize: 11,
                                fontFamily: 'Barlow',
                                fontWeight: FontWeight.w400,
                                letterSpacing: 0.55,
                              ),
                            ),
                          ],
                        ),
// Box 3
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            GestureDetector(
                              onTap: () {
// Ensuring the navigation is correctly done
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                      const PrefirManagmentScreen()),
                                );
                              },
                              child: Container(
                                width: 59,
                                height: 59,
                                margin: const EdgeInsets.all(4),
                                decoration: ShapeDecoration(
                                  color: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    side: const BorderSide(
                                        width: 1,
                                        color: Color(0x802A489E)),
                                    borderRadius:
                                    BorderRadius.circular(10),
                                  ),
                                  shadows: const [
                                    BoxShadow(
                                      color: Color(0x111F3982),
                                      blurRadius: 30,
                                      offset: Offset(0, 8),
                                      spreadRadius: 10,
                                    ),
                                  ],
                                ),
                                child: Center(
                                  child: Image.asset(
                                    'icons/3.png', // Example image path, replace with your actual image path
                                    width: 30,
                                    height: 30,
                                  ),
                                ),
                              ),
                            ),
                            const Text(
                              'Track Your \n Compliants',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Color(0xFF2A489E),
                                fontSize: 11,
                                fontFamily: 'Barlow',
                                fontWeight: FontWeight.w400,
                                height: 0,
                                letterSpacing: 0.55,
                              ),
                            ),
                          ],
                        ),
// Box 4
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const CrimeStatisticsScreen(),
                                  ),
                                );
                              },
                              child: Container(
                                width: 59,
                                height: 59,
                                margin: const EdgeInsets.all(4),
                                decoration: ShapeDecoration(
                                  color: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    side: const BorderSide(width: 1, color: Color(0x802A489E)),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  shadows: const [
                                    BoxShadow(
                                      color: Color(0x111F3982),
                                      blurRadius: 60,
                                      offset: Offset(0, 8),
                                      spreadRadius: 60,
                                    ),
                                  ],
                                ),
                                child: Center(
                                    child: ShaderMask(
                                      shaderCallback: (bounds) => LinearGradient(
                                       colors: [Colors.red, Color(0x802A489E)], // Gradient colors
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                      ).createShader(bounds),
                                      child: const Icon(
                                        Icons.bar_chart, // User Management Icon
                                        size: 30, // Adjusted size for better visibility
                                        color: Colors.white, // This must be white for ShaderMask to work
                                      ),
                                    ),
                                ),
                              ),
                            ),
                            const Text(
                              'Crime \n Statisrics',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Color(0xFF2A489E),
                                fontSize: 11,
                                fontFamily: 'Barlow',
                                fontWeight: FontWeight.w400,
                                letterSpacing: 0.55,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 12.0),
// Second row with 4 boxes
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
// Box 5
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                      const MissingfoundpropertyScreen()),
                                );
                              },
                              child: Container(
                                width: 59,
                                height: 59,
                                margin: const EdgeInsets.all(4),
                                decoration: ShapeDecoration(
                                  color: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    side: const BorderSide(
                                        width: 1,
                                        color: Color(0x802A489E)),
                                    borderRadius:
                                    BorderRadius.circular(10),
                                  ),
                                  shadows: const [
                                    BoxShadow(
                                      color: Color(0x111F3982),
                                      blurRadius: 30,
                                      offset: Offset(0, 8),
                                      spreadRadius: 10,
                                    ),
                                  ],
                                ),
                                child: Center(
                                  child: ShaderMask(
                                    shaderCallback: (bounds) => LinearGradient(
                                      colors: [Colors.red, Color(0x802A489E)], // Gradient colors
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ).createShader(bounds),
                                    child: const Icon(
                                      Icons.inventory, // User Management Icon
                                      size: 30, // Adjusted size for better visibility
                                      color: Colors.white, // This must be white for ShaderMask to work
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const Text(
                              'Report Found',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Color(0xFF2A489E),
                                fontSize: 11,
                                fontFamily: 'Barlow',
                                fontWeight: FontWeight.w400,
                                height: 0,
                                letterSpacing: 0.55,
                              ),
                            )
                          ],
                        ),
// Box 6
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>  RedzoneScreen(),
                                  ),
                                );
                              },
                              child: Container(
                                width: 59,
                                height: 59,
                                margin: const EdgeInsets.all(4),
                                decoration: ShapeDecoration(
                                  color: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    side: const BorderSide(width: 1, color: Color(0x802A489E)),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  shadows: const [
                                    BoxShadow(
                                      color: Color(0x111F3982),
                                      blurRadius: 60,
                                      offset: Offset(0, 8),
                                      spreadRadius: 60,
                                    ),
                                  ],
                                ),
                                child: Center(
                                  child: ShaderMask(
                                    shaderCallback: (Rect bounds) {
                                      return LinearGradient(
                                        colors: [Color(0x802A489E), Color(0xFFE22128)], // Gradient colors
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                      ).createShader(bounds);
                                    },
                                    child: Icon(
                                      Icons.shield, // User Management Icon
                                      size: 30, // Adjusted size for better visibility
                                      color: Colors.white, // Keep white so ShaderMask applies the gradient
                                    ),
                                  ),

                                ),
                              ),
                            ),
                            const Text(
                              'Red Zone',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Color(0xFF2A489E),
                                fontSize: 11,
                                fontFamily: 'Barlow',
                                fontWeight: FontWeight.w400,
                                letterSpacing: 0.55,
                              ),
                            ),
                          ],
                        ),
// Box 7
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                      const CrimeReportScreen()),
                                );
                              },
                              child: Container(
                                width: 59,
                                height: 59,
                                margin: const EdgeInsets.all(4),
                                decoration: ShapeDecoration(
                                  color: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    side: const BorderSide(
                                        width: 1,
                                        color: Color(0x802A489E)),
                                    borderRadius:
                                    BorderRadius.circular(10),
                                  ),
                                  shadows: const [
                                    BoxShadow(
                                      color: Color(0x111F3982),
                                      blurRadius: 30,
                                      offset: Offset(0, 8),
                                      spreadRadius: 10,
                                    ),
                                  ],
                                ),
                                child: Center(
                                  child: Image.asset(
                                    'icons/7.png', // Example image path, replace with your actual image path
                                    width: 28,
                                    height: 28,
                                  ),
                                ),
                              ),
                            ),
                            const Text(
                              'Stations FInder',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Color(0xFF2A489E),
                                fontSize: 11,
                                fontFamily: 'Barlow',
                                fontWeight: FontWeight.w400,
                                height: 0,
                                letterSpacing: 0.55,
                              ),
                            )
                          ],
                        ),
// Box 8
                        Column(
                            mainAxisSize: MainAxisSize.min, children: [
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                    const JobWebScreen()),
                              );
                            },
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 59,
                                  height: 59,
                                  margin: const EdgeInsets.all(4),
                                  decoration: ShapeDecoration(
                                    color: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      side: const BorderSide(
                                          width: 1,
                                          color: Color(0x802A489E)),
                                      borderRadius:
                                      BorderRadius.circular(10),
                                    ),
                                    shadows: const [
                                      BoxShadow(
                                        color: Color(0x111F3982),
                                        blurRadius: 30,
                                        offset: Offset(0, 8),
                                        spreadRadius: 10,
                                      ),
                                    ],
                                  ),
                                  child: Center(
                                    child: Image.asset(
                                      'icons/8.png',
                                      width: 28,
                                      height: 28,
                                    ),
                                  ),
                                ),
                                const Text(
                                  'Job Portal',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: Color(0xFF2A489E),
                                    fontSize: 11,
                                    fontFamily: 'Barlow',
                                    fontWeight: FontWeight.w400,
                                    height: 0,
                                    letterSpacing: 0.55,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ]),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(
                height: 20.0,
              ),
              Container(
                width: 340,
                height: 35,
                decoration: ShapeDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment(1.00, 0.00),
                    end: Alignment(-1, 0),
                    colors: [Color(0xFFE22128), Color(0xFF2A489E)],
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  shadows: const [
                    BoxShadow(
                      color: Color(0x3F000000),
                      blurRadius: 4,
                      offset: Offset(2, 4),
                      spreadRadius: 0,
                    ),
                  ],
                ),
                child: const Center(
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          'UPCOMING EVENTS',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontFamily: 'Barlow',
                            fontWeight: FontWeight.w700,
                            height: 1,
                            letterSpacing: 0.60,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      )
          : screens[index],
      floatingActionButton: FloatingActionButton(
        onPressed: () => signOut(context),
        child: const Icon(Icons.login_rounded),
      ),
    );
  }

  Widget _buildFIRDetail(String label, double progress, String status) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 11,
            fontFamily: 'Barlow',
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 4),
        // Progress bar
        SizedBox(
          width: 62, // Adjusted width for a smaller progress bar
          child: LinearProgressIndicator(
            value: progress,
            backgroundColor: Colors.white.withAlpha((0.2 * 255).toInt()),
            valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFE22128)),
            minHeight: 3.0, // Reduced height for a thinner progress bar
          ),
        ),
        const SizedBox(height: 4),
        Text(
          // textAlign: TextAlign.center,
          status,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 10,
            fontFamily: 'Barlow',
            fontWeight: FontWeight.w700,
            letterSpacing: 0.3,
          ),
        ),
      ],
    );
  }


}
