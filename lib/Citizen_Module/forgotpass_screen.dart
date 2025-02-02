import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fyp_v2/Citizen_Module/login_screen.dart';



class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  void sendPasswordResetEmail() async {
    try {
      // Send password reset link to the email entered by the user
      await FirebaseAuth.instance.sendPasswordResetEmail(
        email: _emailController.text.trim(),
      );
      showSuccessDialog();
    } on FirebaseAuthException catch (e) {
      showErrorDialog(e.message ?? "An error occurred");
    }
  }

  // Success Dialog using Flutter's AlertDialog
  void showSuccessDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Check Your Email"),
          content: const Text("A password reset link has been sent to your email."),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const LoginScreen(),
                  ),
                );
              },
              child: const Text("OK"),
            ),
          ],
        );
      },
    );
  }

  // Error Dialog using Flutter's AlertDialog
  void showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Error"),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text("OK"),
            ),
          ],
        );
      },
    );
  }

  static const TextStyle textStyle = TextStyle(
    fontFamily: 'Barlow',
    fontSize: 16.0,
    fontWeight: FontWeight.bold,
    letterSpacing: 1,
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: const Color(0xFF2A489E),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(top: 100.0),
          child: Column(
            children: [
              const CircleAvatar(
                radius: 65.0,
                backgroundImage: AssetImage('images/Police.png'),
              ),
              const SizedBox(height: 10.0),
              Text(
                'FORGOT PASSWORD',
                style: textStyle.copyWith(fontSize: 17.0, color: Colors.white),
              ),
              const SizedBox(height: 50.0),
              Expanded(
                child: SingleChildScrollView(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(30),
                    ),
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      children: [
                        const SizedBox(height: 10.0),
                        const Text(
                          'Details For OTP Verification',
                          style: TextStyle(
                            color: Colors.red,
                            fontSize: 16.0,
                            letterSpacing: 1.0,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const Text(
                          'Enter National Id No & Mobile Number \n To Send One Time Password',
                          style: TextStyle(
                            color: Color(0xFF2A489E),
                            fontSize: 13.0,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 20.0),
                        buildTextField(
                          controller: _emailController,
                          labelText: 'Enter your Email',
                          obscureText: false,
                        ),
                        buildTextField(
                          controller: _phoneController,
                          labelText: 'Enter your phone',
                          obscureText: false,
                        ),
                        const SizedBox(height: 5.0),
                        SizedBox(
                          width: 245.0,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              foregroundColor: Colors.white,
                              backgroundColor: Colors.red,
                            ),
                            onPressed: sendPasswordResetEmail, // Call the function
                            child: const Text('Get Password Reset Link'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // TextField Widget for Email and Phone
  Widget buildTextField({
    required TextEditingController controller,
    required String labelText,
    bool obscureText = false,
  }) {
    final iconMap = {
      'Enter your CNIC': Icons.credit_card,
      'Enter your phone': Icons.phone,
    };

    final prefixIcon = iconMap[labelText] ?? Icons.lock;

    return Padding(
      padding: const EdgeInsets.only(bottom: 15.0),
      child: TextFormField(
        controller: controller,
        obscureText: obscureText,
        style: const TextStyle(
          color: Color(0xFF203982), // Set the text color to blue
        ),
        decoration: InputDecoration(
          border: const OutlineInputBorder(),
          labelText: labelText,
          labelStyle: const TextStyle(
            fontSize: 15.0,
            color: Color(0xFF203982),
          ),
          contentPadding: const EdgeInsets.symmetric(
            vertical: 8.0,
            horizontal: 10.0,
          ),
          focusedBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: Color(0xFF203982), width: 1.5),
          ),
          enabledBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: Color(0xFF203982), width: 1.0),
          ),
          prefixIcon: ShaderMask(
            shaderCallback: (Rect bounds) {
              return const LinearGradient(
                colors: [Color(0xFF203982), Colors.red], // Gradient colors
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ).createShader(bounds);
            },
            child: Icon(
              prefixIcon,
              color: Colors.white, // White icon color will show the gradient
              size: 19.5,
            ),
          ),
        ),
      ),
    );
  }
}