import 'package:flutter/material.dart';
import 'package:macro_file_manager/widgets/cross/global_props.dart';
import 'package:macro_file_manager/widgets/fileManager/path/remote_list.dart';
import 'package:universal_disk_space/universal_disk_space.dart';

import '../content_list.dart';
import 'disk_list.dart';

class HomeList extends StatefulWidget {
  const HomeList({this.onItemTap, super.key});

  final Future Function(String newDir)? onItemTap;

  @override
  State<HomeList> createState() => _HomeListState();
}

class _HomeListState extends State<HomeList> {
  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final TextStyle? groupTitleStyle = theme.textTheme.bodyLarge?.copyWith(
      color: theme.colorScheme.primary,
    );
    const cardPadding = EdgeInsets.symmetric(vertical: GlobalProps.radius, horizontal: GlobalProps.radius * 1.6);
    const titleMargin = EdgeInsets.only(bottom: GlobalProps.radius, left: GlobalProps.radius);
    return ContentList(
      child: SingleChildScrollView(
        child: Column(
          children: [
            Card(
              shape: GlobalProps.roundedBorderBig,
              child: Padding(
                padding: cardPadding,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      margin: titleMargin,
                      child: Text("Remote:", style: groupTitleStyle),
                    ),
                    RemoteList(
                      key: const Key("RemoteList"),
                      onItemTap: (remoteInfo) async {
                        //TODO: remote on tap
                        await widget.onItemTap?.call("disk.mountPath");
                      },
                    ),
                  ],
                ),
              ),
            ),
            Card(
              shape: GlobalProps.roundedBorderBig,
              child: Padding(
                padding: cardPadding,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      margin: titleMargin,
                      child: Text("Local device:", style: groupTitleStyle),
                    ),
                    DisksList(
                      key: const Key("DisksList"),
                      onItemTap: (Disk disk) async {
                        await widget.onItemTap?.call(disk.mountPath);
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
