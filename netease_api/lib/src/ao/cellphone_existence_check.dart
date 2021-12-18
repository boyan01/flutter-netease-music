import 'package:json_annotation/json_annotation.dart';

part 'cellphone_existence_check.g.dart';

@JsonSerializable()
class CellphoneExistenceCheck {
  CellphoneExistenceCheck({
    this.exist,
    this.nickname,
    this.hasPassword,
  });

  factory CellphoneExistenceCheck.fromJson(Map<String, dynamic> map) =>
      _$CellphoneExistenceCheckFromJson(map);

  final int? exist;
  final String? nickname;
  final bool? hasPassword;

  bool get isExist => exist == 1;

  Map<String, dynamic> toJson() => _$CellphoneExistenceCheckToJson(this);
}
