import 'dart:math';
import 'dart:typed_data';

class OTP {
  /// Bytes count
  final int length;
  final bool auto;
  final Random _random;
  final Duration expiration;

  late Uint8List _key;
  Uint8List get key => _key;
  late DateTime _lastUpdated;

  bool get expired => DateTime.now().difference(_lastUpdated) >= expiration;

  OTP.single(this.expiration, {this.length = 8})
      : auto = false,
        _random = Random.secure() {
    refreshKey();
  }

  OTP.auto(this.expiration, {this.length = 8})
      : auto = true,
        _random = Random.secure() {
    refreshKey();
    _lastUpdated = DateTime.now();
  }

  Uint8List refreshKey() => _key = defaultKey(random: _random);

  bool verifyKey(Uint8List other) {
    if (other.length != _key.length) {
      return false;
    }
    for (int i = 0; i < _key.length; i++) {
      if (_key[i] != other[i]) {
        return false;
      }
    }
    return true;
  }

  static Uint8List defaultKey({Random? random}) => randomKey(8, 0xff + 1, random: random);
  static Uint8List randomKey(int length, int maxValue, {Random? random}) {
    random ??= Random.secure();
    final list = List<int>.generate(length, (index) => random!.nextInt(maxValue));
    return Uint8List.fromList(list);
  }
}
