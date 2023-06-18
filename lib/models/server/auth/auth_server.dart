import 'dart:convert';
import 'dart:io';

import 'package:macro_file_manager/models/Keys/Key.dart';
import 'package:macro_file_manager/models/cross/net/http/http_method.dart';

class AuthServer {
  static const int port = 21821;

  static start() async {
    final pair = await Key.getSimplePair(generateIfMissing: true);
    final privateKeyBytes = utf8.encode(pair.privateKey);
    // final context = SecurityContext.defaultContext..usePrivateKeyBytes(privateKeyBytes);
    final ip = InternetAddress.anyIPv4;
    final server = await HttpServer.bind(ip, port);

    await for (HttpRequest request in server) {
      handleConnection(request);
    }
  }

  static int lastRequest = 0;
  static Future<void> handleConnection(HttpRequest request) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    if (lastRequest + 1000 < now) {
      request.response
        ..statusCode = 418 //? I'm a teapot
        ..close();
      return;
    }
    lastRequest = now;

    if (request.method == HttpMethod.get.name) {
      request.response
        ..headers.contentType = ContentType.text
        ..write("Hello, world!")
        ..close();
    } else {
      request.response
        ..statusCode = HttpStatus.methodNotAllowed
        ..write("Unsupported request: ${request.method}.")
        ..close();
    }
  }
}
