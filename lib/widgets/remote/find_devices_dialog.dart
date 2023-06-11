import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class FindDevicesDialog extends StatelessWidget {
  const FindDevicesDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(FontAwesomeIcons.arrowLeftLong),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: ListView(
          children: [
            const ListTile(
              title: Text("tile"),
            ),
          ],
        ),
      ),
    );
  }
}
