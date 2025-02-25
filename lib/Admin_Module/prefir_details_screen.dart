import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:timeline_tile/timeline_tile.dart';

class PrefirDetailsScreen extends StatefulWidget {
  final String firId; // Firestore Document ID
  final Map<String, dynamic> firData;
  final bool isAdmin;



  const PrefirDetailsScreen({
    Key? key,
    required this.firId,
    required this.firData,
    this.isAdmin = false,
  }) : super(key: key);

  @override
  State<PrefirDetailsScreen> createState() => _PrefirDetailsScreenState();
}

class _PrefirDetailsScreenState extends State<PrefirDetailsScreen> {
  String? selectedStatus;

  @override
  void initState() {
    super.initState();
    selectedStatus = widget.firData['status']; // Set initial status
  }
  Map<String, String>? selectedOfficer;

  /// **Function to Update FIR Status in Firestore**
  Future<void> _updateStatus(String newStatus) async {
    try {
      await FirebaseFirestore.instance
          .collection('pre_fir')
          .doc(widget.firId)
          .update({'status': newStatus});

      setState(() {
        selectedStatus = newStatus; // Update UI after Firestore update
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('FIR Status Updated Successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error updating status: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

/// Assign Officers to the Case
  Future<void> _assignOfficer(Map<String, String> officerData) async {
    try {
      await FirebaseFirestore.instance
          .collection('pre_fir')
          .doc(widget.firId)
          .update({'assigned_officer': officerData});

      setState(() {
        widget.firData['assigned_officer'] = officerData; // Update UI
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Officer Assigned Successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error assigning officer: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF2A489E),
      body: SafeArea(
        child: SingleChildScrollView(
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
              const SizedBox(height: 20),
              Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  ),
                ),
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Incident Details
                      _buildSectionHeader('Incident Details'),
                      _buildDataTable([
                        {'label': 'Subject', 'value': widget.firData['incident_subject']},
                        {'label': 'Date', 'value': widget.firData['incident_date']},
                        {'label': 'Location', 'value': widget.firData['incident_location']},
                        {'label': 'Description', 'value': widget.firData['incident_detail']},
                      ]),

                      // Complainant Details
                      _buildSectionHeader('Complainant Details'),
                      _buildDataTable([
                        {'label': 'Name', 'value': widget.firData['complainant_name']},
                        {'label': 'CNIC', 'value': widget.firData['cnic']},
                        {'label': 'Gender', 'value': widget.firData['complainant_gender']},
                        {'label': 'Email', 'value': widget.firData['email']},
                        {'label': 'Contact', 'value': widget.firData['contact']},
                      ]),

                      // Victim Details
                      _buildSectionHeader('Victim Details'),
                      _buildDataTable([
                        {'label': 'Name', 'value': widget.firData['victim_name']},
                        {'label': 'CNIC', 'value': widget.firData['victim_cnic']},
                        {'label': 'Gender', 'value': widget.firData['victim_gender']},
                        {'label': 'Contact', 'value': widget.firData['victim_contact']},
                        {'label': 'Address', 'value': widget.firData['victim_address']},
                      ]),

                      // Suspect Details
                      _buildSectionHeader('Suspect Details'),
                      _buildDataTable([
                        {'label': 'Name', 'value': widget.firData['suspect_name']},
                        {'label': 'Address', 'value': widget.firData['suspect_address']},
                        {'label': 'Description', 'value': widget.firData['suspect_description']},
                      ]),

                      // Witness Details
                      _buildSectionHeader('Witness Details'),
                      _buildDataTable([
                        {'label': 'Name', 'value': widget.firData['witness_name']},
                        {'label': 'Contact', 'value': widget.firData['witness_contact']},
                      ]),

                      // FIR Status
                      _buildSectionHeader('FIR Status'),
                      _buildDataTable([
                        {'label': 'Status', 'value': selectedStatus},
                        {'label': 'Reporting Date', 'value': widget.firData['reporting_date']},
                      ], isStatusSection: true),

                        // Assigned Officer Details
                      if (widget.firData.containsKey('assigned_officer') && widget.firData['assigned_officer'] != null)
                        _buildSectionHeader('Assigned Officer'),
                      if (widget.firData.containsKey('assigned_officer') && widget.firData['assigned_officer'] != null)
                        _buildDataTable([
                          {'label': 'Name', 'value': widget.firData['assigned_officer']['name']},
                          {'label': 'Badge Number', 'value': widget.firData['assigned_officer']['badge_number']},
                          {'label': 'Rank', 'value': widget.firData['assigned_officer']['rank']},
                        ]),


                      if (widget.isAdmin) _buildStatusUpdateDropdown(),
                      _buildOfficerAssignmentDropdown(),


                      // FIR Progress Timeline
                      _buildSectionHeader('FIR Progress'),
                      _buildTimeline(selectedStatus ?? "New"),
                    ]

                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// **Dropdown for Admins to Update FIR Status**
  Widget _buildStatusUpdateDropdown() {
    return Card(
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 3,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 5),
            DropdownButtonFormField<String>(
              value: selectedStatus,
              decoration: const InputDecoration(
                labelText: 'Select Status',
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
                contentPadding:
                EdgeInsets.symmetric(vertical: 8.0, horizontal: 10.0),
              ),
              style: const TextStyle(
                color: Color(0xFF203982), // Selected value color (Blue)
                fontSize: 14.0,
                fontWeight: FontWeight.w500,
              ),
              dropdownColor: Colors.white, // Dropdown menu background color
              items: ["New", "Pending", "Resolved", "Rejected", "In Progress"]
                  .map((status) => DropdownMenuItem(
                value: status,
                child: Text(
                  status,
                  style: const TextStyle(
                    color: Color(0xFF203982), // Dropdown item text color
                  ),
                ),
              ))
                  .toList(),
              onChanged: (newStatus) {
                if (newStatus != null) {
                  _updateStatus(newStatus);
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  /// **Table Cell UI**
  Widget _buildTableCell(String text, {bool isHeader = false}) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Text(text, style: TextStyle(fontSize: 13, fontWeight: isHeader ? FontWeight.bold : FontWeight.normal)),
    );
  }

  /// **FIR Progress Timeline**
  Widget _buildTimeline(String status) {
    List<String> steps = ["New", "Pending", "In Progress", "Resolved", "Rejected"];
    int currentStep = steps.indexOf(status);

    // Define custom colors for each status
    Map<String, Color> statusColors = {
      "New": Color(0xFF2A489E),
      "Pending": Colors.orange,
      "In Progress": Colors.amber,
      "Resolved": Colors.green,
      "Rejected": Colors.red,
    };

    return Column(
      children: List.generate(steps.length, (index) {
        Color stepColor = index <= currentStep ? statusColors[steps[index]] ?? Colors.grey : Colors.grey;

        return TimelineTile(
          alignment: TimelineAlign.start,
          isFirst: index == 0,
          isLast: index == steps.length - 1,
          indicatorStyle: IndicatorStyle(
            width: 20,
            color: stepColor, // Assign color based on status
          ),
          endChild: Padding(
            padding: const EdgeInsets.all(18.0),
            child: Text(
              steps[index],
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: stepColor, // Assign color based on status
              ),
            ),
          ),
        );
      }),
    );
  }


  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 15, bottom: 8),
      child: Text(
        title,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF2A489E)),
      ),
    );
  }

  Widget _buildDataTable(List<Map<String, String?>> data, {bool isStatusSection = false}) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8.0),
        boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.3), blurRadius: 5)],
      ),
      child: Table(
        columnWidths: const {0: FlexColumnWidth(1.5), 1: FlexColumnWidth(2.5)},
        children: data.map((item) {
          return TableRow(children: [
            _buildTableCell(item['label']!, isHeader: true),
            _buildTableCell(item['value'] ?? 'Not Available'),
          ]);
        }).toList(),
      ),
    );
  }

  String? selectedOfficerBadge; // Store only the selected officer's badge number

  Widget _buildOfficerAssignmentDropdown() {
    return FutureBuilder<QuerySnapshot>(
      future: FirebaseFirestore.instance
          .collection('users')
          .where('role', isEqualTo: 'POLICE') // Fetch only police officers
          .get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return const Center(child: Text("Error loading officers"));
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text("No officers available"));
        }

        List<Map<String, String>> officers = snapshot.data!.docs.map((doc) {
          final data = doc.data() as Map<String, dynamic>? ?? {};
          return {
            "name": data["username"]?.toString() ?? "Unknown",
            "badge_number": data["badgeno"]?.toString() ?? "N/A",
            "rank": data["rank"]?.toString() ?? "N/A", // ✅ Added rank here
          };
        }).toList();

        return Card(
          color: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 3,
          margin: const EdgeInsets.symmetric(vertical: 8),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Assign Officer",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF203982)),
                ),
                const SizedBox(height: 10),
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(
                    labelText: 'Select Officer',
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
                  ),
                  value: selectedOfficerBadge, // Set the selected value
                  items: officers.map((officer) {
                    return DropdownMenuItem<String>(
                      value: officer["badge_number"], // Use badge_number as value
                      child: Text(
                        "${officer['name']} (Badge: ${officer['badge_number']})",
                        style: const TextStyle(color: Color(0xFF203982), fontSize: 14),
                      ),
                    );
                  }).toList(),
                  onChanged: (badgeNumber) {
                    setState(() {
                      selectedOfficerBadge = badgeNumber; // Store selected badge number
                    });
                  },
                ),
                const SizedBox(height: 10),
                Center(
                  child: ElevatedButton(
                    onPressed: selectedOfficerBadge != null
                        ? () {
                      // Find selected officer details before assigning
                      Map<String, String>? selectedOfficer = officers.firstWhere(
                            (officer) => officer["badge_number"] == selectedOfficerBadge,
                        orElse: () => {},
                      );
                      if (selectedOfficer.isNotEmpty) {
                        _assignOfficer(selectedOfficer);
                      }
                    }
                        : null,
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                    child: const Text("Assign Officer", style: TextStyle(color: Colors.white, fontSize: 12)),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }



}
