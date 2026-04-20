import 'package:uuid/uuid.dart';

enum AppointmentSource { manual, voice, handwriting }

enum ReminderOffset {
  atTime(0, 'Đúng giờ'),
  fiveMin(5, 'Trước 5 phút'),
  fifteenMin(15, 'Trước 15 phút'),
  thirtyMin(30, 'Trước 30 phút'),
  oneHour(60, 'Trước 1 giờ'),
  oneDay(1440, 'Trước 1 ngày');

  const ReminderOffset(this.minutes, this.label);
  final int minutes;
  final String label;
}

final class Appointment {
  Appointment({
    String? id,
    required this.userId,
    required this.title,
    required this.startAt,
    this.endAt,
    this.description,
    this.location,
    this.reminderOffset = ReminderOffset.fifteenMin,
    this.source = AppointmentSource.manual,
    this.rawTranscript,
    DateTime? createdAt,
    DateTime? updatedAt,
    this.notificationId,
  })  : id = id ?? const Uuid().v4(),
        createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  final String id;
  final String userId;
  final String title;
  final DateTime startAt;
  final DateTime? endAt;
  final String? description;
  final String? location;
  final ReminderOffset reminderOffset;
  final AppointmentSource source;
  final String? rawTranscript;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int? notificationId;

  DateTime get reminderFireAt =>
      startAt.subtract(Duration(minutes: reminderOffset.minutes));

  bool get isUpcoming => startAt.isAfter(DateTime.now());
  bool get isToday {
    final now = DateTime.now();
    return startAt.year == now.year &&
        startAt.month == now.month &&
        startAt.day == now.day;
  }

  Appointment copyWith({
    String? title,
    DateTime? startAt,
    DateTime? endAt,
    String? description,
    String? location,
    ReminderOffset? reminderOffset,
    int? notificationId,
  }) =>
      Appointment(
        id: id,
        userId: userId,
        title: title ?? this.title,
        startAt: startAt ?? this.startAt,
        endAt: endAt ?? this.endAt,
        description: description ?? this.description,
        location: location ?? this.location,
        reminderOffset: reminderOffset ?? this.reminderOffset,
        source: source,
        rawTranscript: rawTranscript,
        createdAt: createdAt,
        updatedAt: DateTime.now(),
        notificationId: notificationId ?? this.notificationId,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'userId': userId,
        'title': title,
        'startAt': startAt.toIso8601String(),
        'endAt': endAt?.toIso8601String(),
        'description': description,
        'location': location,
        'reminderOffset': reminderOffset.name,
        'source': source.name,
        'rawTranscript': rawTranscript,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
        'notificationId': notificationId,
      };

  factory Appointment.fromJson(Map<String, dynamic> json) => Appointment(
        id: json['id'] as String,
        userId: json['userId'] as String,
        title: json['title'] as String,
        startAt: DateTime.parse(json['startAt'] as String),
        endAt: json['endAt'] != null
            ? DateTime.parse(json['endAt'] as String)
            : null,
        description: json['description'] as String?,
        location: json['location'] as String?,
        reminderOffset: ReminderOffset.values.byName(
            json['reminderOffset'] as String? ?? 'fifteenMin'),
        source: AppointmentSource.values.byName(
            json['source'] as String? ?? 'manual'),
        rawTranscript: json['rawTranscript'] as String?,
        createdAt: DateTime.parse(json['createdAt'] as String),
        updatedAt: DateTime.parse(json['updatedAt'] as String),
        notificationId: json['notificationId'] as int?,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is Appointment && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
