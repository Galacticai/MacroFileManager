import 'dart:math' as math;

import 'package:macro_file_manager/models/cross/special_characters.dart';

// ignore: constant_identifier_names
enum KibiByteUnits { B, KiB, MiB, GiB, TiB, PiB, EiB, ZiB, YiB, RiB, QiB }

// ignore: constant_identifier_names
enum KiloByteUnits { B, KB, MB, GB, TB, PB, EB, ZB, YB, RB, QB }

const int kiloByteMultiplier = 1000;
const int kibiByteMultiplier = 1024;

extension ByteConvert on int {
  int get asBit => this * 8;

  // kilo
  int get asKiloByte => this ~/ kiloByteMultiplier;

  int get asMegaByte => this ~/ math.pow(kiloByteMultiplier, 2);

  int get asGigaByte => this ~/ math.pow(kiloByteMultiplier, 3);

  int get asPetaByte => this ~/ math.pow(kiloByteMultiplier, 4);

  int get asExaByte => this ~/ math.pow(kiloByteMultiplier, 5);

  // kibi
  int get asKibiByte => this ~/ kibiByteMultiplier;

  int get asMebiByte => this ~/ math.pow(kibiByteMultiplier, 2);

  int get asGibiByte => this ~/ math.pow(kibiByteMultiplier, 3);

  int get asPebiByte => this ~/ math.pow(kibiByteMultiplier, 4);

  int get asExbiByte => this ~/ math.pow(kibiByteMultiplier, 5);

  /// Assume this [int] value unit is bytes and convert it to the nearest unit with 1 decimal digit (except if it exceeds the defined [KiloByteUnits]/[KibiByteUnits])
  /// Examples:
  /// - 1024 => 1 KiB
  /// - 1000 => 1 KB
  String formatBytes({bool kibi = false, bool withUnit = true}) {
    final int multiplier = kibi ? kibiByteMultiplier : kiloByteMultiplier;
    double size = toDouble();
    final int unitIndex = (size > 0) ? (math.log(size) / math.log(multiplier)).floor() : 0;
    size /= math.pow(multiplier, unitIndex);

    final value = size.toStringAsFixed(1);

    if (!withUnit) return value;

    final List<Enum> units = kibi ? KibiByteUnits.values : KiloByteUnits.values;
    return value + SpecialCharacters.narrowNonBreakingSpace + units[unitIndex].toString().split('.')[1];
  }

  String get formatKiloBytes => formatBytes();

  String get formatKibiBytes => formatBytes(kibi: true);
}
