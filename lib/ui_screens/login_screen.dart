// ignore_for_file: use_build_context_synchronously

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:inspectionpro/ui_screens/home_screen.dart';
import 'package:inspectionpro/ui_screens/splash_screen.dart';
import 'package:inspectionpro/utils/api_config.dart';
import 'package:inspectionpro/utils/commonutils.dart';
import 'package:inspectionpro/widgets/custom_textfield.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../gen/assets.gen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final formKey = GlobalKey<FormState>();
  final userIdController = TextEditingController();
  final passwordController = TextEditingController();
  bool rememberMeChecked = false;

  @override
  void initState() {
    super.initState();
    userIdController.text = 'demo';
    passwordController.text = 'demo@123';
  }

  Future<void> signin() async {
    try {
      bool isConnected = await CommonUtils.checkInternetConnectivity();
      if (!isConnected) {
        Fluttertoast.showToast(msg: 'No internet connection, Please try again.');
        FocusScope.of(context).unfocus();
        Navigator.of(context).pop();
        return;
      }

      const apiUrl = '$baseUrl$login';

      final requestBody = jsonEncode({
        "UserName": userIdController.text,
        "RememberMe": rememberMeChecked,
        "Password": passwordController.text
      });

      final jsonResponse = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json',
        },
        body: requestBody,
      );

      Navigator.of(context).pop();
      if (jsonResponse.statusCode == 200) {
        Map<String, dynamic> responseData = jsonDecode(jsonResponse.body);

        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setBool('isLoggedIn', true);
        await prefs.setString('UserName', responseData['UserName']);
        await prefs.setString('ApplicationName', responseData['ApplicationName']);

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
      } else {
        Fluttertoast.showToast(msg: jsonResponse.body);
      }
    } catch (e) {
      Navigator.of(context).pop();
      rethrow;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF212121),
      body: SafeArea(
        child: GestureDetector(
          onTap: () {
            FocusScope.of(context).unfocus();
          },
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32.0),
              child: Form(
                key: formKey,
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

                    const SizedBox(height: 48),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'USER ID',
                        style: TextStyle(
                          color: Colors.grey[400],
                          fontSize: 14,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    CustomTextfield(
                      controller: userIdController,
                      hintText: 'Enter User ID',
                      validator: userIdValidator,
                    ),
                    const SizedBox(height: 16),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'PASSWORD',
                        style: TextStyle(
                          color: Colors.grey[400],
                          fontSize: 14,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    CustomTextfield(
                      controller: passwordController,
                      hintText: 'Enter Password',
                      obscureText: true,
                      validator: passwordValidator,
                    ),
                    const SizedBox(height: 30),
                    rememberMeCheckBox(),
                    const SizedBox(height: 20),
                    signinBtn(),
                    /*  const SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: () {
                        showLoadingDialog(context);
                        Future.delayed(Duration(seconds: 2), () {
                          Navigator.of(context).pop();
                        });
                      },
                      child: Text('Show Loading'),
                    ), */
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

//MARK: SignIn Btn
  SizedBox signinBtn() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          if (formKey.currentState!.validate()) {
            CommonUtils.showLoadingDialog(context);
            signin();
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF42A5F5),
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        child: const Text(
          'SIGN IN',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            letterSpacing: 1.2,
          ),
        ),
      ),
    );
  }

  //MARK: Remember Me
  GestureDetector rememberMeCheckBox() {
    return GestureDetector(
      onTap: () {
        setState(() {
          rememberMeChecked = !rememberMeChecked;
        });
      },
      child: Row(
        children: [
          SizedBox(
            width: 20,
            height: 20,
            child: Checkbox(
              value: rememberMeChecked,
              onChanged: (value) {
                setState(() {
                  rememberMeChecked = value!;
                });
              },
              activeColor: Colors.blue,
              checkColor: Colors.white,
              side: BorderSide(color: Colors.grey[400]!),
            ),
          ),
          const SizedBox(width: 10),
          Text(
            'REMEMBER ME',
            style: TextStyle(
              color: Colors.grey[400],
              fontSize: 14,
              letterSpacing: 1.2,
            ),
          ),
        ],
      ),
    );
  }

  String? userIdValidator(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter User ID';
    }
    return null;
  }

  String? passwordValidator(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter Password';
    }
    return null;
  }
}
