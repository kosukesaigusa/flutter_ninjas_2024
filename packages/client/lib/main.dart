import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const App(),
      scrollBehavior: const MaterialScrollBehavior().copyWith(
        dragDevices: {
          PointerDeviceKind.mouse,
          PointerDeviceKind.touch,
          PointerDeviceKind.stylus,
          PointerDeviceKind.unknown,
        },
      ),
    ),
  );
}

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print('🔔 Handling a background message: ${message.messageId}');
}

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  @override
  void initState() {
    () async {
      await FirebaseAuth.instance.signInAnonymously();
      final messaging = FirebaseMessaging.instance;
      final settings = await messaging.requestPermission();
      print('User granted permission: ${settings.authorizationStatus}');
      FirebaseMessaging.onMessage.listen((message) {
        print('Got a message whilst in the foreground!');
        print('Message data: ${message.data}');
        if (message.notification != null) {
          print(
            'Message also contained a notification: ${message.notification}',
          );
        }
      });
    }();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('FlutterNinjas 2024')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(
              height: 96,
              width: 96,
              child: Image(image: AssetImage('assets/flutter_ninjas.png')),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () async {
                final apnsToken =
                    await FirebaseMessaging.instance.getAPNSToken();
                if (apnsToken == null) {
                  return;
                }
                final token = await FirebaseMessaging.instance.getToken();
                final uid = FirebaseAuth.instance.currentUser?.uid;
                if (token == null || uid == null) {
                  return;
                }
                await FirebaseFirestore.instance
                    .collection('participants')
                    .doc(uid)
                    .set({'token': token});
              },
              child: const Text('Join FlutterNinjas!'),
            ),
            const SizedBox(height: 32),
            TextButton(
              onPressed: () async {
                final uid = FirebaseAuth.instance.currentUser?.uid;
                if (uid == null) {
                  return;
                }
                await FirebaseFirestore.instance
                    .collection('participants')
                    .doc(uid)
                    .delete();
                if (!context.mounted) {
                  return;
                }
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Canceled participation')),
                );
              },
              child: const Text('Cancel participation'),
            ),
          ],
        ),
      ),
    );
  }
}
