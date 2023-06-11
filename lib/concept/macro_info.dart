import 'package:dart_ipify/dart_ipify.dart';

/// Info about a Macro File Manager host
class MacroInfo {
  Future<void> a() async {
    final ip = await Ipify.ipv4();
  }

  @override
  String toString() => "macrofm://";
}
