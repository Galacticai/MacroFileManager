import 'dart:convert';
import 'dart:io';

class Vol {
  final String path;
  final String volOutput;

  Vol(this.path) : volOutput = cmdVolSync(path);
  Vol._(this.path, {required this.volOutput});

  static Future<Vol> createAsync(String letter) async {
    return Vol._(letter, volOutput: await cmdVol(letter));
  }

  bool get found => _patterns["label"]!.hasMatch(volOutput.trim());
  String get label => _part("label");
  String get serial => _part("serial");

  String _part(String partName) => _patterns[partName]!.firstMatch(volOutput.trim())?.group(0)?.substring(_partLengths[partName]!) ?? "";
  final Map<String, RegExp> _patterns = {
    "label": RegExp(r"Volume in drive [A-Z] is .+"),
    "serial": RegExp(r"Volume Serial Number is .+"),
  };
  final Map<String, int> _partLengths = {
    "label": "Volume in drive X is ".length,
    "serial": "Volume Serial Number is ".length,
  };

  static String cmdVolSync(String path) {
    if (!Platform.isWindows || path.isEmpty) return "";
    final ProcessResult result = Process.runSync("cmd", ["/c", "vol \"$path\""], runInShell: true);
    final String text = result.stdout.toString();
    return text.trim();
  }

  static Future<String> cmdVol(String path) async {
    final Process process = await Process.start("vol", [path], runInShell: true);
    final String text = await process.stdout.transform(utf8.decoder).join();
    return text.trim();
  }
}
