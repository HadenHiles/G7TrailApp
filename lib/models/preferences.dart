// ignore_for_file: file_names

class Preferences {
  bool darkMode;
  bool beaconFoundSound;
  bool beaconFoundVibrate;
  String? fcmToken;

  Preferences(this.darkMode, this.beaconFoundSound, this.beaconFoundVibrate, this.fcmToken);
}
