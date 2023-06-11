import 'package:flutter/material.dart';
import 'package:macro_file_manager/concept/cross/text_man.dart';
import 'package:macro_file_manager/widgets/cross/global_props.dart';

class PathListLoading extends StatelessWidget {
  const PathListLoading({required this.target, super.key});

  final String target;

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: GlobalProps.radius, horizontal: GlobalProps.radiusBig),
        child: ListView(
          shrinkWrap: true,
          children: [
            Text(
              "Loading path...",
              style: theme.textTheme.bodyLarge!.copyWith(
                color: theme.colorScheme.primary,
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: GlobalProps.radius),
              child: LinearProgressIndicator(),
            ),
            Text(
              TextMan.shortPath(target, 3, 3),
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
