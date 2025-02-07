import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class SettingsScreen extends StatefulWidget {
  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _darkMode = false;
  bool _notifications = true;
  String _selectedLanguage = 'English';

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
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const SizedBox(height: 22.0),
              const Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: 'SETTINGS',
                      style: TextStyle(
                        color: Colors.white,
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
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                    ),
                  ),
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      child: Column(
                        children: [
                          // Profile Section
                          SizedBox(
                            width: 340,
                            child: Card(
                              color: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              child: ListTile(
                                leading: const CircleAvatar(
                                  backgroundImage: AssetImage('images/user.png'),
                                ),
                                title: const Text('Meraj Uddin'),
                                subtitle: const Text('meraj@example.com'),
                                trailing: ShaderMask(
                                  shaderCallback: (Rect bounds) {
                                    return const LinearGradient(
                                      colors: [Color(0xFF203982), Colors.red],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ).createShader(bounds);
                                  },
                                  child: const Icon(Icons.edit, color: Colors.white),
                                ),
                                onTap: () {},
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),

                          // Dark Mode Toggle
                          SwitchListTile(
                            title: const Text('Dark Mode'),
                            secondary: ShaderMask(
                              shaderCallback: (Rect bounds) {
                                return const LinearGradient(
                                  colors: [Color(0xFF203982), Colors.red],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ).createShader(bounds);
                              },
                              child: const Icon(Icons.dark_mode, color: Colors.white),
                            ),
                            value: _darkMode,
                            onChanged: (value) {
                              setState(() {
                                _darkMode = value;
                              });
                            },
                          ),

                          // Language Selection
                          ListTile(
                            title: const Text('Language'),
                            leading: ShaderMask(
                              shaderCallback: (Rect bounds) {
                                return const LinearGradient(
                                  colors: [Color(0xFF203982), Colors.red],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ).createShader(bounds);
                              },
                              child: const Icon(Icons.language, color: Colors.white),
                            ),
                            trailing: DropdownButton<String>(
                              value: _selectedLanguage,
                              items: ['English', 'Urdu', 'Sindhi', 'Arabic'].map((lang) {
                                return DropdownMenuItem(value: lang, child: Text(lang));
                              }).toList(),
                              onChanged: (value) {
                                setState(() {
                                  _selectedLanguage = value!;
                                });
                              },
                            ),
                          ),

                          // Notifications Toggle
                          SwitchListTile(
                            title: const Text('Notifications'),
                            secondary: ShaderMask(
                              shaderCallback: (Rect bounds) {
                                return const LinearGradient(
                                  colors: [Color(0xFF203982), Colors.red],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ).createShader(bounds);
                              },
                              child: const Icon(Icons.notifications, color: Colors.white),
                            ),
                            value: _notifications,
                            onChanged: (value) {
                              setState(() {
                                _notifications = value;
                              });
                            },
                          ),

                          // Privacy & Security
                          ListTile(
                            title: const Text('Privacy & Security'),
                            leading: ShaderMask(
                              shaderCallback: (Rect bounds) {
                                return const LinearGradient(
                                  colors: [Color(0xFF203982), Colors.red],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ).createShader(bounds);
                              },
                              child: const Icon(Icons.lock, color: Colors.white),
                            ),
                            onTap: () {},
                          ),

                          // Logout Button
                          ListTile(
                            title: const Text('Logout', style: TextStyle(color: Colors.red)),
                            leading: ShaderMask(
                              shaderCallback: (Rect bounds) {
                                return const LinearGradient(
                                  colors: [Color(0xFF203982), Colors.red],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ).createShader(bounds);
                              },
                              child: const Icon(Icons.exit_to_app, color: Colors.white),
                            ),
                            onTap: () {
                              // Add logout function here
                            },
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
}
