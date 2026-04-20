// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Vietnamese (`vi`).
class AppLocalizationsVi extends AppLocalizations {
  AppLocalizationsVi([String locale = 'vi']) : super(locale);

  @override
  String get appName => 'ButlerX';

  @override
  String get appTagline => 'Trợ lý gia đình thông minh của bạn';

  @override
  String get btnContinue => 'Tiếp tục';

  @override
  String get btnBack => 'Quay lại';

  @override
  String get btnSave => 'Lưu';

  @override
  String get btnCancel => 'Hủy';

  @override
  String get btnConfirm => 'Xác nhận';

  @override
  String get btnEdit => 'Chỉnh sửa';

  @override
  String get btnDelete => 'Xóa';

  @override
  String get btnRetry => 'Thử lại';

  @override
  String get btnClose => 'Đóng';

  @override
  String get btnDone => 'Xong';

  @override
  String get errorGeneral => 'Đã xảy ra lỗi. Vui lòng thử lại.';

  @override
  String get errorNetwork =>
      'Không có kết nối mạng. Vui lòng kiểm tra internet.';

  @override
  String get errorUnauthorized =>
      'Phiên đăng nhập đã hết hạn. Vui lòng đăng nhập lại.';

  @override
  String get authWelcome => 'Chào mừng đến với ButlerX';

  @override
  String get authSubtitle => 'Trợ lý gia đình thông minh của bạn';

  @override
  String get authEmailLabel => 'Email';

  @override
  String get authEmailHint => 'Nhập địa chỉ email';

  @override
  String get authPasswordLabel => 'Mật khẩu';

  @override
  String get authPasswordHint => 'Nhập mật khẩu';

  @override
  String get authLoginBtn => 'Đăng nhập';

  @override
  String get authRegisterBtn => 'Đăng ký';

  @override
  String get authGoogleBtn => 'Tiếp tục với Google';

  @override
  String get authForgotPassword => 'Quên mật khẩu?';

  @override
  String get authNoAccount => 'Chưa có tài khoản? ';

  @override
  String get authHaveAccount => 'Đã có tài khoản? ';

  @override
  String get authLogout => 'Đăng xuất';

  @override
  String get authEmailInvalid => 'Email không hợp lệ';

  @override
  String get authPasswordTooShort => 'Mật khẩu phải có ít nhất 6 ký tự';

  @override
  String onboardingStep(int current, int total) {
    return 'Bước $current/$total';
  }

  @override
  String get onboardingNameTitle => 'Xin chào! Tôi là ButlerX';

  @override
  String get onboardingNameSubtitle => 'Hãy để tôi làm quen với bạn nhé';

  @override
  String get onboardingNameLabel => 'Tên của bạn';

  @override
  String get onboardingNameHint => 'Ví dụ: Minh, Hoa, An...';

  @override
  String get onboardingNameRequired => 'Vui lòng nhập tên của bạn';

  @override
  String get onboardingDobTitle => 'Ngày sinh của bạn?';

  @override
  String get onboardingDobLabel => 'Chọn ngày sinh';

  @override
  String get onboardingGenderTitle => 'Giới tính của bạn?';

  @override
  String get onboardingGenderMale => 'Nam';

  @override
  String get onboardingGenderFemale => 'Nữ';

  @override
  String get onboardingGenderOther => 'Khác';

  @override
  String get onboardingAddressTitle => 'Bạn muốn tôi xưng hô thế nào?';

  @override
  String get onboardingAddressSubtitle => 'Tôi sẽ gọi bạn là...';

  @override
  String get onboardingPersonalityTitle => 'Tính cách của bạn?';

  @override
  String get onboardingPersonalitySubtitle =>
      'Tôi sẽ điều chỉnh cách trò chuyện phù hợp';

  @override
  String get onboardingPersonalityFormal => 'Trang trọng, lịch sự';

  @override
  String get onboardingPersonalityWarm => 'Thân thiện, ấm áp';

  @override
  String get onboardingPersonalityPlayful => 'Vui vẻ, hài hước';

  @override
  String onboardingComplete(String name) {
    return 'Hoàn tất! Chào mừng $name';
  }

  @override
  String get navChat => 'Trò chuyện';

  @override
  String get navSchedule => 'Lịch hẹn';

  @override
  String get navHealth => 'Sức khỏe';

  @override
  String get navMealPlan => 'Thực đơn';

  @override
  String get navSettings => 'Cài đặt';

  @override
  String get chatInputHint => 'Nhập tin nhắn...';

  @override
  String get chatVoiceHint => 'Nhấn để nói...';

  @override
  String get chatListening => 'Đang nghe...';

  @override
  String get chatThinking => 'Đang suy nghĩ...';

  @override
  String get chatNewConversation => 'Cuộc trò chuyện mới';

  @override
  String get scheduleTitle => 'Lịch hẹn';

  @override
  String get scheduleAddBtn => 'Thêm lịch hẹn';

  @override
  String get scheduleVoiceBtn => 'Tạo bằng giọng nói';

  @override
  String get scheduleHandwriteBtn => 'Viết tay';

  @override
  String get scheduleEmpty => 'Chưa có lịch hẹn nào';

  @override
  String get scheduleEmptySubtitle =>
      'Thêm lịch hẹn bằng giọng nói, chữ viết tay hoặc nhập tay';

  @override
  String get scheduleToday => 'Hôm nay';

  @override
  String get scheduleTomorrow => 'Ngày mai';

  @override
  String get scheduleThisWeek => 'Tuần này';

  @override
  String get scheduleConfirmTitle => 'Xác nhận lịch hẹn';

  @override
  String get scheduleConfirmSubtitle => 'Thông tin sau có đúng không?';

  @override
  String get healthTitle => 'Sức khỏe';

  @override
  String get healthLogBtn => 'Ghi chỉ số';

  @override
  String get healthWeight => 'Cân nặng';

  @override
  String get healthHeight => 'Chiều cao';

  @override
  String get healthBloodPressure => 'Huyết áp';

  @override
  String get healthHeartRate => 'Nhịp tim';

  @override
  String get healthSteps => 'Số bước chân';

  @override
  String get healthSleep => 'Giấc ngủ';

  @override
  String get healthUnitKg => 'kg';

  @override
  String get healthUnitCm => 'cm';

  @override
  String get healthUnitMmhg => 'mmHg';

  @override
  String get healthUnitBpm => 'bpm';

  @override
  String get healthUnitSteps => 'bước';

  @override
  String get healthUnitHours => 'giờ';

  @override
  String get healthWeeklyAvg => 'Trung bình tuần';

  @override
  String get healthNoData => 'Chưa có dữ liệu';

  @override
  String get mealPlanTitle => 'Thực đơn của tôi';

  @override
  String get mealPlanGenerateBtn => 'Tạo thực đơn';

  @override
  String get mealPlanRegenerateBtn => 'Tạo lại';

  @override
  String get mealPlanBreakfast => 'Bữa sáng';

  @override
  String get mealPlanLunch => 'Bữa trưa';

  @override
  String get mealPlanDinner => 'Bữa tối';

  @override
  String get mealPlanSnack => 'Bữa phụ';

  @override
  String get mealPlanSwapBtn => 'Đổi món';

  @override
  String get mealPlanShoppingList => 'Danh sách mua sắm';

  @override
  String mealPlanCalories(int cal) {
    return '$cal kcal';
  }

  @override
  String get mealPlanGenerating => 'Đang tạo thực đơn...';

  @override
  String get mealPlanEmpty => 'Chưa có thực đơn';

  @override
  String get mealPlanEmptySubtitle =>
      'Nhấn để tạo thực đơn cá nhân hóa dựa trên sức khỏe của bạn';

  @override
  String get settingsTitle => 'Cài đặt';

  @override
  String get settingsProfile => 'Hồ sơ cá nhân';

  @override
  String get settingsNotifications => 'Thông báo';

  @override
  String get settingsVoice => 'Giọng nói';

  @override
  String get settingsPrivacy => 'Quyền riêng tư';

  @override
  String get settingsTheme => 'Giao diện';

  @override
  String get settingsThemeLight => 'Sáng';

  @override
  String get settingsThemeDark => 'Tối';

  @override
  String get settingsThemeSystem => 'Theo hệ thống';

  @override
  String get settingsAbout => 'Về ButlerX';

  @override
  String settingsVersion(String version) {
    return 'Phiên bản $version';
  }

  @override
  String get settingsLogout => 'Đăng xuất';

  @override
  String get settingsLogoutConfirm => 'Bạn có chắc chắn muốn đăng xuất?';

  @override
  String get settingsDeleteAccount => 'Xóa tài khoản';

  @override
  String get settingsDeleteAccountConfirm =>
      'Hành động này không thể hoàn tác. Tất cả dữ liệu của bạn sẽ bị xóa vĩnh viễn.';

  @override
  String get reminderTitle => 'Nhắc nhở';

  @override
  String reminderBefore(int minutes) {
    return 'Trước $minutes phút';
  }

  @override
  String get reminderUpcoming => 'Sắp diễn ra';

  @override
  String get reminderMorningBriefing => 'Chương trình ngày hôm nay';

  @override
  String get permissionMicTitle => 'Quyền truy cập microphone';

  @override
  String get permissionMicMessage =>
      'ButlerX cần quyền truy cập microphone để lắng nghe giọng nói của bạn.';

  @override
  String get permissionNotifTitle => 'Quyền gửi thông báo';

  @override
  String get permissionNotifMessage =>
      'Cho phép ButlerX gửi thông báo nhắc nhở lịch hẹn.';

  @override
  String get permissionDeny => 'Từ chối';

  @override
  String get permissionAllow => 'Cho phép';
}
