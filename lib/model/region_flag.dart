import 'package:json_annotation/json_annotation.dart';

part 'region_flag.g.dart';

@JsonSerializable()
class RegionFlag {
  RegionFlag({
    required this.code,
    required this.emoji,
    required this.unicode,
    required this.name,
    this.dialCode,
  });

  factory RegionFlag.fromMap(Map map) => _$RegionFlagFromJson(map);

  final String code;
  final String emoji;
  final String unicode;
  final String name;

  // could be null
  final String? dialCode;

  Map<String, dynamic> toMap() => _$RegionFlagToJson(this);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RegionFlag &&
          runtimeType == other.runtimeType &&
          code == other.code &&
          emoji == other.emoji &&
          unicode == other.unicode &&
          name == other.name &&
          dialCode == other.dialCode;

  @override
  int get hashCode =>
      code.hashCode ^
      emoji.hashCode ^
      unicode.hashCode ^
      name.hashCode ^
      dialCode.hashCode;

  @override
  String toString() {
    return 'RegionFlag{code: $code, emoji: $emoji, unicode: $unicode, name: $name, dialCode: $dialCode}';
  }
}
