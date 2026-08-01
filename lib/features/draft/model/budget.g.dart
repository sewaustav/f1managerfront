// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'budget.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$BudgetImpl _$$BudgetImplFromJson(Map<String, dynamic> json) => _$BudgetImpl(
  budget: (json['budget'] as num?)?.toInt() ?? 0,
  tokens: (json['tokens'] as num?)?.toInt() ?? 0,
);

Map<String, dynamic> _$$BudgetImplToJson(_$BudgetImpl instance) =>
    <String, dynamic>{'budget': instance.budget, 'tokens': instance.tokens};
