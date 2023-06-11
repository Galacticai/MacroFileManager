import 'dart:io';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:macro_file_manager/widgets/cross/byte_convert.dart';
import 'package:macro_file_manager/widgets/cross/global_props.dart';
import 'package:macro_file_manager/widgets/file_system_entity_icon.dart';
import 'package:path/path.dart' as path;

@immutable
class PathListItem extends StatefulWidget {
  final FileSystemEntity entity;
  final bool isLink;
  final bool isHidden;
  final bool? isSystem; //? Windows only
  final bool? isReadOnly; //? Windows only

  final Future Function(String newPath)? onTap;
  final Future Function(Offset position)? onLongPress;
  final Future Function(bool isSelected)? onSelectedChanged;
  final Future Function(Offset position)? onContextMenuOpen;
  final Future Function(ContextMenuAction action)? onContextMenuTap;
  final Future Function(PointerEnterEvent ev)? onPointerEnter;
  final Future Function(PointerExitEvent ev)? onPointerExit;
  final Future Function(PointerHoverEvent ev)? onPointerHover;

  const PathListItem({
    required this.entity,
    this.onTap,
    this.onLongPress,
    this.onSelectedChanged,
    this.onContextMenuOpen,
    this.onContextMenuTap,
    this.onPointerEnter,
    this.onPointerExit,
    this.onPointerHover,
    this.isLink = false,
    this.isHidden = false,
    this.isSystem,
    this.isReadOnly,
    super.key,
  });

  bool get isDirectoryTarget => FileSystemEntity.isDirectorySync(entity.path);
  bool get isFileTarget => FileSystemEntity.isFileSync(entity.path);

  @override
  State<PathListItem> createState() => _PathListItemState();
}

enum ContextMenuAction {
  copy("copy"),
  paste("paste"),
  rename("rename"),
  delete("delete"),
  properties("properties");

  const ContextMenuAction(this.value);
  final String value;
}

class _PathListItemState extends State<PathListItem> {
  bool _isHovering = false;
  bool _isSelected = false;

  FileStat get _stat => widget.entity.statSync();

  String get _timeModified => "${_stat.modified.hour.toString().padLeft(2, '0')}:${_stat.modified.minute.toString().padLeft(2, '0')}";

  String get _dateModified => "${_stat.modified.day.toString().padLeft(2, '0')}/${_stat.modified.month}/${_stat.modified.year}";

  Offset _tapPosition = Offset.zero;

  _showContextMenu(BuildContext context) async {
    final RenderObject? overlay = Overlay.of(context).context.findRenderObject();
    if (overlay == null) return;

    final result = await showMenu(
      context: context,
      position: RelativeRect.fromRect(
        Rect.fromLTWH(_tapPosition.dx, _tapPosition.dy, 30, 30),
        Rect.fromLTWH(0, 0, overlay.paintBounds.size.width, overlay.paintBounds.size.height),
      ),
      items: [
        const PopupMenuItem(value: ContextMenuAction.copy, child: Text('Copy')),
        const PopupMenuItem(value: ContextMenuAction.paste, child: Text("Paste")),
        const PopupMenuItem(value: ContextMenuAction.rename, child: Text("Rename")),
        const PopupMenuItem(value: ContextMenuAction.delete, child: Text("Delete")),
        const PopupMenuItem(value: ContextMenuAction.properties, child: Text("Properties")),
      ],
    );
    await widget.onContextMenuOpen?.call(_tapPosition);

    if (result == null) return;
    switch (result) {
      case ContextMenuAction.copy:
        break;
      case ContextMenuAction.paste:
        break;
      case ContextMenuAction.rename:
        break;
      case ContextMenuAction.delete:
        break;
      case ContextMenuAction.properties:
        break;
    }

    await widget.onContextMenuTap?.call(result);
  }

  _setTapPosition(Offset offset) async {
    setState(() => _tapPosition = offset);
  }

  _setSelected(bool isSelected) async {
    setState(() => _isSelected = isSelected);
    await widget.onSelectedChanged?.call(isSelected);
  }

  _longPress(Offset position) async {
    _setSelected(!_isSelected);
    await widget.onLongPress?.call(position);
  }

  _pointerEnter(PointerEnterEvent ev) async {
    setState(() => _isHovering = true);
    await widget.onPointerEnter?.call(ev);
  }

  _pointerExit(PointerExitEvent ev) async {
    setState(() => _isHovering = false);
    await widget.onPointerExit?.call(ev);
  }

  _pointerHover(PointerHoverEvent ev) async {
    _setTapPosition(ev.position);
    await widget.onPointerHover?.call(ev);
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    var titleColor = _isSelected ? theme.colorScheme.primary : theme.colorScheme.onBackground;
    if (widget.isSystem ?? false) {
      titleColor = theme.colorScheme.error;
    } else if (widget.isLink) {
      titleColor = theme.colorScheme.tertiary;
    }
    if (widget.isHidden) {
      titleColor = titleColor.withAlpha(160);
    }

    const infoIconContainerMargin = EdgeInsets.only(right: 4);
    const infoIconContainerPadding = EdgeInsets.symmetric(horizontal: 6, vertical: 4);
    const infoIconPadding = EdgeInsets.symmetric(horizontal: 2);
    final infoIconsVisible = widget.isHidden || widget.isLink || (widget.isSystem ?? false) || (widget.isReadOnly ?? false);
    const double infoIconSize = 12;
    final infoIconBG = theme.colorScheme.surfaceVariant.withAlpha(150), infoIconColor = theme.colorScheme.onSurfaceVariant.withAlpha(150);

    return MouseRegion(
      onEnter: _pointerEnter,
      onExit: _pointerExit,
      onHover: _pointerHover,
      child: GestureDetector(
        onTapDown: (TapDownDetails details) => _setTapPosition(details.globalPosition),
        onLongPress: () => _longPress(_tapPosition),
        behavior: HitTestBehavior.deferToChild,
        child: ListTile(
          selected: _isSelected,
          selectedTileColor: theme.colorScheme.primaryContainer.withAlpha(100),
          leading: SizedBox(
            width: 42,
            height: 42,
            child: _isHovering || _isSelected
                ? Checkbox(
                    value: _isSelected,
                    onChanged: (newValue) => _setSelected(newValue ?? false),
                  )
                : Container(
                    decoration: BoxDecoration(color: theme.colorScheme.surfaceVariant, shape: BoxShape.circle),
                    child: Center(
                      child: widget.entity.iconColored(theme.colorScheme.secondary, size: 42),
                    ),
                  ),
          ),
          trailing: Visibility(
            visible: _isHovering,
            child: IconButton(
              icon: const Icon(FontAwesomeIcons.ellipsisVertical),
              onPressed: () => _showContextMenu(context),
            ),
          ),
          title: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Visibility(
                visible: infoIconsVisible,
                child: Container(
                  margin: infoIconContainerMargin,
                  padding: infoIconContainerPadding,
                  decoration: BoxDecoration(
                    color: infoIconBG,
                    borderRadius: BorderRadius.circular(GlobalProps.radius),
                  ),
                  child: Row(
                    children: [
                      Visibility(
                        visible: widget.isSystem ?? false,
                        child: Padding(
                          padding: infoIconPadding,
                          child: Icon(FontAwesomeIcons.windows, size: infoIconSize, color: infoIconColor),
                        ),
                      ),
                      Visibility(
                        visible: widget.isReadOnly ?? false,
                        child: Padding(
                          padding: infoIconPadding,
                          child: Icon(FontAwesomeIcons.glasses, size: infoIconSize, color: infoIconColor),
                        ),
                      ),
                      Visibility(
                        visible: widget.isHidden,
                        child: Padding(
                          padding: infoIconPadding,
                          child: Icon(FontAwesomeIcons.eyeSlash, size: infoIconSize, color: infoIconColor),
                        ),
                      ),
                      Visibility(
                        visible: widget.isLink,
                        child: Padding(
                          padding: infoIconPadding,
                          child: Icon(FontAwesomeIcons.link, size: infoIconSize, color: infoIconColor),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Flexible(
                child: Text(
                  path.basename(widget.entity.path),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: titleColor, fontWeight: FontWeight.w600),
                  overflow: TextOverflow.fade,
                ),
              ),
            ],
          ),
          subtitle: Text(
            "${widget.entity is File ? "${_stat.size.formatKibiBytes} • " : ""}$_timeModified • $_dateModified",
            style: TextStyle(color: Theme.of(context).colorScheme.secondary),
            overflow: TextOverflow.fade,
          ),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(GlobalProps.radiusBig)),
          ),
          onTap: () async => await widget.onTap?.call("${Platform.isWindows ? "" : '/'}${widget.entity.path}"),
        ),
      ),
    );
  }
}
