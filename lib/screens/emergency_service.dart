import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class EmergencyService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final String uid = FirebaseAuth.instance.currentUser!.uid;

  // Save an emergency contact
  Future<void> addContact(String name, String phone) async {
    await _db.collection('users').doc(uid).collection('contacts').add({
      'name': name,
      'phone': phone,
    });
  }

  // Trigger SOS Event in Database
  Future<void> triggerSOSEvent(double lat, double lng) async {
    await _db.collection('alerts').add({
      'userId': uid,
      'location': GeoPoint(lat, lng),
      'timestamp': FieldValue.serverTimestamp(),
      'status': 'active',
    });
    // Integration Point: Here you would trigger a Firebase Cloud Function
    // to send actual SMS via Twilio API.
  }
}