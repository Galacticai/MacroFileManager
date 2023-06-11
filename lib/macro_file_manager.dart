import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/material.dart';

import 'widgets/fileManager/file_manager.dart';

class MacroFileManager extends StatefulWidget {
  const MacroFileManager({this.useAcrylic = false, super.key});

  final bool useAcrylic;

  @override
  State<MacroFileManager> createState() => _MacroFileManager();
}

class _MacroFileManager extends State<MacroFileManager> {
  static get _defualtSeedColor => Colors.blue;

  static get _defaultLightColorScheme => ColorScheme.fromSeed(seedColor: _defualtSeedColor);

  static get _defaultDarkColorScheme => ColorScheme.fromSeed(seedColor: _defualtSeedColor, brightness: Brightness.dark);

  @override
  Widget build(BuildContext context) {
    //TODO: move to remote section setup
    // await Permission.ignoreBatteryOptimizations.request();

    //? Works but does not listen to OS accent color changes
    //? so it uses the initial accent color
    return DynamicColorBuilder(
      builder: (lightColorScheme, darkColorScheme) {
        ColorScheme light = lightColorScheme ?? _defaultLightColorScheme;
        ColorScheme dark = darkColorScheme ?? _defaultDarkColorScheme;
        if (widget.useAcrylic) {
          light = light.copyWith(background: light.background.withAlpha(0));
          dark = dark.copyWith(background: dark.background.withAlpha(0));
        }

        return MaterialApp(
          title: "Macro File Manager",
          key: const Key("MaterialApp"),
          theme: ThemeData(colorScheme: light, useMaterial3: true),
          darkTheme: ThemeData(colorScheme: dark, useMaterial3: true),
          themeMode: ThemeMode.system,
          home: FileManager(useAcrylic: widget.useAcrylic, key: const Key("FileManager")),
          debugShowCheckedModeBanner: false,
        );
      },
    );
  }
}
