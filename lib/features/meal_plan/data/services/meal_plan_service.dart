import 'dart:convert';

import 'package:dart_openai/dart_openai.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/errors/app_exception.dart';
import '../../../auth/domain/entities/user_profile.dart';
import '../../../chat/data/services/openai_service.dart';
import '../../../health/domain/entities/health_record.dart';
import '../../domain/entities/meal_plan.dart';

part 'meal_plan_service.g.dart';

@riverpod
MealPlanService mealPlanService(Ref ref) =>
    MealPlanService(ref.watch(openAiServiceProvider));

final class MealPlanService {
  MealPlanService(this._openAi);
  final OpenAiService _openAi;

  Future<MealPlan> generate({
    required String userId,
    required UserProfile profile,
    HealthRecord? latestRecord,
  }) async {
    final key = await _openAi.getApiKey();
    if (key == null || key.isEmpty) {
      throw const ValidationException(
          'Cần API key để tạo thực đơn. Vào Cài đặt để thêm.');
    }
    OpenAI.apiKey = key;

    final age = DateTime.now().difference(profile.birthdate).inDays ~/ 365;
    final gender = switch (profile.gender) {
      Gender.male => 'Nam',
      Gender.female => 'Nữ',
      Gender.other => 'Khác',
    };

    final healthInfo = StringBuffer();
    healthInfo.write('Tuổi: $age, Giới tính: $gender');
    if (latestRecord != null) {
      if (latestRecord.weightKg != null) {
        healthInfo.write(', Cân nặng: ${latestRecord.weightKg!.toStringAsFixed(1)}kg');
      }
      if (latestRecord.heightCm != null) {
        healthInfo.write(', Chiều cao: ${latestRecord.heightCm!.toStringAsFixed(0)}cm');
      }
      if (latestRecord.bmi != null) {
        healthInfo.write(
            ', BMI: ${latestRecord.bmi!.toStringAsFixed(1)} (${latestRecord.bmiLabel})');
      }
      if (latestRecord.bloodPressureSystolic != null) {
        healthInfo.write(
            ', Huyết áp: ${latestRecord.bloodPressureSystolic}/${latestRecord.bloodPressureDiastolic} mmHg');
      }
      if (latestRecord.bloodSugarMmol != null) {
        healthInfo.write(
            ', Đường huyết: ${latestRecord.bloodSugarMmol!.toStringAsFixed(1)} mmol/L');
      }
    }

    final systemPrompt = '''
Bạn là chuyên gia dinh dưỡng người Việt Nam. Hãy tạo thực đơn 7 ngày phù hợp sức khỏe và văn hoá ăn uống Việt Nam.

Thông tin sức khỏe người dùng: $healthInfo

Yêu cầu:
- Ưu tiên món ăn Việt Nam truyền thống, lành mạnh
- Phù hợp với tình trạng sức khỏe được cung cấp
- Đa dạng, không lặp lại quá nhiều
- Mỗi ngày gồm: sáng, trưa, tối và (tuỳ chọn) bữa phụ

Trả về JSON với format:
{
  "healthContext": "Lý do và lưu ý dinh dưỡng ngắn gọn (1-2 câu)",
  "days": [
    {
      "dayLabel": "Thứ Hai",
      "breakfast": "tên món sáng",
      "lunch": "tên món trưa",
      "dinner": "tên món tối",
      "snack": "bữa phụ hoặc null"
    }
  ]
}
Chỉ trả về JSON, không giải thích thêm.
''';

    try {
      final response = await OpenAI.instance.chat.create(
        model: 'gpt-4o-mini',
        messages: [
          OpenAIChatCompletionChoiceMessageModel(
            role: OpenAIChatMessageRole.system,
            content: [
              OpenAIChatCompletionChoiceMessageContentItemModel.text(
                  systemPrompt),
            ],
          ),
          OpenAIChatCompletionChoiceMessageModel(
            role: OpenAIChatMessageRole.user,
            content: [
              OpenAIChatCompletionChoiceMessageContentItemModel.text(
                  'Tạo thực đơn 7 ngày cho tôi.'),
            ],
          ),
        ],
        temperature: 0.7,
        maxTokens: 1500,
        responseFormat: {'type': 'json_object'},
      );

      final raw = response.choices.first.message.content?.first.text ?? '';
      if (raw.isEmpty) throw const ServerException('Không nhận được thực đơn từ AI.');

      final json = jsonDecode(raw) as Map<String, dynamic>;
      final daysRaw = json['days'] as List<dynamic>? ?? [];

      final days = daysRaw
          .map((d) => DailyMeal.fromJson(d as Map<String, dynamic>))
          .toList();

      if (days.isEmpty) throw const ServerException('Thực đơn trống.');

      return MealPlan(
        userId: userId,
        generatedAt: DateTime.now(),
        days: days,
        healthContext: json['healthContext'] as String?,
      );
    } on RequestFailedException catch (e) {
      throw ServerException('Lỗi tạo thực đơn: ${e.message}');
    } on FormatException {
      throw const ServerException('Không thể đọc thực đơn từ AI.');
    }
  }
}
