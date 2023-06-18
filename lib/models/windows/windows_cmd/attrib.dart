import 'dart:async';
import 'dart:convert';
import 'dart:io';

/// run attrib command for Windows 10-11 (supports others but Windows 7 may have less attributes)
class Attrib {
  final String path;
  final bool followSymlinks;
  final String attribOutput;

  Attrib(this.path, {this.followSymlinks = true}) : attribOutput = cmdAttribSync(path);
  Attrib._(this.path, {this.followSymlinks = true, required this.attribOutput});

  static Future<Attrib> createAsync(String path, {bool followSymlinks = true}) async {
    return Attrib._(path, followSymlinks: followSymlinks, attribOutput: await cmdAttrib(path));
  }

  bool get exists => attribOutput.contains("File not found");
  FileSystemEntityType get type => FileSystemEntity.typeSync(path, followLinks: followSymlinks);
  bool get isFile => type == FileSystemEntityType.file;
  bool get isDirectory => type == FileSystemEntityType.directory;
  bool get isLink => type == FileSystemEntityType.link;

  String get attributesOnly => attribOutput.replaceAll(path, "").trim();

  /// 	Read-only file attribute.
  bool get isReadOnly => attributesOnly.contains('R');

  /// 	Archive file attribute.
  bool get isArchive => attributesOnly.contains('A');

  /// 	System file attribute.
  bool get isSystem => attributesOnly.contains('S');

  /// 	Hidden file attribute.
  bool get isHidden => attributesOnly.contains('H');

  /// 	Offline attribute.
  bool get isOffline => attributesOnly.contains('O');

  /// 	Not content indexed file attribute.
  bool get isNotContentIndexed => attributesOnly.contains('I');

  /// 	No scrub file attribute
  bool get isNoScrub => attributesOnly.contains('X');

  /// 	Integrity attribute.
  bool get isIntegrity => attributesOnly.contains('V');

  /// 	Pinned attribute.
  bool get isPinned => attributesOnly.contains('P');

  /// 	Unpinned attribute.
  bool get isUnpinned => attributesOnly.contains('U');

  /// 	SMR Blob attribute.
  bool get isSmrBlob => attributesOnly.contains('B');

  static String cmdAttribSync(String path) {
    if (!Platform.isWindows || path.isEmpty) return "";
    final ProcessResult result = Process.runSync("attrib", [path]);
    return result.stdout.toString();
  }

  static Future<String> cmdAttrib(String path) async {
    if (!Platform.isWindows || path.isEmpty) return "";
    final Process process = await Process.start("attrib", [path]);
    return await process.stdout.transform(utf8.decoder).join();
  }
}
