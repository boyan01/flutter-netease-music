import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

import '../repository.dart';

part 'netease_user.g.dart';

@JsonSerializable()
class NeteaseUser with EquatableMixin {
  NeteaseUser({
    required this.user,
    required this.loginByQrCode,
  });

  factory NeteaseUser.fromJson(Map<String, dynamic> json) =>
      _$NeteaseUserFromJson(json);

  final User user;
  final bool loginByQrCode;

  @override
  List<Object?> get props => [user, loginByQrCode];

  Map<String, dynamic> toJson() => _$NeteaseUserToJson(this);
}
