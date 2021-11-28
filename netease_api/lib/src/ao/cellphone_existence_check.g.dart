// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cellphone_existence_check.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CellphoneExistenceCheck _$CellphoneExistenceCheckFromJson(
        Map<String, dynamic> json) =>
    CellphoneExistenceCheck(
      exist: json['exist'] as int?,
      nickname: json['nickname'] as String?,
      hasPassword: json['hasPassword'] as bool?,
    );

Map<String, dynamic> _$CellphoneExistenceCheckToJson(
        CellphoneExistenceCheck instance) =>
    <String, dynamic>{
      'exist': instance.exist,
      'nickname': instance.nickname,
      'hasPassword': instance.hasPassword,
    };
