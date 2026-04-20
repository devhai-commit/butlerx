import 'package:uuid/uuid.dart';

final class DailyMeal {
  const DailyMeal({
    required this.dayLabel,
    required this.breakfast,
    required this.lunch,
    required this.dinner,
    this.snack,
  });

  final String dayLabel;
  final String breakfast;
  final String lunch;
  final String dinner;
  final String? snack;

  Map<String, dynamic> toJson() => {
        'dayLabel': dayLabel,
        'breakfast': breakfast,
        'lunch': lunch,
        'dinner': dinner,
        'snack': snack,
      };

  factory DailyMeal.fromJson(Map<String, dynamic> json) => DailyMeal(
        dayLabel: json['dayLabel'] as String,
        breakfast: json['breakfast'] as String,
        lunch: json['lunch'] as String,
        dinner: json['dinner'] as String,
        snack: json['snack'] as String?,
      );
}

final class MealPlan {
  MealPlan({
    String? id,
    required this.userId,
    required this.generatedAt,
    required this.days,
    this.healthContext,
  }) : id = id ?? const Uuid().v4();

  final String id;
  final String userId;
  final DateTime generatedAt;
  final List<DailyMeal> days;
  final String? healthContext;

  Map<String, dynamic> toJson() => {
        'id': id,
        'userId': userId,
        'generatedAt': generatedAt.toIso8601String(),
        'days': days.map((d) => d.toJson()).toList(),
        'healthContext': healthContext,
      };

  factory MealPlan.fromJson(Map<String, dynamic> json) => MealPlan(
        id: json['id'] as String,
        userId: json['userId'] as String,
        generatedAt: DateTime.parse(json['generatedAt'] as String),
        days: (json['days'] as List<dynamic>)
            .map((d) => DailyMeal.fromJson(d as Map<String, dynamic>))
            .toList(),
        healthContext: json['healthContext'] as String?,
      );
}
