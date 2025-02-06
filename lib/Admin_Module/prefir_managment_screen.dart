import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fyp_v2/Citizen_Module/fir_view_screen.dart';

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
                    TextField(
                      controller: searchController,
                      decoration: _inputDecoration('Search Your Pre FIR', Icons.search),
                      style: const TextStyle(color: Color(0xFF2A489E), fontSize: 14.0),
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
                                child: ListTile(
                                  title: Text(data['incident_subject'] ?? 'No Subject',
                                      style: _textStyle(14, Color(0xFF2A489E))),
                                  subtitle: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('Status: ${data['status'] ?? 'Unknown'}',
                                          style: _textStyle(12, Color(0xFF2A489E).withAlpha(200))),
                                      Text('Date: ${data['incident_date'] ?? 'Unknown'}',
                                          style: _textStyle(12, Color(0xFF2A489E).withAlpha(200))),
                                    ],
                                  ),
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                        icon: Icon(Icons.edit, color: Colors.blue),
                                        onPressed: () => _updateStatus(fir.id, data['status']),
                                      ),
                                      IconButton(
                                        icon: Icon(Icons.delete, color: Colors.red),
                                        onPressed: () => _deleteFIR(fir.id),
                                      ),
                                    ],
                                  ),
                                  onTap: () {
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

  void _updateStatus(String firId, String currentStatus) {
    showDialog(
      context: context,
      builder: (context) {
        String newStatus = currentStatus;
        return AlertDialog(
          title: Text('Update Status'),
          content: DropdownButtonFormField<String>(
            value: newStatus,
            onChanged: (value) {
              newStatus = value!;
            },
            items: statusOptions.map((status) {
              return DropdownMenuItem(value: status, child: Text(status));
            }).toList(),
          ),
          actions: [
            TextButton(
              child: Text('Cancel'),
              onPressed: () => Navigator.pop(context),
            ),
            TextButton(
              child: Text('Update'),
              onPressed: () {
                FirebaseFirestore.instance
                    .collection('pre_fir')
                    .doc(firId)
                    .update({'status': newStatus}).then((_) {
                  Navigator.pop(context);
                }).catchError((error) {
                  print("Failed to update status: $error");
                });
              },
            ),
          ],
        );
      },
    );
  }

  void _deleteFIR(String firId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Confirm Delete'),
        content: Text('Are you sure you want to delete this Pre-FIR?'),
        actions: [
          TextButton(
            child: Text('Cancel'),
            onPressed: () => Navigator.pop(context),
          ),
          TextButton(
            child: Text('Delete'),
            onPressed: () {
              FirebaseFirestore.instance
                  .collection('pre_fir')
                  .doc(firId)
                  .delete()
                  .then((_) {
                Navigator.pop(context);
              }).catchError((error) {
                print("Failed to delete FIR: $error");
              });
            },
          ),
        ],
      ),
    );
  }

  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      border: OutlineInputBorder(),
      prefixIcon: Icon(icon, color: Color(0xFF2A489E)),
    );
  }

  TextStyle _textStyle(double fontSize, Color color) {
    return TextStyle(
      fontSize: fontSize,
      fontWeight: FontWeight.bold,
      color: color,
    );
  }
}
