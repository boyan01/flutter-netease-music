class RegionFlag {
  final String code;
  final String emoji;
  final String unicode;
  final String name;

  // could be null
  final String dialCode;

  RegionFlag({this.code, this.emoji, this.unicode, this.name, this.dialCode});

  Map<String, dynamic> toMap() {
    return {
      'code': this.code,
      'emoji': this.emoji,
      'unicode': this.unicode,
      'name': this.name,
      'dialCode': this.dialCode,
    };
  }

  factory RegionFlag.fromMap(Map map) {
    return new RegionFlag(
      code: map['code'] as String,
      emoji: map['emoji'] as String,
      unicode: map['unicode'] as String,
      name: map['name'] as String,
      dialCode: map['dialCode'] as String,
    );
  }

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
  int get hashCode => code.hashCode ^ emoji.hashCode ^ unicode.hashCode ^ name.hashCode ^ dialCode.hashCode;

  @override
  String toString() {
    return 'RegionFlag{code: $code, emoji: $emoji, unicode: $unicode, name: $name, dialCode: $dialCode}';
  }
}
