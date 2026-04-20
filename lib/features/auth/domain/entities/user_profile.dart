enum Gender { male, female, other }

enum AddressTitle {
  ong('ông'),
  ba('bà'),
  anh('anh'),
  chi('chị'),
  em('em'),
  chau('cháu');

  const AddressTitle(this.label);
  final String label;
}

enum PersonalityTag {
  formal('Trang trọng, lịch sự'),
  warm('Thân thiện, ấm áp'),
  playful('Vui vẻ, hài hước');

  const PersonalityTag(this.label);
  final String label;
}

enum AgeBand { child, teen, adult, middleAged, elderly }

final class UserProfile {
  const UserProfile({
    required this.uid,
    required this.email,
    required this.displayName,
    required this.birthdate,
    required this.gender,
    required this.addressTitle,
    required this.personalityTag,
    this.heightCm,
    this.weightKg,
    this.onboardingComplete = false,
  });

  final String uid;
  final String email;
  final String displayName;
  final DateTime birthdate;
  final Gender gender;
  final AddressTitle addressTitle;
  final PersonalityTag personalityTag;
  final double? heightCm;
  final double? weightKg;
  final bool onboardingComplete;

  AgeBand get ageBand {
    final age = DateTime.now().difference(birthdate).inDays ~/ 365;
    return switch (age) {
      < 13 => AgeBand.child,
      < 18 => AgeBand.teen,
      < 40 => AgeBand.adult,
      < 60 => AgeBand.middleAged,
      _ => AgeBand.elderly,
    };
  }

  String get firstNameGreeting => displayName.split(' ').last;

  UserProfile copyWith({
    String? displayName,
    DateTime? birthdate,
    Gender? gender,
    AddressTitle? addressTitle,
    PersonalityTag? personalityTag,
    double? heightCm,
    double? weightKg,
    bool? onboardingComplete,
  }) =>
      UserProfile(
        uid: uid,
        email: email,
        displayName: displayName ?? this.displayName,
        birthdate: birthdate ?? this.birthdate,
        gender: gender ?? this.gender,
        addressTitle: addressTitle ?? this.addressTitle,
        personalityTag: personalityTag ?? this.personalityTag,
        heightCm: heightCm ?? this.heightCm,
        weightKg: weightKg ?? this.weightKg,
        onboardingComplete: onboardingComplete ?? this.onboardingComplete,
      );

  Map<String, dynamic> toJson() => {
        'uid': uid,
        'email': email,
        'displayName': displayName,
        'birthdate': birthdate.toIso8601String(),
        'gender': gender.name,
        'addressTitle': addressTitle.name,
        'personalityTag': personalityTag.name,
        'heightCm': heightCm,
        'weightKg': weightKg,
        'onboardingComplete': onboardingComplete,
      };

  factory UserProfile.fromJson(Map<String, dynamic> json) => UserProfile(
        uid: json['uid'] as String,
        email: json['email'] as String,
        displayName: json['displayName'] as String,
        birthdate: DateTime.parse(json['birthdate'] as String),
        gender: Gender.values.byName(json['gender'] as String),
        addressTitle: AddressTitle.values.byName(json['addressTitle'] as String),
        personalityTag: PersonalityTag.values.byName(json['personalityTag'] as String),
        heightCm: (json['heightCm'] as num?)?.toDouble(),
        weightKg: (json['weightKg'] as num?)?.toDouble(),
        onboardingComplete: json['onboardingComplete'] as bool? ?? false,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is UserProfile && uid == other.uid;

  @override
  int get hashCode => uid.hashCode;
}
