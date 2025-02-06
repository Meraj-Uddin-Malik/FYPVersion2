import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

class ScanningPage extends StatefulWidget {
  @override
  _ScanningPageState createState() => _ScanningPageState();
}

class _ScanningPageState extends State<ScanningPage> with TickerProviderStateMixin {
  String _name = "John Doe";
  String _cnic = "12345-6789012-3";
  String _phone = "0300-2354323";
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
      duration: Duration(seconds: 2),
      vsync: this,
    );
    _circleAnimation = Tween<double>(begin: 0.0, end: 80.0).animate(
      CurvedAnimation(parent: _circleController, curve: Curves.easeOut),
    );
    _circleController.repeat(reverse: true);

    // Text Fade In/Out Animation
    _textController = AnimationController(
      duration: Duration(seconds: 1),
      vsync: this,
    )..repeat(reverse: true);
    _textAnimation = Tween<double>(begin: 0.3, end: 1.0).animate(_textController);

    _fetchDetails();
  }

  @override
  void dispose() {
    _circleController.dispose();
    _textController.dispose();
    super.dispose();
  }

  Future<void> _fetchDetails() async {
    try {
      await Future.delayed(Duration(seconds: 2));

      setState(() {
        _revealStep = 1; // Reveal Name
      });
      await Future.delayed(Duration(seconds: 1));

      setState(() {
        _revealStep = 2; // Reveal CNIC
      });
      await Future.delayed(Duration(seconds: 1));

      setState(() {
        _revealStep = 3; // Reveal Phone Number
      });
      await Future.delayed(Duration(seconds: 1));

      // Fetch current location
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() {
          _location = "Location services are disabled";
        });
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          setState(() {
            _location = "Location permission denied";
          });
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        setState(() {
          _location = "Location permissions are permanently denied";
        });
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
        _revealStep = 4; // Reveal Location
      });
    } catch (e) {
      setState(() {
        _location = "Failed to get location: $e";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Scanning..."),
      ),
      body: Center( // Center widget to keep all content in the center
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              // Animated scanning effect
              Container(
                width: 200,
                height: 200,
                alignment: Alignment.center,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    AnimatedBuilder(
                      animation: _circleController,
                      builder: (context, child) {
                        return Container(
                          width: _circleAnimation.value * 2,
                          height: _circleAnimation.value * 2,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.red.withOpacity(0.3),
                          ),
                        );
                      },
                    ),
                    AnimatedBuilder(
                      animation: _circleController,
                      builder: (context, child) {
                        return Container(
                          width: _circleAnimation.value * 1.5,
                          height: _circleAnimation.value * 1.5,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.red.withOpacity(0.5),
                          ),
                        );
                      },
                    ),
                    AnimatedBuilder(
                      animation: _circleController,
                      builder: (context, child) {
                        return Container(
                          width: _circleAnimation.value,
                          height: _circleAnimation.value,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.red.withOpacity(0.7),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
              SizedBox(height: 10),

              // Scanning text with fade-in/out effect
              FadeTransition(
                opacity: _textAnimation,
                child: Text(
                  "SCANNING",
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                ),
              ),
              SizedBox(height: 10),

              // Gradually revealing information
              if (_revealStep >= 1) Text("Name: $_name"),
              if (_revealStep >= 2) Text("CNIC: $_cnic"),
              if (_revealStep >= 3) Text("Phone: $_phone"),
              if (_revealStep >= 4) Text("Location: $_location"),
            ],
          ),
        ),
      ),
    );
  }
}
