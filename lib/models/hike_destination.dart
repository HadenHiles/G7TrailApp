import 'dart:convert';

class HikeDestination {
  String id;
  bool entryPoint;
  String destinationName;
  String beaconTitle;
  String beaconId;
  String? imgURL;

  HikeDestination({
    required this.id,
    required this.entryPoint,
    required this.destinationName,
    required this.beaconTitle,
    required this.beaconId,
    this.imgURL,
  });

  factory HikeDestination.fromJson(Map<String, dynamic> jsonData) {
    return HikeDestination(
      id: jsonData['id'],
      entryPoint: jsonData['entry_point'],
      destinationName: jsonData['destination_name'],
      beaconTitle: jsonData['beacon_title'],
      beaconId: jsonData['beacon_id'],
      imgURL: jsonData['img_url'],
    );
  }

  static Map<String, dynamic> toMap(HikeDestination d) => {
        'id': d.id,
        'entry_point': d.entryPoint,
        'destination_name': d.destinationName,
        'beacon_title': d.beaconTitle,
        'beacon_id': d.beaconId,
        'img_url': d.imgURL,
      };

  static String encode(List<HikeDestination> destinations) => json.encode(
        destinations.map<Map<String, dynamic>>((d) => HikeDestination.toMap(d)).toList(),
      );

  static List<HikeDestination> decode(String destinations) => (json.decode(destinations) as List<dynamic>).map<HikeDestination>((item) => HikeDestination.fromJson(item)).toList();
}
