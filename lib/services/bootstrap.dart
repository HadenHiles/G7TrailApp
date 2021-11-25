import 'package:firebase_auth/firebase_auth.dart';

final user = FirebaseAuth.instance.currentUser;

Future<void> bootstrap() async {
  await bootstrapUserData();
}

Future<void> bootstrapUserData() async {}
