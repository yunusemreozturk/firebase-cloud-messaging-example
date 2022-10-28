import 'package:firebase_cloud_messaging/src/app.dart';
import 'package:firebase_cloud_messaging/src/fcm/fcm.dart';
import 'package:firebase_cloud_messaging/src/start_app/start_app.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await StartApp.startFirebase();
  await StartApp.startFCM();

  Get.lazyPut(() => FCM(), fenix: true);

  runApp(const MyApp());
}
