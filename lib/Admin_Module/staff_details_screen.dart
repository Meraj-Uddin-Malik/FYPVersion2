import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';

class StaffDetailsScreen extends StatefulWidget {
  final Map<String, dynamic> user;
  final String userId;

  const StaffDetailsScreen({Key? key, required this.user, required this.userId})
      : super(key: key);

  @override
  _StaffDetailsScreenState createState() => _StaffDetailsScreenState();
}

class _StaffDetailsScreenState extends State<StaffDetailsScreen> {
  bool isDeleting = false;

  // Function to show the update pop-up
  void showUpdateDialog() {
    TextEditingController usernameController =
    TextEditingController(text: widget.user['username'] ?? '');
    TextEditingController emailController =
    TextEditingController(text: widget.user['email'] ?? '');
    TextEditingController phoneController =
    TextEditingController(text: widget.user['phone'] ?? '');
    String selectedGender = widget.user['gender'] ?? 'Male'; // Default Gender

    showDialog(
      context: context,
      barrierDismissible: false, // Prevents accidental closing
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Update User Details"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildTextField("Username", usernameController, false),
              _buildTextField("Email", emailController, false),
              _buildTextField("Phone", phoneController, false),

              // Gender Dropdown
              DropdownButtonFormField<String>(
                value: selectedGender,
                decoration: const InputDecoration(
                  labelText: "Gender",
                  border: OutlineInputBorder(),
                ),
                items: ["Male", "Female", "Other"].map((String gender) {
                  return DropdownMenuItem(
                    value: gender,
                    child: Text(gender),
                  );
                }).toList(),
                onChanged: (newValue) {
                  selectedGender = newValue!;
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () async {
                try {
                  await FirebaseFirestore.instance
                      .collection('users')
                      .doc(widget.userId)
                      .update({
                    'username': usernameController.text,
                    'email': emailController.text,
                    'phone': phoneController.text,
                    'gender': selectedGender,
                  });

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text("User details updated successfully!")),
                  );
                  Navigator.pop(context);
                  setState(() {}); // Refresh UI
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Failed to update user: $e")),
                  );
                }
              },
              child: const Text("Save"),
            ),
          ],
        );
      },
    );
  }

  // Function to delete user
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
                      text: 'STAFF ',
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
                  decoration: const BoxDecoration(color: Colors.white),
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
                              color: Color(0xFF2A489E),
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
                          // Dropdown Menu for Update & Delete
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: const Color(0xFF203982), // Blue border
                                  width: 1.0,
                                ),
                              ),
                              padding: const EdgeInsets.symmetric(horizontal: 12),
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<String>(
                                  isExpanded: true,
                                  hint: const Text(
                                    "Select Action",
                                    style: TextStyle(
                                      fontSize: 14.0,
                                      color: Color(0xFF203982),
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  dropdownColor: const Color(0xFFE3F2FD), // Light blue dropdown background
                                  icon: const Icon(Icons.arrow_drop_down, color: Color(0xFF203982)), // Custom dropdown icon
                                  items: [
                                    DropdownMenuItem(
                                      value: "update",
                                      child: Row(
                                        children: const [
                                          Icon(Icons.edit, color: Color(0xFF203982), size: 18,), // Icon for update
                                          SizedBox(width: 10),
                                          Text("Update User",
                                              style: TextStyle(fontSize: 14,color: Color(0xFF203982))),
                                        ],
                                      ),
                                    ),
                                    DropdownMenuItem(
                                      value: "delete",
                                      child: Row(
                                        children: const [
                                          Icon(Icons.delete, color: Colors.redAccent, size: 18,), // Icon for delete
                                          SizedBox(width: 10),
                                          Text("Delete User",
                                              style: TextStyle(fontSize: 14, color: Colors.redAccent)),
                                        ],
                                      ),
                                    ),
                                  ],
                                  onChanged: (value) {
                                    if (value == "update") {
                                      showUpdateDialog();
                                    } else if (value == "delete") {
                                      deleteUser();
                                    }
                                  },
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 15),

                          // User Details Cards
                          _buildDetailCard(Icons.credit_card, "CNIC",
                              widget.user['cnic'] ?? 'N/A'),
                          _buildDetailCard(Icons.mail, "Email",
                              widget.user['email'] ?? 'N/A'),
                          _buildDetailCard(Icons.phone, "Phone",
                              widget.user['phone'] ?? 'N/A'),
                          _buildDetailCard(Icons.male, "Gender",
                              widget.user['gender'] ?? 'N/A'),
                          const SizedBox(height: 20),

                          // Restrict & Unrestrict Buttons
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: widget.user['isRestricted'] == true ? Colors.green : Colors.redAccent,
                                padding: const EdgeInsets.symmetric(horizontal: 80, vertical: 12),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              ),
                              onPressed: toggleUserStatus,
                              child: Text(
                                widget.user['isRestricted'] == true ? "Unrestrict" : "Restrict",
                                style: const TextStyle(color: Colors.white),
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
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

  // Function to create a reusable text field
  Widget _buildTextField(
      String label, TextEditingController controller, bool isDisabled) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TextField(
        controller: controller,
        enabled: !isDisabled,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          filled: isDisabled,
          fillColor: Colors.grey[300],
        ),
      ),
    );
  }

  // Function to create a user detail card with gradient icon
  Widget _buildDetailCard(IconData icon, String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 4),
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
            child: Icon(icon, color: Colors.white, size: 20), // Gradient Icon
          ),
          title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF203982))),
          subtitle: Text(value, style: const TextStyle(fontSize: 12, color: Color(0xFF203982))),
        ),
      ),
    );
  }

  void toggleUserStatus() async {
    bool isCurrentlyRestricted = widget.user['isRestricted'] ?? false;
    bool newStatus = !isCurrentlyRestricted; // Toggle status

    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.userId)
          .update({'isRestricted': newStatus});

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(newStatus ? "User restricted!" : "User unrestricted!")),
      );

      setState(() {
        widget.user['isRestricted'] = newStatus; // Update UI state
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to update user status: $e")),
      );
    }
  }


}
