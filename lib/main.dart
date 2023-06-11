import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_acrylic/flutter_acrylic.dart';

import 'concept/server/auth/auth_server.dart';
import 'macro_file_manager.dart';

Future<void> main() async {
  //? Windows 11 acrylic effect
  final bool useAcrylic = false; //= Platform.isWindows && Platform.operatingSystemVersion.contains("Windows 10 or later");
  if (useAcrylic) {
    SystemUiOverlayStyle style = ThemeMode.system == ThemeMode.light ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark;
    SystemChrome.setSystemUIOverlayStyle(style);
    WidgetsFlutterBinding.ensureInitialized();
    await Window.setEffect(effect: WindowEffect.acrylic, color: const Color(0xee222222));
    await Window.initialize();
  }
  runApp(MacroFileManager(useAcrylic: useAcrylic));
  await AuthServer().start();
}
