import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';

class RedzoneScreen extends StatefulWidget {
  @override
  _RedzoneScreenState createState() => _RedzoneScreenState();
}

class _RedzoneScreenState extends State<RedzoneScreen> {
  Map<String, int> districtCrimeCount = {};
  int totalCases = 0;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchCrimeData();
  }

  /// 🔥 Fetch Data from Firebase and Count FIRs per District
  Future<void> fetchCrimeData() async {
    try {
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

      if (mounted) {
        setState(() {
          districtCrimeCount = tempCrimeCount;
          totalCases = tempTotalCases;
          isLoading = false;
        });
      }
    } catch (e) {
      print("Error fetching data: $e");
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
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
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Color(0xFF2A489E),
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Colors.white,
      systemNavigationBarIconBrightness: Brightness.dark,
    ));

    var sortedDistricts = districtCrimeCount.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Scaffold(
      backgroundColor: const Color(0xFF2A489E),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            const SizedBox(height: 22.0),
            const CircleAvatar(
              radius: 55.0,
              backgroundImage: AssetImage('images/Police.png'),
            ),
            const SizedBox(height: 14.0),
            const Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: 'RED ZONE ',
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
                    text: 'AREAS',
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
            const SizedBox(height: 30.0),
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  ),
                ),
                child: isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : sortedDistricts.isEmpty
                    ? const Center(
                  child: Text(
                    "No data available",
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                )
                    : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    /// 🔥 Header with Total Crime Count & Badge
                    Container(
                      padding: const EdgeInsets.all(15),
                      color: Colors.white,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 5),
                          Row(
                            mainAxisAlignment:
                            MainAxisAlignment.spaceBetween,
                            children: [
                              Text("Total FIR Cases: $totalCases",
                                  style: const TextStyle(fontWeight: FontWeight.w600,fontSize: 15,
                                      color: Color(0xFF2A489E))),
                              Chip(
                                label: const Text("⚠️ High Alert Zone",
                                    style: TextStyle(
                                        color: Colors.white)),
                                backgroundColor: Colors.red[600],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),

                    /// 🔥 Top 3 Most Dangerous Areas
                    if (sortedDistricts.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.all(8),
                        child: Column(
                          crossAxisAlignment:
                          CrossAxisAlignment.start,
                          children: [
                            const Text("🔥 Most Dangerous Areas",
                                style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold),),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment:
                              MainAxisAlignment.spaceEvenly,
                              children: sortedDistricts
                                  .take(3)
                                  .map((entry) => _buildTopCrimeCard(
                                  entry.key, entry.value))
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
                          String district =
                              sortedDistricts[index].key;
                          int count = sortedDistricts[index].value;
                          String crimeLevel = getCrimeLevel(count);

                          return Card(
                            margin: const EdgeInsets.symmetric(
                                vertical: 5, horizontal: 15),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            color: getSeverityColor(crimeLevel),
                            child: ListTile(
                              title: Text(district,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white)),
                              subtitle: Text("Total FIRs: $count",
                                  style: const TextStyle(
                                      color: Colors.white70)),
                              trailing: Chip(
                                label: Text(crimeLevel,
                                    style: const TextStyle(
                                        color: Colors.white)),
                                backgroundColor: Colors.black54,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  /// 🔥 Top 3 Dangerous Areas Card
  Widget _buildTopCrimeCard(String district, int count) {
    return Container(
      width: 110,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.red[800],
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          const Icon(Icons.local_fire_department, color: Colors.yellow, size: 30),
          const SizedBox(height: 5),
          Text(district,
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
          Text("$count Cases",
              style: const TextStyle(color: Colors.white70, fontSize: 12)),
        ],
      ),
    );
  }
}
