import 'dart:convert';
import 'package:flutter/services.dart' as rootBundle;

Future<Map<String, dynamic>> caricaDatiCalciatori() async {
  // Carica il file JSON dalla cartella assets
  final String jsonString = await rootBundle.rootBundle.loadString('assets/calciatori_data.json');
  
  // Decodifica la stringa JSON in un oggetto Dart
  final Map<String, dynamic> calciatoriData = json.decode(jsonString);
  
  return calciatoriData;
}
