import 'dart:convert';

import 'package:firebase_cloud_messaging/src/service/firestore_service.dart';
import 'package:firebase_cloud_messaging/src/view/home_page.dart';
import 'package:firebase_cloud_messaging/src/view/second_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:timezone/timezone.dart' as tz;

class FCM extends GetxController {
  late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  final _messaging = FirebaseMessaging.instance;
  final FirestoreService _firestoreService = FirestoreService();
  var initializationsSettings;

  @override
  void onInit() async {
    super.onInit();

    await requestPermisssion();
    await getToken();
    initializePlatform();
    await listenNotification();
  }

  static Future<void> firebaseMessagingBackgroundHandler(
      RemoteMessage message) async {
    await Firebase.initializeApp();
  }

  Future<void> requestPermisssion() async {
    await _messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );
  }

  Future<void> getToken() async {
    await _messaging.getToken().then((String? value) async {
      await _firestoreService.saveToken(value!);
    });
  }

  void initializePlatform() {
    var androidInitialize =
        const AndroidInitializationSettings('@mipmap/ic_launcher');
    var iosInitialize = const DarwinInitializationSettings();

    initializationsSettings =
        InitializationSettings(android: androidInitialize, iOS: iosInitialize);

    flutterLocalNotificationsPlugin.initialize(
      initializationsSettings,
      onDidReceiveNotificationResponse: onDidReceiveNotificationResponse,
    );
  }

  Future<void> listenNotification() async {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      BigTextStyleInformation bigTextStyleInformation = BigTextStyleInformation(
        message.notification!.body.toString(),
        htmlFormatBigText: true,
        contentTitle: message.notification!.title.toString(),
        htmlFormatContent: true,
      );

      AndroidNotificationDetails androidPlatformChannelSpecifics =
          AndroidNotificationDetails(
        'CHANNEL_NAME',
        'CHANNEL_DESCRIPTION',
        importance: Importance.max,
        styleInformation: bigTextStyleInformation,
        priority: Priority.high,
        playSound: true,
      );

      NotificationDetails platformChannelSpecifics = NotificationDetails(
        android: androidPlatformChannelSpecifics,
        iOS: const DarwinNotificationDetails(),
      );

      // await zonedScheduleNotification(
      //   message.notification!.body!,
      //   DateTime.now().add(const Duration(seconds: 1)),
      //   message.notification!.title,
      //   platformChannelSpecifics,
      // );

      showNotification(
        message.notification!.body!,
        message.notification!.title!,
        platformChannelSpecifics,
      );
    });
  }

  void onDidReceiveNotificationResponse(NotificationResponse details) {
    if (details.payload != null && details.payload!.isNotEmpty) {
      Get.to(() => SecondPage(info: details.payload.toString()));
    } else {
      Get.to(() => const HomePage());
    }
  }

  void showNotification(
    String note,
    String occ,
    NotificationDetails channelDetails,
  ) async {
    int id = 0;
    await flutterLocalNotificationsPlugin.show(
      id,
      occ,
      note,
      channelDetails,
      payload: note,
    );
  }

  Future<void> zonedScheduleNotification(
    String note,
    DateTime date,
    occ,
    NotificationDetails channelDetails,
  ) async {
    try {
      int id = 0;
      await flutterLocalNotificationsPlugin.zonedSchedule(
        id,
        occ,
        note,
        tz.TZDateTime.parse(tz.local, date.toString()),
        channelDetails,
        androidAllowWhileIdle: true,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );
    } catch (e) {
      print('Error: FCM(zonedScheduleNotification): ${e.toString()}');
    }
  }

  void sendPushMessage(String token, String body, String title) async {
    try {
      await http.post(
        Uri.parse('https://fcm.googleapis.com/fcm/send'),
        headers: <String, String>{
          'Content-Type': 'application/json',
          'Authorization': 'key=YOUR_SERVER_KEY',
        },
        body: jsonEncode(
          <String, dynamic>{
            'priority': 'high',
            'data': <String, dynamic>{
              'click_action': 'FLUTTER_NOTIFICATION_CLICK',
              'status': 'done',
              'body': body,
              'title': title
            },
            'notification': <String, dynamic>{
              'title': title,
              'body': body,
              'android_channel_id': 'CHANNEL_NAME'
            },
            'to': token,
          },
        ),
      );
    } catch (e) {
      print('Error: FCM(sendPushMessage): ${e.toString()}');
    }
  }
}
