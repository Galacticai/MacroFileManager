import 'dart:io';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:macro_file_manager/models/cross/special_characters.dart';
import 'package:macro_file_manager/models/unix/known_storage_paths.dart';
import 'package:macro_file_manager/models/windows/windows_cmd/vol.dart';
import 'package:macro_file_manager/widgets/cross/byte_convert.dart';
import 'package:macro_file_manager/widgets/cross/global_props.dart';
import 'package:macro_file_manager/widgets/fileManager/path/path_list.dart';
import 'package:path/path.dart' as path_tool;
import 'package:universal_disk_space/universal_disk_space.dart';

class DiskItem extends StatefulWidget {
  DiskItem.desktop({required this.disk, this.onTap, super.key})
      : isAndroid = false,
        directory = disk.mountPath;
  DiskItem.android({required this.directory, this.onTap, super.key})
      : isAndroid = true,
        disk = Disk(devicePath: directory, mountPath: directory, totalSize: 1, availableSpace: 1, usedSpace: 0);

  final bool isAndroid;
  final String directory;
  final Disk disk;
  final Future Function(Disk)? onTap;

  @override
  State<DiskItem> createState() => _DiskItemState();
}

class _DiskItemState extends State<DiskItem> {
  Future<String> _getDiskLabel() async {
    if (Platform.isWindows) {
      return (await Vol.createAsync(widget.disk.mountPath)).label;
    }
    return getKnownStoragePaths(widget.disk.mountPath);
  }

  @override
  Widget build(BuildContext context) {
    final String path =
        Platform.isAndroid && widget.disk.mountPath == "/storage/emulated" ? path_tool.join(widget.disk.mountPath, '0') : widget.disk.mountPath;
    final totalSpace = widget.disk.usedSpace + widget.disk.availableSpace;

    final theme = Theme.of(context);
    final subtitleStyle = PathList.subtitleStyle(theme).copyWith(color: theme.colorScheme.onPrimaryContainer);

    return ListTile(
      hoverColor: theme.colorScheme.surfaceVariant.withAlpha(100),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(GlobalProps.radiusBig),
      ),
      leading: const Icon(FontAwesomeIcons.hardDrive),
      title: FutureBuilder(
        future: _getDiskLabel(),
        builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
          return Text(snapshot.hasData ? "${Platform.isWindows ? "($path) " : ""}${snapshot.data}" : path);
        },
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.symmetric(vertical: GlobalProps.radius),
            child: Stack(
              children: [
                SizedBox(
                  height: 20,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: LinearProgressIndicator(
                      color: theme.colorScheme.primaryContainer,
                      value: widget.disk.usedSpace / totalSpace,
                    ),
                  ),
                ),
                Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Text(
                      "${widget.disk.usedSpace.formatBytes(kibi: true, withUnit: false)} / ${totalSpace.formatKibiBytes}"
                      " —${SpecialCharacters.narrowNonBreakingSpace}${widget.disk.availableSpace.formatKibiBytes}"
                      "${SpecialCharacters.narrowNonBreakingSpace}free",
                      style: subtitleStyle,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      onTap: () async => await widget.onTap?.call(widget.disk),
    );
  }
}
