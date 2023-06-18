import 'package:flutter/material.dart';

import 'global_props.dart';

class Info extends StatelessWidget {
  final String title;
  final String? details;
  final bool detailsMono;
  final IconData? icon;
  final Color? color;
  final Widget? child;

  const Info(this.title, {this.details, this.detailsMono = false, this.icon, this.color, this.child, super.key});

  @override
  Widget build(BuildContext context) {
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
              : Padding(
                  padding: const EdgeInsets.symmetric(vertical: GlobalProps.radius, horizontal: GlobalProps.radiusLarge),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 500),
                    child: Text(details!, style: detailsMono ? TextStyle(fontFamily: theme.textTheme.bodyMedium?.fontFamily) : null),
                  ),
                ),
        ),
        child ?? const SizedBox.shrink()
      ],
    );
  }

  static Info withButtons(
    String title, {
    List<Widget>? buttons,
    String? details,
    bool detailsMono = false,
    IconData? icon,
    Color? color,
    double spacing = GlobalProps.radius,
  }) {
    return Info(
      title,
      details: details,
      detailsMono: detailsMono,
      icon: icon,
      color: color,
      child: buttons == null
          ? const SizedBox.shrink()
          : Center(
              child: Wrap(spacing: spacing, children: buttons),
            ),
    );
  }
}
