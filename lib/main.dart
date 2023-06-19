import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_acrylic/flutter_acrylic.dart';
import 'package:window_manager/window_manager.dart';

import 'macro_file_manager.dart';

Future<void> main() async {
  // //? Windows 11 acrylic effect
  final bool useAcrylic = false; //= Platform.isWindows && Platform.operatingSystemVersion.contains("Windows 10 or later");
  if (useAcrylic) {
    SystemUiOverlayStyle style = ThemeMode.system == ThemeMode.light ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark;
    SystemChrome.setSystemUIOverlayStyle(style);
    WidgetsFlutterBinding.ensureInitialized();
    await Window.setEffect(effect: WindowEffect.acrylic, color: const Color(0xee222222));
    await Window.initialize();
  }

  WidgetsFlutterBinding.ensureInitialized();
  await windowManager.ensureInitialized();
  if (Platform.isWindows || Platform.isLinux) {
    WindowManager.instance.setMinimumSize(const Size(500, 500));
  }
  runApp(MacroFileManager(useAcrylic: useAcrylic));
}
