enum OccasionCategory { birthday, anniversary, holiday, custom }

final class SpecialOccasion {
  const SpecialOccasion({
    required this.id,
    required this.label,
    required this.month,
    required this.day,
    required this.category,
    this.isLunar = false,
    this.year,
  });

  final String id;
  final String label;
  final int month;
  final int day;
  final int? year;
  final OccasionCategory category;
  final bool isLunar;

  /// Next occurrence from today (Gregorian only for now)
  DateTime nextOccurrence() {
    final now = DateTime.now();
    var next = DateTime(now.year, month, day);
    if (!next.isAfter(now)) next = DateTime(now.year + 1, month, day);
    return next;
  }

  int get daysUntilNext =>
      nextOccurrence().difference(DateTime.now()).inDays;
}

/// Pre-seeded Vietnamese public holidays (fixed Gregorian dates).
/// Lunar holidays (Tết) are approximated — proper lunar calc is Phase 4.
abstract final class VietnameseHolidays {
  static List<SpecialOccasion> get all => [
        const SpecialOccasion(
          id: 'tet_duong_lich',
          label: 'Tết Dương Lịch',
          month: 1,
          day: 1,
          category: OccasionCategory.holiday,
        ),
        const SpecialOccasion(
          id: 'hung_vuong',
          label: 'Giỗ Tổ Hùng Vương',
          month: 4,
          day: 18,
          category: OccasionCategory.holiday,
        ),
        const SpecialOccasion(
          id: 'giai_phong',
          label: 'Ngày Giải Phóng Miền Nam',
          month: 4,
          day: 30,
          category: OccasionCategory.holiday,
        ),
        const SpecialOccasion(
          id: 'quoc_te_lao_dong',
          label: 'Ngày Quốc Tế Lao Động',
          month: 5,
          day: 1,
          category: OccasionCategory.holiday,
        ),
        const SpecialOccasion(
          id: 'quoc_khanh',
          label: 'Quốc Khánh',
          month: 9,
          day: 2,
          category: OccasionCategory.holiday,
        ),
        // Approx Tết Nguyên Đán 2026 — proper lunar calc added in Phase 4
        const SpecialOccasion(
          id: 'tet_nguyen_dan',
          label: 'Tết Nguyên Đán',
          month: 2,
          day: 17,
          category: OccasionCategory.holiday,
          isLunar: true,
        ),
        const SpecialOccasion(
          id: 'trung_thu',
          label: 'Tết Trung Thu',
          month: 10,
          day: 6,
          category: OccasionCategory.holiday,
          isLunar: true,
        ),
      ];
}
