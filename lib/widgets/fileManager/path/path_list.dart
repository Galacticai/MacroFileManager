import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:macro_file_manager/concept/file_system_entity_is_hidden.dart';
import 'package:macro_file_manager/concept/windows/windows_cmd/attrib.dart';
import 'package:macro_file_manager/widgets/fileManager/content_list.dart';
import 'package:macro_file_manager/widgets/fileManager/error_page.dart';
import 'package:macro_file_manager/widgets/fileManager/path/home_list.dart';
import 'package:macro_file_manager/widgets/fileManager/path/path_list_item.dart';
import 'package:macro_file_manager/widgets/fileManager/path/path_list_loading.dart';

@immutable
class PathList extends StatefulWidget {
  final String directory;
  final bool showHidden;
  final Future Function(String newPath)? onItemTap;
  final Future Function(bool selected)? onItemSelectionChanged;
  final Future Function(ContextMenuAction action)? onItemContextMenuTap;

  const PathList({
    required this.directory,
    this.showHidden = false,
    this.onItemTap,
    this.onItemSelectionChanged,
    this.onItemContextMenuTap,
    super.key,
  });

  static TextStyle get titleStyle => const TextStyle(fontWeight: FontWeight.w500);
  static TextStyle subtitleStyle(ThemeData theme) => TextStyle(color: theme.colorScheme.onSecondaryContainer.withAlpha(160));

  @override
  State<PathList> createState() => _PathListState();
}

class _PathListState extends State<PathList> {
  bool _loading = false;

  List<PathListItem> _folders = [], _files = [];
  int get _itemsCount => _folders.length + _files.length;
  ListView get _listView => ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        shrinkWrap: true,
        itemCount: _itemsCount,
        itemBuilder: (context, i) {
          return i < _folders.length ? _folders[i] : _files[i - _folders.length];
        },
      );

  _addItem(PathListItem item) {
    if (item.isDirectoryTarget) {
      _folders.add(item);
    } else if (item.isFileTarget) {
      _files.add(item);
    }
  }

  // _removeItem(int i) {
  //   _listKey.currentState!.removeItem(i, (context, animation) {
  //     return FadeTransition(opacity: animation, child: _items[i]);
  //   });
  //   _items.removeAt(i);
  // }

  @override
  Widget build(BuildContext context) {
    if (widget.directory == "home") {
      return HomeList(onItemTap: widget.onItemTap);
    }
    if (widget.directory.startsWith("macrofm://")) {
      //TODO: handle macrofm://
    }

    _loadItems(widget.directory);

    return StreamBuilder(
      stream: _streamController.stream,
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return PathListLoading(target: widget.directory);
        } else if (snapshot.hasError) {
          final isEmpty = snapshot.error == "empty";
          return ErrorPage(
            title: isEmpty ? "Nothing here..." : "Failed to load the specified path",
            details: isEmpty ? null : snapshot.error.toString(),
            icon: isEmpty ? FontAwesomeIcons.ghost : FontAwesomeIcons.triangleExclamation,
            color: isEmpty ? null : Theme.of(context).colorScheme.error,
            directory: widget.directory,
            onItemTap: widget.onItemTap,
          );
        }
        return ContentList(loading: _loading, child: _listView);
      },
    );
  }

  final StreamController _streamController = StreamController.broadcast();
  Stream<(FileSystemEntity, Attrib?)> _getItemDetails() async* {
    final stream = Directory(widget.directory).list(followLinks: false);

    final bool isWindows = Platform.isWindows;
    await for (final FileSystemEntity entity in stream) {
      // without the delay the yield will be instant on unix
      // which breaks the loading animation and looks choppy
      // when a new item is added and rendered
      if (!isWindows) {
        await Future.delayed(const Duration(microseconds: 1));
      }

      final Attrib? attrib = isWindows ? await Attrib.createAsync(entity.path) : null;
      if (!widget.showHidden) {
        final isHiddenWindows = attrib?.isHidden; //!? null => is on unix
        final isHidden = isHiddenWindows ?? entity.isHiddenUnix;
        if (isHidden) continue;
      }
      yield (entity, attrib);
    }
  }

  _loadItems(String loadPath) async {
    _folders = [];
    _files = [];
    _loading = true;
    try {
      await for (final itemDetail in _getItemDetails()) {
        //? cancel loading if path changed
        if (loadPath != widget.directory) break;

        final entity = itemDetail.$1;
        final attrib = itemDetail.$2;
        final item = PathListItem(
          entity: entity,
          onTap: widget.onItemTap,
          isLink: entity is Link,
          isHidden: attrib?.isHidden ?? entity.isHiddenUnix,
          isSystem: attrib?.isSystem,
          isReadOnly: attrib?.isReadOnly,
          onSelectedChanged: widget.onItemSelectionChanged,
          onContextMenuTap: widget.onItemContextMenuTap,
        );
        _addItem(item);
        _streamController.add(null);
      }
      if (_itemsCount == 0) {
        _streamController.addError("empty");
      }
    } catch (e) {
      _streamController.addError(e);
    }
    if (loadPath == widget.directory) _loading = false;
  }
}
