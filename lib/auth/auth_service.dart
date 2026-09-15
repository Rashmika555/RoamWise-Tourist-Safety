import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> signOut() async {
    // Firebase logout
    await _auth.signOut();

    // Clear guest login
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('isGuest');
  }
}
