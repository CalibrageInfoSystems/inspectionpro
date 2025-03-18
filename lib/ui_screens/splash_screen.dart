import 'dart:async';
import 'package:flutter/material.dart';
import 'package:inspectionpro/gen/assets.gen.dart';
import 'package:inspectionpro/ui_screens/login_screen.dart';

import 'package:shared_preferences/shared_preferences.dart';
import '../database/InspDatabaseHelper.dart';
import 'home_screen.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  InspDatabaseHelper? _inspDatabaseHelper;

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    try {
      _inspDatabaseHelper = InspDatabaseHelper();
      await _inspDatabaseHelper!.createDatabase();
      await Future.delayed(Duration(seconds: 1));
    } catch (e) {
      print("Error initializing database: $e");
    }

    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool isLogin = prefs.getBool("isLogin") ?? false;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
          builder: (context) => isLogin ? HomeScreen() : LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: HexColor.fromHex('#272A33'),
        // Set background color // Set your desired background color here
        body: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Logo and Title Section
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        //   color: Colors.white.withOpacity(0.1),
                      ),
                      padding: const EdgeInsets.all(8.0),
                      child: Image.asset(
                        Assets.images.appLogo512.path,
                        // 'assets/app_logo_512.png',
                        // Load logo from drawable (assets)
                        width: 60,
                        height: 60,
                      ),
                    ),
                    RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: 'Inspection',
                            style: TextStyle(
                              color: HexColor.fromHex('#f5f5f5'),
                              fontSize: 35,
                              fontFamily: 'Roboto',
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          TextSpan(
                            text: 'Pro',
                            style: TextStyle(
                              color: Colors.grey[400],
                              fontSize: 35,
                              fontWeight: FontWeight.w400,
                              fontFamily: 'Roboto',
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Center(
                  child: Text(
                    'INSPECTION MANAGEMENT',
                    style: TextStyle(
                      color: Colors.grey[400],
                      fontSize: 20,
                      letterSpacing: 0.2,
                      fontWeight: FontWeight.w100,
                      fontFamily: 'Roboto',
                    ),
                  ),
                )
              ],
            ),
          ),
        ));
  }
}

extension HexColor on Color {
  /// Creates a Color from a hex code string, e.g., "#272A33" or "272A33".
  static Color fromHex(String hexString) {
    final buffer = StringBuffer();
    if (hexString.length == 6 || hexString.length == 7) buffer.write('ff');
    buffer.write(hexString.replaceFirst('#', ''));
    return Color(int.parse(buffer.toString(), radix: 16));
  }
}
