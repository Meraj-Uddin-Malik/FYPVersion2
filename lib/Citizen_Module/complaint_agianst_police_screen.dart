import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:art_sweetalert/art_sweetalert.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path/path.dart' as path;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:io';

class ComplaintAgianstPoliceScreen extends StatefulWidget {
  const ComplaintAgianstPoliceScreen({super.key});

  @override
  State<ComplaintAgianstPoliceScreen> createState() => _ComplaintAgianstPoliceScreenState();
}

class _ComplaintAgianstPoliceScreenState extends State<ComplaintAgianstPoliceScreen> {
  final TextEditingController fullNameController = TextEditingController();
  final TextEditingController cnicController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController subjectController = TextEditingController();
  final TextEditingController incidentDateController = TextEditingController();
  final TextEditingController incidentReportDateController = TextEditingController();
  final TextEditingController incidentLocationController = TextEditingController();
  final TextEditingController reportIncidentController = TextEditingController(); // Incident Description

// New fields
  final TextEditingController officerNameController = TextEditingController(); // Officer Name / Badge Number (if known)
  final TextEditingController evidenceDescriptionController = TextEditingController(); // Evidence Description
  final TextEditingController additionalCommentsController = TextEditingController(); // Additional Comments


  final TextEditingController victimEmailController = TextEditingController();

  String fileName = "No file selected";
  final _formKey = GlobalKey<FormState>();
  List<String> _districts = [];
  List<String> _tehsils = [];
  String? _selectedDistrict;
  String? _selectedGender;
  File? selectedFile;
  String? fileUrl;

  String? userId = FirebaseAuth.instance.currentUser?.uid;


  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue)
  {
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

  void submitForm() async {
    if (_formKey.currentState!.validate()) {
      ArtSweetAlert.show(
        context: context,
        artDialogArgs: ArtDialogArgs(
          type: ArtSweetAlertType.info,
          title: "Confirm Submission",
          text: "Are you sure you want to submit the form?",
          confirmButtonText: "Submit",
          cancelButtonText: "Cancel",
          onConfirm: () async {
            Navigator.of(context).pop(); // Close the SweetAlert dialog

            try {
              if (selectedFile != null) {
                await uploadFile(selectedFile!); // Upload the selected file
              }

              // Get logged-in user's UID
              String? userId = FirebaseAuth.instance.currentUser?.uid;
              if (userId == null) {
                throw "User not logged in!";
              }

              // Reference to Firestore collection
              CollectionReference preFIRCollection =
              FirebaseFirestore.instance.collection('pre_fir');

              // Add form data to Firestore with userId
              await preFIRCollection.add({
                'complainant_name': fullNameController.text,
                'email': emailController.text,
                'cnic': cnicController.text,
                'contact': phoneController.text,
                'incident_subject': subjectController.text,
                'incident_date': incidentDateController.text,
                'reporting_date': incidentReportDateController.text,
                'incident_location': incidentLocationController.text,
                'incident_detail': reportIncidentController.text,
                'victim_gender': _selectedGender,
                'file_url': fileUrl,
                'status': 'New',
                'timestamp': FieldValue.serverTimestamp(),
                'complainant_gender': _selectedGender,
                'userId': userId, // ✅ Attach UID
              });

              // Show success message
              ArtSweetAlert.show(
                context: context,
                artDialogArgs: ArtDialogArgs(
                  type: ArtSweetAlertType.success,
                  title: "Success",
                  text: "FIR Submitted Successfully!",
                  confirmButtonText: "OK",
                ),
              );

              // Reset form and fields
              _formKey.currentState?.reset();
              clearControllers();
            } catch (e) {
              // Show error message
              ArtSweetAlert.show(
                context: context,
                artDialogArgs: ArtDialogArgs(
                  type: ArtSweetAlertType.warning,
                  title: "Error",
                  text: "Error submitting form: $e",
                  confirmButtonText: "OK",
                ),
              );
            }
          },
          onCancel: () {
            Navigator.of(context).pop();
          },
        ),
      );
    }
  }


  // void submitForm() async {
  //   if (_formKey.currentState!.validate()) {
  //     ArtSweetAlert.show(
  //       context: context,
  //       artDialogArgs: ArtDialogArgs(
  //         type: ArtSweetAlertType.info, // Info type for confirmation dialog
  //         title: "Confirm Submission",
  //         text: "Are you sure you want to submit the form?",
  //         confirmButtonText: "Submit",
  //         cancelButtonText: "Cancel",
  //         onConfirm: () async {
  //           Navigator.of(context).pop(); // Close the SweetAlert dialog
  //
  //           try {
  //             if (selectedFile != null) {
  //               // Upload the selected file
  //               await uploadFile(selectedFile!);
  //             }
  //
  //             // Reference to Firestore collection
  //             CollectionReference preFIRCollection = FirebaseFirestore.instance.collection('pre_fir');
  //
  //             // Add form data to Firestore with default status "New"
  //             await preFIRCollection.add({
  //               'complainant_name': fullNameController.text,
  //               'email': emailController.text,
  //               'cnic': cnicController.text,
  //               'contact': phoneController.text,
  //               'incident_subject': subjectController.text,
  //               'incident_date': incidentDateController.text,
  //               'reporting_date': incidentReportDateController.text,
  //               'incident_location': incidentLocationController.text,
  //               'incident_detail': reportIncidentController.text,
  //               'victim_name': victimNameController.text,
  //               'victim_cnic': victimCnicController.text,
  //               'victim_address': victimAddressController.text,
  //               'victim_contact': victimContactController.text,
  //               'victim_gender': _selectedGender, // Use gender for victim gender
  //               'suspect_name': suspectNameController.text,
  //               'suspect_address': suspectAddressController.text,
  //               'suspect_description': suspectDetailController.text,
  //               'witness_name': witnessNameController.text,
  //               'witness_contact': witnessContactController.text,
  //               'file_url': fileUrl, // Store file URL from Firebase Storage
  //               'status': 'New', // Default status as "New"
  //               'timestamp': FieldValue.serverTimestamp(), // Server timestamp
  //               'complainant_gender': _selectedGender, // Use gender for complainant gender
  //             });
  //
  //             // Show success message
  //             ArtSweetAlert.show(
  //               context: context,
  //               artDialogArgs: ArtDialogArgs(
  //                 type: ArtSweetAlertType.success, // Success type
  //                 title: "Success",
  //                 text: "FIR Submitted Successfully!",
  //                 confirmButtonText: "OK",
  //               ),
  //             );
  //
  //             // Reset form and fields
  //             _formKey.currentState?.reset(); // Reset the form
  //             clearControllers();
  //           } catch (e) {
  //             // Show error message
  //             ArtSweetAlert.show(
  //               context: context,
  //               artDialogArgs: ArtDialogArgs(
  //                 type: ArtSweetAlertType.warning, // Warning type (since error is not available)
  //                 title: "Error",
  //                 text: "Error submitting form: $e",
  //                 confirmButtonText: "OK",
  //               ),
  //             );
  //           }
  //         },
  //         onCancel: () {
  //           Navigator.of(context).pop(); // Close the SweetAlert dialog on cancel
  //         },
  //       ),
  //     );
  //   }
  // }

  void clearControllers() {
    fullNameController.clear();
    emailController.clear();
    cnicController.clear();
    phoneController.clear();
    subjectController.clear();
    incidentDateController.clear();
    incidentReportDateController.clear();
    incidentLocationController.clear();
    reportIncidentController.clear();
    _selectedGender = null; // Reset the gender value
    fileName = '';
    fileUrl = '';
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

  Future<void> uploadFile(File file) async {
    try {
      String fileName = path.basename(file.path); // Get the file name
      FirebaseStorage storage = FirebaseStorage.instance;
      Reference ref = storage.ref().child('uploads/$fileName');

      // Upload the file to Firebase Storage
      UploadTask uploadTask = ref.putFile(file);

      // Get the file's URL after it's uploaded
      TaskSnapshot snapshot = await uploadTask;
      fileUrl = await snapshot.ref.getDownloadURL();

      print("File uploaded successfully. URL: $fileUrl");
    } catch (e) {
      print("Error uploading file: $e");
    }
  }

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

  @override
  void initState() {
    super.initState();
    _fetchDistricts(); // Fetch districts when the screen loads
  }


  // Date Picker
  Future<void> _selectDate(BuildContext context, TextEditingController controller) async {
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
                          const SizedBox(height: 20.0),

                          // Step Number 1 - Complainant's Information
                          const Text(
                            'Complainant Information',
                            style: TextStyle(
                              color: Color(0xFF2A489E),
                              fontWeight: FontWeight.w500,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Form(
                            key: _formKey, // Wrap the form in a Form widget for validation
                            child: Column(
                              children: [
                                _buildTextField(fullNameController, 'Complainant Name', Icons.person, isRequired: true),
                                const SizedBox(height: 10),
                                _buildTextField(emailController, 'Email Address', Icons.email, isRequired: true, isEmail: true),
                                const SizedBox(height: 10),
                                _buildTextField(cnicController, 'Complainant CNIC', Icons.credit_card, isCNIC: true),
                                const SizedBox(height: 10),
                                _buildTextField(phoneController, 'Contact Number', Icons.phone, isRequired: true),
                                const SizedBox(height: 20),

                                // Step Number 2 - Complaint Details
                                const Text(
                                  'Complaint Details',
                                  style: TextStyle(
                                    color: Color(0xFF2A489E),
                                    fontWeight: FontWeight.w500,
                                    fontSize: 16,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                _buildTextField(subjectController, 'Complaint Subject', Icons.subject, isRequired: true),
                                const SizedBox(height: 10),
                                _buildTextField(incidentDateController, 'Incident Date-Time', Icons.calendar_today, isDateField: true, isRequired: true),
                                const SizedBox(height: 10),
                                _buildTextField(incidentLocationController, 'Incident Location', Icons.location_on, isRequired: true),
                                const SizedBox(height: 10),
                                _buildTextField(reportIncidentController, 'Incident Detail', Icons.description, isMultiline: true, isRequired: true),

                                const Text(
                                  'Police Officer(s) Involved',
                                  style: TextStyle(
                                    color: Color(0xFF2A489E),
                                    fontWeight: FontWeight.w500,
                                    fontSize: 16,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                _buildTextField(officerNameController, 'Officer Name / Badge No', Icons.person),
                                const SizedBox(height: 15),

                                const Text(
                                  'Additional Information (Optional)',
                                  style: TextStyle(
                                    color: Color(0xFF2A489E),
                                    fontWeight: FontWeight.w500,
                                    fontSize: 16,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                _buildTextField(additionalCommentsController, 'Any Additional Comments', Icons.comment),

                                const SizedBox(height: 22),
                                SizedBox(
                                  height: 1.0,
                                  width: 300.0,
                                  child: Center(
                                    child: Container(
                                      margin: const EdgeInsetsDirectional.only(start: 1.0, end: 4.0),
                                      height: 5.0,
                                      color: const Color(0xFF2A489E).withAlpha((0.5 * 255).toInt()),
                                    ),
                                  ),
                                ),

                                // File Upload Section (if needed)
                                Center(
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        children: [
                                          ElevatedButton(
                                            style: ElevatedButton.styleFrom(
                                              foregroundColor: Colors.white,
                                              backgroundColor: Color(0xFF2A489E),
                                            ),
                                            onPressed: pickFile, // Your file picker function
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                const Icon(Icons.upload_file, color: Colors.white),
                                                const SizedBox(width: 15),
                                                const Text('Browse'),
                                              ],
                                            ),
                                          ),
                                          const SizedBox(height: 10),
                                          Text(fileName.isEmpty ? 'No file selected' : fileName, style: TextStyle(fontSize: 11)),
                                        ],
                                      ),
                                      const SizedBox(width: 55),
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          const Text('• Document 25 Mb', style: TextStyle(fontSize: 12, color: Color(0xFF2A489E))),
                                          const Text('• Picture 25 Mb', style: TextStyle(fontSize: 12, color: Color(0xFF2A489E))),
                                          const Text('• Video 50 Mb', style: TextStyle(fontSize: 12, color: Color(0xFF2A489E))),
                                          const Text('• Audio 50 Mb', style: TextStyle(fontSize: 12, color: Color(0xFF2A489E))),
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
                                      if (_formKey.currentState?.validate() ?? false) {
                                        submitForm(); // Calling the submit method
                                      } else {
                                        print('Please fill out all required fields correctly.');
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

}
