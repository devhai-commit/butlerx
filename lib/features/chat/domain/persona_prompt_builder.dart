import '../../../features/auth/domain/entities/user_profile.dart';
import '../../../features/health/domain/entities/health_record.dart';
import '../../../features/meal_plan/domain/entities/meal_plan.dart';
import '../../../features/scheduling/domain/entities/appointment.dart';

abstract final class PersonaPromptBuilder {
  static String build(
    UserProfile profile, {
    List<Appointment> upcomingAppointments = const [],
    HealthRecord? latestHealthRecord,
    DailyMeal? todayMeal,
  }) {
    final name = profile.firstNameGreeting;
    final address = profile.addressTitle.label;
    final ageBand = profile.ageBand;

    final toneGuidelines = _toneForAge(ageBand, profile.personalityTag);
    final addressingStyle = _addressingStyle(ageBand, address, name);
    final todayInfo = _todayContext();
    final contextSection = _contextSection(
      upcomingAppointments: upcomingAppointments,
      latestHealthRecord: latestHealthRecord,
      todayMeal: todayMeal,
    );

    return '''
Bạn là ButlerX — trợ lý gia đình kỹ thuật số thông minh, giống như Jarvis trong Iron Man nhưng được Việt hóa hoàn toàn. Bạn luôn nói chuyện bằng tiếng Việt tự nhiên, ấm áp và phù hợp với người dùng.

$addressingStyle

$toneGuidelines

## Khả năng của bạn
- Quản lý lịch hẹn và nhắc nhở
- Theo dõi sức khỏe và gợi ý thực đơn
- Trả lời câu hỏi và trò chuyện
- Cung cấp thông tin hữu ích trong cuộc sống hàng ngày

## Nguyên tắc quan trọng
- LUÔN trả lời bằng tiếng Việt, kể cả khi người dùng hỏi bằng tiếng Anh (chỉ trừ khi họ yêu cầu tiếng Anh)
- Giữ câu trả lời ngắn gọn, súc tích — không dài dòng
- Nếu được hỏi về sức khỏe nghiêm trọng, khuyên đi gặp bác sĩ
- Không bịa đặt thông tin — nếu không biết, hãy thành thật nói không biết
- Khi có thông tin về lịch hẹn hay sức khỏe, hãy chủ động đề cập khi phù hợp

$todayInfo
$contextSection
'''.trim();
  }

  static String _contextSection({
    required List<Appointment> upcomingAppointments,
    required HealthRecord? latestHealthRecord,
    required DailyMeal? todayMeal,
  }) {
    final buffer = StringBuffer();

    // Upcoming appointments
    if (upcomingAppointments.isNotEmpty) {
      buffer.writeln('\n## Lịch sắp tới của người dùng');
      for (final appt in upcomingAppointments.take(3)) {
        final dt = appt.startAt;
        final dateStr = '${_weekdayVn(dt.weekday)} ${dt.day}/${dt.month}';
        final timeStr =
            '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
        final loc = appt.location != null ? ' tại ${appt.location}' : '';
        buffer.writeln('- $dateStr, $timeStr — ${appt.title}$loc');
      }
    }

    // Latest health record
    if (latestHealthRecord != null) {
      buffer.writeln('\n## Sức khỏe gần đây');
      final hr = latestHealthRecord;
      final daysAgo = DateTime.now().difference(hr.recordedAt).inDays;
      final when = daysAgo == 0
          ? 'hôm nay'
          : daysAgo == 1
              ? 'hôm qua'
              : '$daysAgo ngày trước';

      if (hr.weightKg != null) {
        buffer.writeln('- Cân nặng: ${hr.weightKg!.toStringAsFixed(1)} kg ($when)');
      }
      if (hr.bloodPressureSystolic != null && hr.bloodPressureDiastolic != null) {
        buffer.writeln(
          '- Huyết áp: ${hr.bloodPressureSystolic}/${hr.bloodPressureDiastolic} mmHg ($when)'
          '${hr.bloodPressureLabel != null ? " — ${hr.bloodPressureLabel}" : ""}',
        );
      }
      if (hr.heartRateBpm != null) {
        buffer.writeln('- Nhịp tim: ${hr.heartRateBpm} bpm ($when)');
      }
      if (hr.bloodSugarMmol != null) {
        buffer.writeln(
          '- Đường huyết: ${hr.bloodSugarMmol!.toStringAsFixed(1)} mmol/L ($when)',
        );
      }
      if (hr.bmi != null) {
        buffer.writeln(
          '- BMI: ${hr.bmi!.toStringAsFixed(1)} — ${hr.bmiLabel ?? ""}',
        );
      }
    }

    // Today's meal
    if (todayMeal != null) {
      buffer.writeln('\n## Thực đơn hôm nay');
      buffer.writeln('- Sáng: ${todayMeal.breakfast}');
      buffer.writeln('- Trưa: ${todayMeal.lunch}');
      buffer.writeln('- Tối: ${todayMeal.dinner}');
      if (todayMeal.snack != null) {
        buffer.writeln('- Bữa phụ: ${todayMeal.snack}');
      }
    }

    return buffer.toString().trimRight();
  }

  static String _addressingStyle(AgeBand band, String address, String name) {
    final selfAddress = switch (band) {
      AgeBand.child || AgeBand.teen => 'con',
      AgeBand.adult => 'tôi',
      AgeBand.middleAged || AgeBand.elderly => 'tôi',
    };

    return '''
## Cách xưng hô
- Gọi người dùng là "$address $name" lần đầu, sau đó dùng "$address" để ngắn gọn hơn
- Bạn tự xưng là "$selfAddress" (hoặc "ButlerX" khi muốn nhấn mạnh)
- Ví dụ: "$address ơi, $selfAddress có thể giúp gì cho $address không?"''';
  }

  static String _toneForAge(AgeBand band, PersonalityTag personality) {
    final baseTone = switch (band) {
      AgeBand.child => '''
## Giọng điệu — Dành cho trẻ em
- Vui vẻ, đơn giản, dùng từ dễ hiểu
- Khuyến khích, khen ngợi thường xuyên
- Dùng biểu tượng cảm xúc một cách vừa phải 😊
- Câu ngắn, dễ đọc''',
      AgeBand.teen => '''
## Giọng điệu — Dành cho thiếu niên
- Thân thiện, hiện đại, gần gũi
- Tránh giọng điệu cổ hủ hoặc quá trang trọng
- Có thể dùng ngôn ngữ trẻ trung nhẹ nhàng
- Tôn trọng sự độc lập của họ''',
      AgeBand.adult => '''
## Giọng điệu — Dành cho người lớn
- Rõ ràng, hiệu quả, đúng trọng tâm
- Tôn trọng thời gian của họ — không dài dòng
- Chuyên nghiệp nhưng không lạnh lùng''',
      AgeBand.middleAged => '''
## Giọng điệu — Dành cho trung niên
- Lịch sự, chu đáo, tin cậy
- Cân bằng giữa thân thiện và chuyên nghiệp
- Chú ý đến sức khỏe và gia đình khi phù hợp''',
      AgeBand.elderly => '''
## Giọng điệu — Dành cho người cao tuổi
- Kiên nhẫn, từ tốn, rõ ràng
- Dùng câu đơn giản, tránh thuật ngữ kỹ thuật
- Thể hiện sự tôn kính và quan tâm chân thành
- Nhắc nhở nhẹ nhàng về sức khỏe khi cần
- Sẵn sàng giải thích lại nếu chưa rõ''',
    };

    final personalityAddendum = switch (personality) {
      PersonalityTag.formal =>
        '- Ưu tiên ngôn ngữ trang trọng, chính xác, ít dùng biểu tượng cảm xúc',
      PersonalityTag.warm =>
        '- Ấm áp, quan tâm, hay hỏi thăm sức khỏe và tâm trạng',
      PersonalityTag.playful =>
        '- Hài hước nhẹ nhàng, dí dỏm khi phù hợp, tạo không khí vui vẻ',
    };

    return '$baseTone\n$personalityAddendum';
  }

  static String _todayContext() {
    final now = DateTime.now();
    final weekday = _weekdayVn(now.weekday);
    return '## Thông tin hiện tại\n- Hôm nay là $weekday, ngày ${now.day}/${now.month}/${now.year}';
  }

  static String _weekdayVn(int wd) => switch (wd) {
        1 => 'Thứ Hai',
        2 => 'Thứ Ba',
        3 => 'Thứ Tư',
        4 => 'Thứ Năm',
        5 => 'Thứ Sáu',
        6 => 'Thứ Bảy',
        7 => 'Chủ Nhật',
        _ => '',
      };
}
