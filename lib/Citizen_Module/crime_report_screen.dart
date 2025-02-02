import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CrimeReportScreen extends StatefulWidget {
  const CrimeReportScreen({super.key});

  @override
  State<CrimeReportScreen> createState() => _CrimeReportScreenState();
}

class _CrimeReportScreenState extends State<CrimeReportScreen> {
  final TextEditingController fullNameController = TextEditingController();
  final TextEditingController cnicController = TextEditingController();
  final TextEditingController incidentSubjectController =
      TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController subjectController = TextEditingController();
  final TextEditingController incidentReport_dateController =
      TextEditingController();
  final TextEditingController incident_dateController = TextEditingController();
  final TextEditingController incidentDetailsController =
      TextEditingController();
  final TextEditingController incidentLocationController =
      TextEditingController();
  final TextEditingController provinceController = TextEditingController();
  final TextEditingController victimContactController = TextEditingController();
  final TextEditingController victimNameController = TextEditingController();
  final TextEditingController victimCnicController = TextEditingController();
  final TextEditingController victimAddressController = TextEditingController();
  final TextEditingController witnessNameController = TextEditingController();
  final TextEditingController witnessAddressController =
      TextEditingController();
  final TextEditingController witnessStatementController =
      TextEditingController();
  final TextEditingController witnessContactController =
      TextEditingController();
  final TextEditingController victimEmailController = TextEditingController();
  final TextEditingController suspectNameController = TextEditingController();
  final TextEditingController suspectAddressController =
      TextEditingController();
  final TextEditingController victimPhoneController = TextEditingController();
  final TextEditingController suspectDetailController = TextEditingController();

  List<String> _districts = [];
  List<String> _tehsils = [];
  String? _selectedDistrict;
  String? _selectedTeshsil;
  String? _selectedUrgency;
  String? _selectedVictimHealth;
  String? _selectedIncidentType;
  String? _selectedRelationShip;

  @override
  void initState() {
    super.initState();
    _fetchDistricts(); // Fetch districts when the screen loads
  }

  // Fetch districts from Firestore
  void _fetchDistricts() async {
    try {
      final snapshot =
          await FirebaseFirestore.instance.collection('sindh_districts').get();

      setState(() {
        _districts = snapshot.docs
            .map((doc) => doc.id)
            .toList(); // Get district names from Firestore documents
      });
    } catch (e) {
      print("Error fetching districts: $e");
    }
  }

  // Fetch tehsils from Firestore based on selected district
  void _fetchTehsils(String district) async {
    try {
      // Fetching tehsils array from the district document
      final snapshot = await FirebaseFirestore.instance
          .collection('sindh_districts')
          .doc(district)
          .get();

      // Extract tehsils from the document's 'tehsils' field
      List<String> tehsilsList =
          List<String>.from(snapshot.data()?['tehsils'] ?? []);

      setState(() {
        _tehsils = tehsilsList; // Store the tehsils in the state
        _selectedTeshsil = null; // Reset selected tehsil
      });
    } catch (e) {
      print("Error fetching tehsils: $e");
    }
  }

  // Date Picker
  Future<void> _selectDate(
      BuildContext context, TextEditingController controller) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      setState(() {
        controller.text =
            "${picked.year}-${picked.month}-${picked.day}"; // Format the date
      });
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
    return Scaffold(
      backgroundColor: const Color(0xFF2A489E),
      // bottomNavigationBar: CurvedNavigationBar(
      //   backgroundColor: Colors.white,
      //   color: const Color(0xFF2A489E),
      //   animationDuration: const Duration(milliseconds: 300),
      //   items: const [
      //     Icon(
      //       Icons.home,
      //       color: Colors.white,
      //       size: 30,
      //     ),
      //     Icon(
      //       Icons.miscellaneous_services,
      //       color: Colors.white,
      //       size: 30,
      //     ),
      //     Icon(
      //       Icons.sos,
      //       color: Colors.white,
      //       size: 30,
      //     ),
      //     Icon(
      //       Icons.settings,
      //       color: Colors.white,
      //       size: 30,
      //     ),
      //     Icon(
      //       Icons.account_circle_sharp,
      //       color: Colors.white,
      //       size: 30,
      //     ),
      //   ],
      // ),
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 22.0),
              const CircleAvatar(
                  radius: 65.0,
                  backgroundImage: AssetImage('images/Police.png')),
              const SizedBox(height: 14.0),
              const Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: 'PRE FIR AGAINST ',
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
                      text: 'CRIME',
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
                  width: 390,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(60),
                      topRight: Radius.circular(60),
                    ),
                  ),
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      child: Column(
                        children: [
                          const SizedBox(
                            height: 20.0,
                          ),


                          //Step Number 1
                          const Text('Personal Information',
                              style: TextStyle(
                                  color: Color(0xFF2A489E),
                                  fontWeight: FontWeight.w500,
                                  fontSize: 16)),
                          const SizedBox(height: 10),
                          _buildTextField(fullNameController,
                              'Complainant Full Name ', Icons.person),
                          const SizedBox(height: 10),
                          _buildTextField(emailController, 'Email Address',
                              Icons.credit_card),
                          const SizedBox(height: 10),
                          _buildTextField(
                              cnicController, 'CNIC', Icons.credit_card),
                          const SizedBox(height: 10),
                          _buildTextField(
                              phoneController, 'Contact Number', Icons.phone),
                          const SizedBox(height: 10),
                          _buildRelationshipDropdown(),


                          //Step Number 2
                          const SizedBox(
                            height: 20.0,
                          ),
                          const Text('Incident Detail',
                              style: TextStyle(
                                  color: Color(0xFF2A489E),
                                  fontWeight: FontWeight.w500,
                                  fontSize: 16)),
                          const SizedBox(height: 10),
                          _buildIncidentTypeDropdown(),
                          const SizedBox(height: 10),// Incident Type drop down
                          _buildTextField(subjectController, 'Incident Subject',
                              Icons.subject),
                          const SizedBox(height: 10),
                          _buildTextField(
                            incident_dateController,
                            'Incident Date-Time',
                            Icons.calendar_today,
                            isDateField: true, // Added isDateField argument
                          ),
                          const SizedBox(height: 10),
                          _buildTextField(
                            incidentReport_dateController,
                            'Date Of Reporting',
                            Icons.calendar_today,
                            isDateField: true, // Added isDateField argument
                          ),
                          const SizedBox(height: 10),
                          _buildTextField(
                            incidentLocationController,
                            'Incident Location',
                            Icons.location_on,
                          ),
                          const SizedBox(height: 10),
                          _buildDistrictDropdown(),
                          const SizedBox(height: 10),
                          _buildTehsilDropdown(),
                          const SizedBox(height: 10),
                          _buildTextField(
                            incidentDetailsController,
                            'Incident Details',
                            Icons.description,
                          ),
                          const SizedBox(height: 10),
                          _buildUrgencyDropdown(), // Urgency Level Drop down


                          //Step Number 3
                          const SizedBox(
                            height: 20.0,
                          ),
                          const Text('Victim Information',
                              style: TextStyle(
                                  color: Color(0xFF2A489E),
                                  fontWeight: FontWeight.w500,
                                  fontSize: 16)),
                          const SizedBox(height: 10),
                          _buildTextField(victimNameController,
                              'Victim Name', Icons.person),
                          const SizedBox(height: 10),
                          _buildTextField(victimCnicController,
                              'Victim CNIC', Icons.credit_card),
                          const SizedBox(height: 10),
                          _buildTextField(victimAddressController,
                              'Victim Address', Icons.map),
                          const SizedBox(height: 10),
                          _buildTextField(victimContactController,
                              'Victim Contact', Icons.phone),
                          const SizedBox(height: 10),
                          _buildVictimHealthDropdown(),

                          //Step Number 4
                          const SizedBox(
                            height: 20.0,
                          ),
                          const Text('Suspect Information',
                              style: TextStyle(
                                  color: Color(0xFF2A489E),
                                  fontWeight: FontWeight.w500,
                                  fontSize: 16)),
                          const SizedBox(height: 10),
                          _buildTextField(suspectNameController,
                              'Suspect Name', Icons.person),
                          const SizedBox(height: 10),
                          _buildTextField(suspectAddressController,
                              'Suspect Address', Icons.map),
                          const SizedBox(height: 10),
                          _buildTextField(suspectDetailController,
                              'Suspect Description', Icons.description),
                          const SizedBox(height: 10),

                          const SizedBox(
                            height: 20.0,
                          ),
                          const Text('Witness Information',
                              style: TextStyle(
                                  color: Color(0xFF2A489E),
                                  fontWeight: FontWeight.w500,
                                  fontSize: 16)),
                          const SizedBox(height: 10),
                          _buildTextField(witnessNameController,
                              'Witness Name', Icons.person),
                          const SizedBox(height: 10),
                          _buildTextField(witnessContactController,
                              'Witness Contact', Icons.person),
                          const SizedBox(height: 10),

                          const Text('Witness Information',
                              style: TextStyle(
                                  color: Color(0xFF2A489E),
                                  fontWeight: FontWeight.w500,
                                  fontSize: 16)),
                          const SizedBox(height: 15),

                          const SizedBox(height: 15),
                          SizedBox(
                            height: 1.0,
                            width: 300.0,
                            child: Center(
                              child: Container(
                                  margin: const EdgeInsetsDirectional.only(
                                      start: 1.0, end: 4.0),
                                  height: 5.0,
                                  color:
                                      const Color(0xFF2A489E).withOpacity(0.5)),
                            ),
                          ),
                          const SizedBox(height: 10.0),
                          SizedBox(
                            width: 245.0,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                foregroundColor: Colors.white,
                                backgroundColor: Colors.red,
                              ),
                              onPressed: () => (),
                              child: const Text('Submit'),
                            ),
                          ),
                          const SizedBox(height: 60),
                        ],
                      ),
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
      TextEditingController controller, String labelText, IconData icon,
      {bool isDateField = false, bool isRequired = false}) {
    return SizedBox(
      width: 300.0,
      child: TextFormField(
        controller: controller,
        validator: (value) {
          if (isRequired && (value == null || value.isEmpty)) {
            return 'This field is required';
          }
          return null;
        },

        onTap: isDateField
            ? () => _selectDate(context, controller)
            : null, // Only show date picker for date fields
        readOnly: isDateField, // Prevent typing in the date fields
        decoration: InputDecoration(
          border: const OutlineInputBorder(),
          labelText: labelText,
          labelStyle: TextStyle(
            color: const Color(0xFF203982).withOpacity(0.7),
            fontSize: 13.0,
          ),
          floatingLabelStyle: const TextStyle(
            color: Color(0xFF203982), // Active label color
            fontWeight: FontWeight.w400,
            fontSize: 17.5,
          ),
          contentPadding: const EdgeInsets.symmetric(
            vertical: 8.0,
            horizontal: 10.0,
          ),
          prefixIcon: ShaderMask(
            shaderCallback: (Rect bounds) {
              return const LinearGradient(
                colors: [Color(0xFF203982), Colors.red],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ).createShader(bounds);
            },
            child: Icon(
              icon,
              color: Colors.red.shade100,
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
      ),
    );
  }

  Widget _buildDistrictDropdown() {
    return SizedBox(
      width: 300.0,
      child: DropdownButtonFormField<String>(
        value: _selectedDistrict,
        decoration: InputDecoration(
          labelText: 'Select your District',
          border: const OutlineInputBorder(),
          labelStyle: TextStyle(
            color: const Color(0xFF203982).withOpacity(0.7),
            fontSize: 13.0,
          ),
          contentPadding: const EdgeInsets.symmetric(
            vertical: 8.0,
            horizontal: 10.0,
          ),
          prefixIcon: ShaderMask(
            shaderCallback: (Rect bounds) {
              return const LinearGradient(
                colors: [Color(0xFF203982), Colors.red],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ).createShader(bounds);
            },
            child: Icon(
              Icons.location_city, // ✅ FIXED: Replaced 'icon' with a valid icon
              color: Colors.red.shade100,
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
        onChanged: (String? newValue) {
          setState(() {
            _selectedDistrict = newValue;
            _tehsils.clear(); // Clear previous tehsils
            _selectedTeshsil = null; // Reset tehsil selection
          });

          if (newValue != null) {
            _fetchTehsils(newValue); // Fetch tehsils for the selected district
          }
        },
        items: _districts.map<DropdownMenuItem<String>>((String district) {
          return DropdownMenuItem<String>(
            value: district,
            child: Text(
              district,
              style: const TextStyle(
                color: Color(0xFF203982),
                fontWeight: FontWeight.w400,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildTehsilDropdown() {
    return SizedBox(
      width: 300.0,
      child: DropdownButtonFormField<String>(
        value: _selectedTeshsil,
        decoration: InputDecoration(
          labelText: 'Select your Tehsil',
          border: const OutlineInputBorder(),
          labelStyle: TextStyle(
            color: const Color(0xFF203982).withOpacity(0.7),
            fontSize: 13.0,
          ),
          contentPadding: const EdgeInsets.symmetric(
            vertical: 8.0,
            horizontal: 10.0,
          ),
          prefixIcon: ShaderMask(
            shaderCallback: (Rect bounds) {
              return const LinearGradient(
                colors: [Color(0xFF203982), Colors.red],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ).createShader(bounds);
            },
            child: Icon(
              Icons.location_city, // ✅ FIXED: Replaced 'icon' with a valid icon
              color: Colors.red.shade100,
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
        onChanged: (String? newValue) {
          setState(() {
            _selectedTeshsil = newValue;
          });
        },
        items: _tehsils.map<DropdownMenuItem<String>>((String tehsil) {
          return DropdownMenuItem<String>(
            value: tehsil,
            child: Text(
              tehsil,
              style: const TextStyle(
                color: Color(0xFF203982),
                fontWeight: FontWeight.w400,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildUrgencyDropdown() {
    List<String> urgencyLevels = ["Low", "Medium", "High", "Critical"];

    return SizedBox(
      width: 300.0,
      child: DropdownButtonFormField<String>(
        value: _selectedUrgency,
        decoration: InputDecoration(
          labelText: 'Select Urgency Level',
          border: const OutlineInputBorder(),
          labelStyle: TextStyle(
            color: const Color(0xFF203982).withOpacity(0.7),
            fontSize: 13.0,
          ),
          contentPadding: const EdgeInsets.symmetric(
            vertical: 8.0,
            horizontal: 10.0,
          ),
          prefixIcon: ShaderMask(
            shaderCallback: (Rect bounds) {
              return const LinearGradient(
                colors: [Color(0xFF203982), Colors.red],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ).createShader(bounds);
            },
            child: Icon(
              Icons.warning_amber_rounded, // Updated icon for urgency
              color: Colors.red.shade100,
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
        onChanged: (String? newValue) {
          setState(() {
            _selectedUrgency = newValue;
          });
        },
        items: urgencyLevels.map<DropdownMenuItem<String>>((String level) {
          return DropdownMenuItem<String>(
            value: level,
            child: Text(
              level,
              style: const TextStyle(
                color: Color(0xFF203982),
                fontWeight: FontWeight.w400,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildRelationshipDropdown() {
    List<String> relationShip = ["Self", "Relative", "Family", "Others"];
    return SizedBox(
      width: 300.0,
      child: DropdownButtonFormField<String>(
        value: _selectedRelationShip,
        decoration: InputDecoration(
          labelText: 'Relationship With Victim',
          border: const OutlineInputBorder(),
          labelStyle: TextStyle(
            color: const Color(0xFF203982).withOpacity(0.7),
            fontSize: 13.0,
          ),
          contentPadding: const EdgeInsets.symmetric(
            vertical: 8.0,
            horizontal: 10.0,
          ),
          prefixIcon: ShaderMask(
            shaderCallback: (Rect bounds) {
              return const LinearGradient(
                colors: [Color(0xFF203982), Colors.red],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ).createShader(bounds);
            },
            child: Icon(
              Icons.handshake, // ✅ FIXED: Replaced 'icon' with a valid icon
              color: Colors.red.shade100,
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
        onChanged: (String? newValue) {
          setState(() {
            _selectedRelationShip = newValue;
          });
        },
        items: relationShip.map<DropdownMenuItem<String>>((String tehsil) {
          return DropdownMenuItem<String>(
            value: tehsil,
            child: Text(
              tehsil,
              style: const TextStyle(
                color: Color(0xFF203982),
                fontWeight: FontWeight.w400,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildVictimHealthDropdown() {
    List<String> victimHealth = ["Stable", "Critical", "Injured", "Others"];
    return SizedBox(
      width: 300.0,
      child: DropdownButtonFormField<String>(
        value: _selectedVictimHealth,
        decoration: InputDecoration(
          labelText: 'Victim Health Status',
          border: const OutlineInputBorder(),
          labelStyle: TextStyle(
            color: const Color(0xFF203982).withOpacity(0.7),
            fontSize: 13.0,
          ),
          contentPadding: const EdgeInsets.symmetric(
            vertical: 8.0,
            horizontal: 10.0,
          ),
          prefixIcon: ShaderMask(
            shaderCallback: (Rect bounds) {
              return const LinearGradient(
                colors: [Color(0xFF203982), Colors.red],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ).createShader(bounds);
            },
            child: Icon(
              Icons
                  .local_hospital, // ✅ FIXED: Replaced 'icon' with a valid icon
              color: Colors.red.shade100,
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
        onChanged: (String? newValue) {
          setState(() {
            _selectedVictimHealth = newValue;
          });
        },
        items: victimHealth.map<DropdownMenuItem<String>>((String tehsil) {
          return DropdownMenuItem<String>(
            value: tehsil,
            child: Text(
              tehsil,
              style: const TextStyle(
                color: Color(0xFF203982),
                fontWeight: FontWeight.w400,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildIncidentTypeDropdown() {
    List<String> incidentType = [
      "Theft & Robbery",
      "Assault & Violence",
      "Fraud & Cybercrime",
      "Harassment & Threats",
      "Others",
    ];
    return SizedBox(
      width: 300.0,
      child: DropdownButtonFormField<String>(
        value: _selectedIncidentType,
        decoration: InputDecoration(
          labelText: 'Select Incident Type',
          border: const OutlineInputBorder(),
          labelStyle: TextStyle(
            color: const Color(0xFF203982).withOpacity(0.7),
            fontSize: 13.0,
          ),
          contentPadding: const EdgeInsets.symmetric(
            vertical: 8.0,
            horizontal: 10.0,
          ),
          prefixIcon: ShaderMask(
            shaderCallback: (Rect bounds) {
              return const LinearGradient(
                colors: [Color(0xFF203982), Colors.red],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ).createShader(bounds);
            },
            child: Icon(
              Icons.emergency, //
              color: Colors.red.shade100,
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
        onChanged: (String? newValue) {
          setState(() {
            _selectedIncidentType = newValue;
          });
        },
        items: incidentType.map<DropdownMenuItem<String>>((String tehsil) {
          return DropdownMenuItem<String>(
            value: tehsil,
            child: Text(
              tehsil,
              style: const TextStyle(
                color: Color(0xFF203982),
                fontWeight: FontWeight.w400,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildStepContent(List<Widget> fields) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: fields
          .map((field) => Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: field,
              ))
          .toList(),
    );
  }
}
