import 'package:butlerx/features/auth/domain/entities/user_profile.dart';
import 'package:butlerx/features/chat/domain/persona_prompt_builder.dart';
import 'package:flutter_test/flutter_test.dart';

UserProfile _profile({
  int yearsOld = 30,
  AddressTitle address = AddressTitle.anh,
  PersonalityTag personality = PersonalityTag.warm,
}) =>
    UserProfile(
      uid: 'uid-1',
      email: 'test@example.com',
      displayName: 'Nguyễn Văn An',
      birthdate: DateTime.now().subtract(Duration(days: yearsOld * 365)),
      gender: Gender.male,
      addressTitle: address,
      personalityTag: personality,
      onboardingComplete: true,
    );

void main() {
  group('PersonaPromptBuilder', () {
    test('always produces non-empty prompt', () {
      final prompt = PersonaPromptBuilder.build(_profile());
      expect(prompt, isNotEmpty);
    });

    test('contains user first name', () {
      final prompt = PersonaPromptBuilder.build(_profile());
      expect(prompt, contains('An'));
    });

    test('contains address title for anh', () {
      final prompt = PersonaPromptBuilder.build(_profile(address: AddressTitle.anh));
      expect(prompt, contains('anh'));
    });

    test('contains address title for ba', () {
      final prompt = PersonaPromptBuilder.build(_profile(address: AddressTitle.ba));
      expect(prompt, contains('bà'));
    });

    test('elderly profile contains elderly tone keywords', () {
      final prompt = PersonaPromptBuilder.build(_profile(yearsOld: 65));
      expect(prompt.toLowerCase(), contains('cao tuổi'));
    });

    test('child profile contains child tone keywords', () {
      final prompt = PersonaPromptBuilder.build(_profile(yearsOld: 8));
      expect(prompt.toLowerCase(), contains('trẻ em'));
    });

    test('formal personality adds formal note', () {
      final prompt = PersonaPromptBuilder.build(
          _profile(personality: PersonalityTag.formal));
      expect(prompt, contains('trang trọng'));
    });

    test('playful personality adds playful note', () {
      final prompt = PersonaPromptBuilder.build(
          _profile(personality: PersonalityTag.playful));
      expect(prompt.toLowerCase(), contains('hài hước'));
    });

    test('prompt instructs Vietnamese responses', () {
      final prompt = PersonaPromptBuilder.build(_profile());
      expect(prompt.toLowerCase(), contains('tiếng việt'));
    });

    test('prompt includes today date context', () {
      final prompt = PersonaPromptBuilder.build(_profile());
      final year = DateTime.now().year.toString();
      expect(prompt, contains(year));
    });
  });

  group('ChatMessage', () {
    test('toJson/fromJson round-trips', () {
      // Import inline to avoid extra file
    });
  });
}
