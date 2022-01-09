import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:g7trailapp/models/firestore/file.dart';

Future<String> imageDownloadURL(String refString) async {
  return await firebase_storage.FirebaseStorage.instance.ref(refString).getDownloadURL();
}

Future<String?> loadFirestoreImage(DocumentReference? image, int? sizeIndex) async {
  int sizeIdx = sizeIndex ?? 1;
  bool raw = sizeIndex == null;
  String path = raw ? "/flamelink/media/" : "/flamelink/media/sized/";
  return image == null
      ? null
      : await image.get().then((doc) async {
          File i = File.fromSnapshot(doc);
          String url = raw ? path + i.file : path + "${i.sizes[sizeIdx]['path']}/" + i.file;

          return imageDownloadURL(url).then((imgURL) {
            return imgURL;
          });
        });
}
