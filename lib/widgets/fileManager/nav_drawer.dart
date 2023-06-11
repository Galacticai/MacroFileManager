import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:path/path.dart' as path;

class NavDrawer extends StatefulWidget {
  const NavDrawer({
    required this.directory,
    required this.useAcrylic,
    this.onItemTap,
    super.key,
  });

  final String directory;
  final Function(String newPath, bool closeMenu)? onItemTap;
  final bool useAcrylic;

  @override
  State<NavDrawer> createState() => _NavDrawerState();
}

enum NavDrawerItemName {
  /// Dynamic items
  other,
  settings,
}

class _NavDrawerState extends State<NavDrawer> {
  @override
  Widget build(BuildContext context) {
    ColorScheme colors = Theme.of(context).colorScheme;

    return Drawer(
      backgroundColor: widget.useAcrylic ? colors.background.withAlpha(128) : colors.background,
      child: Column(
        children: <Widget>[
          Expanded(
            child: ListView(
              children: [
                widget.onItemTap == null
                    ? const ListTile(
                        leading: Icon(FontAwesomeIcons.house),
                        title: Text("Home"),
                        subtitle: Text("Jump back to home"),
                      )
                    : ListTile(
                        leading: const Icon(FontAwesomeIcons.house),
                        title: const Text("Home"),
                        subtitle: const Text("Jump back to home"),
                        onTap: () => widget.onItemTap?.call("home", true),
                      ),
                ListTile(
                  leading: const Icon(FontAwesomeIcons.arrowUp),
                  title: const Text("Up"),
                  subtitle: const Text("Jump up in path"),
                  onTap: () {
                    if (widget.directory == "home") return;
                    if (widget.directory == "/") {
                      widget.onItemTap?.call("home", true);
                      return;
                    }
                    widget.onItemTap?.call(path.dirname(widget.directory), true);
                  },
                ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('Settings'),
            onTap: () => {}, //TODO: open settings
          ),
        ],
      ),
    );
  }
}
