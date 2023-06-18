enum HttpMethod {
  get,
  post,
  put,
  delete,
  head,
  patch,
  options;

  /// Returns the name of the HTTP method in uppercase.
  /// Example: `HttpMethod.get.name` is `"GET"`
  String get name => toString().split(".").last.toUpperCase();
  static HttpMethod getHttpMethod(String s) => HttpMethod.values.firstWhere((e) => e.name == s.toLowerCase());
}
