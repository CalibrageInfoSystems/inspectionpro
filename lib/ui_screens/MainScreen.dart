import 'package:flutter/material.dart';

class MainScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Main Screen"),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () {
              Navigator.pop(context); // Go back to login
            },
          ),
        ],
      ),
      body: Center(
        child: Text(
          "Welcome to Main Screen!",
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
