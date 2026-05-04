import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class Creation {
  final String imageUrl;
  final String featureLabel;
  final DateTime date;

  Creation({
    required this.imageUrl,
    required this.featureLabel,
    required this.date,
  });

  Map<String, dynamic> toJson() => {
    'imageUrl': imageUrl,
    'featureLabel': featureLabel,
    'date': date.toIso8601String(),
  };

  factory Creation.fromJson(Map<String, dynamic> json) {
    return Creation(
      imageUrl: json['imageUrl'] as String,
      featureLabel: json['featureLabel'] as String,
      date: DateTime.parse(json['date'] as String),
    );
  }
}

class CreationsStore {
  static final CreationsStore _instance = CreationsStore._internal();
  factory CreationsStore() => _instance;
  CreationsStore._internal();

  List<Creation> creations = [];

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    final String? creationsStr = prefs.getString('creations_data');
    if (creationsStr != null) {
      final List<dynamic> decoded = jsonDecode(creationsStr);
      creations = decoded.map((e) => Creation.fromJson(e)).toList();
    }
  }

  Future<void> addCreation(Creation creation) async {
    creations.insert(0, creation);
    await _saveData();
  }

  Future<void> _saveData() async {
    final prefs = await SharedPreferences.getInstance();
    final String encoded = jsonEncode(creations.map((e) => e.toJson()).toList());
    await prefs.setString('creations_data', encoded);
  }
}
