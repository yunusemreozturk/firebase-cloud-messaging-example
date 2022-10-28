import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:timezone/data/latest.dart' as tz;

import '../fcm/fcm.dart';

class StartApp {
  static startFirebase() async {
    await Firebase.initializeApp();
  }

  static Future<void> startFCM() async {
    await FirebaseMessaging.instance.getInitialMessage();
    FirebaseMessaging.onBackgroundMessage(
        FCM.firebaseMessagingBackgroundHandler);

    tz.initializeTimeZones();
  }
}
