import 'package:cloud_firestore/cloud_firestore.dart';

class WelcomeScreen {
  String? id;
  Map<String, dynamic> flMeta;
  String title;
  String? description;
  int order;
  DocumentReference? reference;

  WelcomeScreen(this.flMeta, this.title, this.description, this.order);

  WelcomeScreen.fromMap(Map<String, dynamic> map, {this.reference})
      : id = map['id'],
        flMeta = map['_fl_meta_'],
        title = map['title'],
        description = map['description'],
        order = map['order'];

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      '_fl_meta_': flMeta,
      'title': title,
      'description': description,
      'order': order,
    };
  }

  WelcomeScreen.fromSnapshot(DocumentSnapshot? snapshot) : this.fromMap(snapshot!.data() as Map<String, dynamic>, reference: snapshot.reference);
}
