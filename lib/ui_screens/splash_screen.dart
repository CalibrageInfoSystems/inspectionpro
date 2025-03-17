import 'dart:async';
import 'package:flutter/material.dart';
import 'package:inspectionpro/ui_screens/login_screen.dart';
import 'package:inspectionpro/ui_screens/MainScreen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../database/InspDatabaseHelper.dart';

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
          builder: (context) => isLogin ? MainScreen() : LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text(
          "Inspection Pro",
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
