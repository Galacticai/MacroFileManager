import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:macro_file_manager/concept/macro_info.dart';
import 'package:macro_file_manager/widgets/cross/global_props.dart';
import 'package:macro_file_manager/widgets/fileManager/path/path_list.dart';
import 'package:macro_file_manager/widgets/remote/find_devices_dialog.dart';

class RemoteList extends StatelessWidget {
  const RemoteList({this.onItemTap, super.key});

  final Function(MacroInfo remoteInfo)? onItemTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ListTile(
            shape: GlobalProps.roundedBorderBig,
            leading: const Icon(Icons.settings),
            title: Text(style: PathList.titleStyle, "Configure this device"),
            subtitle: Text(
              style: PathList.subtitleStyle(Theme.of(context)),
              "Set up the details of this device which will be seen by others while scanning",
            ),
            onTap: () => {}),
        ListTile(
          shape: GlobalProps.roundedBorderBig,
          leading: const Icon(FontAwesomeIcons.magnifyingGlass),
          title: Text(style: PathList.titleStyle, "Find devices"),
          subtitle: Text(
            style: PathList.subtitleStyle(Theme.of(context)),
            "Check local network for other devices running Macro File Manager",
          ),
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const FindDevicesDialog()),
          ),
        ),
      ],
    );
  }
}
