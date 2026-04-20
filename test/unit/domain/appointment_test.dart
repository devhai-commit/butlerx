import 'package:flutter_test/flutter_test.dart';

import 'package:butlerx/features/scheduling/domain/entities/appointment.dart';
import 'package:butlerx/features/scheduling/domain/entities/special_occasion.dart';

void main() {
  group('Appointment', () {
    late Appointment base;

    setUp(() {
      base = Appointment(
        userId: 'u1',
        title: 'Khám bệnh',
        startAt: DateTime(2026, 6, 15, 9, 0),
        endAt: DateTime(2026, 6, 15, 10, 0),
        location: 'Bệnh viện Q1',
        reminderOffset: ReminderOffset.thirtyMin,
      );
    });

    test('generates a non-empty id when none provided', () {
      expect(base.id, isNotEmpty);
    });

    test('two appointments with different ids are not equal', () {
      final other = Appointment(
        userId: 'u1',
        title: 'Khám bệnh',
        startAt: DateTime(2026, 6, 15, 9, 0),
      );
      expect(base, isNot(equals(other)));
    });

    test('two references to the same object are equal', () {
      expect(base, equals(base));
    });

    test('reminderFireAt is startAt minus offset minutes', () {
      expect(
        base.reminderFireAt,
        equals(base.startAt.subtract(const Duration(minutes: 30))),
      );
    });

    test('isUpcoming returns true for future appointments', () {
      final future = Appointment(
        userId: 'u1',
        title: 'Future',
        startAt: DateTime.now().add(const Duration(days: 1)),
      );
      expect(future.isUpcoming, isTrue);
    });

    test('isUpcoming returns false for past appointments', () {
      final past = Appointment(
        userId: 'u1',
        title: 'Past',
        startAt: DateTime.now().subtract(const Duration(days: 1)),
      );
      expect(past.isUpcoming, isFalse);
    });

    test('isToday returns true when startAt is today', () {
      final today = Appointment(
        userId: 'u1',
        title: 'Today',
        startAt: DateTime.now(),
      );
      expect(today.isToday, isTrue);
    });

    test('isToday returns false when startAt is tomorrow', () {
      final tomorrow = Appointment(
        userId: 'u1',
        title: 'Tomorrow',
        startAt: DateTime.now().add(const Duration(days: 1)),
      );
      expect(tomorrow.isToday, isFalse);
    });

    test('copyWith preserves unchanged fields', () {
      final updated = base.copyWith(title: 'Khám mắt');
      expect(updated.id, equals(base.id));
      expect(updated.userId, equals(base.userId));
      expect(updated.title, equals('Khám mắt'));
      expect(updated.location, equals(base.location));
    });

    test('toJson / fromJson round-trips successfully', () {
      final json = base.toJson();
      final restored = Appointment.fromJson(json);
      expect(restored.id, equals(base.id));
      expect(restored.title, equals(base.title));
      expect(restored.startAt, equals(base.startAt));
      expect(restored.endAt, equals(base.endAt));
      expect(restored.location, equals(base.location));
      expect(restored.reminderOffset, equals(base.reminderOffset));
      expect(restored.source, equals(base.source));
    });

    test('toJson includes all required keys', () {
      final json = base.toJson();
      for (final key in ['id', 'userId', 'title', 'startAt', 'reminderOffset', 'source', 'createdAt', 'updatedAt']) {
        expect(json.containsKey(key), isTrue, reason: 'Missing key: $key');
      }
    });
  });

  group('ReminderOffset', () {
    test('atTime has 0 minutes', () => expect(ReminderOffset.atTime.minutes, equals(0)));
    test('oneDay has 1440 minutes', () => expect(ReminderOffset.oneDay.minutes, equals(1440)));
    test('all offsets have non-empty labels', () {
      for (final r in ReminderOffset.values) {
        expect(r.label, isNotEmpty);
      }
    });
  });

  group('SpecialOccasion', () {
    test('nextOccurrence returns a future date', () {
      for (final h in VietnameseHolidays.all) {
        expect(h.nextOccurrence().isAfter(DateTime.now().subtract(const Duration(days: 1))), isTrue);
      }
    });

    test('daysUntilNext is non-negative', () {
      for (final h in VietnameseHolidays.all) {
        expect(h.daysUntilNext, greaterThanOrEqualTo(0));
      }
    });

    test('VietnameseHolidays.all contains at least 5 holidays', () {
      expect(VietnameseHolidays.all.length, greaterThanOrEqualTo(5));
    });

    test('all holidays have non-empty ids and labels', () {
      for (final h in VietnameseHolidays.all) {
        expect(h.id, isNotEmpty);
        expect(h.label, isNotEmpty);
      }
    });
  });
}
