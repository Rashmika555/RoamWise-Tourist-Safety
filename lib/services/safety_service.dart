import 'dart:math';

class SafetyService {
  // In a production app, this would call your AI Backend/Cloud Function
  // For the prototype, we simulate risk analysis based on coordinates
  Future<Map<String, dynamic>> getAreaSafetyScore(double lat, double lng) async {
    await Future.delayed(const Duration(seconds: 1)); // Simulate network

    // Logic: Random score for demo, or mock "High Risk" zones
    int score = Random().nextInt(40) + 60; // Returns 60-100

    return {
      'score': score,
      'status': score > 80 ? 'Safe' : 'Caution',
      'warnings': score > 80 ? [] : ['Unlit areas reported nearby', 'High pickpocket rate'],
      'local_emergency': '911' // This would change based on country reverse-geocoding
    };
  }
}