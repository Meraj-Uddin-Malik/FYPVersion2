import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fyp_v2/Admin_Module/prefir_details_screen.dart';

class MissingfoundpropertyScreen extends StatefulWidget {
  const MissingfoundpropertyScreen({super.key});

  @override
  State<MissingfoundpropertyScreen> createState() => _MissingfoundpropertyScreenState();
}

class _MissingfoundpropertyScreenState extends State<MissingfoundpropertyScreen> {
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
            const Text(
              'MISSING & FOUND ',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontFamily: 'Barlow',
                fontWeight: FontWeight.w700,
                letterSpacing: 3.36,
              ),
            ),
            const Text(
              'REPORTS MANAGEMENT',
              style: TextStyle(
                color: Color(0xFFE22128),
                fontSize: 16,
                fontFamily: 'Barlow',
                fontWeight: FontWeight.w700,
                letterSpacing: 3.36,
              ),
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
                    /// **Search Field**
                    TextField(
                      controller: searchController,
                      decoration: _inputDecoration('Search Your Missing Item Report', Icons.search),
                      style: const TextStyle(color: Color(0xFF2A489E), fontSize: 14),
                      cursorColor: const Color(0xFF2A489E),
                      onChanged: (value) {
                        setState(() {
                          searchQuery = value.toLowerCase();
                        });
                      },
                    ),
                    const SizedBox(height: 10),

                    /// **Dropdown for Status Filter**
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

                    /// **Fetching Data from Firebase**
                    Expanded(
                      child: StreamBuilder<QuerySnapshot>(
                        stream: FirebaseFirestore.instance
                            .collection('lost_found_reports')
                            .orderBy('timestamp', descending: true)
                            .snapshots(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return const Center(child: CircularProgressIndicator());
                          }

                          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                            return const Center(child: Text('No records found.'));
                          }

                          var reportsList = snapshot.data!.docs.where((doc) {
                            var data = doc.data() as Map<String, dynamic>;
                            var subject = data['incident_subject']?.toString().toLowerCase() ?? '';
                            var status = data['status'] ?? '';

                            bool matchesSearch = subject.contains(searchQuery);
                            bool matchesStatus = selectedStatus == 'All' || status == selectedStatus;

                            return matchesSearch && matchesStatus;
                          }).toList();

                          return ListView.builder(
                            itemCount: reportsList.length,
                            itemBuilder: (context, index) {
                              var report = reportsList[index];
                              var data = report.data() as Map<String, dynamic>;

                              return Card(
                                color: Colors.white,
                                elevation: 3,
                                margin: const EdgeInsets.symmetric(vertical: 6),
                                child: ListTile(
                                  title: Text(data['report_type'] ?? 'No Subject',
                                      style: _textStyle(14, const Color(0xFF2A489E))),
                                  subtitle: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      _infoText('Status:', data['status']),
                                      _infoText('Location:', data['incident_location']),
                                      _infoText('Date:', data['incident_date']),
                                      _infoText('Reporter:', data['reporter_name']),
                                      _infoText('Contact:', data['contact_number']),
                                      _infoText('Item Description:', data['item_description']),
                                    ],
                                  ),
                                  trailing: const Icon(Icons.arrow_forward_ios, color: Color(0xFF2A489E), size: 15),
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => PrefirDetailsScreen(
                                          firId: report.id,
                                          firData: data,
                                          isAdmin: true,
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

  /// **Helper function for input decoration**
  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: const Color(0xFF203982)),
      labelStyle: const TextStyle(fontSize: 14.0, color: Color(0xFF203982), fontWeight: FontWeight.w400),
      border: const OutlineInputBorder(borderSide: BorderSide(color: Color(0xFF203982))),
      enabledBorder: const OutlineInputBorder(borderSide: BorderSide(color: Color(0xFF203982), width: 0.5)),
      focusedBorder: const OutlineInputBorder(borderSide: BorderSide(color: Color(0xFF203982), width: 1.0)),
      contentPadding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 10.0),
    );
  }

  /// **Helper function for text styles**
  TextStyle _textStyle(double fontSize, Color color) {
    return TextStyle(fontSize: fontSize, fontWeight: FontWeight.bold, color: color);
  }

  /// **Helper function for formatted information display**
  Widget _infoText(String label, dynamic value) {
    return Text(
      '$label ${value ?? "Not Available"}',
      style: const TextStyle(fontSize: 12, color: Color(0xFF2A489E)),
    );
  }
}
