import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:g7trailapp/models/firestore/file.dart';

Future<String> imageDownloadURL(String refString) async {
  return await firebase_storage.FirebaseStorage.instance.ref(refString).getDownloadURL();
}

Future<String?> loadFirestoreImage(DocumentReference? image) async {
  return image == null
      ? null
      : await image.get().then((doc) async {
          File i = File.fromSnapshot(doc);
          return imageDownloadURL("/flamelink/media/sized/${i.sizes[1]['path']}/${i.file}").then((imgURL) {
            return imgURL;
          });
        });
}
