import 'dart:async';
import 'dart:io';

import 'package:macro_file_manager/models/cross/net/http/http_method.dart';

class HttpServerExpress {
  final dynamic host;
  final int port;

  /// Throttle requests
  /// - This throttles all clients together
  /// - 1 request/sec by default
  /// - Negative or 0 value means no throttling
  Duration requestThrottling;
  late Map<HttpMethod, Future Function(HttpRequest request)>? responses;
  HttpServer? _server;

  HttpServerExpress(this.host, this.port, {this.responses, this.requestThrottling = Duration.zero});

  Future<void> start() async {
    if (_server != null) return;
    _server = await HttpServer.bind(host, port);
    await for (HttpRequest request in _server!) {
      if (_server == null) break;
      _response(request);
    }
  }

  Future<void> stop() async {
    if (_server == null) return;
    await _server!.close();
    _server = null;
  }

  /// Find all hosts on the subnet. Returns a stream of [HttpClientRequest]s.
  /// - This skips failed connections
  static Stream<HttpClientRequest?> discover(
    String subnet, {
    int port = 80,
    Duration timeout = const Duration(seconds: 5),
  }) {
    final controller = StreamController<HttpClientRequest?>();
    if (port < 1 || port > 0xFFFF) {
      controller.addError("Port ($port) must be between 1 and 65535 (0xFFFF)");
      controller.close();
      return controller.stream;
    }
    // TODO: validate subnet

    final futures = <Future>[];
    for (int i = 1; i <= 0xFF; ++i) {
      final host = '$subnet.$i';
      final future = _ping(host, port: port, timeout: timeout);
      futures.add(future);

      finished() {
        futures.remove(future);
        if (futures.isEmpty) controller.close();
      }

      future
        ..then((request) {
          if (request != null) controller.add(request);
        })
        ..timeout(timeout, onTimeout: finished)
        ..whenComplete(finished);
    }

    // Future.wait(futures).timeout(timeout);

    return controller.stream;
  }

  late int lastRequestTime;
  Future<void> _response(HttpRequest request) async {
    if (responses == null || responses!.isEmpty || !responses!.containsKey(request.method)) {
      request.response
        ..statusCode = 418 //? I'm a teapot
        ..close();
      return;
    }
    if (requestThrottling.inMilliseconds > 0) {
      //? Throttle requests - 1 request/sec
      final time = DateTime.now().millisecondsSinceEpoch;
      if (lastRequestTime + requestThrottling.inMilliseconds < time) {
        request.response
          ..statusCode = HttpStatus.tooManyRequests
          ..close();
        return;
      }
      lastRequestTime = time;
    }
    responses![HttpMethod.getHttpMethod(request.method)]?.call(request);
  }

  /// Ping a host. Returns a [HttpClientRequest] if successful, otherwise null.
  static Future<HttpClientRequest?> _ping(
    String host, {
    int port = 80,
    String path = '/',
    Duration timeout = const Duration(seconds: 5),
  }) async {
    try {
      final client = HttpClient()..connectionTimeout = timeout;
      return await client.get(host, port, path);
    } catch (_) {
      return null;
    }
  }
}
