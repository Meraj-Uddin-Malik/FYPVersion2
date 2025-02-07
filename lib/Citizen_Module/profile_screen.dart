import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class UserProfileScreen extends StatefulWidget {
  @override
  _UserProfileScreen createState() => _UserProfileScreen();
}

class _UserProfileScreen extends State<UserProfileScreen> {

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
              const Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: 'User',
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
                      text: 'Profile',
                      style: TextStyle(
                        color: Colors.red,
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
                          // Profile Picture (Avatar Image)
                          CircleAvatar(
                            radius: 50,
                            backgroundImage: AssetImage("images/user.png"), // Replace with your avatar image path
                          ),
                          SizedBox(height: 10),

                          // Name and Email
                          Text(
                            "Meraj Uddin",
                            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                          ),
                          Text(
                            "meraj@example.com",
                            style: TextStyle(fontSize: 16, color: Colors.grey),
                          ),
                          SizedBox(height: 20),

                          // Profile Options (ListTile Cards)
                          _buildProfileCard(
                            icon: Icons.phone,
                            title: "Phone",
                            description: "+92 300 1234567",
                            onTap: () {
                              // Navigate to Phone Settings or Edit
                            },
                          ),
                          SizedBox(height: 10),
                          _buildProfileCard(
                            icon: Icons.edit,
                            title: "Edit Profile",
                            description: "Update your personal info",
                            onTap: () {
                              // Navigate to Edit Profile Screen
                            },
                          ),
                          SizedBox(height: 10),
                          _buildProfileCard(
                            icon: Icons.settings,
                            title: "Settings",
                            description: "Manage your preferences",
                            onTap: () {
                              // Navigate to Settings Screen
                            },
                          ),
                          SizedBox(height: 10),
                          _buildProfileCard(
                            icon: Icons.logout,
                            title: "Logout",
                            description: "Sign out from your account",
                            onTap: () {
                              // Handle Logout
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

  Widget _buildProfileCard({
    required IconData icon,
    required String title,
    required String description,
    required VoidCallback onTap,
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
              // Gradient Icon
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
                  color: Colors.white, // Color for the icon after applying gradient
                  size: 22,
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
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF2A489E),
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      description,
                      style: TextStyle(
                        fontSize: 13,
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
