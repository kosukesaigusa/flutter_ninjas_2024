// GENERATED CODE - DO NOT MODIFY BY HAND

import 'package:dart_firebase_functions/dart_firebase_functions.dart';
import 'package:functions_framework/serve.dart';
import 'package:server/functions.dart' as function_library;

Future<void> main(List<String> args) async {
  final app = function_library.initializeAdminApp();
  FirebaseFunctions.initialize(app);
  await serve(args, _nameToFunctionTarget);
}

FunctionTarget? _nameToFunctionTarget(String name) => switch (name) {
      'hello' => FunctionTarget.http(
          function_library.hello,
        ),
      'oncreateparticipant' =>
        FunctionTarget.cloudEventWithContext((event, context) {
          const pathPattern = 'participants/{participantId}';
          final documentIds =
              FirestorePathParser(pathPattern).parse(event.subject!);
          final data = QueryDocumentSnapshotBuilder(event).fromCloudEvent();
          return function_library.oncreateparticipant(
            (participantId: documentIds['participantId']!),
            data.snapshot,
            context,
          );
        }),
      _ => null
    };
