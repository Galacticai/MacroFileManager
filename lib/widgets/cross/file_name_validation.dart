extension FileNameValidation on String {
  static const String unixFileNameRegexp = r"^[\w\-. ]+$";

  /// Unix valid file name: ^[\w\-. ]+$
  bool get isValidUnixFileName {
    return RegExp(unixFileNameRegexp).hasMatch(this);
  }

  bool get isValidWindowsFileName {
    return false;
  }
}
