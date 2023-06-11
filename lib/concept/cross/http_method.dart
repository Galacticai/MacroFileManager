enum HttpMethod {
  get,
  post,
  put,
  delete,
  head,
  patch,
  options;

  String get name => toString().split(".").last.toUpperCase();
}
