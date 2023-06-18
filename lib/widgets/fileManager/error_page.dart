import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:macro_file_manager/widgets/cross/global_props.dart';
import 'package:macro_file_manager/widgets/cross/info.dart';
import 'package:path/path.dart' as path;

class PathInfo extends Info {
  const PathInfo(
    super.title, {
    required this.directory,
    this.onItemTap,
    super.details,
    super.color,
    super.icon,
    super.key,
  });

  final String directory;
  final Future Function(String newDir)? onItemTap;

  @override
  Widget build(BuildContext context) {
    return Info.withButtons(
      title,
      buttons: [
        TextButton.icon(
          onPressed: () => onItemTap?.call("home"),
          icon: const Icon(FontAwesomeIcons.house),
          label: const Text("Home"),
        ),
        TextButton.icon(
          onPressed: () => onItemTap?.call(directory),
          icon: const Icon(FontAwesomeIcons.arrowRotateRight),
          label: const Text("Retry"),
        ),
        TextButton.icon(
          onPressed: () => onItemTap?.call(path.dirname(directory)),
          icon: const Icon(FontAwesomeIcons.arrowUp),
          label: const Text("Parent"),
        ),
      ],
      icon: super.icon,
      color: super.color,
    );
    final ThemeData theme = Theme.of(context);
    final colorFinal = color ?? theme.colorScheme.secondary;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: GlobalProps.radiusLarge),
          child: Column(children: [
            Icon(icon, size: 64, color: colorFinal),
            Text(
              title,
              style: TextStyle(
                fontSize: theme.textTheme.bodyLarge?.fontSize ?? 24,
                color: colorFinal,
              ),
            ),
          ]),
        ),
        Padding(
          padding: const EdgeInsets.only(bottom: GlobalProps.radiusLarge),
          child: details == null
              ? null
              : Card(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: GlobalProps.radius, horizontal: GlobalProps.radiusLarge),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 500),
                      child: Text(details!),
                    ),
                  ),
                ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextButton.icon(
              onPressed: () => onItemTap?.call("home"),
              icon: const Icon(FontAwesomeIcons.house),
              label: const Text("Home"),
            ),
            TextButton.icon(
              onPressed: () => onItemTap?.call(directory),
              icon: const Icon(FontAwesomeIcons.arrowRotateRight),
              label: const Text("Retry"),
            ),
            TextButton.icon(
              onPressed: () => onItemTap?.call(path.dirname(directory)),
              icon: const Icon(FontAwesomeIcons.arrowUp),
              label: const Text("Parent"),
            ),
          ],
        )
      ],
    );
  }
}
