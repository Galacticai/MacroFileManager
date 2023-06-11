import 'package:flutter/material.dart';
import 'package:macro_file_manager/widgets/cross/global_props.dart';

class ContentList extends StatelessWidget {
  const ContentList({
    required this.child,
    this.loading = false,
    this.loadingBarHeight = GlobalProps.radius,
    this.cornerRadius = GlobalProps.radius,
    super.key,
  });

  final Widget child;
  final bool loading;
  final double loadingBarHeight;
  final double cornerRadius;

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.topCenter,
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(cornerRadius),
            child: child,
          ),
          Container(
            alignment: Alignment.bottomCenter,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(cornerRadius),
              child: AnimatedOpacity(
                opacity: loading ? 1 : 0,
                duration: GlobalProps.animationDuration,
                curve: Curves.easeOut,
                child: AnimatedSize(
                  duration: GlobalProps.animationDuration,
                  curve: Curves.easeOut,
                  child: SizedBox(
                    height: loading ? loadingBarHeight : loadingBarHeight * .5,
                    child: const LinearProgressIndicator(),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
