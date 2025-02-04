import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';

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
  final TextEditingController incidentReportDateController =
      TextEditingController();
  final TextEditingController incidentDateController = TextEditingController();
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
  final TextEditingController reportIncidentController =
      TextEditingController();

  List<String> _districts = [];
  List<String> _tehsils = [];
  String? _selectedDistrict;
  String? _selectedTeshsil;
  String? _selectedUrgency;
  String? _selectedVictimHealth;
  String? _selectedIncidentType;
  String? _selectedRelationShip;
  File? selectedFile;
  String fileName = "No file selected";

  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    // Remove all non-digit characters
    String digits = newValue.text.replaceAll(RegExp(r'\D'), '');

    // Restrict input to a maximum of 13 digits
    if (digits.length > 13) {
      digits = digits.substring(0, 13);
    }

    // Add hyphens automatically
    String formatted = '';
    if (digits.length <= 5) {
      formatted = digits; // First 5 digits
    } else if (digits.length <= 13) {
      formatted =
          '${digits.substring(0, 5)}-${digits.substring(5)}'; // Add first hyphen
    } else {
      formatted =
          '${digits.substring(0, 5)}-${digits.substring(5, 12)}-${digits.substring(12)}'; // Add second hyphen
    }

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }

  final _formKey = GlobalKey<FormState>();

  void submitForm() {
    if (_formKey.currentState!.validate()) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text("Confirm Submission"),
            content: SingleChildScrollView(
              child: ListBody(children: [
                Text(
                    "Full Name: ${fullNameController.text.isNotEmpty ? fullNameController.text : 'No data'}"),
                Text(
                    "Email: ${emailController.text.isNotEmpty ? emailController.text : 'No data'}"),
                Text(
                    "CNIC: ${cnicController.text.isNotEmpty ? cnicController.text : 'No data'}"),
                Text(
                    "Phone: ${phoneController.text.isNotEmpty ? phoneController.text : 'No data'}"),
                Text(
                    "Incident Location: ${incidentLocationController.text.isNotEmpty ? incidentLocationController.text : 'No data'}"),
                Text(
                    "Incident Date: ${incidentDateController.text.isNotEmpty ? incidentDateController.text : 'No data'}"),
                Text(
                    "Date of Reporting: ${incidentReportDateController.text.isNotEmpty ? incidentReportDateController.text : 'No data'}"),
                Text(
                    "File: ${fileName.isEmpty ? 'No file selected' : fileName}"),
                Text(
                    "Incident Subject: ${subjectController.text.isNotEmpty ? subjectController.text : 'No data'}"),
                Text(
                    "Victim Name: ${victimNameController.text.isNotEmpty ? victimNameController.text : 'No data'}"),
                Text(
                    "Victim CNIC: ${victimCnicController.text.isNotEmpty ? victimCnicController.text : 'No data'}"),
                Text(
                    "Victim Address: ${victimAddressController.text.isNotEmpty ? victimAddressController.text : 'No data'}"),
                Text(
                    "Victim Contact: ${victimContactController.text.isNotEmpty ? victimContactController.text : 'No data'}"),
                Text(
                    "Suspect Name: ${suspectNameController.text.isNotEmpty ? suspectNameController.text : 'No data'}"),
                Text(
                    "Suspect Address: ${suspectAddressController.text.isNotEmpty ? suspectAddressController.text : 'No data'}"),
                Text(
                    "Suspect Description: ${suspectDetailController.text.isNotEmpty ? suspectDetailController.text : 'No data'}"),
                Text(
                    "Witness Name: ${witnessNameController.text.isNotEmpty ? witnessNameController.text : 'No data'}"),
                Text(
                    "Witness Contact: ${witnessContactController.text.isNotEmpty ? witnessContactController.text : 'No data'}"),
              ]),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text("Cancel"),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Form Submitted Successfully!"),
                      backgroundColor: Colors.green,
                    ),
                  );
                },
                child: const Text("Submit"),
              ),
            ],
          );
        },
      );
    }
  }

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

  Future<void> pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.any, // Allows selection of all file types
    );

    if (result != null) {
      setState(() {
        selectedFile = File(result.files.single.path!);
        fileName = result.files.single.name;
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
                          const SizedBox(height: 20.0),

                          // Step Number 1 - Personal Information
                          const Text(
                            'Personal Information',
                            style: TextStyle(
                              color: Color(0xFF2A489E),
                              fontWeight: FontWeight.w500,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Form(
                            key:
                                _formKey, // Wrap the form in a Form widget for validation
                            child: Column(
                              children: [
                                _buildTextField(fullNameController,
                                    'Complainant Name ', Icons.person, isRequired: true,),
                                const SizedBox(height: 10),
                                _buildTextField(emailController,
                                    'Email Address', Icons.credit_card, isRequired: true, isEmail: true),
                                const SizedBox(height: 10),
                                _buildTextField(
                                    cnicController, 'CNIC', Icons.credit_card,
                                    isCNIC: true),
                                const SizedBox(height: 10),
                                _buildTextField(phoneController,
                                    'Contact Number', Icons.phone, isRequired: true,),
                                const SizedBox(height: 10),
                                _buildRelationshipDropdown(),

                                // Step Number 2 - Incident Detail
                                const SizedBox(height: 20.0),
                                const Text(
                                  'Incident Detail',
                                  style: TextStyle(
                                    color: Color(0xFF2A489E),
                                    fontWeight: FontWeight.w500,
                                    fontSize: 16,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                _buildIncidentTypeDropdown(),
                                const SizedBox(height: 10),
                                _buildTextField(subjectController,
                                    'Incident Subject', Icons.subject, isRequired: true,),
                                const SizedBox(height: 10),
                                _buildTextField(
                                  incidentDateController,
                                  'Incident Date-Time',
                                  Icons.calendar_today,
                                  isDateField: true,
                                  isRequired: true,
                                ),
                                const SizedBox(height: 10),
                                _buildTextField(
                                  incidentReportDateController,
                                  'Date Of Reporting',
                                  Icons.calendar_today,
                                  isDateField: true,
                                  isRequired: true,
                                ),
                                const SizedBox(height: 10),
                                _buildTextField(incidentLocationController,
                                    'Incident Location', Icons.location_on,
                                  isRequired: true,),
                                const SizedBox(height: 10),
                                _buildDistrictDropdown(),
                                const SizedBox(height: 10),
                                _buildTehsilDropdown(),
                                const SizedBox(height: 10),
                                _buildUrgencyDropdown(),
                                const SizedBox(height: 10),
                                _buildTextField(
                                  reportIncidentController,
                                  'Incident Detail / Victim Statement',
                                  Icons.description,
                                  isMultiline: true,
                                  isRequired: true,
                                ),


                                // Step Number 3 - Victim Information
                                const SizedBox(height: 20.0),
                                const Text(
                                  'Victim Information',
                                  style: TextStyle(
                                    color: Color(0xFF2A489E),
                                    fontWeight: FontWeight.w500,
                                    fontSize: 16,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                _buildTextField(victimNameController,
                                    'Victim Name', Icons.person,
                                  isRequired: true,),
                                const SizedBox(height: 10),
                                _buildTextField(victimCnicController,
                                    'Victim CNIC', Icons.credit_card,
                                    isCNIC: true),
                                const SizedBox(height: 10),
                                _buildTextField(victimAddressController,
                                    'Victim Address', Icons.map,
                                  isRequired: true,),
                                const SizedBox(height: 10),
                                _buildTextField(victimContactController,
                                    'Victim Contact', Icons.phone,
                                  isRequired: true,),
                                const SizedBox(height: 10),
                                _buildVictimHealthDropdown(),

                                // Step Number 4 - Suspect Information (Optional)
                                const SizedBox(height: 20.0),
                                const Text(
                                  'Suspect Information (Optional)',
                                  style: TextStyle(
                                    color: Color(0xFF2A489E),
                                    fontWeight: FontWeight.w500,
                                    fontSize: 16,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                _buildTextField(suspectNameController,
                                    'Suspect Name', Icons.person),
                                const SizedBox(height: 10),
                                _buildTextField(suspectAddressController,
                                    'Suspect Address', Icons.map),
                                const SizedBox(height: 10),
                                _buildTextField(suspectDetailController,
                                    'Suspect Description', Icons.description),

                                // Step Number 5 - Witness Information (Optional)
                                const SizedBox(height: 20.0),
                                const Text(
                                  'Witness Information (Optional)',
                                  style: TextStyle(
                                    color: Color(0xFF2A489E),
                                    fontWeight: FontWeight.w500,
                                    fontSize: 16,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                _buildTextField(witnessNameController,
                                    'Witness Name', Icons.person),
                                const SizedBox(height: 10),
                                _buildTextField(witnessContactController,
                                    'Witness Contact', Icons.phone),

                                const SizedBox(height: 22),
                                SizedBox(
                                  height: 1.0,
                                  width: 300.0,
                                  child: Center(
                                    child: Container(
                                      margin: const EdgeInsetsDirectional.only(
                                          start: 1.0, end: 4.0),
                                      height: 5.0,
                                      color: const Color(0xFF2A489E)
                                          .withAlpha((0.5 * 255).toInt()),
                                    ),
                                  ),
                                ),

                                // File Upload Section
                                Center(
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          ElevatedButton(
                                            style: ElevatedButton.styleFrom(
                                              foregroundColor: Colors.white,
                                              backgroundColor:
                                                  Color(0xFF2A489E),
                                            ),
                                            onPressed:
                                                pickFile, // Your file picker function
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                const Icon(Icons.upload_file,
                                                    color: Colors.white),
                                                const SizedBox(width: 15),
                                                const Text('Browse'),
                                              ],
                                            ),
                                          ),
                                          const SizedBox(height: 10),
                                          Text(
                                              fileName.isEmpty
                                                  ? 'No file selected'
                                                  : fileName,
                                              style: TextStyle(fontSize: 11)),
                                        ],
                                      ),
                                      const SizedBox(width: 55),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          const Text('• Document 25 Mb',
                                              style: TextStyle(
                                                  fontSize: 12,
                                                  color: Color(0xFF2A489E))),
                                          const Text('• Picture 25 Mb',
                                              style: TextStyle(
                                                  fontSize: 12,
                                                  color: Color(0xFF2A489E))),
                                          const Text('• Video 50 Mb',
                                              style: TextStyle(
                                                  fontSize: 12,
                                                  color: Color(0xFF2A489E))),
                                          const Text('• Audio 50 Mb',
                                              style: TextStyle(
                                                  fontSize: 12,
                                                  color: Color(0xFF2A489E))),
                                        ],
                                      ),
                                    ],
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
                                    onPressed: () {
                                      if (_formKey.currentState?.validate() ??
                                          false) {
                                        submitForm(); // Calling the submit method
                                      } else {
                                        print(
                                            'Please fill out all required fields correctly.');
                                      }
                                    },
                                    child: const Text('Submit'),
                                  ),
                                ),
                                const SizedBox(height: 60),
                              ],
                            ),
                          ),
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
      TextEditingController controller,
      String labelText,
      IconData icon, {
        bool isDateField = false,
        bool isRequired = false,
        bool isMultiline = false,
        bool isCNIC = false,
        bool isPhoneNumber = false,
        bool isEmail = false, // Added isEmail flag
      }) {
    return SizedBox(
      width: 300.0,
      height: isMultiline ? 170.0 : null, // Increase height for multiline field
      child: TextFormField(
        controller: controller,
        validator: (value) {
          if (isRequired && (value == null || value.isEmpty)) {
            return 'This field is required';
          }

          // CNIC Validation
          if (isCNIC && (value == null || value.isEmpty || !RegExp(r'^\d{5}-\d{7}-\d{1}$').hasMatch(value))) {
            return 'Please enter a valid CNIC (format: 00000-0000000-0)';
          }

          // Phone Number Validation (11 digits only)
          if (isPhoneNumber && (value == null || value.isEmpty || !RegExp(r'^\d{11}$').hasMatch(value))) {
            return 'Please enter a valid 11-digit phone number';
          }

          // Email Validation
          if (isEmail && (value == null || value.isEmpty || !RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$').hasMatch(value))) {
            return 'Please enter a valid email address';
          }

          return null;
        },
        onTap: isDateField ? () => _selectDate(context, controller) : null,
        readOnly: isDateField,
        maxLines: isMultiline ? null : 1,
        minLines: isMultiline ? 5 : 1,
        keyboardType: isMultiline ? TextInputType.multiline : TextInputType.text,
        style: TextStyle(
          color: Color(0xFF203982), // Set the text color to blue
          fontSize: 14.0, // Optional: Set a custom font size for text inside the field
        ),
        decoration: InputDecoration(
          border: const OutlineInputBorder(),
          labelText: labelText, // Shows the label inside the field
          labelStyle: TextStyle(
            color: const Color(0xFF203982).withAlpha((0.7 * 255).toInt()),
            fontSize: 13.0,
          ),
          contentPadding: const EdgeInsets.symmetric(
            vertical: 12.0, // Adjust vertical padding
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
          errorBorder: const OutlineInputBorder(
            borderSide: BorderSide(
              color: Colors.red,
              width: 1.0,
            ),
          ),
          focusedErrorBorder: const OutlineInputBorder(
            borderSide: BorderSide(
              color: Colors.red,
              width: 1.0,
            ),
          ),
          hintText: 'Enter $labelText', // Optional: Show hint text when the field is empty
          hintStyle: TextStyle(
            color: Color(0xFF203982).withAlpha((0.5 * 255).toInt()),
          ),
        ),
        inputFormatters: [
          if (isCNIC) ...[
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(13), // Allowing maximum 15 characters (13 digits + 2 hyphens)
            TextInputFormatter.withFunction((oldValue, newValue) {
              // Formatting CNIC as 00000-0000000-0
              String text = newValue.text.replaceAll(RegExp(r'[^0-9]'), ''); // Remove any non-digit characters

              if (text.length > 5) {
                text = text.substring(0, 5) + '-' + text.substring(5);
              }
              if (text.length > 13) {
                text = text.substring(0, 13) + '-' + text.substring(13);
              }

              return TextEditingValue(
                text: text,
                selection: TextSelection.collapsed(offset: text.length),
              );
            }),
          ],
          if (isPhoneNumber) ...[
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(11), // Limit to 11 digits only
          ],
        ],
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
            color: const Color(0xFF203982).withAlpha((0.7 * 255).toInt()),
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
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please select a district'; // Error message when no district is selected
          }
          return null; // No error if a value is selected
        },
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
            color: const Color(0xFF203982).withAlpha((0.7 * 255).toInt()),
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
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please select a tehsil'; // Error message when no tehsil is selected
          }
          return null; // No error if a value is selected
        },
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
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please select an urgency level'; // Make it required
          }
          return null;
        },
        decoration: InputDecoration(
          labelText: 'Select Urgency Level',
          border: const OutlineInputBorder(),
          labelStyle: TextStyle(
            color: const Color(0xFF203982).withAlpha((0.7 * 255).toInt()),
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
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please select a relationship'; // Make it required
          }
          return null;
        },
        decoration: InputDecoration(
          labelText: 'Relationship With Victim',
          border: const OutlineInputBorder(),
          labelStyle: TextStyle(
            color: const Color(0xFF203982).withAlpha((0.7 * 255).toInt()),
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
        items: relationShip.map<DropdownMenuItem<String>>((String relationship) {
          return DropdownMenuItem<String>(
            value: relationship,
            child: Text(
              relationship,
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
            color: const Color(0xFF203982).withAlpha((0.7 * 255).toInt()),
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
              Icons.local_hospital, // Replaced 'icon' with a valid icon
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
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please select victim health status';
          }
          return null;
        },
        items: victimHealth.map<DropdownMenuItem<String>>((String health) {
          return DropdownMenuItem<String>(
            value: health,
            child: Text(
              health,
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
            color: const Color(0xFF203982).withAlpha((0.7 * 255).toInt()),
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
              Icons.emergency, // Icon for incident type
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
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please select an incident type'; // Error message when no incident type is selected
          }
          return null; // No error if a value is selected
        },
        onChanged: (String? newValue) {
          setState(() {
            _selectedIncidentType = newValue;
          });
        },
        items: incidentType.map<DropdownMenuItem<String>>((String incident) {
          return DropdownMenuItem<String>(
            value: incident,
            child: Text(
              incident,
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

}
