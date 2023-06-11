import 'dart:io';

import 'package:file_icon/file_icon.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:path/path.dart' as path_tools;

extension FileSystemEntityExtension on FileSystemEntity {
  iconColored(Color? color, {double? size}) {
    double? sizeFontAwesome = size == null ? null : size / 1.6;
    if (this is Directory) {
      return Icon(FontAwesomeIcons.folder, color: color, size: sizeFontAwesome);
    } else if (this is File) {
      return FileIcon(path_tools.basename(path), size: size);
    } else if (this is Link) {
      //!? not calling iconColored to avoid creating an instance of entity again
      //!? so only using type instead
      final targetEntity = FileSystemEntity.typeSync(path, followLinks: true);
      return targetEntity is Directory ? Icon(FontAwesomeIcons.folder, color: color, size: sizeFontAwesome) : FileIcon(path_tools.basename(path));
    } else {
      return Icon(FontAwesomeIcons.triangleExclamation, color: color, size: sizeFontAwesome);
    }
  }

  get icon => iconColored(null);
}
