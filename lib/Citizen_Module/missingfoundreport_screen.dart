import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:art_sweetalert/art_sweetalert.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path/path.dart' as path;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:io';

class MissingfoundreportScreen extends StatefulWidget {
  const MissingfoundreportScreen({super.key});

  @override
  State<MissingfoundreportScreen> createState() =>
      _MissingfoundreportScreenState();
}

class _MissingfoundreportScreenState extends State<MissingfoundreportScreen> {
  final TextEditingController fullNameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController cnicController = TextEditingController();
  final TextEditingController incidentDateController = TextEditingController();
  final TextEditingController incidentLocationController =
      TextEditingController();
  final TextEditingController itemDescriptionController =
      TextEditingController();
  final TextEditingController itemConditionController = TextEditingController();
  final TextEditingController identificationMarksController =
      TextEditingController();
  final TextEditingController personNameController = TextEditingController();
  final TextEditingController personAgeController = TextEditingController();
  final TextEditingController clothingDescriptionController =
      TextEditingController();
  final TextEditingController physicalFeaturesController =
      TextEditingController();
  final TextEditingController additionalCommentsController =
      TextEditingController();
  TextEditingController dobController = TextEditingController();


  String fileName = "No file selected";
  final _formKey = GlobalKey<FormState>();

  String? _selectedReportType;
  String? _selectedItemCategory;
  String? _selectedItemCondition;
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

  void submitLostFoundReport() async {
    if (_formKey.currentState!.validate()) {
      ArtSweetAlert.show(
        context: context,
        artDialogArgs: ArtDialogArgs(
          type: ArtSweetAlertType.info,
          title: "Confirm Submission",
          text: "Are you sure you want to submit the Lost & Found report?",
          confirmButtonText: "Submit",
          cancelButtonText: "Cancel",
          onConfirm: () async {
            Navigator.of(context).pop(); // Close SweetAlert dialog

            try {
              // Get logged-in user's UID
              String? userId = FirebaseAuth.instance.currentUser?.uid;
              if (userId == null) {
                throw "User not logged in!";
              }

              // Reference to Firestore collection for lost & found reports
              CollectionReference lostFoundCollection = FirebaseFirestore
                  .instance
                  .collection('lost_found_reports');

              // Add form data to Firestore with userId
              await lostFoundCollection.add({
                'reporter_name': fullNameController.text,
                'contact_number': phoneController.text,
                'email': emailController.text,
                'cnic': cnicController.text,
                'report_type': _selectedReportType, // Add selected report type
                'incident_date': incidentDateController.text,
                'incident_location': incidentLocationController.text,
                'item_description': itemDescriptionController.text,
                'item_condition': itemConditionController.text,
                'identification_marks': identificationMarksController.text,
                'person_name': personNameController.text,
                'gender': _selectedGender,
                'dob': dobController.text,
                'clothing_description': clothingDescriptionController.text,
                'physical_features': physicalFeaturesController.text,
                'additional_comments': additionalCommentsController.text,
                'status': 'New', // Mark status as New
                'timestamp': FieldValue.serverTimestamp(),
                'userId': userId, // Attach the UID of the reporter
              });

              // Show success message
              ArtSweetAlert.show(
                context: context,
                artDialogArgs: ArtDialogArgs(
                  type: ArtSweetAlertType.success,
                  title: "Success",
                  text: "Lost & Found Report Submitted Successfully!",
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
                  text: "Error submitting report: $e",
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

  void clearControllers() {
    fullNameController.clear();
    emailController.clear();
    cnicController.clear();
    phoneController.clear();
    itemDescriptionController.clear();
    itemConditionController.clear();
    identificationMarksController.clear();
    personNameController.clear();
    clothingDescriptionController.clear();
    physicalFeaturesController.clear();
    additionalCommentsController.clear();
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
                      text: 'LOST FOUND INFORMATION ',
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
                      text: 'REPORT TO POLICE',
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
                      child: Column(children: [
                        const SizedBox(height: 20.0),
                        const Text(
                          'NOTE',
                          style: TextStyle(
                            color: Color(0xFFE22128),
                            fontWeight: FontWeight.w500,
                            fontSize: 12,
                          ),
                        ),
                        const Text(
                          'This form is for submitting Lost & Found'
                          'Reports to the police. \n'
                          'If you have found an item or have information about a missing \n'
                              'person, please provide the details. Your report helps the police \n'
                          'return lost items or locate missing individuals, contributing to community safety Thank you for your assistance!',
                          style: TextStyle(
                            color: Color(0xFF2A489E),
                            fontWeight: FontWeight.w400,
                            fontSize: 11,
                          ),
                          textAlign: TextAlign.center,

                        ),


                        const SizedBox(height: 20.0),
                        const Text(
                          'Reporter Information',
                          style: TextStyle(
                            color: Color(0xFF2A489E),
                            fontWeight: FontWeight.w500,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Form(
                          key: _formKey,
                          child: Column(
                            children: [
                              _buildTextField(fullNameController,
                                  'Reporter Name', Icons.person,
                                  isRequired: true),
                              const SizedBox(height: 10),
                              _buildTextField(phoneController, 'Contact Number',
                                  Icons.phone,
                                  isRequired: true),
                              const SizedBox(height: 10),
                              _buildTextField(
                                  emailController, 'Email Address', Icons.email,
                                  isEmail: true),
                              const SizedBox(height: 10),
                              _buildTextField(cnicController, 'CNIC (Optional)',
                                  Icons.credit_card,
                                  isCNIC: true),
                              const SizedBox(height: 20),

                              // Step Number 2 - Report Type
                              const Text(
                                'Report Type',
                                style: TextStyle(
                                  color: Color(0xFF2A489E),
                                  fontWeight: FontWeight.w500,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 10),
                              _buildReportTypeDropdown(),
                              const SizedBox(height: 10),
                              _buildTextField(incidentDateController,
                                  'Date-Time Found', Icons.calendar_today,
                                  isDateField: true, isRequired: true),
                              const SizedBox(height: 10),
                              _buildTextField(incidentLocationController,
                                  'Location Found', Icons.location_on,
                                  isRequired: true),
                              const SizedBox(height: 20),

                              // Step Number 3 - Item/Person Details
                              const Text(
                                'Details of Found Item / Person',
                                style: TextStyle(
                                  color: Color(0xFF2A489E),
                                  fontWeight: FontWeight.w500,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 10),
                              if (_selectedReportType == "Found Item") ...[
                                _buildItemCategoryDropdown(),
                                const SizedBox(height: 10),
                                _buildItemConditionDropdown(),
                                const SizedBox(height: 10),
                                _buildTextField(itemDescriptionController,
                                    'Item Description', Icons.description,
                                    isMultiline: true, isRequired: true),
// remove the space between them
                                _buildTextField(
                                    identificationMarksController,
                                    'Identification Marks (if any)',
                                    Icons.info),
                                const SizedBox(height: 10),
                              ] else if (_selectedReportType ==
                                  "Found Missing Person") ...[
                                _buildTextField(personNameController,
                                    'Person Name (if known)', Icons.person),
                                const SizedBox(height: 10),
                                _buildDateOfBirthField(),
                                const SizedBox(height: 10),
                                _buildGenderDropdown(),
                                const SizedBox(height: 10),
                                _buildTextField(clothingDescriptionController,
                                    'Clothing Description', Icons.checkroom,
                                    isMultiline: true, isRequired: true),
                                const SizedBox(height: 10),
                                _buildTextField(
                                    physicalFeaturesController,
                                    'Physical Features / Identifying Marks',
                                    Icons.info,
                                    isMultiline: true),
                              ],

                              const Text(
                                'Additional Information (Optional)',
                                style: TextStyle(
                                  color: Color(0xFF2A489E),
                                  fontWeight: FontWeight.w500,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 10),
                              _buildTextField(additionalCommentsController,
                                  'Any Additional Comments', Icons.comment),

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
                              const SizedBox(height: 10),
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
                              const SizedBox(height: 10),
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
                                      submitLostFoundReport();
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
                      ]),
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
          if (isCNIC &&
              (value == null ||
                  value.isEmpty ||
                  !RegExp(r'^\d{5}-\d{7}-\d{1}$').hasMatch(value))) {
            return 'Please enter a valid CNIC (format: 00000-0000000-0)';
          }

          // Phone Number Validation (11 digits only)
          if (isPhoneNumber &&
              (value == null ||
                  value.isEmpty ||
                  !RegExp(r'^\d{11}$').hasMatch(value))) {
            return 'Please enter a valid 11-digit phone number';
          }

          // Email Validation
          if (isEmail &&
              (value == null ||
                  value.isEmpty ||
                  !RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$')
                      .hasMatch(value))) {
            return 'Please enter a valid email address';
          }

          return null;
        },
        onTap: isDateField ? () => _selectDate(context, controller) : null,
        readOnly: isDateField,
        maxLines: isMultiline ? null : 1,
        minLines: isMultiline ? 5 : 1,
        keyboardType:
            isMultiline ? TextInputType.multiline : TextInputType.text,
        style: TextStyle(
          color: Color(0xFF203982), // Set the text color to blue
          fontSize:
              14.0, // Optional: Set a custom font size for text inside the field
        ),
        decoration: InputDecoration(
          border: const OutlineInputBorder(),
          labelText: labelText,
          // Shows the label inside the field
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
          hintText: 'Enter $labelText',
          // Optional: Show hint text when the field is empty
          hintStyle: TextStyle(
            color: Color(0xFF203982).withAlpha((0.5 * 255).toInt()),
          ),
        ),
        inputFormatters: [
          if (isCNIC) ...[
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(13),
            // Allowing maximum 15 characters (13 digits + 2 hyphens)
            TextInputFormatter.withFunction((oldValue, newValue) {
              // Formatting CNIC as 00000-0000000-0
              String text = newValue.text.replaceAll(
                  RegExp(r'[^0-9]'), ''); // Remove any non-digit characters

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

  Widget _buildReportTypeDropdown() {
    List<String> reportTypes = [
      "Found Item",
      "Found Missing Person",
    ];

    return SizedBox(
      width: 300.0,
      child: DropdownButtonFormField<String>(
        value: _selectedReportType,
        decoration: InputDecoration(
          labelText: 'Select Report Type',
          border: const OutlineInputBorder(),
          labelStyle: TextStyle(
            color: const Color(0xFF203982).withAlpha((0.7 * 255).toInt()),
            fontSize: 13.0,
          ),
          contentPadding: const EdgeInsets.symmetric(
            vertical: 8.0,
            horizontal: 10.0,
          ),
          prefixIcon: Icon(
            Icons.report, // Custom icon
            color: Colors.red.shade100,
            size: 19.5,
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
            return 'Please select a report type';
          }
          return null;
        },
        onChanged: (String? newValue) {
          setState(() {
            _selectedReportType = newValue;
          });
        },
        items: reportTypes.map<DropdownMenuItem<String>>((String report) {
          return DropdownMenuItem<String>(
            value: report,
            child: Text(
              report,
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

  Widget _buildItemCategoryDropdown() {
    List<String> itemCategories = [
      "Electronics",
      "Jewelry",
      "Clothing",
      "Documents",
      "Other",
    ];

    return SizedBox(
      width: 300.0,
      child: DropdownButtonFormField<String>(
        value: _selectedItemCategory,
        decoration: InputDecoration(
          labelText: 'Select Item Category',
          border: const OutlineInputBorder(),
          labelStyle: TextStyle(
            color: const Color(0xFF203982).withAlpha((0.7 * 255).toInt()),
            fontSize: 13.0,
          ),
          contentPadding: const EdgeInsets.symmetric(
            vertical: 8.0,
            horizontal: 10.0,
          ),
          prefixIcon: Icon(
            Icons.category, // Custom icon
            color: Colors.red.shade100,
            size: 19.5,
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
            return 'Please select an item category';
          }
          return null;
        },
        onChanged: (String? newValue) {
          setState(() {
            _selectedItemCategory = newValue;
          });
        },
        items: itemCategories.map<DropdownMenuItem<String>>((String category) {
          return DropdownMenuItem<String>(
            value: category,
            child: Text(
              category,
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

  Widget _buildItemConditionDropdown() {
    List<String> itemConditions = [
      "New",
      "Used - Good Condition",
      "Used - Damaged",
      "Old",
      "Other",
    ];

    return SizedBox(
      width: 300.0,
      child: DropdownButtonFormField<String>(
        value: _selectedItemCondition,
        decoration: InputDecoration(
          labelText: 'Select Item Condition',
          border: const OutlineInputBorder(),
          labelStyle: TextStyle(
            color: const Color(0xFF203982).withAlpha((0.7 * 255).toInt()),
            fontSize: 13.0,
          ),
          contentPadding: const EdgeInsets.symmetric(
            vertical: 8.0,
            horizontal: 10.0,
          ),
          prefixIcon: Icon(
            Icons.check_box, // Custom icon
            color: Colors.red.shade100,
            size: 19.5,
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
            return 'Please select item condition';
          }
          return null;
        },
        onChanged: (String? newValue) {
          setState(() {
            _selectedItemCondition = newValue;
          });
        },
        items: itemConditions.map<DropdownMenuItem<String>>((String condition) {
          return DropdownMenuItem<String>(
            value: condition,
            child: Text(
              condition,
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

  Widget _buildGenderDropdown() {
    List<String> genders = [
      "Male",
      "Female",
      "Other",
    ];

    return SizedBox(
      width: 300.0,
      child: DropdownButtonFormField<String>(
        value: _selectedGender,
        decoration: InputDecoration(
          labelText: 'Select Gender',
          border: const OutlineInputBorder(),
          labelStyle: TextStyle(
            color: const Color(0xFF203982).withAlpha((0.7 * 255).toInt()),
            fontSize: 13.0,
          ),
          contentPadding: const EdgeInsets.symmetric(
            vertical: 8.0,
            horizontal: 10.0,
          ),
          prefixIcon: Icon(
            Icons.person, // Custom icon
            color: Colors.red.shade100,
            size: 19.5,
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
            return 'Please select a gender';
          }
          return null;
        },
        onChanged: (String? newValue) {
          setState(() {
            _selectedGender = newValue;
          });
        },
        items: genders.map<DropdownMenuItem<String>>((String gender) {
          return DropdownMenuItem<String>(
            value: gender,
            child: Text(
              gender,
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

  Widget _buildDateOfBirthField() {
    return SizedBox(
      width: 300.0,
      child: DropdownButtonFormField<String>(
        value: dobController.text.isEmpty ? null : dobController.text,
        decoration: InputDecoration(
          labelText: 'Date of Birth',
          border: const OutlineInputBorder(),
          labelStyle: TextStyle(
            color: const Color(0xFF203982).withAlpha((0.7 * 255).toInt()),
            fontSize: 13.0,
          ),
          contentPadding: const EdgeInsets.symmetric(
            vertical: 8.0,
            horizontal: 10.0,
          ),
          prefixIcon: Icon(
            Icons.calendar_today, // Calendar icon
            color: Colors.red.shade100,
            size: 19.5,
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
        onChanged: (String? newValue) {},
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please select your date of birth';
          }
          return null;
        },
        items: [
          DropdownMenuItem<String>(
            value: dobController.text,
            child: GestureDetector(
              onTap: () async {
                // Show date picker when user taps on the field
                DateTime? selectedDate = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime(1900),
                  lastDate: DateTime.now(),
                );
                if (selectedDate != null) {
                  // Update the DOB controller with the selected date
                  dobController.text = "${selectedDate.toLocal()}".split(' ')[0]; // Format: yyyy-MM-dd
                  _calculateAge(selectedDate);
                }
              },
              child: Text(
                dobController.text.isEmpty ? 'Select your Date of Birth' : dobController.text,
                style: TextStyle(
                  color: dobController.text.isEmpty ? Colors.grey : Color(0xFF203982),
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _calculateAge(DateTime dob) {
    final DateTime currentDate = DateTime.now();
    int age = currentDate.year - dob.year;

    if (currentDate.month < dob.month || (currentDate.month == dob.month && currentDate.day < dob.day)) {
      age--;  // Subtract 1 if birthday hasn't occurred yet this year
    }

    setState(() {
      personAgeController.text = age.toString();  // Display age in the age field
    });
  }

}
