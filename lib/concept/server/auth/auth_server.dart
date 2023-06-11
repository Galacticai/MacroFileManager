import 'dart:convert';
import 'dart:io';

import 'package:macro_file_manager/concept/Keys/Key.dart';

class AuthServer {
  static const int port = 21821;

  start() async {
    final pair = await Key.getSimplePair(generateIfMissing: true);
    final privateKeyBytes = utf8.encode(pair.privateKey);
    // final context = SecurityContext.defaultContext..usePrivateKeyBytes(privateKeyBytes);
    final ip = InternetAddress.anyIPv4;
    final server = await HttpServer.bind(ip, port);

    await for (HttpRequest request in server) {
      handleConnection(request);
    }
  }

  handleConnection(HttpRequest request) async {
    if (request.method == "GET") {
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
    // Handle the SSH handshake and authentication process here.
    // This will typically involve reading and writing data to/from the
    // clientSocket using the SecureSocket class.

    // Once the client is authenticated, you can execute commands
    // using the SSH protocol by sending and receiving data over the
    // clientSocket.
  }
}
