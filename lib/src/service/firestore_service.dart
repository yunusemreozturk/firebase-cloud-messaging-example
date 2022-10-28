import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final firestore = FirebaseFirestore.instance;

  Future<void> saveToken(String token) async {
    await firestore.collection('UserTokens').doc('User1').set({
      'token': token,
    });
  }

  Future<String?> getToken(String name) async {
    DocumentSnapshot snapshot = await FirebaseFirestore.instance
        .collection('UserTokens')
        .doc(name)
        .get();

    return snapshot['token'];
  }
}
