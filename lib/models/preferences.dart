// ignore_for_file: file_names

class Preferences {
  bool darkMode;
  bool beaconFoundAlert;
  bool autoPlayAudio;
  String? fcmToken;

  Preferences(this.darkMode, this.beaconFoundAlert, this.autoPlayAudio, this.fcmToken);
}
