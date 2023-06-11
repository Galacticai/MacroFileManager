import 'package:flutter/material.dart';
import 'package:macro_file_manager/widgets/fileManager/path/path_bar_item.dart';
import 'package:path/path.dart' as path;

@immutable
class PathBar extends StatelessWidget {
  const PathBar({required this.directory, this.onItemTap, this.count = -1, super.key});

  final String directory;
  final Function(String)? onItemTap;
  final int count;

  @override
  Widget build(BuildContext context) {
    if (directory == "home" || directory == "404") {
      return const Text("Macro File Manager");
    }

    List<Widget> list = [];
    final parts = directory.split(path.separator).where((element) => element.isNotEmpty).toList();

    if (parts.isEmpty) return const Text("Path error.");
    final int startIndex = parts.length - count.clamp(0, parts.length);

    const arrow = Icon(Icons.keyboard_arrow_right_rounded);
    const arrowDouble = Icon(Icons.keyboard_double_arrow_right_rounded);

    list.add(PathItem(directory: "home", onTap: onItemTap));
    list.add(arrow);

    if (startIndex > 0) {
      list.add(PathItem(directory: parts[0] + path.separator, onTap: onItemTap));
      list.add(startIndex > 1 ? arrowDouble : arrow);
    }

    String current = "";

    for (int i = 0; i < parts.length; i++) {
      final part = parts[i];
      current += part + path.separator;
      if (i < startIndex) continue;

      final bool isNotLast = i < parts.length - 1;
      list.add(
        isNotLast && onItemTap != null
            ? PathItem(
                directory: current,
                onTap: onItemTap,
              )
            : PathItem(directory: current),
      );

      if (isNotLast) list.add(arrow);
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      clipBehavior: Clip.antiAlias,
      controller: ScrollController(),
      child: Row(children: list),
    );
  }
}
