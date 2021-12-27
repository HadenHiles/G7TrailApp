import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;

Future<String> imageDownloadURL(String refString) async {
  return await firebase_storage.FirebaseStorage.instance.ref(refString).getDownloadURL();
}
