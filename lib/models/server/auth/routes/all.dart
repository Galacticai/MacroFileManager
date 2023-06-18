import 'package:macro_file_manager/models/cross/net/http/http_method.dart';
import 'package:macro_file_manager/models/cross/net/http/http_route.dart';

final List<HttpRoute> all = [
  HttpRoute(
    "/",
    onRequest: {
      HttpMethod.get: (req) {
        return Future.value();
      },
    },
  ),
];
