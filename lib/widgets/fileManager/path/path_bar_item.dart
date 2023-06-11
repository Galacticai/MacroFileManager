import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:macro_file_manager/widgets/cross/global_props.dart';
import 'package:path/path.dart' as path;

class PathItem extends StatelessWidget {
  const PathItem({required this.directory, this.onTap, this.maxLength = 15, this.highlightTextItem = true, super.key});

  /// A single part of the path
  /// Examples:
  /// - /full/path/((part))/to/file
  /// - /full/path/to/file/((part))
  final String directory;
  final Function(String newDir)? onTap;
  final int maxLength;
  final bool highlightTextItem;

  static const double spacingTopBottom = 5;
  static const double visualTextCenterBottomPadding = 2;

  static const TextStyle _textStyle = TextStyle(fontSize: 16, fontWeight: FontWeight.w500);

  String shortString(String input) {
    if (input.length <= maxLength) return input;
    return "${input.substring(0, maxLength)} …";
  }

  /// Match the dimensions of a button without being a button
  Widget _textItem(BuildContext context) {
    const double spacingTopBottom = 5;
    ColorScheme colors = Theme.of(context).colorScheme;
    return Container(
      margin: const EdgeInsets.only(
        top: spacingTopBottom,
        bottom: spacingTopBottom,
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.all(Radius.circular(GlobalProps.radiusBig)),
        child: Container(
          alignment: Alignment.center,
          color: highlightTextItem ? colors.secondaryContainer : colors.background,
          padding: const EdgeInsets.only(
            left: 12,
            top: spacingTopBottom,
            right: 12,
            bottom: spacingTopBottom + visualTextCenterBottomPadding,
          ),
          child: ConstrainedBox(
            constraints: BoxConstraints(minWidth: directory == "home" ? 0 : 32, maxWidth: 100),
            child: Text(
              path.basename(directory),
              overflow: TextOverflow.ellipsis,
              style: _textStyle,
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buttonItem(BuildContext context) {
    return TextButton(
      child: Container(
        padding: const EdgeInsets.only(bottom: visualTextCenterBottomPadding),
        child: directory == "home"
            ? const Icon(FontAwesomeIcons.house)
            : Text(
                path.basename(directory),
                overflow: TextOverflow.ellipsis,
                style: _textStyle,
              ),
      ),
      onPressed: () => onTap?.call(directory),
    );
  }

  @override
  Widget build(BuildContext context) {
    return onTap == null ? _textItem(context) : _buttonItem(context);
  }
}
