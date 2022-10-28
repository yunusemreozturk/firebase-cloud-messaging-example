import 'package:firebase_cloud_messaging/src/fcm/fcm.dart';
import 'package:firebase_cloud_messaging/src/service/firestore_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  TextEditingController username = TextEditingController();
  TextEditingController title = TextEditingController();
  TextEditingController body = TextEditingController();

  final FirestoreService _firestoreService = FirestoreService();
  final FCM fcm = Get.find();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
          child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          TextFormField(
            controller: username,
          ),
          TextFormField(
            controller: title,
          ),
          TextFormField(
            controller: body,
          ),
          GestureDetector(
            onTap: () async {
              String name = username.text.trim();
              String titleText = title.text;
              String bodyText = body.text;

              if (name != '') {
                String? token = await _firestoreService.getToken(name);

                print('token: ${token!}');

                fcm.sendPushMessage(token, titleText, bodyText);
              }
            },
            child: Container(
              margin: const EdgeInsets.all(20),
              height: 40,
              width: 200,
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.redAccent.withOpacity(0.5),
                  )
                ],
              ),
              child: const Center(child: Text('Button')),
            ),
          )
        ],
      )),
    );
  }
}
