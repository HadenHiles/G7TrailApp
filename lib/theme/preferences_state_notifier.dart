import 'package:g7trailapp/models/preferences.dart';
import 'package:flutter/material.dart';

class PreferencesStateNotifier extends ChangeNotifier {
  Preferences preferences = Preferences((ThemeMode.system == ThemeMode.dark), null);

  void updateSettings(Preferences preferences) {
    this.preferences = preferences;
    notifyListeners();
  }
}
