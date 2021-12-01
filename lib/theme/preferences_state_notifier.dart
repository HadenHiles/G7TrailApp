import 'package:g7trailapp/models/preferences.dart';
import 'package:flutter/material.dart';
import 'package:g7trailapp/main.dart';

class PreferencesStateNotifier extends ChangeNotifier {
  Preferences prefs = preferences;

  void updateSettings(Preferences preferences) {
    prefs = preferences;
    notifyListeners();
  }
}
