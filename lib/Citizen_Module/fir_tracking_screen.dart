import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fyp_v2/Citizen_Module/fir_view_screen.dart';

class PreFIRTrackingScreen extends StatefulWidget {
  const PreFIRTrackingScreen({super.key});

  @override
  State<PreFIRTrackingScreen> createState() => _PreFIRTrackingScreenState();
}

class _PreFIRTrackingScreenState extends State<PreFIRTrackingScreen> {
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
            Text('Pre FIR Tracking', style: _textStyle(18.0, Colors.white)),
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
                    const SizedBox(
                      height: 10.0,
                    ),
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            SizedBox(height: 15.0,),
                            TextField(
                              controller: searchController,
                              decoration: InputDecoration(
                                labelText: 'Search Your Pre FIR',
                                labelStyle: TextStyle(
                                  color: const Color(0xFF203982).withAlpha((0.7 * 255).toInt()),
                                  fontSize: 15,
                                ),
                                prefixIcon: ShaderMask(
                                  shaderCallback: (Rect bounds) {
                                    return const LinearGradient(
                                      colors: [Color(0xFF203982), Colors.pink],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ).createShader(bounds);
                                  },
                                  child: Icon(
                                    Icons.search,
                                    color: Colors.pink.shade100,
                                    size: 20.0,
                                  ),
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                  vertical: 8.0,
                                  horizontal: 10.0,
                                ),
                                border: const OutlineInputBorder(),
                                enabledBorder: const OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: Color(0xFF203982),
                                    width: 0.6,
                                  ),
                                ),
                                focusedBorder: const OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: Color(0xFF203982),
                                    width: 1.0,
                                  ),
                                ),
                              ),
                              style: const TextStyle(color: Color(0xFF2A489E), fontSize: 14.0),
                              cursorColor: const Color(0xFF2A489E), // Cursor color
                              onChanged: (value) {
                                setState(() {
                                  searchQuery = value.toLowerCase();
                                });
                              },
                            ),
                            const SizedBox(height: 10),
                            DropdownButtonFormField<String>(
                              value: selectedStatus,
                              decoration: InputDecoration(
                                labelText: 'Filter by Status',
                                labelStyle: TextStyle(
                                  color: const Color(0xFF203982).withAlpha((0.7 * 255).toInt()),
                                  fontSize: 13.0,
                                ),
                                border: const OutlineInputBorder(),
                                contentPadding: const EdgeInsets.symmetric(
                                  vertical: 8.0,
                                  horizontal: 10.0,
                                ),
                                prefixIcon: ShaderMask(
                                  shaderCallback: (Rect bounds) {
                                    return const LinearGradient(
                                      colors: [Color(0xFF203982), Colors.pink],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ).createShader(bounds);
                                  },
                                  child: Icon(
                                    Icons.filter_list, // Icon for filtering
                                    color: Colors.pink.shade100,
                                    size: 19.5,
                                  ),
                                ),
                                enabledBorder: const OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: Color(0xFF203982),
                                    width: 0.6,
                                  ),
                                ),
                                focusedBorder: const OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: Color(0xFF203982),
                                    width: 1.0,
                                  ),
                                ),
                              ),
                              style: TextStyle(
                                color: Color(0xFF2A489E), // Set selected text color
                                fontSize: 14.0,
                              ),
                              dropdownColor: Colors.white, // Background color of dropdown menu
                              onChanged: (value) {
                                setState(() {
                                  selectedStatus = value!;
                                });
                              },
                              items: statusOptions.map((status) {
                                return DropdownMenuItem(
                                  value: status,
                                  child: Text(
                                    status,
                                    style: TextStyle(
                                      color: Color(0xFF2A489E), // Set dropdown text color
                                      fontSize: 14.0,
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                            const SizedBox(height: 10),
                            StreamBuilder<QuerySnapshot>(
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
                                  shrinkWrap: true, // Allows the list to take only the space it needs
                                  itemCount: firList.length,
                                  itemBuilder: (context, index) {
                                    var fir = firList[index];
                                    var data = fir.data() as Map<String, dynamic>;

                                    return Card(
                                      color: Colors.white,
                                      child: ListTile(
                                        title: Text(
                                          data['incident_subject'] ?? 'No Subject',
                                          style: TextStyle(color: Color(0xFF2A489E), fontWeight: FontWeight.w500, fontSize: 14), // Blue color for title
                                        ),
                                        subtitle: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Status: ${data['status'] ?? 'Unknown'}',
                                              style: TextStyle(color: Color(0xFF2A489E).withAlpha((0.8 * 255).toInt()), fontSize: 12), // Blue color for subtitle text
                                            ),
                                            Text(
                                              'Date: ${data['incident_date'] ?? 'Unknown'}',
                                              style: TextStyle(color: Color(0xFF2A489E).withAlpha((0.8 * 255).toInt()), fontSize: 12), // Blue color for date
                                            ),
                                          ],
                                        ),
                                        trailing: const Text("View", style: TextStyle(color: Color(0xFF2A489E), fontSize: 12.0, fontWeight: FontWeight.w400),), // Changed icon to 'view'
                                        onTap: () {
                                          // Navigate to FIR details page
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => PreFIRViewScreen(firData: data),
                                            ),
                                          );
                                        },
                                      ),
                                    );

                                  },
                                );
                              },
                            ),
                          ],
                        ),
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

  TextStyle _textStyle(double fontSize, Color color) {
    return TextStyle(
      fontFamily: 'Barlow',
      fontSize: fontSize,
      fontWeight: FontWeight.bold,
      color: color,
    );
  }
}
