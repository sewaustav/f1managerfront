import 'package:freezed_annotation/freezed_annotation.dart';

part 'standing.freezed.dart';
part 'standing.g.dart';

@freezed
class Standing with _$Standing {
  const factory Standing({
    @Default(<String, int>{}) Map<String, int> drivers,
    @Default(<String, int>{}) Map<String, int> teams,
  }) = _Standing;
  factory Standing.fromJson(Map<String, dynamic> json) => _$StandingFromJson(json);
}
