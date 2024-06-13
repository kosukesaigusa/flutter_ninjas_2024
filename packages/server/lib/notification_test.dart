import 'package:dart_firebase_admin/messaging.dart';

import 'config/config.dart';

void main(List<String> args) async {
  const title = 'FCM test by dart_firebase_admin!';
  const body = 'Hello from Demo!';
  final messaging = Messaging(adminApp);
  final token = args.first;
  final messageId = await messaging.send(
    TokenMessage(
      token: token,
      notification: Notification(
        title: title,
        body: body,
        imageUrl: 'https://cdn.kosukesaigusa.com/assets%2Fflutter_ninja.png',
      ),
    ),
  );
  print('messageId: $messageId');
}
