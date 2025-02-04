import 'package:firebase_core/firebase_core.dart';
import 'package:fyp_v2/Citizen_Module/crime_report_screen.dart';
import 'package:flutter/material.dart';

import 'Citizen_Module/login_screen.dart';
import 'Citizen_Module/main_screen.dart';
import 'Citizen_Module/signup_screen.dart';
import 'Citizen_Module/splash_screen.dart';
import 'Citizen_Module/welcome_screen.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});


  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: CrimeReportScreen(),
      // initialRoute: '/',  // Initial route set to SplashScreen
      // routes: {
      //   '/': (context) => const Splashscreen(),
      //   '/welcome_screen': (context) => const WelcomeScreen(),
      //   '/login_screen': (context) => const LoginScreen(),
      //   '/signup_screen': (context) => const SignUpScreen(),
      //   '/main_screen': (context) =>  const MainScreen(),
      // },
    );
  }
}
