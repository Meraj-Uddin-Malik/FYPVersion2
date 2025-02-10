import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class SaftytipsScreen extends StatelessWidget {
  const SaftytipsScreen({super.key});

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
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const SizedBox(height: 22.0),
              const CircleAvatar(
                radius: 65.0,
                backgroundImage: AssetImage('images/Police.png'),
              ),
              const SizedBox(height: 14.0),
              const Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: 'SAFTY ',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontFamily: 'Barlow',
                        fontWeight: FontWeight.w700,
                        height: 0,
                        letterSpacing: 3.36,
                      ),
                    ),
                    TextSpan(
                      text: 'TIPS',
                      style: TextStyle(
                        color: Color(0xFFE22128),
                        fontSize: 16,
                        fontFamily: 'Barlow',
                        fontWeight: FontWeight.w700,
                        height: 0,
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
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                  ),
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      child: Column(
                        children: [
                          // Header Text
                          const SizedBox(height: 20),
                          Text(
                            'FOLLOW THIS TIP & KEEP YOURSELF SAFE',
                            style: TextStyle(
                              fontSize: 12,
                              fontFamily: 'Barlow',
                              fontWeight: FontWeight.w600,
                              height: 0,
                              foreground: Paint()
                                ..shader = const LinearGradient(
                                  colors: [Color(0xFF203982), Colors.pink], // Gradient colors
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ).createShader(Rect.fromLTWH(0, 0, 200, 70)), // Defines the text size for gradient application
                            ),
                          ),

                          const SizedBox(height: 20),

                          // Safety Tip Cards
                          _buildSafetyTipCard(
                            icon: Icons.lock,
                            title: 'Home Security Tip',
                            description:
                                'Lock your doors and windows before leaving your house. It prevents easy access for burglars.',
                          ),
                          const SizedBox(height: 10),
                          _buildSafetyTipCard(
                            icon: Icons.phone,
                            title: 'Emergency Contact',
                            description:
                                'Save emergency numbers for quick access. In emergencies, every second counts.',
                          ),
                          const SizedBox(height: 10),
                          _buildSafetyTipCard(
                            icon: Icons.healing,
                            title: 'First Aid',
                            description:
                                'Know basic first aid in case of accidents. It can save lives until help arrives.',
                          ),
                          const SizedBox(height: 10),
                          _buildSafetyTipCard(
                            icon: Icons.security,
                            title: 'Personal Safety',
                            description:
                                'Always be aware of your surroundings when walking alone. Avoid distractions and stay alert.',
                          ),
                          const SizedBox(height: 10),
                          _buildSafetyTipCard(
                            icon: Icons.local_fire_department,
                            title: 'Fire Safety',
                            description:
                                'Have a fire extinguisher accessible in your home. Learn how to use it in case of fire emergencies.',
                          ),
                          const SizedBox(height: 10),

                          // Additional Safety Tips
                          _buildSafetyTipCard(
                            icon: Icons.directions_walk,
                            title: 'Walking Safety',
                            description:
                                'Walk in well-lit areas, especially at night. Avoid shortcuts through isolated areas.',
                          ),
                          const SizedBox(height: 10),
                          _buildSafetyTipCard(
                            icon: Icons.car_repair,
                            title: 'Car Safety',
                            description:
                                'Keep your car doors locked at all times and avoid leaving valuables in plain sight.',
                          ),
                          const SizedBox(height: 10),
                          _buildSafetyTipCard(
                            icon: Icons.email,
                            title: 'Online Privacy',
                            description:
                                'Don\'t share personal details on unknown websites. Protect your data from identity theft.',
                          ),
                          const SizedBox(height: 10),
                          _buildSafetyTipCard(
                            icon: Icons.ac_unit,
                            title: 'Weather Preparedness',
                            description:
                                'Stay informed about weather conditions, especially during storms. Prepare emergency kits for severe weather.',
                          ),
                          const SizedBox(height: 10),
                          _buildSafetyTipCard(
                            icon: Icons.hotel,
                            title: 'Hotel Safety',
                            description:
                                'Ensure your hotel room door is fully locked. Use the hotel safe for storing valuables.',
                          ),
                          const SizedBox(height: 10),
                          _buildSafetyTipCard(
                            icon: Icons.live_tv,
                            title: 'Internet Safety',
                            description:
                                'Use strong passwords and enable two-factor authentication for online accounts.',
                          ),
                          const SizedBox(height: 10),
                          _buildSafetyTipCard(
                            icon: Icons.assignment_ind,
                            title: 'Identity Protection',
                            description:
                                'Shred sensitive documents and be cautious of phishing scams that try to steal your personal information.',
                          ),
                          const SizedBox(height: 10),
                          _buildSafetyTipCard(
                            icon: Icons.people,
                            title: 'Group Safety',
                            description:
                                'When out in public, travel in groups. It’s safer and ensures there’s someone to help in emergencies.',
                          ),
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

  // Helper method to build a safety tip card
  Widget _buildSafetyTipCard({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return SizedBox(
      width: 340.0, // Set your desired width here
      child: Card(
        color: Colors.white,
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Row(
            children: [
              ShaderMask(
                shaderCallback: (Rect bounds) {
                  return const LinearGradient(
                    colors: [Color(0xFF203982), Colors.pink], // Gradient colors
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ).createShader(bounds);
                },
                child: Icon(
                  icon,
                  color: Colors
                      .white, // Color for the icon after applying gradient
                  size: 20,
                ),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF2A489E),
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      description,
                      style: TextStyle(
                        fontSize: 12,
                        color: Color(0xFF2A489E).withAlpha((0.7 * 255).toInt()),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
