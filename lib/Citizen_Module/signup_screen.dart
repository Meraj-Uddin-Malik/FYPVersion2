import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:art_sweetalert/art_sweetalert.dart';

import 'login_screen.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

TextEditingValue formatEditUpdate(
    TextEditingValue oldValue, TextEditingValue newValue) {
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

class _SignUpScreenState extends State<SignUpScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _cnicController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
  TextEditingController();
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
    super.dispose();
  }



  void _clearFields() {
    _usernameController.clear();
    _emailController.clear();
    _cnicController.clear();
    _phoneController.clear();
    _passwordController.clear();
    _confirmPasswordController.clear();
    setState(() {
      _selectedGender = null; // Reset dropdown
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
      String gender = _selectedGender ?? 'Not specified'; // default gender
      String role = 'CITIZEN'; // Set default role, you can modify this logic if needed (e.g., based on user selection)

      // Firebase Auth SignUp
      UserCredential userCredential =
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Save additional data (like username, CNIC, phone, gender) to Firestore
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userCredential.user?.uid)
          .set({
        'username': username,
        'cnic': cnic,
        'phone': phone,
        'gender': gender,
        'email': email,
        'role': role,
      });


      ArtSweetAlert.show(
        context: context,
        artDialogArgs: ArtDialogArgs(
          type: ArtSweetAlertType.success,
          title: "Success",
          text: "Signup successful!",
          confirmButtonText: "OK", // Optional: Customize button text
          onConfirm: () {
            // Navigate to Login Page
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const LoginScreen()),
            );
          },
        ),
      );


      // Clear fields after successful signup
      _clearFields();

      // Success message
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Signup successful!')));
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
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(errorMessage)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF2A489E),
      body: SafeArea(
        child: Column(
          children: [
            const CircleAvatar(
              radius: 65.0,
              backgroundImage: AssetImage('images/Police.png'),
            ),
            const SizedBox(height: 10),
            Text('Welcome Back', style: _textStyle(18.0, Colors.white)),
            Text('Sign Up', style: _textStyle(16.0, const Color(0xFFE22128))),
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
                    Text(
                      'Enter Details To Signup',
                      style: _textStyle(15.0, const Color(0xFF2A489E)),
                      textAlign: TextAlign.center,
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
                                  TextEditingController(), // Empty controller since it's read-only
                                  'Role',
                                  false, // `obscureText` is false as it's not a password
                                  Icons.account_circle, // No icon is passed
                                  isReadOnly: true,
                                  initialValue: 'CITIZEN',
                                ),


                                _buildTextField(_usernameController,
                                    'Enter your name', false, Icons.person),
                                _buildTextField(_emailController,
                                    'Enter your email', false, Icons.email),
                                _buildTextField(
                                  _cnicController,
                                  'Enter your CNIC',
                                  false,
                                  Icons.credit_card,
                                ),
                                _buildTextField(_phoneController,
                                    'Enter your phone', false, Icons.phone),
                                _buildGenderDropdown(),
                                _buildTextField(_passwordController,
                                    'Enter your password', true, Icons.lock),
                                _buildTextField(_confirmPasswordController,
                                    'Confirm your password', true, Icons.lock),
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
                                        // Optional: Show error messages for invalid fields
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(const SnackBar(
                                            content: Text(
                                                'Please fix the errors')));
                                      }
                                    },
                                    child: const Text('Submit'),
                                  ),
                                ),
                                const SizedBox(height: 10.0),
                                GestureDetector(
                                  onTap: () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                        const LoginScreen()),
                                  ),
                                  child: RichText(
                                    text: TextSpan(
                                      text: "Already have an account? ",
                                      style: const TextStyle(
                                          color: Color(0xFF2A489E),
                                          fontSize: 14.0),
                                      children: [
                                        TextSpan(
                                          text: 'Sign In.',
                                          style: TextStyle(
                                            color: const Color(0xFF2A489E)
                                                .withOpacity(0.8),
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
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
        inputFormatters: labelText == 'Enter your phone'
            ? [
          FilteringTextInputFormatter.digitsOnly, // Allows only digits
          LengthLimitingTextInputFormatter(11), // Limits input to 11 digits
        ]
            : labelText == 'Enter your CNIC'
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
          suffixIcon: (labelText == 'Enter your password' ||
              labelText == 'Confirm your password')
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
          if (labelText == 'Enter your email' &&
              !RegExp(r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$")
                  .hasMatch(value)) {
            return 'Invalid email address';
          }
          if (labelText == 'Enter your phone' &&
              (value.length != 11 || !RegExp(r'^\d{11}$').hasMatch(value))) {
            return 'Invalid 11-digit phone number';
          }
          if (labelText == 'Enter your CNIC' &&
              !RegExp(r"^\d{5}-\d{7}-\d$").hasMatch(value)) {
            return 'Invalid CNIC format (e.g., 00000-0000000-0)';
          }
          if (labelText == 'Enter your password') {
            if (!RegExp(
                r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]{8,}$')
                .hasMatch(value)) {
              return 'Password must have:\n• At least 8 characters\n• 1 uppercase\n• 1 lowercase\n• 1 number\n• 1 special character';
            }
          }
          if (labelText == 'Confirm your password' &&
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
            labelText: 'Select your gender',
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
              return 'Please select your gender';
            }
            return null;
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
