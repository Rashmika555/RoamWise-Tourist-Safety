import 'package:flutter/material.dart';
import 'package:roamwise/auth/auth_service.dart';
import '../../main.dart';

class ProfileTab extends StatelessWidget {
  const ProfileTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ElevatedButton.icon(
        icon: const Icon(Icons.logout),
        label: const Text("Logout"),
        onPressed: () async {
          final navigator = Navigator.of(context);
          await AuthService().signOut();

          // 🔥 Force app to restart from Welcome screen
          navigator.pushAndRemoveUntil(
            MaterialPageRoute(builder: (_) => const WelcomeScreen()),
            (route) => false,
          );
        },
      ),
    );
  }
}
