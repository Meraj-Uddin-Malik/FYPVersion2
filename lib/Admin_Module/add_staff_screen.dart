import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:art_sweetalert/art_sweetalert.dart';
import 'package:intl/intl.dart';
import 'dart:io';


class AddStaffScreen extends StatefulWidget {
  const AddStaffScreen({super.key});

  @override
  State<AddStaffScreen> createState() => _AddStaffScreenState();
}

TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
  // Remove all non-digit characters
  String digits = newValue.text.replaceAll(RegExp(r'\D'), '');
  // Add hyphens automatically
  String formatted = '';
  if (digits.length <= 5) {
    formatted = digits; // First 5 digits
  } else if (digits.length <= 12) {
    formatted =
    '${digits.substring(0, 5)}-${digits.substring(5)}'; // Add first hyphen
  } else if (digits.length <= 13) {
    formatted =
    '${digits.substring(0, 5)}-${digits.substring(5, 12)}-${digits.substring(12)}'; // Add second hyphen
  } else {
    // **Changed Line:** Ensure input is restricted to 13 digits including the second hyphen.
    formatted =
    '${digits.substring(0, 5)}-${digits.substring(5, 12)}-${digits.substring(12, 13)}'; // Restrict to 13 digits
  }

  return TextEditingValue(
    text: formatted,
    selection: TextSelection.collapsed(offset: formatted.length),
  );
}

final _formKey = GlobalKey<FormState>();

class _AddStaffScreenState extends State<AddStaffScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _cnicController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
  TextEditingController();
  final TextEditingController _rankController = TextEditingController(); // Rank/Designation
  final TextEditingController _stationController = TextEditingController(); // Police Station Name
  final TextEditingController _addressController = TextEditingController(); // Address
  final TextEditingController _dobController = TextEditingController(); // Date of Birth
  final TextEditingController _joiningDateController = TextEditingController(); // Joining Date
  final TextEditingController _emergencyContactController = TextEditingController(); // Emergency Contact
  final TextEditingController _badgeNoController = TextEditingController(); // ✅ Badge Number

  String? _selectedGender;
  bool _isPasswordVisible = false;

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _cnicController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _rankController.dispose();
    _stationController.dispose();
    _addressController.dispose();
    _dobController.dispose();
    _joiningDateController.dispose();
    _emergencyContactController.dispose();
    _badgeNoController.dispose(); // ✅ Disposing badge number controller
    super.dispose();
  }

  void _clearFields() {
    _usernameController.clear();
    _emailController.clear();
    _cnicController.clear();
    _phoneController.clear();
    _passwordController.clear();
    _confirmPasswordController.clear();
    _rankController.clear();
    _stationController.clear();
    _addressController.clear();
    _dobController.clear();
    _joiningDateController.clear();
    _emergencyContactController.clear();
    _badgeNoController.clear(); // ✅ Clearing badge number field
    setState(() {
      _selectedGender = null;
    });
  }

  Future<void> _signUpWithFirebase() async {
    try {
      // Get values from controllers
      String email = _emailController.text.trim();
      String password = _passwordController.text.trim();
      String username = _usernameController.text.trim();
      String cnic = _cnicController.text.trim();
      String phone = _phoneController.text.trim();
      String gender = _selectedGender ?? 'Not specified';
      String role = 'POLICE';
      String rank = _rankController.text.trim();
      String station = _stationController.text.trim();
      String address = _addressController.text.trim();
      String dob = _dobController.text.trim();
      String joiningDate = _joiningDateController.text.trim();
      String emergencyContact = _emergencyContactController.text.trim();
      String badgeno = _badgeNoController.text.trim(); // ✅ Retrieving badge number

      // Firebase Auth SignUp
      UserCredential userCredential =
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );


      // Save additional data to Firestore
      await FirebaseFirestore.instance.collection('users').doc(userCredential.user?.uid).set({
        'username': username,
        'cnic': cnic,
        'phone': phone,
        'gender': gender,
        'email': email,
        'role': role,
        'rank': rank,
        'station': station,
        'address': address,
        'dob': dob,
        'joiningDate': joiningDate,
        'emergencyContact': emergencyContact,
        'badgeno': badgeno, //
      });

      // Show success message
      ArtSweetAlert.show(
        context: context,
        artDialogArgs: ArtDialogArgs(
          type: ArtSweetAlertType.success,
          title: "Success",
          text: "Staff has been added successfully!",
          confirmButtonText: "OK",
        ),
      );

      // Clear fields after successful signup
      _clearFields();
    } catch (e) {
      String errorMessage = "Signup failed: $e";
      if (e is FirebaseAuthException) {
        switch (e.code) {
          case 'weak-password':
            errorMessage = 'Password is too weak';
            break;
          case 'email-already-in-use':
            errorMessage = 'Email is already in use';
            break;
          case 'invalid-email':
            errorMessage = 'Invalid email address';
            break;
          default:
            errorMessage = 'Unknown error occurred';
        }
      }
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(errorMessage)));
    }
  }




  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF2A489E),
      body: SafeArea(
        child: Column(
          children: [
            SizedBox(height: 20,),
            const CircleAvatar(
              radius: 50.0,
              backgroundImage: AssetImage('images/Police.png'),
            ),
            const SizedBox(height: 10),
            const Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: 'ADD ',
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
                    text: 'Staff',
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
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(50),
                    topRight: Radius.circular(50),
                  ),
                ),
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    const SizedBox(
                      height: 10.0,
                    ),

                    Expanded(
                      child: SingleChildScrollView(
                        child: Form(
                          key: _formKey,
                          child: Padding(
                            padding: const EdgeInsets.only(top: 15.0),
                            child: Column(
                              children: [
                                _buildTextField(
                                  TextEditingController(), // Read-only Role
                                  'Role',
                                  false,
                                  Icons.account_circle,
                                  isReadOnly: true,
                                  initialValue: 'POLICE',
                                ),
                                _buildTextField(_usernameController, 'Enter Staff Name', false, Icons.person),
                                _buildTextField(_emailController, 'Enter Staff Email', false, Icons.email),
                                _buildTextField(_cnicController, 'Enter Staff CNIC', false, Icons.credit_card),
                                _buildTextField(_phoneController, 'Enter Staff Phone', false, Icons.phone),
                                _buildGenderDropdown(),
                                _buildTextField(_rankController, 'Enter Rank/Designation', false, Icons.badge), // New
                                _buildTextField(_stationController, 'Enter Police Station Name', false, Icons.location_city), // New
                                _buildTextField(_addressController, 'Enter Address', false, Icons.home), // New
                                _buildDatePicker(_dobController, 'Select Date of Birth', Icons.calendar_today), // New
                               SizedBox(height: 10,),
                                 _buildDatePicker(_joiningDateController, 'Select Joining Date', Icons.calendar_today), // New
                                SizedBox(height: 10,),
                                _buildTextField(_badgeNoController, 'Badge No', false, Icons.badge), // New
                                _buildTextField(_emergencyContactController, 'Enter Emergency Contact', false, Icons.phone_in_talk), // New
                                _buildTextField(_passwordController, 'Enter Staff Password', true, Icons.lock),
                                _buildTextField(_confirmPasswordController, 'Confirm Staff Password', true, Icons.lock),
                                SizedBox(
                                  width: 220.0,
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      foregroundColor: Colors.white,
                                      backgroundColor: Colors.red,
                                    ),
                                    onPressed: () {
                                      if (_formKey.currentState!.validate()) {
                                        _signUpWithFirebase(); // Call Firebase SignUp
                                      } else {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(content: Text('Please fix the errors')),
                                        );
                                      }
                                    },
                                    child: const Text('Submit'),
                                  ),
                                ),
                                const SizedBox(height: 10.0),
                              ],
                            ),
                          ),
                        ),
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



  Widget _buildTextField(
      TextEditingController controller,
      String labelText,
      bool obscureText,
      IconData icon, {
        bool isReadOnly = false,
        String? initialValue,
      }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: TextFormField(
        controller: isReadOnly ? null : controller,
        obscureText: obscureText && !_isPasswordVisible,
        readOnly: isReadOnly,
        initialValue: isReadOnly ? initialValue : null,
        style: const TextStyle(
          color: Color(0xFF203982),
          fontSize: 14.0, // Blue text for user input
        ),
        keyboardType: labelText.contains('phone') || labelText.contains('CNIC')
            ? TextInputType.number
            : TextInputType.text,
        inputFormatters: labelText == 'Enter Staff phone'
            ? [
          FilteringTextInputFormatter.digitsOnly, // Allows only digits
          LengthLimitingTextInputFormatter(11), // Limits input to 11 digits
        ]
            : labelText == 'Enter Staff CNIC'
            ? [
          FilteringTextInputFormatter.digitsOnly,
          LengthLimitingTextInputFormatter(13), // CNIC Limit
          TextInputFormatter.withFunction((oldValue, newValue) {
            // CNIC Formatter
            String digits = newValue.text.replaceAll(RegExp(r'\D'), '');
            String formatted = '';
            if (digits.length <= 5) {
              formatted = digits;
            } else if (digits.length <= 12) {
              formatted =
              '${digits.substring(0, 5)}-${digits.substring(5)}';
            } else {
              formatted =
              '${digits.substring(0, 5)}-${digits.substring(5, 12)}-${digits.substring(12)}';
            }
            return TextEditingValue(
              text: formatted,
              selection:
              TextSelection.collapsed(offset: formatted.length),
            );
          }),
        ]
            : [],
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
          suffixIcon: (labelText == 'Enter Staff password' ||
              labelText == 'Confirm Staff password')
              ? IconButton(
            icon: Icon(
              _isPasswordVisible
                  ? Icons.visibility
                  : Icons.visibility_off,
              color: const Color(0xFF203982),
            ),
            iconSize: 19.0,
            onPressed: () {
              setState(() {
                _isPasswordVisible = !_isPasswordVisible;
              });
            },
          )
              : null,
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
            return 'This field cannot be empty';
          }
          if (labelText == 'Enter Staff email' &&
              !RegExp(r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$")
                  .hasMatch(value)) {
            return 'Invalid email address';
          }
          if (labelText == 'Enter Staff phone' &&
              (value.length != 11 || !RegExp(r'^\d{11}$').hasMatch(value))) {
            return 'Invalid 11-digit phone number';
          }
          if (labelText == 'Enter Staff CNIC' &&
              !RegExp(r"^\d{5}-\d{7}-\d$").hasMatch(value)) {
            return 'Invalid CNIC format (e.g., 00000-0000000-0)';
          }
          if (labelText == 'Enter Staff password') {
            if (!RegExp(
                r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]{8,}$')
                .hasMatch(value)) {
              return 'Password must have:\n• At least 8 characters\n• 1 uppercase\n• 1 lowercase\n• 1 number\n• 1 special character';
            }
          }
          if (labelText == 'Confirm Staff password' &&
              value != _passwordController.text) {
            return 'Passwords do not match';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildGenderDropdown() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: DropdownButtonFormField<String>(
          value: _selectedGender,
          decoration: const InputDecoration(
            labelText: 'Select Gender',
            labelStyle: TextStyle(
                fontSize: 14.0,
                color: Color(0xFF203982),
                fontWeight: FontWeight.w400 // Blue label color
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
          dropdownColor:
          const Color(0xFFE3F2FD), // Light blue dropdown background
          onChanged: (String? newValue) {
            setState(() {
              _selectedGender = newValue;
            });
          },
          items: ['Male', 'Female', 'Other']
              .map<DropdownMenuItem<String>>(
                (String value) => DropdownMenuItem<String>(
              value: value,
              child: Text(
                value,
                style: const TextStyle(
                    color: Color(0xFF203982),
                    fontWeight: FontWeight.w400, // Blue dropdown text
                    fontSize: 14.0),
              ),
            ),
          )
              .toList(),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please select Staff gender';
            }
            return null;
          }),
    );
  }

  Widget _buildDatePicker(TextEditingController controller, String label, IconData icon) {
    return TextFormField(
      controller: controller,
      readOnly: true,
      decoration: InputDecoration(
        labelText: label,
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
        labelStyle: TextStyle(
            fontSize: 14.0,
            color: Color(0xFF203982),
            fontWeight: FontWeight.w400 // Blue label color
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
      onTap: () async {
        DateTime? pickedDate = await showDatePicker(
          context: context,
          initialDate: DateTime.now(),
          firstDate: DateTime(1950),
          lastDate: DateTime.now(),
        );
        if (pickedDate != null) {
          controller.text = DateFormat('yyyy-MM-dd').format(pickedDate);
        }
      },
    );
  }



}
