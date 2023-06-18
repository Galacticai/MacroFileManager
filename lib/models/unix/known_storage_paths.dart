/// Known storage paths.
/// Note that there's no processing here. This is just a map of predefined path names. The path may not always correspond to your system.
///
/// Examples:
/// - "C:" could be "Windows"
/// - "/home" could be "Home"
/// - "/storage/emulated/0" could be "Internal Storage" ...
final Map<String, String> knownStoragePaths = {
  "/storage/emulated/0": "Internal Storage",
  "/storage/emulated": "Internal Storage",
  "/storage": "Storage",
  "/home": "Home",
  '/': "Root",
};

/// Returns the keys of [knownStoragePaths] in descending order of length.
List<String> get _knonwStoragePaths_keysInOrder {
  return knownStoragePaths.keys.toList() //!? flutter ignores the order defined by me
    ..sort((a, b) => b.length.compareTo(a.length)); //!? so here it is sorted again
}

/// Use [knownStoragePaths] to get label for [path].
String getKnownStoragePaths(String path) {
  for (final path in _knonwStoragePaths_keysInOrder) {
    if (path.startsWith(path)) return knownStoragePaths[path]!;
  }
  return path;
}
