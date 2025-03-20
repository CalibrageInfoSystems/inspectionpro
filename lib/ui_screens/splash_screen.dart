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
  late Future<void> _initializationFuture;

  @override
  void initState() {
    super.initState();
    _initializationFuture = _initializeApp();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Preload the image after the context is available
    precacheImage(AssetImage(Assets.images.appLogo512.path), context);
  }

  Future<void> _initializeApp() async {
    try {
      _inspDatabaseHelper = InspDatabaseHelper();
      await _inspDatabaseHelper!.createDatabase();
      await Future.delayed(Duration(seconds: 1));
    } catch (e) {
      print("Error initializing database: $e");
    }
    await _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool isLogin = prefs.getBool("isLoggedIn") ?? false;

    // Navigate based on login status after the build is complete
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (context) => isLogin ? HomeScreen() : LoginScreen()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _initializationFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return _buildUI();
        } else {
          return Scaffold(
            backgroundColor: HexColor.fromHex('#272A33'),
            body: const Center(child: CircularProgressIndicator()),
          );
        }
      },
    );
  }

  Widget _buildUI() {
    return Scaffold(
      backgroundColor: HexColor.fromHex('#272A33'),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    Assets.images.appLogo512.path,
                    width: 60,
                    height: 60,
                    fit: BoxFit.contain,
                  ),
                  const SizedBox(width: 10),
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
                  '  INSPECTION MANAGEMENT',
                  style: TextStyle(
                    color: Colors.grey[400],
                    fontSize: 20,
                    letterSpacing: 0.2,
                    fontWeight: FontWeight.w100,
                    fontFamily: 'Roboto',
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
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
