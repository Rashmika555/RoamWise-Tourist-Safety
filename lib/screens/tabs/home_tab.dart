import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../../services/safety_service.dart';

class HomeTab extends StatefulWidget {
  const HomeTab({super.key});

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  final SafetyService _safetyService = SafetyService();
  int _safetyScore = 0;
  String _status = "Scanning Area...";

  @override
  void initState() {
    super.initState();
    _checkLocalSafety();
  }

  Future<void> _checkLocalSafety() async {
    Position pos = await Geolocator.getCurrentPosition();
    final data = await _safetyService.getAreaSafetyScore(pos.latitude, pos.longitude);
    setState(() {
      _safetyScore = data['score'];
      _status = data['status'];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text("Current Area Safety", style: TextStyle(fontSize: 18, color: Colors.grey)),
        const SizedBox(height: 20),
        Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              width: 150, height: 150,
              child: CircularProgressIndicator(
                value: _safetyScore / 100,
                strokeWidth: 10,
                backgroundColor: Colors.grey.shade200,
                color: _safetyScore > 75 ? Colors.green : Colors.orange,
              ),
            ),
            Text("$_safetyScore%", style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
          ],
        ),
        const SizedBox(height: 24),
        Text("Status: $_status", style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w500)),
        const SizedBox(height: 40),
        _buildActionCard(Icons.security, "Travel Advice", "Avoid alleyways in this sector."),
      ],
    );
  }

  Widget _buildActionCard(IconData icon, String title, String sub) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: ListTile(leading: Icon(icon, color: Colors.blue), title: Text(title), subtitle: Text(sub)),
    );
  }
}