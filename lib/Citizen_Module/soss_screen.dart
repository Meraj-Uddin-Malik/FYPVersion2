import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/services.dart';

class SossScreen extends StatefulWidget {
  const SossScreen({super.key});

  @override
  State<SossScreen> createState() => _SossScreenState();
}

class _SossScreenState extends State<SossScreen> with TickerProviderStateMixin {
  String _name = "Loading...";
  String _cnic = "Loading...";
  String _phone = "Loading...";
  String _location = "Fetching location...";
  int _revealStep = 0;

  late AnimationController _circleController;
  late Animation<double> _circleAnimation;
  late AnimationController _textController;
  late Animation<double> _textAnimation;

  @override
  void initState() {
    super.initState();

    // Circle Animation
    _circleController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    _circleAnimation = Tween<double>(begin: 0.0, end: 80.0).animate(
      CurvedAnimation(parent: _circleController, curve: Curves.easeOut),
    );

    // Text Fade In/Out Animation
    _textController = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    )..repeat(reverse: true);

    _textAnimation = Tween<double>(begin: 0.3, end: 1.0).animate(_textController);

    _fetchDetails(); // Fetch user details on load
  }

  @override
  void dispose() {
    _circleController.dispose();
    _textController.dispose();
    super.dispose();
  }

  Future<void> _fetchDetails() async {
    try {
      // Get user data from Firebase
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        print('User logged in: ${user.email}'); // Debugging: Check if user is logged in

        DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();

        if (userDoc.exists) {
          print('User data found: ${userDoc.data()}'); // Debugging: Check data fetched

          setState(() {
            _name = userDoc['username'] ?? 'No username';
            _cnic = userDoc['cnic'] ?? 'No CNIC';
            _phone = userDoc['phone'] ?? 'No phone number';
          });
        } else {
          setState(() {
            _name = 'No user data found';
            _cnic = 'No user data found';
            _phone = 'No user data found';
          });
        }
      } else {
        setState(() {
          _name = 'User not logged in';
        });
      }

      await Future.delayed(const Duration(seconds: 2));

      setState(() => _revealStep = 1);
      await Future.delayed(const Duration(seconds: 1));

      setState(() => _revealStep = 2);
      await Future.delayed(const Duration(seconds: 1));

      setState(() => _revealStep = 3);
      await Future.delayed(const Duration(seconds: 1));

      // Fetch current location
      await _fetchLocation();

      setState(() => _revealStep = 4); // Reveal Location
    } catch (e) {
      setState(() => _location = "Failed to get location: $e");
      print("Error fetching details: $e"); // Debugging: Check errors
    }
  }

  Future<void> _fetchLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      setState(() => _location = "Location services are disabled");
      return;
    }

    PermissionStatus permission = await Permission.location.request();

    if (permission.isDenied) {
      setState(() => _location = "Location permission denied");
      return;
    } else if (permission.isPermanentlyDenied) {
      setState(() {
        _location = "Location permission permanently denied. Enable from settings.";
      });
      openAppSettings(); // Open settings page
      return;
    }

    Position position = await Geolocator.getCurrentPosition();
    List<Placemark> placemarks = await placemarkFromCoordinates(
      position.latitude,
      position.longitude,
    );

    Placemark place = placemarks[0];

    setState(() {
      _location = "${place.street}, ${place.subLocality}, ${place.locality}, ${place.administrativeArea}, ${place.country}";
    });
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Color(0xFF2A489E),
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Colors.white,
      systemNavigationBarIconBrightness: Brightness.dark,
    ));

    return Scaffold(
      backgroundColor: const Color(0xFF2A489E),
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 22.0),
              const CircleAvatar(
                  radius: 65.0,
                  backgroundImage: AssetImage('images/Police.png')),
              const SizedBox(height: 14.0),
              const Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: 'SOS ',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontFamily: 'Barlow',
                        fontWeight: FontWeight.w700,
                        letterSpacing: 3.36,
                      ),
                    ),
                    TextSpan(
                      text: 'DETAILS',
                      style: TextStyle(
                        color: Color(0xFFE22128),
                        fontSize: 16,
                        fontFamily: 'Barlow',
                        fontWeight: FontWeight.w700,
                        letterSpacing: 3.36,
                      ),
                    ),
                  ],
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 30.0),
              Expanded(
                child: Container(
                  width: 390,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(60),
                      topRight: Radius.circular(60),
                    ),
                  ),
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Container(
                            width: 200,
                            height: 200,
                            alignment: Alignment.center,
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                for (double opacity in [0.3, 0.5, 0.7])
                                  AnimatedBuilder(
                                    animation: _circleController,
                                    builder: (context, child) {
                                      return Container(
                                        width: _circleAnimation.value * (opacity * 2),
                                        height: _circleAnimation.value * (opacity * 2),
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: Colors.red.withOpacity(opacity),
                                        ),
                                      );
                                    },
                                  ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 10),
                          FadeTransition(
                            opacity: _textAnimation,
                            child: const Text(
                              "SCANNING",
                              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                            ),
                          ),
                          const SizedBox(height: 10),
                          if (_revealStep >= 1) Text("Name: $_name"),
                          if (_revealStep >= 2) Text("CNIC: $_cnic"),
                          if (_revealStep >= 3) Text("Phone: $_phone"),
                          if (_revealStep >= 4) Text("Location: $_location"),
                        ],
                      ),
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
