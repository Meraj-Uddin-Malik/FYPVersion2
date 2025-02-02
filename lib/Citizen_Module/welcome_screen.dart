import 'package:flutter/material.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  static const TextStyle welcomeTextStyle = TextStyle(
    fontFamily: 'Barlow',
    fontSize: 16.0,
    fontWeight: FontWeight.bold,
    color: Colors.white,
    letterSpacing: 1,
  );

  static const TextStyle sindhPoliceTextStyle = TextStyle(
    fontFamily: 'Barlow',
    fontSize: 16.0,
    fontWeight: FontWeight.bold,
    color: Color(0xFFE22128),
    letterSpacing: 1,
  );

  static const TextStyle headingTextStyle = TextStyle(
    fontFamily: 'Barlow',
    fontSize: 24.0,
    fontWeight: FontWeight.bold,
    color: Color(0xFF2A489E),
    letterSpacing: 3,
  );

  static const TextStyle subHeadingTextStyle = TextStyle(
    fontFamily: 'Barlow',
    fontSize: 10.0,
    fontWeight: FontWeight.bold,
    color: Color(0xFF2A489E),
    letterSpacing: 1,
  );

  static const TextStyle evaluateButtonTextStyle = TextStyle(
    fontFamily: 'Barlow',
    fontWeight: FontWeight.w800,
    letterSpacing: 1,
  );

  static const Color backgroundColor = Color(0xFF2A489E);
  static const Color containerColor = Colors.white;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: backgroundColor,
        body: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [

              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const CircleAvatar(
                      radius: 65.0,
                      backgroundImage: AssetImage('images/Police.png'),
                    ),
                    const SizedBox(height: 20.0),
                    RichText(
                      text: const TextSpan(children: [
                        TextSpan(text: 'WELCOME TO ', style: welcomeTextStyle),
                        TextSpan(text: 'SINDH POLICE ', style: sindhPoliceTextStyle),
                      ]),
                    ),
                    const SizedBox(height: 5),
                    const Text(
                      'PRE FIR COMPLAINT SYSTEM',
                      style: TextStyle(
                        color: Colors.white,
                        fontFamily: 'Barlow',
                        fontSize: 12.0,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ],
                ),
              ),

              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: containerColor,
                    borderRadius: const BorderRadius.only(
                      topRight: Radius.circular(50.0),
                      topLeft: Radius.circular(50.0),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black,
                        spreadRadius: 4,
                        blurRadius: 3,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 30.0),
                        const Text('Let’s', style: headingTextStyle),
                        const Text('get started', style: headingTextStyle),
                        const SizedBox(height: 4.0),
                        const Text(
                          'EVERYTHING START FROM HERE',
                          style: subHeadingTextStyle,
                        ),
                        const SizedBox(height: 89.0),
                        Center(
                          child: Column(
                            children: [
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  foregroundColor: Colors.white,
                                  backgroundColor: const Color(0xFF2A489E),
                                ),
                                onPressed: () {
                                  Navigator.pushNamed(context, '/login_screen');
                                },
                                child: const SizedBox(
                                  width: 250.0,
                                  child: Center(child: Text('LogIn', style: evaluateButtonTextStyle,)),
                                ),
                              ),
                              const SizedBox(height: 3),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  foregroundColor: Colors.white,
                                  backgroundColor: Colors.red,
                                ),
                                onPressed: () {
                                  Navigator.pushNamed(context, '/signup_screen');
                                },
                                child: const SizedBox(
                                  width: 250.0,
                                  child: Center(child: Text('Sign Up', style: evaluateButtonTextStyle)),
                                ),
                              ),
                            ],
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
}
