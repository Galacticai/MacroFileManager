import 'dart:async';
import 'dart:io';

import 'package:card_loading/card_loading.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:external_path/external_path.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:macro_file_manager/models/unix/unix_cmd/df.dart';
import 'package:macro_file_manager/modified/disk_space/disk_space.dart' as modified_disk_space;
import 'package:macro_file_manager/widgets/cross/global_props.dart';
import 'package:oktoast/oktoast.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:universal_disk_space/universal_disk_space.dart' as disk_space;

import '../content_list.dart';
import 'disk_list_item.dart';

class DisksList extends StatefulWidget {
  const DisksList({this.onItemTap, super.key});

  final Future Function(disk_space.Disk)? onItemTap;

  @override
  State<DisksList> createState() => _DisksListState();
}

class _DisksListState extends State<DisksList> {
  Future<void> _copyToClipboard(String text, String name) async {
    await Clipboard.setData(ClipboardData(text: text));
    showToast("Copied to clipboard ($name)");
    HapticFeedback.mediumImpact();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _getStorage(),
      builder: (BuildContext context, AsyncSnapshot<List<disk_space.Disk>> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return ContentList(child: _loadingTile(context));
        } else if (snapshot.hasError) {
          return errorPage(context, snapshot.error);
        }
        final disks = snapshot.data!;

        return Column(
          children: disks.map((disk) => DiskItem.desktop(disk: disk, onTap: widget.onItemTap)).toList(),
        );
      },
    );
  }

  errorPage(BuildContext context, Object? ex) {
    final theme = Theme.of(context);

    final version = FutureBuilder(
      future: DeviceInfoPlugin().androidInfo,
      builder: (BuildContext context, AsyncSnapshot<AndroidDeviceInfo> snapshot) {
        if (!snapshot.hasData) return const SizedBox.shrink();
        final info = snapshot.data!;
        return Text("${info.manufacturer} • ${info.product} • ${info.version.release} (${info.version.sdkInt}) • ${info.hardware}");
      },
    );

    return ContentList(
      child: Column(
        children: [
          Icon(
            FontAwesomeIcons.triangleExclamation,
            color: theme.colorScheme.error,
            size: 64,
          ),
          Text(
            "Error while fetching storage devices",
            style: TextStyle(
              color: theme.colorScheme.error,
              fontSize: theme.textTheme.bodyLarge?.fontSize ?? 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          version,
          GestureDetector(
            onTap: () async => await _copyToClipboard(ex.toString(), "Error details"),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: GlobalProps.radius, horizontal: GlobalProps.radiusBig),
              child: Card(
                color: theme.colorScheme.surfaceVariant,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: GlobalProps.radius, horizontal: GlobalProps.radiusBig),
                  child: Text(
                    ex.toString(),
                    style: const TextStyle(fontFamily: "monospace", fontSize: 12),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Tries to grant the storage permission on Android.
  /// returns true if the permission is granted.
  Future<Map<Permission, PermissionStatus>> _grantAndroidPermission() async {
    final permissions = <Permission>[
      Permission.requestInstallPackages,
      //Permission.manageExternalStorage,
    ];

    try {
      final info = await DeviceInfoPlugin().androidInfo;
      if (info.version.sdkInt < 30) {
        permissions.add(Permission.storage);
      } else if (info.version.sdkInt >= 30) {
        permissions.addAll([
          Permission.photos,
          Permission.videos,
          Permission.audio,
        ]);
      }

      bool failed = false;
      var result = <Permission, PermissionStatus>{};
      for (final permission in permissions) {
        if (result.containsKey(permission)) continue;
        PermissionStatus status = await permission.request();
        if (status != PermissionStatus.granted) failed = true;
        result[permission] = status;
      }
      if (failed) return Future.error(result);
      return result;
    } catch (ex) {
      return Future.error(ex);
    }
  }

  Future<List<disk_space.Disk>> _getStorage() async {
    if (Platform.isAndroid) {
      try {
        await _grantAndroidPermission();
      } catch (ex) {
        return Future.error(ex);
      }
      final paths = await ExternalPath.getExternalStorageDirectories();
      final disks = paths.map((path) async {
        final mountInfo = (await DF.createAsync(path))!;
        final disk_space.Disk disk = disk_space.Disk(
          devicePath: mountInfo.filesystem,
          mountPath: path,
          totalSize: mountInfo.total,
          usedSpace: mountInfo.used,
          availableSpace: mountInfo.available,
        );
        return disk;
      });
      return await Future.wait(disks);
    }

    final diskSpace = modified_disk_space.DiskSpace();
    await diskSpace.scan();
    return diskSpace.disks;
  }

  Widget _loadingTile(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final cardLoadingTheme = CardLoadingTheme(colorOne: colors.surfaceVariant, colorTwo: colors.surfaceVariant.withAlpha(100));
    final cardLoadingThemeBar = CardLoadingTheme(colorOne: colors.primaryContainer, colorTwo: colors.surfaceVariant.withAlpha(100));
    final cardLoadingBorderRadius = BorderRadius.circular(GlobalProps.radius);

    return ListTile(
      leading: const CircularProgressIndicator(),
      title: Container(
        margin: const EdgeInsets.only(bottom: 10),
        child: Row(
          children: [
            Flexible(
              child: FractionallySizedBox(
                widthFactor: .75,
                child: CardLoading(
                  height: 10,
                  cardLoadingTheme: cardLoadingTheme,
                  borderRadius: cardLoadingBorderRadius,
                ),
              ),
            ),
            Flexible(
              child: FractionallySizedBox(
                widthFactor: .6,
                child: CardLoading(
                  height: 10,
                  cardLoadingTheme: cardLoadingTheme,
                  borderRadius: cardLoadingBorderRadius,
                ),
              ),
            ),
            Flexible(
              child: FractionallySizedBox(
                widthFactor: .5,
                child: CardLoading(
                  height: 10,
                  cardLoadingTheme: cardLoadingTheme,
                  borderRadius: cardLoadingBorderRadius,
                ),
              ),
            ),
          ],
        ),
      ),
      subtitle: CardLoading(
        height: 20,
        cardLoadingTheme: cardLoadingThemeBar,
        borderRadius: cardLoadingBorderRadius,
      ),
    );
  }
}
