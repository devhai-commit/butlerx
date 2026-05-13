import 'package:uuid/uuid.dart';

enum RepeatRule {
  none('Không lặp'),
  daily('Hàng ngày'),
  weekly('Hàng tuần'),
  monthly('Hàng tháng');

  const RepeatRule(this.label);
  final String label;
}

final class Reminder {
  Reminder({
    String? id,
    required this.userId,
    required this.title,
    this.body,
    required this.scheduledAt,
    this.repeatRule = RepeatRule.none,
    this.isActive = true,
    this.linkedAppointmentId,
    DateTime? createdAt,
  })  : id = id ?? const Uuid().v4(),
        createdAt = createdAt ?? DateTime.now();

  final String id;
  final String userId;
  final String title;
  final String? body;
  final DateTime scheduledAt;
  final RepeatRule repeatRule;
  final bool isActive;
  final String? linkedAppointmentId;
  final DateTime createdAt;

  bool get isUpcoming => scheduledAt.isAfter(DateTime.now());

  int get notificationId => id.hashCode.abs() % 100000;

  Reminder copyWith({
    String? title,
    String? body,
    DateTime? scheduledAt,
    RepeatRule? repeatRule,
    bool? isActive,
    String? linkedAppointmentId,
  }) =>
      Reminder(
        id: id,
        userId: userId,
        title: title ?? this.title,
        body: body ?? this.body,
        scheduledAt: scheduledAt ?? this.scheduledAt,
        repeatRule: repeatRule ?? this.repeatRule,
        isActive: isActive ?? this.isActive,
        linkedAppointmentId:
            linkedAppointmentId ?? this.linkedAppointmentId,
        createdAt: createdAt,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'userId': userId,
        'title': title,
        'body': body,
        'scheduledAt': scheduledAt.toIso8601String(),
        'repeatRule': repeatRule.name,
        'isActive': isActive,
        'linkedAppointmentId': linkedAppointmentId,
        'createdAt': createdAt.toIso8601String(),
      };

  factory Reminder.fromJson(Map<String, dynamic> json) => Reminder(
        id: json['id'] as String,
        userId: json['userId'] as String,
        title: json['title'] as String,
        body: json['body'] as String?,
        scheduledAt: DateTime.parse(json['scheduledAt'] as String),
        repeatRule: RepeatRule.values.byName(
            json['repeatRule'] as String? ?? 'none'),
        isActive: json['isActive'] as bool? ?? true,
        linkedAppointmentId: json['linkedAppointmentId'] as String?,
        createdAt: DateTime.parse(json['createdAt'] as String),
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is Reminder && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
