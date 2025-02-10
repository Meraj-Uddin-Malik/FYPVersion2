import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';

class CrimeStatisticsScreen extends StatefulWidget {
  const CrimeStatisticsScreen({super.key});

  @override
  State<CrimeStatisticsScreen> createState() => _CrimeStatisticsScreenState();
}

class _CrimeStatisticsScreenState extends State<CrimeStatisticsScreen> {
  int totalCases = 0;
  int openCases = 0;
  int resolvedCases = 0;
  int pendingCases = 0;

  String selectedCrimeType = "All";
  DateTime? selectedDate;

  final List<String> crimeTypes = [
    "All",
    "Theft & Robbery",
    "Assault & Violence",
    "Fraud & Cybercrime",
    "Harassment & Threats",
    "Others",
  ];

  String selectedCrimeOrIncidentType = "All"; // Default value


  @override
  void initState() {
    super.initState();
    fetchCrimeData();
  }

  Future<void> fetchCrimeData() async {
    QuerySnapshot snapshot =
        await FirebaseFirestore.instance.collection('pre_fir').get();

    List<DocumentSnapshot> docs = snapshot.docs;

    int open = 0, resolved = 0, pending = 0, total = docs.length;

    for (var doc in docs) {
      var data = doc.data() as Map<String, dynamic>;
      String status = data['status'] ?? 'Unknown';

      if (status == "Open") open++;
      if (status == "Resolved") resolved++;
      if (status == "Pending") pending++;
      if (status == "Rejected") pending++;
    }

    setState(() {
      totalCases = total;
      openCases = open;
      resolvedCases = resolved;
      pendingCases = pending;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF2A489E),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 10),
            const CircleAvatar(
              radius: 55.0,
              backgroundImage: AssetImage('images/Police.png'),
            ),
            const SizedBox(height: 10),
            const Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: 'CRIME ',
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
                    text: 'STATISTICS',
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
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30)),
                ),
                child: Column(
                  children: [
                    /// **Dropdown for Crime Type**
                    DropdownButtonFormField<String>(
                      value: selectedCrimeType,
                      decoration: _inputDecoration("Select Crime Type", Icons.filter_list),
                      items: crimeTypes.map((type) {
                        return DropdownMenuItem(
                          value: type,
                          child: Text(
                            type,
                            style: TextStyle(color: Color(0xFF2A489E)), // Make text blue
                          ),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          selectedCrimeType = value!;
                          fetchCrimeData();
                        });
                      },
                      style: TextStyle(color: Colors.blue), // Ensures selected value is blue
                    ),

                    const SizedBox(height: 10),

                    /// **Date Picker**
                    ElevatedButton.icon(
                      icon: const Icon(Icons.date_range),
                      label: Text(
                        selectedDate == null
                            ? "Select Date"
                            : "${selectedDate!.day}-${selectedDate!.month}-${selectedDate!.year}",
                      ),
                      onPressed: () async {
                        DateTime? pickedDate = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime(2020),
                          lastDate: DateTime.now(),
                        );
                        if (pickedDate != null) {
                          setState(() {
                            selectedDate = pickedDate;
                            fetchCrimeData();
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 20),

                    /// **Pie Chart**
                    CrimePieChart(
                      totalCases: totalCases,
                      openCases: openCases,
                      resolvedCases: resolvedCases,
                      pendingCases: pendingCases,
                    ),

                    const SizedBox(height: 10),

                    /// **Statistics Grid**
                    Expanded(
                      child: GridView.count(
                        crossAxisCount: 2,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                        children: [
                          _buildStatCard(
                              "Total Cases", totalCases, Colors.blue),
                          _buildStatCard(
                              "Open Cases", openCases, Colors.orange),
                          _buildStatCard(
                              "Resolved Cases", resolvedCases, Colors.green),
                          _buildStatCard(
                              "Pending Cases", pendingCases, Colors.red),
                        ],
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

  /// **📌 UI Helper for Input Fields**
  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: const Color(0xFF203982)),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
    );
  }

  /// **📌 Crime Statistics Card**
  Widget _buildStatCard(String title, int value, Color color) {
    return Card(
      elevation: 3,
      color: Colors.white,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(title,
              style:
                  const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
          const SizedBox(height: 5),
          Text(value.toString(),
              style: TextStyle(
                  fontSize: 18, fontWeight: FontWeight.bold, color: color)),
        ],
      ),
    );
  }
}

/// **📊 Crime Pie Chart**
class CrimePieChart extends StatelessWidget {
  final int totalCases, openCases, resolvedCases, pendingCases;

  const CrimePieChart({
    super.key,
    required this.totalCases,
    required this.openCases,
    required this.resolvedCases,
    required this.pendingCases,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 200,
          child: PieChart(
            PieChartData(
              sectionsSpace: 2,
              centerSpaceRadius: 40,
              sections: _generateSections(),
            ),
          ),
        ),
        const SizedBox(height: 10),

        /// **📌 Legend**
        Wrap(
          alignment: WrapAlignment.center,
          spacing: 10,
          children: [
            _buildLegendItem("Total", Colors.blue),
            _buildLegendItem("Open", Colors.orange),
            _buildLegendItem("Resolved", Colors.green),
            _buildLegendItem("Pending", Colors.red),
          ],
        ),
      ],
    );
  }

  /// **📌 Generate Pie Sections**
  List<PieChartSectionData> _generateSections() {
    if (totalCases == 0) return [];

    return [
      _buildSection("Total", totalCases, Colors.blue),
      _buildSection("Open", openCases, Colors.orange),
      _buildSection("Resolved", resolvedCases, Colors.green),
      _buildSection("Pending", pendingCases, Colors.red),
    ];
  }

  /// **📌 Pie Section Helper**
  PieChartSectionData _buildSection(String title, int value, Color color) {
    if (value == 0) return PieChartSectionData();

    return PieChartSectionData(
      color: color,
      value: value.toDouble(),
      title: "${(value / totalCases * 100).toStringAsFixed(1)}%",
      radius: 50,
      titleStyle: const TextStyle(
          fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
    );
  }

  /// **📌 Legend Helper**
  Widget _buildLegendItem(String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(width: 12, height: 12, color: color),
        const SizedBox(width: 5),
        Text(label,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
      ],
    );
  }
}
