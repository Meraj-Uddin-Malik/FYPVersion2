import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';

class UserDetailScreen extends StatefulWidget {
  final Map<String, dynamic> user;
  final String userId;

  const UserDetailScreen({Key? key, required this.user, required this.userId})
      : super(key: key);

  @override
  _UserDetailScreenState createState() => _UserDetailScreenState();
}

class _UserDetailScreenState extends State<UserDetailScreen> {
  bool isRestricting = false;
  bool isDeleting = false;
  bool isRestricted = false;

  @override
  void initState() {
    super.initState();
    isRestricted = widget.user['isRestricted'] ?? false;
  }

  void toggleRestriction() async {
    setState(() => isRestricting = true);

    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.userId)
          .update({
        'isRestricted': !isRestricted,
      });

      setState(() {
        isRestricted = !isRestricted;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(isRestricted
                ? "User has been restricted!"
                : "User has been unrestricted!")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to update restriction: $e")),
      );
    }

    setState(() => isRestricting = false);
  }

  void deleteUser() async {
    setState(() => isDeleting = true);

    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.userId)
          .delete();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("${widget.user['username']} has been deleted!")),
      );

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to delete user: $e")),
      );
    }

    setState(() => isDeleting = false);
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
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const SizedBox(height: 30.0),
              const Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: 'USER ',
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
                      text: 'DETAILS',
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
                  ),
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 0),
                      child: Column(
                        children: [
                          // Profile Header
                          Container(
                            padding: const EdgeInsets.all(20),
                            width: double.infinity,
                            decoration: const BoxDecoration(
                              gradient: LinearGradient(
                                  colors: [Color(0xFF2A489E), Color(0xFF2A489E)]),
                              borderRadius: BorderRadius.vertical(
                                  bottom: Radius.circular(30)),
                            ),
                            child: Column(
                              children: [
                                const CircleAvatar(
                                  radius: 50,
                                  backgroundColor: Colors.white,
                                  child: Icon(Icons.person,
                                      size: 60, color: Colors.blueAccent),
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  widget.user['username'] ?? "No Name",
                                  style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white),
                                ),
                                Text(
                                  widget.user['email'] ?? "No Email",
                                  style: const TextStyle(color: Colors.white70),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 20),

                          // User Details Cards
                          _buildDetailCard(Icons.credit_card, "CNIC",
                              widget.user['cnic'] ?? 'N/A'),
                          _buildDetailCard(Icons.mail, "Email",
                              widget.user['email'] ?? 'N/A'),
                          _buildDetailCard(Icons.male, "Gender",
                              widget.user['gender'] ?? 'N/A'),
                          _buildDetailCard(Icons.phone, "Phone",
                              widget.user['phone'] ?? 'N/A'),
                          const SizedBox(height: 20),

                          // Action Buttons
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                _buildActionButton(
                                  text:
                                      isRestricted ? "Unrestrict" : "Restrict",
                                  color: isRestricted
                                      ? Colors.green
                                      : Colors.orange,
                                  icon: isRestricted
                                      ? Icons.lock_open
                                      : Icons.block,
                                  isLoading: isRestricting,
                                  onTap: toggleRestriction,
                                ),
                                _buildActionButton(
                                  text: "Delete",
                                  color: Colors.red,
                                  icon: Icons.delete,
                                  isLoading: isDeleting,
                                  onTap: deleteUser,
                                ),
                              ],
                            ),
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

  Widget _buildDetailCard(IconData icon, String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 1),
      child: Card(
        color: Colors.white,
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        child: ListTile(
          leading: ShaderMask(
            shaderCallback: (bounds) => const LinearGradient(
              colors: [Color(0xFFE22128), Color(0xFF203982)], // Red & Blue
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ).createShader(bounds),
            child: Icon(icon, color: Colors.white, size: 18,), // Icon with Gradient Effect
          ),
          title: Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF203982)),
          ),
          subtitle: Text(
            value,
            style: const TextStyle(fontSize: 12, color: Color(0xFF203982)),
          ),
        ),
      ),
    );
  }

  // Action Button Widget
  Widget _buildActionButton(
      {required String text,
      required Color color,
      required IconData icon,
      required bool isLoading,
      required VoidCallback onTap}) {
    return ElevatedButton.icon(
      onPressed: isLoading ? null : onTap,
      icon: isLoading
          ? const CircularProgressIndicator(color: Colors.white)
          : Icon(icon, color: Colors.white),
      label: Text(text, style: const TextStyle(color: Colors.white)),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }
}
