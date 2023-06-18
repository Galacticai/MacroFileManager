import 'dart:typed_data';

enum IPClass {
  a(0, 0, 0x8, "Class A"),
  b(1, 0x81, 0xC, "Class B"),
  c(2, 0xC1, 0xE, "Class C");

  final int networkIndex;
  int get hostIndexBegin => networkIndex + 1;
  final int networkMin;
  final int networkMax;
  final String label;
  const IPClass(this.networkIndex, this.networkMin, this.networkMax, this.label);
}

IPClass? getClass(Uint8List ip) {
  if (ip.length != 4) return null;
  if (ip[0] < 0x80) {
    return IPClass.a;
  } else if (ip[0] < 0xC0) {
    return IPClass.b;
  } else if (ip[0] < 0xE0) {
    return IPClass.c;
  }
  return null;
}
