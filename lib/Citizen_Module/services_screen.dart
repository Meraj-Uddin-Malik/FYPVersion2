import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ServicesScreen extends StatelessWidget {
  const ServicesScreen({super.key});

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
                      text: 'OUR',
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
                      text: 'SERVICES',
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
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                    ),
                  ),
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      child: Column(
                        children: [
                          ServiceCard(
                            icon: Icons.gavel,
                            title: 'Pre-FIR Against Crime',
                            description: 'Quickly file a Pre-FIR to report a crime.',
                            onTap: () {
                              Navigator.pushNamed(context, '/pre_fir');
                            },
                          ),
                          ServiceCard(
                            icon: Icons.report,
                            title: 'Complaint Against Police',
                            description: 'Report police misconduct or unfair treatment.',
                            onTap: () {
                              Navigator.pushNamed(context, '/complaint_police');
                            },
                          ),
                          ServiceCard(
                            icon: Icons.track_changes,
                            title: 'Track Your Complaints',
                            description: 'Check real-time updates on your complaints.',
                            onTap: () {
                              Navigator.pushNamed(context, '/track_complaint');
                            },
                          ),
                          ServiceCard(
                            icon: Icons.verified_user,
                            title: 'Complaint to IGP',
                            description: 'Directly file a complaint to the IGP of Police.',
                            onTap: () {
                              Navigator.pushNamed(context, '/complaint_igp');
                            },
                          ),
                          ServiceCard(
                            icon: Icons.search,
                            title: 'Lost & Found Complaints',
                            description: 'Report lost or found items for quick recovery.',
                            onTap: () {
                              Navigator.pushNamed(context, '/lost_found');
                            },
                          ),
                          ServiceCard(
                            icon: Icons.work,
                            title: 'Jobs Portal',
                            description: 'Find and apply for police department jobs.',
                            onTap: () {
                              Navigator.pushNamed(context, '/jobs_portal');
                            },
                          ),
                          ServiceCard(
                            icon: Icons.map,
                            title: 'Station Finder',
                            description: 'Locate the nearest police station easily.',
                            onTap: () {
                              Navigator.pushNamed(context, '/station_finder');
                            },
                          ),
                          ServiceCard(
                            icon: Icons.security,
                            title: 'Safety Tips',
                            description: 'Get expert safety tips and crime prevention advice.',
                            onTap: () {
                              Navigator.pushNamed(context, '/safety_tips');
                            },
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
}

class ServiceCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final VoidCallback onTap;

  const ServiceCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: 315,
        child: Card(
          elevation: 6,
          margin: EdgeInsets.only(bottom: 10),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(15),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                gradient: LinearGradient(
                  colors: [Colors.white, Colors.white],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: ListTile(
                contentPadding: EdgeInsets.symmetric(horizontal: 13, vertical: 5),

                // Leading Icon with Gradient Effect
                leading: ShaderMask(
                  shaderCallback: (Rect bounds) {
                    return LinearGradient(
                      colors: [Color(0xFF2A489E), Colors.red],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ).createShader(bounds);
                  },
                  child: Icon(icon, size: 25, color: Colors.white),
                ),

                title: Text(
                  title,
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                ),

                subtitle: Text(
                  description,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 12),
                ),

                // Trailing Icon with Gradient Effect
                trailing: ShaderMask(
                  shaderCallback: (Rect bounds) {
                    return LinearGradient(
                      colors: [Colors.purple, Colors.deepOrange],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ).createShader(bounds);
                  },
                  child: Icon(Icons.arrow_forward_ios, size: 17, color: Colors.white),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

}
