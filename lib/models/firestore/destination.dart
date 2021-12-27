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
  int order;
  String? imgURL;
  DocumentReference? reference;

  Destination(this.flMeta, this.images, this.art, this.audio, this.destinationName, this.destinationSummary, this.difficulty, this.entryPoint, this.order);

  Destination.fromMap(Map<String, dynamic> map, {this.reference})
      : id = map['id'],
        flMeta = map['_fl_meta_'],
        images = map["images"] == ""
            ? []
            : map["images"].map<DestinationImage>((map) {
                return DestinationImage.fromMap(map);
              }).toList(),
        art = map["art"] == ""
            ? []
            : map["art"].map<DestinationArt>((map) {
                return DestinationArt.fromMap(map);
              }).toList(),
        audio = map['audio'] == ""
            ? []
            : map["audio"].map<DestinationAudio>((map) {
                return DestinationAudio.fromMap(map);
              }).toList(),
        destinationName = map['destinationName'],
        destinationSummary = map['destinationSummary'],
        difficulty = map['difficulty'],
        entryPoint = map['entryPoint'],
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
    for (var m in art) {
      mappedAudio.add(m.toMap());
    }

    return {
      'id': id,
      '_fl_meta_': flMeta,
      'images': mappedImages,
      'art': mappedArt,
      'audio': mappedAudio,
      'destinationName': destinationName,
      'destinationSummary': destinationSummary,
      'difficulty': difficulty,
      'entryPoint': entryPoint,
      'order': order,
    };
  }

  Destination.fromSnapshot(DocumentSnapshot? snapshot) : this.fromMap(snapshot!.data() as Map<String, dynamic>, reference: snapshot.reference);
}
