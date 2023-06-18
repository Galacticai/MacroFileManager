import 'dart:io';

import 'package:package_info_plus/package_info_plus.dart';

/// Info about a Macro File Manager host
class MacroHost {
  final String name;
  final Uri uri;
  final List<(FileSystemEntityType, String)> paths;

  const MacroHost(this.name, this.uri, this.paths);

  @override
  String toString() => uri.toString();
  String toMacroFmString() => "macrofm://${uri.host}:${uri.port}/${uri.path}";
  String toPath(String path) => "${toMacroFmString()}/$path";

  /// The default port for Macro File Manager
  static const int port = 21821;

  /// The user agent string for Macro File Manager
  /// Example: `"macrofm/v1.0.0 (macrofilemanager)"`
  static Future<String> getUserAgent() async {
    final package = await PackageInfo.fromPlatform();
    final platform = Platform.version.split(' ');
    final dartVersion = platform.first;
    final os = platform.last.replaceAll('"', '');
    return "macrofm/${package.version} (${package.packageName}) Dart/$dartVersion (dart:io)";
  }

  static bool isMacroUserAgent(String userAgent) => RegExp(r"macrofm/v\d+\.\d+\.\d+ \(macrofilemanager\)").hasMatch(userAgent);

  static Future<MacroHost> getMacroHost(String host) async {
    try {
      HttpClient client = HttpClient();
      client.userAgent = await getUserAgent();
      HttpClientRequest request = await client.get(host, MacroHost.port, "/info");
      print(client.userAgent);
      final uri = Uri.parse("http://$host:$port");
      return MacroHost(uri.host, uri, []);
    } catch (e) {
      return Future.error(e);
    }
  }
}
