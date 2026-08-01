import 'package:freezed_annotation/freezed_annotation.dart';

part 'group_requests.freezed.dart';
part 'group_requests.g.dart';

@freezed
class CreateGroupRequest with _$CreateGroupRequest {
  const factory CreateGroupRequest({required String name, required String password}) = _CreateGroupRequest;
  factory CreateGroupRequest.fromJson(Map<String, dynamic> json) => _$CreateGroupRequestFromJson(json);
}

@freezed
class JoinGroupRequest with _$JoinGroupRequest {
  const factory JoinGroupRequest({required int id, required String password}) = _JoinGroupRequest;
  factory JoinGroupRequest.fromJson(Map<String, dynamic> json) => _$JoinGroupRequestFromJson(json);
}
