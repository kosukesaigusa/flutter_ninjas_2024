import 'package:dart_firebase_admin/dart_firebase_admin.dart';
import 'package:dart_firebase_admin/messaging.dart';
import 'package:dart_firebase_functions/dart_firebase_functions.dart';
import 'package:functions_framework/functions_framework.dart';
import 'package:shelf/shelf.dart';

import 'config/config.dart';

FirebaseAdminApp initializeAdminApp() => adminApp;

@HTTPFunction()
Future<Response> hello(Request request) async => Response.ok('Hello, World!');

@OnDocumentCreated('participants/{participantId}')
Future<void> oncreateparticipant(
  ({String participantId}) params,
  QueryDocumentSnapshot snapshot,
  RequestContext context,
) async {
  context.logger.debug('participantId: ${params.participantId}');
  final data = snapshot.data();
  final token = data?['token'] as String?;
  if (token == null) {
    context.logger.error('Token is missing: ${params.participantId}');
    return;
  }

  await messaging.send(
    TokenMessage(
      token: token,
      notification: Notification(
        title: 'FlutterNinjas 2024!',
        body: 'Welcome to FlutterNinjas!',
        imageUrl: 'https://cdn.kosukesaigusa.com/assets%2Fflutter_ninja.png',
      ),
    ),
  );
  await snapshot.ref.update({'isNotificationSent': true});
}
