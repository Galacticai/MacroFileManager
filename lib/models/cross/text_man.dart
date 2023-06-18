import 'dart:io';
import 'dart:math';

import 'package:macro_file_manager/models/cross/special_characters.dart';

class TextMan {
  static String shortPath(String path, int keepStart, int keepEnd, {bool trailingSeparator = false, String pathSeparator = "detectOS"}) {
    if (path.isEmpty) return path;
    if (pathSeparator == "detectOS") {
      pathSeparator = Platform.isWindows ? '\\' : '/';
    }

    final parts = path.split(pathSeparator);

    final len = parts.length;
    if (len == 1) return path;
    if (keepStart >= len && keepEnd >= len) return path;

    keepStart = max(0, min(keepStart, len - 1));
    keepEnd = max(0, min(keepEnd, len - 1));

    final firstParts = parts.sublist(0, keepStart);
    var lastParts = parts.sublist(len - keepEnd);
    if (lastParts.isEmpty || lastParts.last.isEmpty) {
      lastParts = lastParts.sublist(0, max(1, lastParts.length - 1));
    }

    final start = firstParts.join(pathSeparator);
    const middle = SpecialCharacters.narrowNonBreakingSpace + SpecialCharacters.ellipses + SpecialCharacters.narrowNonBreakingSpace;
    final end = lastParts.join(pathSeparator);
    final trail = trailingSeparator ? pathSeparator : "";

    return start + pathSeparator + middle + pathSeparator + end + trail;
  }

  String fixPath(String path, {String platform = "detectOS"}) {
    if (platform == "detectOS") {
      platform = Platform.operatingSystem;
    }
    final separator = platform == "windows" ? '\\' : '/';
    final separatorAnti = platform != "windows" ? '\\' : '/';

    path = path.replaceAll(separatorAnti, separator);
    path = path.replaceAll(separator + separator, separator);

    if (platform == "linux" || platform == "android") {
      // Convert drive letter to root directory (only for Unix-like systems)
      if (path.length > 1 && path[1] == ':') {
        path = '/${path.substring(0, 1).toLowerCase()}${path.substring(2)}';
      }
    }

    return path;
  }
}
