import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:g7trailapp/models/firestore/destination_art.dart';
import 'package:g7trailapp/models/firestore/destination_audio.dart';
import 'package:g7trailapp/models/firestore/destination_image.dart';

class Destination {
  String? id;
  Map<String, dynamic> flMeta;
  List<DestinationImage> images;
  List<DestinationArt> art;
  List<DestinationAudio> audio;
  String destinationName;
  String destinationSummary;
  String difficulty;
  bool entryPoint;
  List<DocumentReference> nearbyDestinations;
  String beaconTitle;
  String beaconId;
  double latitude;
  double longitude;
  String panoId;
  int order;
  String? imgURL;
  DocumentReference? reference;

  Destination(
    this.flMeta,
    this.images,
    this.art,
    this.audio,
    this.destinationName,
    this.destinationSummary,
    this.difficulty,
    this.entryPoint,
    this.nearbyDestinations,
    this.beaconTitle,
    this.beaconId,
    this.latitude,
    this.longitude,
    this.panoId,
    this.order,
  );

  Destination.fromMap(Map<String, dynamic> map, {this.reference})
      : id = map['id'],
        flMeta = map['_fl_meta_'],
        images = map['content']["images"] == ""
            ? []
            : map['content']["images"].map<DestinationImage>((map) {
                return DestinationImage.fromMap(map);
              }).toList(),
        art = map['content']["art"] == ""
            ? []
            : map['content']["art"].map<DestinationArt>((map) {
                return DestinationArt.fromMap(map);
              }).toList(),
        audio = map['content']['audio'] == ""
            ? []
            : map['content']["audio"].map<DestinationAudio>((map) {
                return DestinationAudio.fromMap(map);
              }).toList(),
        destinationName = map['destinationName'],
        destinationSummary = map['content']['destinationSummary'],
        difficulty = map['content']['difficulty'],
        entryPoint = map['entryPoint'],
        nearbyDestinations = map['nearbyDestinations'].isEmpty
            ? []
            : map['nearbyDestinations'].map<DocumentReference>((map) {
                return map as DocumentReference;
              }).toList(),
        beaconTitle = map['beaconInfo']['beaconTitle'] ?? "",
        beaconId = map['beaconInfo']['beaconId'] ?? "",
        latitude = (map['beaconInfo']['latitude'] == "" || map['beaconInfo']['latitude'] == null) ? 0.0 : map['beaconInfo']['latitude'],
        longitude = (map['beaconInfo']['longitude'] == "" || map['beaconInfo']['longitude'] == null) ? 0.0 : map['beaconInfo']['longitude'],
        panoId = (map['beaconInfo']['panoId'] == "" || map['beaconInfo']['panoId'] == null) ? "" : map['beaconInfo']['panoId'], // TODO: replace default empty string with a panoId of parking lot or something
        order = map['order'];

  Map<String, dynamic> toMap() {
    List<Map<String, dynamic>> mappedImages = [];
    List<Map<String, dynamic>> mappedArt = [];
    List<Map<String, dynamic>> mappedAudio = [];

    for (var m in images) {
      mappedImages.add(m.toMap());
    }
    for (var m in art) {
      mappedArt.add(m.toMap());
    }
    for (var m in audio) {
      mappedAudio.add(m.toMap());
    }

    return {
      'id': id,
      '_fl_meta_': flMeta,
      'destinationName': destinationName,
      'entryPoint': entryPoint,
      'content': {
        'images': mappedImages,
        'art': mappedArt,
        'audio': mappedAudio,
        'destinationSummary': destinationSummary,
        'difficulty': difficulty,
      },
      'nearbyDestinations': nearbyDestinations,
      'beaconInfo': {
        'beaconTitle': beaconTitle,
        'beaconId': beaconId,
        'latitude': latitude,
        'longitude': longitude,
        'panoId': panoId,
      },
      'order': order,
    };
  }

  Destination.fromSnapshot(DocumentSnapshot? snapshot) : this.fromMap(snapshot!.data() as Map<String, dynamic>, reference: snapshot.reference);
}
