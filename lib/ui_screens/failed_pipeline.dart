import 'package:flutter/material.dart';

class FailedPipeline extends StatelessWidget {
  const FailedPipeline({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: const Color(0xFF212121),
        centerTitle: true,
        title: const Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green),
            SizedBox(width: 8),
            Text(
              'Failed Pipeline',
              style: TextStyle(color: Colors.white, fontSize: 20),
            ),
          ],
        ),
      ),
      body: Container(
        color: const Color(0xFFF5F5F5),
        child: Column(
          children: [
            Container(
              alignment: Alignment.centerRight,
              color: const Color.fromARGB(255, 153, 153, 153),
              padding: const EdgeInsets.all(8.0),
              child: const Text(
                'FACILITY: TestClient / USER: demo',
                style: TextStyle(fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
