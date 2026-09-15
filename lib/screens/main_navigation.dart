import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

import 'home_screen.dart';
import 'tabs/map_tab.dart';
import 'tabs/alerts_tab.dart';
import 'tabs/profile_tab.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;

  late final List<Widget> _tabs = [
    HomeScreen(
      onViewMap: () => _setTab(1),
      onEmergency: () => _setTab(2),
      onReportIncident: () => _setTab(2),
    ),
    const MapTab(),
    const AlertsTab(),
    const ProfileTab(),
  ];

  @override
  void initState() {
    super.initState();
    // Listen for internet changes to support "Offline Mode"
    Connectivity().onConnectivityChanged.listen((List<ConnectivityResult> results) {
      if (results.contains(ConnectivityResult.none)) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Offline Mode: SOS will be sent via SMS."),
              backgroundColor: Colors.orange,
            ),
          );
        }
      }
    });
  }

  void _setTab(int index) {
    setState(() => _currentIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // body displays the currently selected tab
      body: IndexedStack(
        index: _currentIndex,
        children: _tabs,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          _setTab(index);
        },
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.blueAccent,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.map), label: 'Map'),
          BottomNavigationBarItem(icon: Icon(Icons.warning), label: 'Alerts'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}