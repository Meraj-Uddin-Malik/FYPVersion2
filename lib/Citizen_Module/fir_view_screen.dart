import 'package:flutter/material.dart';
import 'package:timeline_tile/timeline_tile.dart';

class PreFIRViewScreen extends StatefulWidget {
  final dynamic firData; // Add the firData parameter here

  const PreFIRViewScreen({super.key, required this.firData}); // Correct constructor

  @override
  State<PreFIRViewScreen> createState() => _PreFIRViewScreenState();
}

class _PreFIRViewScreenState extends State<PreFIRViewScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF2A489E),
      body: SafeArea(
        child: SingleChildScrollView( // Make the entire screen scrollable
          child: Column(
            children: [
              const SizedBox(height: 10),
              const CircleAvatar(
                radius: 65.0,
                backgroundImage: AssetImage('images/Police.png'),
              ),
              const SizedBox(height: 10),
              Text('Pre FIR View', style: _textStyle(18.0, Colors.white)),
              const SizedBox(height: 20),
              Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(50),
                    topRight: Radius.circular(50),
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
                      {'label': 'Email', 'value': widget.firData['email']},
                      {'label': 'Contact', 'value': widget.firData['contact']},
                    ]),

                    // Victim Details
                    _buildSectionHeader('Victim Details'),
                    _buildDataTable([
                      {'label': 'Name', 'value': widget.firData['victim_name']},
                      {'label': 'CNIC', 'value': widget.firData['victim_cnic']},
                      {'label': 'Address', 'value': widget.firData['victim_address']},
                      {'label': 'Contact', 'value': widget.firData['victim_contact']},
                    ]),

                    // FIR Status
                    _buildSectionHeader('FIR Status'),
                    _buildDataTable([
                      {'label': 'Status', 'value': widget.firData['status']},
                      {'label': 'Reporting Date', 'value': widget.firData['reporting_date']},
                    ]),

                    // FIR Status Timeline moved to the end
                    _buildSectionHeader('FIR Progress'),
                    _buildTimeline(widget.firData['status']),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 📌 Table-Based Detail Display
  Widget _buildDataTable(List<Map<String, String?>> data) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8.0),
        boxShadow: [
          BoxShadow(color: Colors.grey.withOpacity(0.3),
              blurRadius: 5,
              spreadRadius: 1),
        ],
      ),
      child: Table(
        border: TableBorder.symmetric(
          inside: BorderSide(color: Colors.grey.shade300, width: 0.5),
        ),
        columnWidths: const {
          0: FlexColumnWidth(1.5),
          1: FlexColumnWidth(2.5),
        },
        children: data.map((item) {
          return TableRow(
            children: [
              _buildTableCell(item['label']!, isHeader: true),
              _buildTableCell(item['value'] ?? 'Not Available'),
            ],
          );
        }).toList(),
      ),
    );
  }

  // 📌 Table Cell Design
  Widget _buildTableCell(String text, {bool isHeader = false}) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Text(
        text,
        style: TextStyle(
          fontSize: isHeader ? 14 : 13,
          fontWeight: isHeader ? FontWeight.bold : FontWeight.normal,
          color: isHeader ? Colors.black : Colors.grey.shade800,
        ),
      ),
    );
  }

  // 📌 Section Header
  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 15, bottom: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Color(0xFF2A489E),
        ),
      ),
    );
  }

  // 📌 Timeline Tracking
  Widget _buildTimeline(String status) {
    List<String> steps = [
      "Under Review",
      "In Process",
      "Resolved",
      "Rejected",
      "Closed"
    ];
    int currentIndex = steps.indexOf(status);

    return Column(
      children: List.generate(steps.length, (index) {
        return TimelineTile(
          alignment: TimelineAlign.start,
          isFirst: index == 0,
          isLast: index == steps.length - 1,
          beforeLineStyle: LineStyle(
            color: index <= currentIndex ? Colors.green : Color(0xFF2A489E).withAlpha((0.4 * 255).toInt()),
          ),
          indicatorStyle: IndicatorStyle(
            color: index <= currentIndex ? Colors.green : Color(0xFF2A489E).withAlpha((0.8 * 255).toInt()),
            width: 20,
          ),
          endChild: Padding(
            padding: const EdgeInsets.only(top: 20, right: 140, bottom: 18),
            child: Column(
              children: [
                SizedBox(height: 4),  // Slight space between the text and line
                Card(
                  elevation: 4,  // Adds shadow for card effect
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),  // Rounded corners for card
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),  // Padding inside the card
                    child: Text(
                      steps[index],
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: index <= currentIndex ? Colors.green : Color(0xFF2A489E).withAlpha((0.7 * 255).toInt()),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      }),
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
