import 'dart:io';
import 'dart:math';

import 'package:process_run/shell.dart';

/// Get disk space information for a given path using the `df` command. (Check [infoCommand])
/// This is only supported on Linux and Android.
/// You will get [null] if the platform is unsupported
class DF {
  final String requestedPath;
  final List<String> infoOutput;

  final String filesystem;
  final int blocks;
  final int total;
  final int used;
  final int available;
  final double useRatio;
  final String mountPoint;

  DF._({
    required this.requestedPath,
    required this.infoOutput,
    required this.filesystem,
    required this.blocks,
    required this.used,
    required this.available,
    required this.useRatio,
    required this.total,
    required this.mountPoint,
  });

  static Future<DF?> createAsync(String path) async {
    if (!Platform.isAndroid && !Platform.isLinux) return null;

    final info = await getInfo(path);

    final String filesystem = info[0].trim();
    final int blocks = (int.tryParse(info[1]) ?? 0) * 1024;
    final int used = (int.tryParse(info[2]) ?? 0) * 1024;
    final int available = max(1, (int.tryParse(info[3]) ?? 0) * 1024);
    final int total = used + available;
    final double useRatio = (int.tryParse(info[4].replaceAll("%", "")) ?? 0) / 100;
    final String mountpoint = info[5].trim();

    return DF._(
      requestedPath: path,
      infoOutput: info,
      filesystem: filesystem,
      blocks: blocks,
      used: used,
      available: available,
      total: total,
      useRatio: useRatio,
      mountPoint: mountpoint,
    );
  }

  /// df -k [mountpoint] | awk '{print $1";"$2";"$3";"$4";"$5";"$6}' | tail -n 1
  /// - Returns a string with the following format: Filesystem;1Kblocks;Used;Available;UsedPercent;MountPoint
  /// - Example output: /dev/sda3;30267332;11080360;17624144;39%;/
  static String infoCommand(
    String mountpoint, {
    bool filesystem = true,
    bool blocks = true,
    bool used = true,
    bool available = true,
    bool usedPercent = true,
    bool mountPoint = true,
  }) {
    return "df -k $mountpoint  | awk '{print \$1\";\"\$2\";\"\$3\";\"\$4\";\"\$5\";\"\$6}' | tail -n 1";
  }

  /// run [infoCommand] and return the output as a [List]<[String]>
  static Future<List<String>> getInfo(String mountpoint, {Shell? shell}) async {
    shell ??= Shell();
    final resultRaw = await Process.run("sh", ["-c", infoCommand(mountpoint)]);
    final result = resultRaw.stdout.toString().trim().split(";");
    return result;
  }
}
