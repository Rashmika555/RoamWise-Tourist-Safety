import 'package:flutter/material.dart';

class LanguageTab extends StatelessWidget {
  const LanguageTab({super.key});

  final List<Map<String, String>> phrases = const [
    {"en": "I need help!", "local": "¡Necesito ayuda!"},
    {"en": "Where is the hospital?", "local": "¿Dónde está el hospital?"},
    {"en": "Call the police.", "local": "Llame a la policía."},
  ];

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: phrases.length,
      itemBuilder: (context, index) => Card(
        margin: const EdgeInsets.all(8),
        child: ListTile(
          title: Text(phrases[index]['local']!, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          subtitle: Text(phrases[index]['en']!),
          trailing: const Icon(Icons.volume_up),
        ),
      ),
    );
  }
}