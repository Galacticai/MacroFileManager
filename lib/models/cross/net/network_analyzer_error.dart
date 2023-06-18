class NetworkAnalyzerError extends Error {
  final int code;
  final String message;
  NetworkAnalyzerError(this.code, this.message);

  static NetworkAnalyzerError get connectionFailed => NetworkAnalyzerError(13, "Connection failed (OS Error: Permission denied)");
  static NetworkAnalyzerError get bindFailed => NetworkAnalyzerError(49, "Bind failed (OS Error: Can't assign requested address)");
  static NetworkAnalyzerError get connectionRefused => NetworkAnalyzerError(61, "OS Error: Connection refused");
  static NetworkAnalyzerError get hostIsDown => NetworkAnalyzerError(64, "Connection failed (OS Error: Host is down)");
  static NetworkAnalyzerError get noRouteToHost => NetworkAnalyzerError(65, "No route to host");
  static NetworkAnalyzerError get networkIsUnreachable => NetworkAnalyzerError(101, "Network is unreachable");
  static NetworkAnalyzerError get connectionRefused2 => NetworkAnalyzerError(111, "Connection refused");
  static NetworkAnalyzerError get noRouteToHost2 => NetworkAnalyzerError(113, "No route to host");
  static NetworkAnalyzerError get connectionTimedOut => NetworkAnalyzerError(1, "SocketException: Connection timed out");
}
