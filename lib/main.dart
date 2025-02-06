import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:fyp_v2/Admin_Module/prefir_managment_screen.dart';
import 'package:fyp_v2/Citizen_Module/complaint_agianst_police_screen.dart';
import 'package:fyp_v2/Citizen_Module/fir_tracking_screen.dart';
import 'package:fyp_v2/Citizen_Module/forgotpass_screen.dart';
import 'package:fyp_v2/Citizen_Module/missingfoundreport_screen.dart';
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
      home: MissingfoundreportScreen(),
      // initialRoute: '/',  // Initial route set to SplashScreen
      // routes: {
      //   '/': (context) => const Splashscreen(),
      //   '/welcome_screen': (context) => const WelcomeScreen(),
      //   '/login_screen': (context) => const LoginScreen(),
      //   '/signup_screen': (context) => const SignUpScreen(),
      //   '/main_screen': (context) =>  const MainScreen(),
      //   '/forgotpass_screen': (context) =>  const ForgotPasswordScreen(),
      //   '/fir_tracking_screen': (context) =>  const PreFIRTrackingScreen(),
      //   '/fir_view_screen': (context) =>  const PreFIRTrackingScreen(),
      // },
    );
  }
}
