import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RedzoneScreen extends StatefulWidget {
  @override
  _RedzoneScreenState createState() => _RedzoneScreenState();
}

class _RedzoneScreenState extends State<RedzoneScreen> {
  Map<String, int> districtCrimeCount = {};
  int totalCases = 0; // Store total FIRs

  @override
  void initState() {
    super.initState();
    fetchCrimeData();
  }

  /// 🔥 Fetch Data from Firebase and Count FIRs per District
  Future<void> fetchCrimeData() async {
    QuerySnapshot snapshot =
    await FirebaseFirestore.instance.collection('pre_fir').get();

    Map<String, int> tempCrimeCount = {};
    int tempTotalCases = 0;

    for (var doc in snapshot.docs) {
      var data = doc.data() as Map<String, dynamic>;
      String district = data['district'] ?? 'Unknown';

      tempTotalCases++; // Count total FIRs

      if (tempCrimeCount.containsKey(district)) {
        tempCrimeCount[district] = tempCrimeCount[district]! + 1;
      } else {
        tempCrimeCount[district] = 1;
      }
    }

    setState(() {
      districtCrimeCount = tempCrimeCount;
      totalCases = tempTotalCases;
    });
  }

  /// 🔴 Get Severity Level Based on Crime Count
  String getCrimeLevel(int count) {
    if (count > 100) return "Extreme";
    if (count > 50) return "High";
    if (count > 20) return "Medium";
    return "Low";
  }

  /// 🎨 Crime Severity Color
  Color getSeverityColor(String level) {
    switch (level) {
      case "Extreme":
        return Colors.red;
      case "High":
        return Colors.orange;
      case "Medium":
        return Colors.yellow;
      default:
        return Colors.green;
    }
  }

  @override
  Widget build(BuildContext context) {
    /// Sort Districts by Crime Count
    var sortedDistricts = districtCrimeCount.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        title: Text('🚨 Crime Hotspots'),
        centerTitle: true,
        backgroundColor: Colors.red[700],
      ),
      body: districtCrimeCount.isEmpty
          ? Center(child: CircularProgressIndicator())
          : Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// 🔥 Header with Total Crime Count & Badge
          Container(
            padding: EdgeInsets.all(15),
            color: Colors.red[900],
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("📍 Redzone Report",
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white)),
                SizedBox(height: 5),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Total FIR Cases: $totalCases",
                        style: TextStyle(color: Colors.white)),
                    Chip(
                      label: Text("⚠️ High Alert Zone",
                          style: TextStyle(color: Colors.white)),
                      backgroundColor: Colors.red[600],
                    ),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(height: 10),

          /// 🔥 Top 3 Most Dangerous Areas
          if (sortedDistricts.isNotEmpty)
            Padding(
              padding: EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("🔥 Most Dangerous Areas",
                      style: TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold)),
                  SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: sortedDistricts
                        .take(3)
                        .map((entry) =>
                        _buildTopCrimeCard(entry.key, entry.value))
                        .toList(),
                  ),
                ],
              ),
            ),

          /// 📊 District-wise Crime List
          Expanded(
            child: ListView.builder(
              itemCount: sortedDistricts.length,
              itemBuilder: (context, index) {
                String district = sortedDistricts[index].key;
                int count = sortedDistricts[index].value;
                String crimeLevel = getCrimeLevel(count);

                return Card(
                  margin: EdgeInsets.symmetric(
                      vertical: 5, horizontal: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  color: getSeverityColor(crimeLevel),
                  child: ListTile(
                    title: Text(district,
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.white)),
                    subtitle: Row(
                      children: [
                        Text("Total FIRs: $count",
                            style: TextStyle(color: Colors.white70)),
                        SizedBox(width: 10),
                        _buildCrimeTrendIcon(),
                      ],
                    ),
                    trailing: Chip(
                      label: Text(crimeLevel,
                          style: TextStyle(color: Colors.white)),
                      backgroundColor: Colors.black54,
                    ),
                    onTap: () {
                      // 🚀 Navigate to detailed FIRs for this district
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  /// 🔥 Top 3 Dangerous Areas Card
  Widget _buildTopCrimeCard(String district, int count) {
    return Container(
      width: 110,
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.red[800],
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 5, offset: Offset(2, 2))
        ],
      ),
      child: Column(
        children: [
          Icon(Icons.local_fire_department, color: Colors.yellow, size: 30),
          SizedBox(height: 5),
          Text(district,
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontWeight: FontWeight.bold, color: Colors.white)),
          Text("$count Cases",
              style: TextStyle(color: Colors.white70, fontSize: 12)),
        ],
      ),
    );
  }

  /// 📈 Randomized Crime Trend Indicator
  Widget _buildCrimeTrendIcon() {
    bool isIncreasing = DateTime.now().second % 2 == 0; // Random trend
    return Icon(
      isIncreasing ? Icons.arrow_upward : Icons.arrow_downward,
      color: isIncreasing ? Colors.greenAccent : Colors.redAccent,
      size: 18,
    );
  }
}
