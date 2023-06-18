import 'dart:io';

import 'package:macro_file_manager/models/cross/net/http/http_method.dart';

class HttpRoute {
  final String path;
  final Map<HttpMethod, Future Function(HttpRequest request)>? onRequest;

  const HttpRoute(this.path, {this.onRequest});

  @override
  bool operator ==(other) => other is HttpRoute && other.path == path;
  @override
  int get hashCode => path.hashCode ^ onRequest.hashCode;
  @override
  String toString() => path;
}
