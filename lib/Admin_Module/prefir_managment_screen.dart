import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fyp_v2/Admin_Module/firdemo.dart';
import 'package:fyp_v2/Admin_Module/prefir_details_screen.dart';

class PrefirManagmentScreen extends StatefulWidget {
  const PrefirManagmentScreen({super.key});

  @override
  State<PrefirManagmentScreen> createState() => _PrefirManagmentScreenState();
}

class _PrefirManagmentScreenState extends State<PrefirManagmentScreen> {
  String searchQuery = '';
  String selectedStatus = 'All';
  TextEditingController searchController = TextEditingController();

  final List<String> statusOptions = [
    'All', 'New', 'Pending', 'Resolved', 'Rejected', 'In Progress'
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF2A489E),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 10),
            const CircleAvatar(
              radius: 65.0,
              backgroundImage: AssetImage('images/Police.png'),
            ),
            const SizedBox(height: 10),
            const Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: 'PRE FIR ',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontFamily: 'Barlow',
                      fontWeight: FontWeight.w700,
                      letterSpacing: 3.36,
                    ),
                  ),
                  TextSpan(
                    text: 'MANAGEMENT',
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
            const SizedBox(height: 20),
            Expanded(
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(50),
                    topRight: Radius.circular(50),
                  ),
                ),
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    /// **Search Field with the given decoration**
                    TextField(
                      controller: searchController,
                      decoration: _inputDecoration('Search Your Pre-FIR', Icons.search),
                      style: TextStyle(color: Color(0xFF2A489E), fontSize: 14),
                      cursorColor: Color(0xFF2A489E),
                      onChanged: (value) {
                        setState(() {
                          searchQuery = value.toLowerCase();
                        });
                      },
                    ),
                    const SizedBox(height: 10),

                    /// **Dropdown with the same styling**
                    DropdownButtonFormField<String>(
                      value: selectedStatus,
                      decoration: _inputDecoration('Filter by Status', Icons.filter_list),
                      style: const TextStyle(color: Color(0xFF2A489E), fontSize: 14.0),
                      dropdownColor: Colors.white,
                      onChanged: (value) {
                        setState(() {
                          selectedStatus = value!;
                        });
                      },
                      items: statusOptions.map((status) {
                        return DropdownMenuItem(value: status, child: Text(status));
                      }).toList(),
                    ),
                    const SizedBox(height: 10),
                    Expanded(
                      child: StreamBuilder<QuerySnapshot>(
                        stream: FirebaseFirestore.instance
                            .collection('pre_fir')
                            .orderBy('timestamp', descending: true)
                            .snapshots(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return const Center(child: CircularProgressIndicator());
                          }

                          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                            return const Center(child: Text('No FIR records found.'));
                          }

                          var firList = snapshot.data!.docs.where((doc) {
                            var data = doc.data() as Map<String, dynamic>;
                            var subject = data['incident_subject'].toString().toLowerCase();
                            var status = data['status'];

                            bool matchesSearch = subject.contains(searchQuery);
                            bool matchesStatus = selectedStatus == 'All' || status == selectedStatus;

                            return matchesSearch && matchesStatus;
                          }).toList();

                          return ListView.builder(
                            itemCount: firList.length,
                            itemBuilder: (context, index) {
                              var fir = firList[index];
                              var data = fir.data() as Map<String, dynamic>;

                              return Card(
                                color: Colors.white,
                                elevation: 3,
                                child: ListTile(
                                  title: Text(data['incident_subject'] ?? 'No Subject',
                                      style: _textStyle(14, Color(0xFF2A489E))),
                                  subtitle: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('Status: ${data['status'] ?? 'Unknown'}',
                                          style: TextStyle(fontSize: 12, color: Color(0xFF2A489E))),
                                      Text('Date: ${data['incident_date'] ?? 'Unknown'}',
                                          style: TextStyle(fontSize: 12, color: Color(0xFF2A489E).withAlpha(200))),
                                    ],
                                  ),
                                  trailing: Icon(Icons.arrow_forward_ios, color: Color(0xFF2A489E),
                                  size: 15,), // Right Arrow
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => Firdemo(
                                          firId: fir.id, // Pass Firestore Document ID
                                          firData: data,
                                          isAdmin: true, // Set based on user role
                                        ),
                                      ),
                                    );
                                  },



                                ),
                              );
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// **Common Input Decoration for Search & Dropdown**
  InputDecoration _inputDecoration(String label, IconData icon) {
    return const InputDecoration(
      labelText: 'Search Pre FIR', // Set Dynamic Label
      labelStyle: TextStyle(
        fontSize: 14.0,
        color: Color(0xFF203982), // Blue label color
        fontWeight: FontWeight.w400,
      ),
      border: OutlineInputBorder(
        borderSide: BorderSide(
          color: Color(0xFF203982), // Blue border color
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(
          color: Color(0xFF203982), // Blue border when inactive
          width: 0.5,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(
          color: Color(0xFF203982), // Blue border when focused
          width: 1.0,
        ),
      ),
      contentPadding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 10.0),
    );
  }

  /// **Text Style Helper**
  TextStyle _textStyle(double fontSize, Color color) {
    return TextStyle(
      fontSize: fontSize,
      fontWeight: FontWeight.bold,
      color: color,
    );
  }
}
