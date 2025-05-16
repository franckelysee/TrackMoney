// app_settings_service.dart
import 'package:hive_flutter/hive_flutter.dart';

class AppSettingsService {
  static const String _boxName = 'appSettings';

  // Ouvrir la boîte des paramètres de l'application
  static Future<Box> _openBox() async {
    return await Hive.openBox(_boxName);
  }

  // Vérifier si c'est la première ouverture de l'application
  static Future<bool> isFirstLaunch() async {
    final box = await _openBox();
    return box.get('isFirstLaunch', defaultValue: true);
  }

  // Mettre à jour l'indicateur de la première ouverture
  static Future<void> setFirstLaunch(bool isFirstLaunch) async {
    final box = await _openBox();
    await box.put('isFirstLaunch', isFirstLaunch);
  }

  // Enregistrer un paramètre
  static Future<void> setSetting(String key, dynamic value) async {
    final box = await _openBox();
    await box.put(key, value);
  }

  // Récupérer un paramètre
  static Future<dynamic> getSetting(String key, {dynamic defaultValue}) async {
    final box = await _openBox();
    return box.get(key, defaultValue: defaultValue);
  }

  // Supprimer un paramètre
  static Future<void> deleteSetting(String key) async {
    final box = await _openBox();
    await box.delete(key);
  }

  // Vérifier si un paramètre existe
  static Future<bool> hasSetting(String key) async {
    final box = await _openBox();
    return box.containsKey(key);
  }

  // Récupérer tous les paramètres
  static Future<Map<dynamic, dynamic>> getAllSettings() async {
    final box = await _openBox();
    final Map<dynamic, dynamic> settings = {};
    for (var key in box.keys) {
      settings[key] = box.get(key);
    }
    return settings;
  }

  // Supprimer tous les paramètres
  static Future<void> clearAllSettings() async {
    final box = await _openBox();
    await box.clear();
  }
}
