class HttpRoute {
  final String _path;
  final String _method;
  String get path => _path;
  String get method => _method;

  const HttpRoute(this._path, this._method);

  @override
  bool operator ==(other) => other is HttpRoute && other._path == _path && other._method == _method;
  @override
  int get hashCode => _path.hashCode ^ _method.hashCode;
}
