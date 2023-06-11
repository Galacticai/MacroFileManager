import 'dart:io';

import 'package:path/path.dart' as path_tool;

import 'windows/windows_cmd/attrib.dart';

extension FileSystemEntityIsHidden on FileSystemEntity {
  bool get isHidden => isHiddenInOS(operatingSystem: "detectOS");
  bool get isHiddenWindows => isHiddenInOS(operatingSystem: "windows");
  bool get isHiddenUnix => isHiddenInOS(operatingSystem: "linux");

  bool isHiddenInOS({String operatingSystem = "detectOS"}) {
    if (operatingSystem == "detectOS") {
      operatingSystem = Platform.operatingSystem;
    }
    final name = path_tool.basename(path);
    switch (operatingSystem) {
      case "android":
      case "linux":
        return RegExp(r"^\..*$").hasMatch(name);
      case "windows":
        switch (name) {
          case "System Volume Information":
            return this is Directory;
          case "desktop.ini":
          case "Thumbs.db":
            return this is File;
          default:
            return Attrib(path).isHidden;
        }
      //nah not supporting others for now
      default:
        return false;
    }
  }
}
