import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:macro_file_manager/widgets/cross/global_props.dart';
import 'package:macro_file_manager/widgets/fileManager/path/path_bar.dart';
import 'package:macro_file_manager/widgets/fileManager/path/path_list.dart';
import 'package:open_file_plus/open_file_plus.dart';
import 'package:path/path.dart' as path;
import 'package:scaffold_responsive/scaffold_responsive.dart';

import 'nav_drawer.dart';

class FileManager extends StatefulWidget {
  const FileManager({this.useAcrylic = false, this.responsiveWidth = 700, super.key});

  final bool useAcrylic;
  final double responsiveWidth;

  @override
  State<FileManager> createState() => _FileManagerState();
}

class _FileManagerState extends State<FileManager> with WidgetsBindingObserver {
  String _directory = "home";

  final _menuController = ResponsiveMenuController();

  bool get _isHome => _directory == "home";
  ValueNotifier<bool> get _showFAB => ValueNotifier(!_isHome);

  @override
  Widget build(BuildContext context) {
    ColorScheme colors = Theme.of(context).colorScheme;

    return MouseRegion(
      cursor: opening ? SystemMouseCursors.progress : SystemMouseCursors.basic,
      child: ResponsiveScaffold(
        backgroundColor: widget.useAcrylic ? colors.background.withAlpha(128) : colors.background,
        minimumWidthForPermanentVisibleMenu: widget.responsiveWidth,
        menuController: _menuController,
        menu: NavDrawer(
          useAcrylic: widget.useAcrylic,
          directory: _directory,
          onItemTap: _onNavDrawerItemTap,
        ),
        appBar: AppBar(
          backgroundColor: widget.useAcrylic ? colors.background.withAlpha(0) : colors.background,
          titleSpacing: 0, //? so the menu icon looks centered
          title: PathBar(
            key: const Key("PathBar"),
            count: 4,
            directory: _directory,
            onItemTap: _setPath,
          ),
          leading: IconButton(
            icon: const Icon(FontAwesomeIcons.listUl),
            onPressed: _menuController.toggle,
          ),
        ),
        floatingActionButton: AnimatedSlide(
          duration: GlobalProps.animationDuration,
          curve: Curves.ease,
          offset: _showFAB.value ? Offset.zero : const Offset(0, 1),
          child: AnimatedOpacity(
            duration: GlobalProps.animationDuration,
            opacity: _showFAB.value ? 1 : 0,
            child: SpeedDial(
              overlayOpacity: 0,
              icon: Icons.add,
              openCloseDial: _showFAB,
              curve: Curves.ease,
              // shape: const RoundedRectangleBorder(
              //   borderRadius: BorderRadius.all(Radius.circular(16)),
              // ),
              dialRoot: (ctx, open, toggleChildren) {
                return FloatingActionButton(
                  onPressed: toggleChildren,
                  child: AnimatedRotation(
                    duration: GlobalProps.animationDuration,
                    turns: open ? .375 : 0,
                    curve: Curves.ease,
                    child: const Icon(Icons.add),
                  ),
                );
              },
              children: [
                SpeedDialChild(
                  label: "New folder",
                  onTap: () => _create(true),
                  shape: const CircleBorder(),
                  child: const Icon(FontAwesomeIcons.folderPlus),
                ),
                SpeedDialChild(
                  label: "New file",
                  onTap: () => _create(false),
                  shape: const CircleBorder(),
                  child: const Icon(FontAwesomeIcons.fileCirclePlus),
                ),
              ],
              child: const Icon(Icons.minimize_outlined),
            ),
          ),
        ),
        body: PathList(
          showHidden: true,
          directory: _directory,
          onItemTap: (String newDir) async {
            final type = FileSystemEntity.typeSync(newDir, followLinks: true);
            if (type == FileSystemEntityType.directory) {
              _setPath(newDir);
            } else {
              await openPath(newDir);
            }
          },
        ),
      ),
    );
  }

  bool opening = false;
  String openingPath = "";
  Future<void> openPath(String openPath) async {
    opening = true;
    openingPath = openPath;

    if (Platform.isWindows) {
      await Process.run('cmd', ['/c', 'start', '', openPath], workingDirectory: _directory);
    } else if (Platform.isLinux) {
      await Process.run('xdg-open', [openPath], workingDirectory: _directory);
    } else if (Platform.isAndroid) {
      //? freezes on Windows
      await OpenFile.open(openPath);
    }

    //? flag down if the path is still the same
    if (openPath == openingPath) opening = false;
  }

  void _onNavDrawerItemTap(String newDir, bool autoClose) {
    bool didSet = _setPath(newDir);
    // ignore autoClose if the screen is small
    if (autoClose && didSet && MediaQuery.of(context).size.width < widget.responsiveWidth) {
      _menuController.close();
    }
  }

  void _reload() => _setPath(_directory);

  bool _setPath(String newDir) {
    if (newDir.endsWith(path.separator)) {
      newDir += path.separator;
    }
    if (newDir == _directory) return false;
    setState(() {
      _directory = newDir;
    });
    return true;
  }

  //TODO: show error info if exists
  //TODO: bug: it reloads + nothing when creating a file with no name
  void _create(bool folder) {
    //? Ignore if clicked before disappearing completely
    if (_isHome) return;

    final TextEditingController textEditingController = TextEditingController();
    bool hasError = false;
    final statesController = MaterialStatesController();

    AlertDialog dialog = AlertDialog(
      icon: Icon(folder ? FontAwesomeIcons.folderPlus : FontAwesomeIcons.fileCirclePlus),
      title: Text("New ${folder ? "folder" : "file"}"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Text("Create a new empty file in \"${path.basename(_directory)}\""),
          TextField(
            controller: textEditingController,
            decoration: const InputDecoration(label: Text("Name"), helperText: "Example: FileName.extension"),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: Navigator.of(context).pop,
          child: const Text("Cancel"),
        ),
        TextButton(
          statesController: statesController,
          onPressed: () {
            String name = textEditingController.text;

            // Add your validation logic here
            if (name.isEmpty) {
              statesController.value = {MaterialState.error};
            } else {
              try {
                String createPath = _directory + path.separator + name;
                if (folder) {
                  Directory(createPath).createSync();
                } else {
                  File(createPath).createSync();
                }
                _reload();
                Navigator.of(context).pop();
              } catch (ex) {
                statesController.value = {MaterialState.error};
                hasError = true;
              }
            }
          },
          child: const Text("OK"),
        ),
      ],
    );
    showDialog(context: context, builder: (context) => dialog);
  }
}
