import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
    'All',
    'New',
    'Pending',
    'Resolved',
    'Rejected',
    'In Progress'
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
            Text('PRE FIR TRACKING', style: _textStyle(18.0, Colors.white)),
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
                    const SizedBox(height: 10.0),
                    TextField(
                      controller: searchController,
                      decoration: InputDecoration(
                        labelText: 'Search Your Pre FIR',
                        labelStyle: TextStyle(
                          color: const Color(0xFF203982).withOpacity(0.7),
                          fontSize: 15,
                        ),
                        prefixIcon:
                            const Icon(Icons.search, color: Color(0xFF203982)),
                        border: const OutlineInputBorder(),
                        enabledBorder: const OutlineInputBorder(
                          borderSide:
                              BorderSide(color: Color(0xFF203982), width: 0.6),
                        ),
                        focusedBorder: const OutlineInputBorder(
                          borderSide:
                              BorderSide(color: Color(0xFF203982), width: 1.0),
                        ),
                      ),
                      style: const TextStyle(
                          color: Color(0xFF2A489E), fontSize: 14.0),
                      cursorColor: const Color(0xFF2A489E),
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
                          color: const Color(0xFF203982).withOpacity(0.7),
                          fontSize: 13.0,
                        ),
                        border: const OutlineInputBorder(),
                        prefixIcon: const Icon(Icons.filter_list,
                            color: Color(0xFF203982)),
                        enabledBorder: const OutlineInputBorder(
                          borderSide:
                              BorderSide(color: Color(0xFF203982), width: 0.6),
                        ),
                        focusedBorder: const OutlineInputBorder(
                          borderSide:
                              BorderSide(color: Color(0xFF203982), width: 1.0),
                        ),
                      ),
                      style: const TextStyle(
                          color: Color(0xFF2A489E), fontSize: 14.0),
                      dropdownColor: Colors.white,
                      onChanged: (value) {
                        setState(() {
                          selectedStatus = value!;
                        });
                      },
                      items: statusOptions.map((status) {
                        return DropdownMenuItem(
                          value: status,
                          child: Text(status,
                              style: const TextStyle(
                                  color: Color(0xFF2A489E), fontSize: 14.0)),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 10),
                    Expanded(
                      child: StreamBuilder<QuerySnapshot>(
                        stream: FirebaseFirestore.instance
                            .collection('pre_fir')
                            .where('userId',
                                isEqualTo:
                                    FirebaseAuth.instance.currentUser?.uid ??
                                        '') // ✅ Fetch only current user's FIRs
                            .snapshots(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Center(
                                child: CircularProgressIndicator());
                          }

                          if (!snapshot.hasData) {
                            return const Center(
                                child: Text('No FIR records found.'));
                          }

                          var docs = snapshot.data!.docs;
                          var firList = docs.where((doc) {
                            var data = doc.data() as Map<String, dynamic>;
                            var subject = data['incident_subject']
                                .toString()
                                .toLowerCase();
                            var status = data['status'];

                            bool matchesSearch = subject.contains(searchQuery);
                            bool matchesStatus = selectedStatus == 'All' ||
                                status == selectedStatus;

                            return matchesSearch && matchesStatus;
                          }).toList();

                          // ✅ Sort manually after filtering
                          firList.sort((a, b) {
                            var dataA = a.data() as Map<String, dynamic>;
                            var dataB = b.data() as Map<String, dynamic>;
                            return (dataB['timestamp'] ?? 0)
                                .compareTo(dataA['timestamp'] ?? 0);
                          });

                          if (docs.isNotEmpty && firList.isEmpty) {
                            return const Center(
                                child: Text('No matching FIRs found.'));
                          } else if (docs.isEmpty) {
                            return const Center(
                                child: Text('No FIR records found.'));
                          }

                          return ListView.builder(
                            itemCount: firList.length,
                            itemBuilder: (context, index) {
                              var fir = firList[index];
                              var data = fir.data() as Map<String, dynamic>;

                              return Card(
                                color: Colors.white,
                                child: ListTile(
                                  title: Text(
                                    data['incident_subject'] ?? 'No Subject',
                                    style: const TextStyle(
                                      color: Color(0xFF2A489E),
                                      fontWeight: FontWeight.w500,
                                      fontSize: 14,
                                    ),
                                  ),
                                  subtitle: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      // Row to display Status and its value on the same line
                                      Row(
                                        children: [
                                          // Status Text
                                          Text(
                                            'Status: ',
                                            style: TextStyle(
                                              color: Color(0xFF2A489E)
                                                  .withOpacity(0.8),
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          // Status Value with Dynamic Color
                                          Text(
                                            '${data['status'] ?? 'Unknown'}',
                                            style: TextStyle(
                                              color: _getStatusColor(data[
                                                      'status'] ??
                                                  'Unknown'), // Dynamic color for the status value
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                      // Date Text
                                      Text(
                                        'Date: ${data['incident_date'] ?? 'Unknown'}',
                                        style: TextStyle(
                                          color: Color(0xFF2A489E)
                                              .withOpacity(0.8),
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                  trailing: const Text(
                                    "View",
                                    style: TextStyle(
                                      color: Color(0xFF2A489E),
                                      fontSize: 12.0,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            PreFIRViewScreen(firData: data),
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

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'new':
        return Color(0xFF2A489E); // Blue for new cases
      case 'pending':
        return Colors.orange; // Orange for pending cases
      case 'resolved':
        return Colors.green; // Green for resolved cases
      case 'rejected':
        return Colors.red; // Red for rejected cases
      case 'in progress':
        return Colors.purple; // Purple for in-progress cases
      default:
        return Colors.grey; // Default color for unknown status
    }
  }

  TextStyle _textStyle(double fontSize, Color color) {
    return TextStyle(
        fontFamily: 'Barlow',
        fontSize: fontSize,
        fontWeight: FontWeight.bold,
        color: color);
  }
}
