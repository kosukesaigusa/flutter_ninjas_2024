import 'package:functions_framework/functions_framework.dart';
import 'package:shelf/shelf.dart';

@CloudFunction()
Response hello(Request request) => Response.ok('Hello, Flutter Ninjas!');
