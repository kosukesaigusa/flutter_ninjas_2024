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
      theme: ThemeData(
        primaryColor: AppColor.primaryBlue,
        colorScheme:
            ThemeData().colorScheme.copyWith(primary: AppColor.primaryBlue),
        scaffoldBackgroundColor: AppColor.backgroundNavy,
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColor.backgroundNavy,
          foregroundColor: AppColor.primaryWhite,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            foregroundColor: AppColor.primaryWhite,
            backgroundColor: AppColor.primaryBlue,
            padding: const EdgeInsets.all(16),
          ),
        ),
      ),
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
        final notification = message.notification;
        if (notification != null) {
          print('notification title: ${notification.title}');
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
                if ((await FirebaseFirestore.instance
                        .collection('participants')
                        .doc(uid)
                        .get())
                    .exists) {
                  if (!context.mounted) {
                    return;
                  }
                  ScaffoldMessenger.of(context)
                    ..removeCurrentSnackBar()
                    ..showSnackBar(
                      const SnackBar(
                        content: Text("You've already joined FlutterNinjas!"),
                      ),
                    );
                  return;
                }
                await FirebaseFirestore.instance
                    .collection('participants')
                    .doc(uid)
                    .set({'token': token});
                if (!context.mounted) {
                  return;
                }
                ScaffoldMessenger.of(context)
                  ..removeCurrentSnackBar()
                  ..showSnackBar(
                    const SnackBar(
                      content: Text('Joined FlutterNinjas! 🎉'),
                    ),
                  );
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
                ScaffoldMessenger.of(context)
                  ..removeCurrentSnackBar()
                  ..showSnackBar(
                    const SnackBar(content: Text('Canceled participation.')),
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

abstract interface class AppColor {
  static const primaryBlue = Color(0xFF3ca6d0);
  static const backgroundNavy = Color(0xFF015699);
  static const primaryWhite = Color(0xFFFFFFFF);
}
