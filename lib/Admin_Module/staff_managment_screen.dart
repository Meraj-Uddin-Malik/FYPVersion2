import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fyp_v2/Admin_Module/demo.dart';
import 'package:fyp_v2/Admin_Module/staff_details_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:shimmer/shimmer.dart';
import 'add_staff_screen.dart'; // Import your Add Staff screen

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MaterialApp(home: StaffManagmentScreen()));
}

class StaffManagmentScreen extends StatefulWidget {
  const StaffManagmentScreen({Key? key}) : super(key: key);

  @override
  _StaffManagmentScreenState createState() => _StaffManagmentScreenState();
}

class _StaffManagmentScreenState extends State<StaffManagmentScreen> {
  String searchQuery = "";
  List<DocumentSnapshot> allUsers = [];
  List<DocumentSnapshot> filteredUsers = [];
  Set<String> uniqueUserIds = {}; // Prevents duplicates
  Timer? _debounce;
  DocumentSnapshot? lastDocument;
  bool isLoadingMore = false;
  bool hasMoreUsers = true;
  final int pageSize = 10; // Pagination limit

  @override
  void initState() {
    super.initState();
    fetchUsers();
  }

  /// ✅ Fetch **only Police** users from Firestore
  void fetchUsers({bool isLoadMore = false}) async {
    if (isLoadMore && !hasMoreUsers) return;

    Query query = FirebaseFirestore.instance
        .collection('users')
        .where('role', isEqualTo: 'POLICE') // ✅ Fetch only Police
        .orderBy('username') // ✅ Requires an index in Firestore
        .limit(pageSize);

    if (isLoadMore && lastDocument != null) {
      query = query.startAfterDocument(lastDocument!);
    }

    setState(() => isLoadingMore = isLoadMore);

    try {
      QuerySnapshot snapshot = await query.get();
      print("🔥 Fetched ${snapshot.docs.length} Police users");

      if (snapshot.docs.isEmpty) {
        setState(() => hasMoreUsers = false);
        return;
      }

      for (var doc in snapshot.docs) {
        if (!uniqueUserIds.contains(doc.id)) {
          uniqueUserIds.add(doc.id);
          allUsers.add(doc);
        }
      }

      setState(() {
        lastDocument = snapshot.docs.last;
        filterUsers();
        isLoadingMore = false;
      });
    } catch (e) {
      setState(() => isLoadingMore = false);
      print("❌ Error fetching users: $e");
    }
  }

  /// ✅ Filter users based on search query
  void filterUsers() {
    setState(() {
      filteredUsers = allUsers.where((doc) {
        var data = doc.data() as Map<String, dynamic>;
        String name = (data['username'] ?? '').toLowerCase();
        String cnic = (data['cnic'] ?? '').toLowerCase();
        return name.contains(searchQuery) || cnic.contains(searchQuery);
      }).toList();
    });
  }

  /// ✅ Debounced Search
  void onSearchChanged(String value) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      setState(() {
        searchQuery = value.toLowerCase();
        filterUsers();
      });
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Color(0xFF2A489E),
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Colors.white,
      systemNavigationBarIconBrightness: Brightness.dark,
    ));

    return Scaffold(
      backgroundColor: const Color(0xFF2A489E),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 22.0),
            const CircleAvatar(
              radius: 65.0,
              backgroundImage: AssetImage('images/Police.png'),
            ),
            const SizedBox(height: 14.0),
            const Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: 'STAFF ',
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
            const SizedBox(height: 30.0),
            Expanded(
              child: Container(
                width: 390,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  ),
                ),
                child: Column(
                  children: [
                Padding(
                padding: const EdgeInsets.all(23.0),
                child: Row(
                  children: [
                    Container(
                      height: 48, // Same height as TextField
                      decoration: BoxDecoration(
                        color: const Color(0xFF203982),
                        borderRadius: BorderRadius.circular(15), // Match TextField style
                      ),
                      child: IconButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const Demo()),
                          );
                        },
                        icon: const Icon(Icons.add, color: Colors.white),
                      ),
                    ),
                    const SizedBox(width: 12), // Add spacing between button and text field
                    Expanded(
                      child: SizedBox(
                        height: 48, // Same height as the button
                          child: TextField(
                            decoration: InputDecoration(
                              labelText: 'Search by Name & CNIC',
                              labelStyle: TextStyle(
                                color: const Color(0xFF203982).withAlpha((0.7 * 255).toInt()),
                                fontSize: 13.0,
                              ),
                              border: const OutlineInputBorder(),
                              prefixIcon: const Icon(Icons.search, color: Color(0xFF203982)),
                              enabledBorder: const OutlineInputBorder(
                                borderSide: BorderSide(color: Color(0xFF203982), width: 0.6),
                              ),
                              focusedBorder: const OutlineInputBorder(
                                borderSide: BorderSide(color: Color(0xFF203982), width: 1.0),
                              ),
                              filled: true,
                              fillColor: Colors.white,
                            ),
                            onChanged: onSearchChanged,
                          ),
                      ),
                    ),
                  ],
                ),
              ),

                    Flexible(
                      child: filteredUsers.isEmpty
                          ? _buildShimmerEffect()
                          : ListView.builder(
                        itemCount: filteredUsers.length + 1,
                        itemBuilder: (context, index) {
                          if (index == filteredUsers.length) {
                            return hasMoreUsers
                                ? TextButton(
                              onPressed: () => fetchUsers(isLoadMore: true),
                              child: const Text("Load More"),
                            )
                                : const SizedBox.shrink();
                          }

                          var user = filteredUsers[index].data() as Map<String, dynamic>;
                          return Card(
                            color: Colors.white,
                            margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            elevation: 3,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: Colors.blue.shade100,
                                child: const Icon(Icons.person, color: Color(0xFF2A489E)),
                              ),
                              title: Text(user['username'] ?? "No Name",
                                  style: const TextStyle(
                                      fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF2A489E))),
                              subtitle: Text("CNIC: ${user['cnic'] ?? 'N/A'}",
                                  style: TextStyle(fontSize: 13, color: Color(0xFF2A489E).withOpacity(0.6))),
                              trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: Color(0xFF2A489E)),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => StaffDetailsScreen(user: user, userId: filteredUsers[index].id),
                                  ),
                                );
                              },
                            ),
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

  /// ✅ Shimmer Effect for Loading State
  Widget _buildShimmerEffect() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.white,
      child: ListView.builder(
        itemCount: 5,
        itemBuilder: (context, index) => const Card(
          child: ListTile(title: Text("Loading...")),
        ),
      ),
    );
  }
}
