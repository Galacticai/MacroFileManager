import 'dart:io';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:macro_file_manager/models/cross/net/http/http_server_express.dart';
import 'package:macro_file_manager/widgets/cross/info.dart';
import 'package:macro_file_manager/widgets/fileManager/content_list.dart';

@immutable
class FindDevicesDialog extends StatefulWidget {
  const FindDevicesDialog({super.key});

  @override
  State<FindDevicesDialog> createState() => _FindDevicesDialogState();
}

class _FindDevicesDialogState extends State<FindDevicesDialog> {
  bool stopped = false;
  late List<Widget> list;

  @override
  Widget build(BuildContext context) {
    list = [];

    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(),
      ),
      body: SingleChildScrollView(
        child: stopped
            ? Info.withButtons(
                "Stopped",
                icon: FontAwesomeIcons.solidFaceMehBlank,
                buttons: [
                  TextButton.icon(
                    label: const Text("Scan again"),
                    icon: const Icon(FontAwesomeIcons.arrowRotateRight),
                    onPressed: () => setState(() => stopped = false),
                  ),
                ],
              )
            : StreamBuilder(
                stream: HttpServerExpress.discover("192.168.0", port: 21821),
                builder: (BuildContext context, AsyncSnapshot<HttpClientRequest?> snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Info.withButtons(
                      "Waiting for devices...",
                      icon: FontAwesomeIcons.magnifyingGlass,
                      color: theme.colorScheme.primary,
                      buttons: [
                        TextButton.icon(
                          label: const Text("Stop"),
                          icon: const Icon(FontAwesomeIcons.x),
                          onPressed: () => setState(() => stopped = true),
                        )
                      ],
                    );
                  }
                  if (snapshot.hasError) {
                    return Info.withButtons(
                      "Something went wrong",
                      details: snapshot.error.toString(),
                      detailsMono: true,
                      icon: FontAwesomeIcons.solidFaceDizzy,
                      color: theme.colorScheme.error,
                      buttons: [
                        TextButton.icon(
                          label: const Text("Back"),
                          icon: const Icon(FontAwesomeIcons.arrowLeft),
                          onPressed: Navigator.of(context).pop,
                        ),
                        TextButton.icon(
                          label: const Text("Retry"),
                          icon: const Icon(FontAwesomeIcons.rotateRight),
                          onPressed: () => setState(() {}),
                        ),
                      ],
                    );
                  }
                  if (snapshot.data == null) {
                    return Info.withButtons(
                      "No devices found.",
                      buttons: [
                        TextButton.icon(
                          label: const Text("Home"),
                          icon: const Icon(FontAwesomeIcons.house, size: 18),
                          onPressed: Navigator.of(context).pop,
                        ),
                      ],
                    );
                  }
                  final HttpClientRequest request = snapshot.data!;
                  final String host = request.headers.host ?? "????";
                  final int port = request.headers.port ?? 0;

                  print("ADDING: $host:$port");
                  list.add(ListTile(
                    leading: const Icon(FontAwesomeIcons.server),
                    title: Text("$host:$port"),
                    onTap: () {},
                  ));

                  return ContentList(
                    loading: snapshot.connectionState != ConnectionState.done,
                    child: ListView(shrinkWrap: true, children: list),
                  );
                },
              ),
      ),
    );
  }
}
