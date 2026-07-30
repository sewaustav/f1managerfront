import 'package:freezed_annotation/freezed_annotation.dart';

part 'budget.freezed.dart';
part 'budget.g.dart';

@freezed
class Budget with _$Budget {
  const factory Budget({@Default(0) int budget, @Default(0) int tokens}) = _Budget;
  factory Budget.fromJson(Map<String, dynamic> json) => _$BudgetFromJson(json);
}
