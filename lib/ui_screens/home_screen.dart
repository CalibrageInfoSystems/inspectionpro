import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:inspectionpro/models/appinfo_model.dart';
import 'package:inspectionpro/ui_screens/failed_pipeline.dart';
import 'package:inspectionpro/utils/api_config.dart';
import 'package:http/http.dart' as http;

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Future<AppInfo> getAppInfo() async {
    try {
      final apiUrl = Uri.parse('$baseUrl$getLines');
      final jsonResponse = await http.get(apiUrl);
      if (jsonResponse.statusCode == 200) {
        return appInfoFromJson(jsonResponse.body);
      } else {
        Fluttertoast.showToast(msg: jsonResponse.body);
        throw Exception(jsonResponse.body);
      }
    } catch (e) {
      rethrow;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF212121),
        title: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.green),
            const SizedBox(width: 8),
            const Text(
              'InspectionPro',
              style: TextStyle(color: Colors.white, fontSize: 20),
            ),
            const Spacer(),
            IconButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const FailedPipeline()),
                  );
                },
                icon: const Icon(
                  Icons.sync_lock_outlined,
                  color: Colors.white,
                )),
            const SizedBox(width: 6),
            IconButton(
                onPressed: getAppInfo,
                icon: const Icon(
                  Icons.logout_outlined,
                  color: Colors.white,
                )),
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
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildTab('All', 4, Colors.grey),
                  const SizedBox(width: 5),
                  _buildTab('Unsaved', 0, Colors.blue),
                  const SizedBox(width: 5),
                  _buildTab('Failed', 1, Colors.red),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                children: [
                  buildItem(),
                  buildItem(),
                  buildItem(),
                  /* _buildListItem('Phyce Line', '03/17/2025 10:04', 'Failed'),
                  _buildListItem('Wheat Line', '03/17/2025 12:32', 'Passed'),
                  _buildListItem('Dry Line', '03/14/2025 12:32', 'Passed'),
                  _buildListItem(
                      'Clothes Line', '03/14/2025 12:32', 'Passed'), */
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTab(String label, int count, Color color) {
    return Expanded(
      child: Container(
        height: 70,
        alignment: Alignment.center,
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          '$label: $count',
          style: const TextStyle(color: Colors.white),
        ),
      ),
    );
  }

  Widget buildItem() {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Colors.grey,
          ),
        ),
      ),
      child: Row(
        children: [
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Phyce Line'),
              SizedBox(height: 5),
              Text('03/17/2025 10:04       Passed'),
            ],
          ),
          const Spacer(),
          IconButton(
            onPressed: () {},
            style: IconButton.styleFrom(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4)),
                side: const BorderSide(
                  color: Colors.green,
                )),
            icon: const Icon(Icons.thumb_up, color: Colors.green, size: 20),
          ),
          IconButton(
            onPressed: () {},
            style: IconButton.styleFrom(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4)),
                side: const BorderSide(
                  color: Colors.red,
                )),
            icon: const Icon(Icons.thumb_down, color: Colors.red, size: 20),
          ),
        ],
      ),
    );
  }

  Widget _buildListItem(String title, String date, String status) {
    Color statusColor = status == 'Failed' ? Colors.red : Colors.green;
    return ListTile(
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text(date),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(status, style: TextStyle(color: statusColor)),
          const SizedBox(width: 8),
          const Icon(Icons.thumb_up, color: Colors.green, size: 20),
          const Icon(Icons.thumb_down, color: Colors.red, size: 20),
        ],
      ),
    );
  }
}
