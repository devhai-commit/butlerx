import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_vi.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[Locale('vi')];

  /// Tên ứng dụng
  ///
  /// In vi, this message translates to:
  /// **'ButlerX'**
  String get appName;

  /// Tagline của ứng dụng
  ///
  /// In vi, this message translates to:
  /// **'Trợ lý gia đình thông minh của bạn'**
  String get appTagline;

  /// No description provided for @btnContinue.
  ///
  /// In vi, this message translates to:
  /// **'Tiếp tục'**
  String get btnContinue;

  /// No description provided for @btnBack.
  ///
  /// In vi, this message translates to:
  /// **'Quay lại'**
  String get btnBack;

  /// No description provided for @btnSave.
  ///
  /// In vi, this message translates to:
  /// **'Lưu'**
  String get btnSave;

  /// No description provided for @btnCancel.
  ///
  /// In vi, this message translates to:
  /// **'Hủy'**
  String get btnCancel;

  /// No description provided for @btnConfirm.
  ///
  /// In vi, this message translates to:
  /// **'Xác nhận'**
  String get btnConfirm;

  /// No description provided for @btnEdit.
  ///
  /// In vi, this message translates to:
  /// **'Chỉnh sửa'**
  String get btnEdit;

  /// No description provided for @btnDelete.
  ///
  /// In vi, this message translates to:
  /// **'Xóa'**
  String get btnDelete;

  /// No description provided for @btnRetry.
  ///
  /// In vi, this message translates to:
  /// **'Thử lại'**
  String get btnRetry;

  /// No description provided for @btnClose.
  ///
  /// In vi, this message translates to:
  /// **'Đóng'**
  String get btnClose;

  /// No description provided for @btnDone.
  ///
  /// In vi, this message translates to:
  /// **'Xong'**
  String get btnDone;

  /// No description provided for @errorGeneral.
  ///
  /// In vi, this message translates to:
  /// **'Đã xảy ra lỗi. Vui lòng thử lại.'**
  String get errorGeneral;

  /// No description provided for @errorNetwork.
  ///
  /// In vi, this message translates to:
  /// **'Không có kết nối mạng. Vui lòng kiểm tra internet.'**
  String get errorNetwork;

  /// No description provided for @errorUnauthorized.
  ///
  /// In vi, this message translates to:
  /// **'Phiên đăng nhập đã hết hạn. Vui lòng đăng nhập lại.'**
  String get errorUnauthorized;

  /// No description provided for @authWelcome.
  ///
  /// In vi, this message translates to:
  /// **'Chào mừng đến với ButlerX'**
  String get authWelcome;

  /// No description provided for @authSubtitle.
  ///
  /// In vi, this message translates to:
  /// **'Trợ lý gia đình thông minh của bạn'**
  String get authSubtitle;

  /// No description provided for @authEmailLabel.
  ///
  /// In vi, this message translates to:
  /// **'Email'**
  String get authEmailLabel;

  /// No description provided for @authEmailHint.
  ///
  /// In vi, this message translates to:
  /// **'Nhập địa chỉ email'**
  String get authEmailHint;

  /// No description provided for @authPasswordLabel.
  ///
  /// In vi, this message translates to:
  /// **'Mật khẩu'**
  String get authPasswordLabel;

  /// No description provided for @authPasswordHint.
  ///
  /// In vi, this message translates to:
  /// **'Nhập mật khẩu'**
  String get authPasswordHint;

  /// No description provided for @authLoginBtn.
  ///
  /// In vi, this message translates to:
  /// **'Đăng nhập'**
  String get authLoginBtn;

  /// No description provided for @authRegisterBtn.
  ///
  /// In vi, this message translates to:
  /// **'Đăng ký'**
  String get authRegisterBtn;

  /// No description provided for @authGoogleBtn.
  ///
  /// In vi, this message translates to:
  /// **'Tiếp tục với Google'**
  String get authGoogleBtn;

  /// No description provided for @authForgotPassword.
  ///
  /// In vi, this message translates to:
  /// **'Quên mật khẩu?'**
  String get authForgotPassword;

  /// No description provided for @authNoAccount.
  ///
  /// In vi, this message translates to:
  /// **'Chưa có tài khoản? '**
  String get authNoAccount;

  /// No description provided for @authHaveAccount.
  ///
  /// In vi, this message translates to:
  /// **'Đã có tài khoản? '**
  String get authHaveAccount;

  /// No description provided for @authLogout.
  ///
  /// In vi, this message translates to:
  /// **'Đăng xuất'**
  String get authLogout;

  /// No description provided for @authEmailInvalid.
  ///
  /// In vi, this message translates to:
  /// **'Email không hợp lệ'**
  String get authEmailInvalid;

  /// No description provided for @authPasswordTooShort.
  ///
  /// In vi, this message translates to:
  /// **'Mật khẩu phải có ít nhất 6 ký tự'**
  String get authPasswordTooShort;

  /// No description provided for @onboardingStep.
  ///
  /// In vi, this message translates to:
  /// **'Bước {current}/{total}'**
  String onboardingStep(int current, int total);

  /// No description provided for @onboardingNameTitle.
  ///
  /// In vi, this message translates to:
  /// **'Xin chào! Tôi là ButlerX'**
  String get onboardingNameTitle;

  /// No description provided for @onboardingNameSubtitle.
  ///
  /// In vi, this message translates to:
  /// **'Hãy để tôi làm quen với bạn nhé'**
  String get onboardingNameSubtitle;

  /// No description provided for @onboardingNameLabel.
  ///
  /// In vi, this message translates to:
  /// **'Tên của bạn'**
  String get onboardingNameLabel;

  /// No description provided for @onboardingNameHint.
  ///
  /// In vi, this message translates to:
  /// **'Ví dụ: Minh, Hoa, An...'**
  String get onboardingNameHint;

  /// No description provided for @onboardingNameRequired.
  ///
  /// In vi, this message translates to:
  /// **'Vui lòng nhập tên của bạn'**
  String get onboardingNameRequired;

  /// No description provided for @onboardingDobTitle.
  ///
  /// In vi, this message translates to:
  /// **'Ngày sinh của bạn?'**
  String get onboardingDobTitle;

  /// No description provided for @onboardingDobLabel.
  ///
  /// In vi, this message translates to:
  /// **'Chọn ngày sinh'**
  String get onboardingDobLabel;

  /// No description provided for @onboardingGenderTitle.
  ///
  /// In vi, this message translates to:
  /// **'Giới tính của bạn?'**
  String get onboardingGenderTitle;

  /// No description provided for @onboardingGenderMale.
  ///
  /// In vi, this message translates to:
  /// **'Nam'**
  String get onboardingGenderMale;

  /// No description provided for @onboardingGenderFemale.
  ///
  /// In vi, this message translates to:
  /// **'Nữ'**
  String get onboardingGenderFemale;

  /// No description provided for @onboardingGenderOther.
  ///
  /// In vi, this message translates to:
  /// **'Khác'**
  String get onboardingGenderOther;

  /// No description provided for @onboardingAddressTitle.
  ///
  /// In vi, this message translates to:
  /// **'Bạn muốn tôi xưng hô thế nào?'**
  String get onboardingAddressTitle;

  /// No description provided for @onboardingAddressSubtitle.
  ///
  /// In vi, this message translates to:
  /// **'Tôi sẽ gọi bạn là...'**
  String get onboardingAddressSubtitle;

  /// No description provided for @onboardingPersonalityTitle.
  ///
  /// In vi, this message translates to:
  /// **'Tính cách của bạn?'**
  String get onboardingPersonalityTitle;

  /// No description provided for @onboardingPersonalitySubtitle.
  ///
  /// In vi, this message translates to:
  /// **'Tôi sẽ điều chỉnh cách trò chuyện phù hợp'**
  String get onboardingPersonalitySubtitle;

  /// No description provided for @onboardingPersonalityFormal.
  ///
  /// In vi, this message translates to:
  /// **'Trang trọng, lịch sự'**
  String get onboardingPersonalityFormal;

  /// No description provided for @onboardingPersonalityWarm.
  ///
  /// In vi, this message translates to:
  /// **'Thân thiện, ấm áp'**
  String get onboardingPersonalityWarm;

  /// No description provided for @onboardingPersonalityPlayful.
  ///
  /// In vi, this message translates to:
  /// **'Vui vẻ, hài hước'**
  String get onboardingPersonalityPlayful;

  /// No description provided for @onboardingComplete.
  ///
  /// In vi, this message translates to:
  /// **'Hoàn tất! Chào mừng {name}'**
  String onboardingComplete(String name);

  /// No description provided for @navChat.
  ///
  /// In vi, this message translates to:
  /// **'Trò chuyện'**
  String get navChat;

  /// No description provided for @navSchedule.
  ///
  /// In vi, this message translates to:
  /// **'Lịch hẹn'**
  String get navSchedule;

  /// No description provided for @navHealth.
  ///
  /// In vi, this message translates to:
  /// **'Sức khỏe'**
  String get navHealth;

  /// No description provided for @navMealPlan.
  ///
  /// In vi, this message translates to:
  /// **'Thực đơn'**
  String get navMealPlan;

  /// No description provided for @navSettings.
  ///
  /// In vi, this message translates to:
  /// **'Cài đặt'**
  String get navSettings;

  /// No description provided for @chatInputHint.
  ///
  /// In vi, this message translates to:
  /// **'Nhập tin nhắn...'**
  String get chatInputHint;

  /// No description provided for @chatVoiceHint.
  ///
  /// In vi, this message translates to:
  /// **'Nhấn để nói...'**
  String get chatVoiceHint;

  /// No description provided for @chatListening.
  ///
  /// In vi, this message translates to:
  /// **'Đang nghe...'**
  String get chatListening;

  /// No description provided for @chatThinking.
  ///
  /// In vi, this message translates to:
  /// **'Đang suy nghĩ...'**
  String get chatThinking;

  /// No description provided for @chatNewConversation.
  ///
  /// In vi, this message translates to:
  /// **'Cuộc trò chuyện mới'**
  String get chatNewConversation;

  /// No description provided for @scheduleTitle.
  ///
  /// In vi, this message translates to:
  /// **'Lịch hẹn'**
  String get scheduleTitle;

  /// No description provided for @scheduleAddBtn.
  ///
  /// In vi, this message translates to:
  /// **'Thêm lịch hẹn'**
  String get scheduleAddBtn;

  /// No description provided for @scheduleVoiceBtn.
  ///
  /// In vi, this message translates to:
  /// **'Tạo bằng giọng nói'**
  String get scheduleVoiceBtn;

  /// No description provided for @scheduleHandwriteBtn.
  ///
  /// In vi, this message translates to:
  /// **'Viết tay'**
  String get scheduleHandwriteBtn;

  /// No description provided for @scheduleEmpty.
  ///
  /// In vi, this message translates to:
  /// **'Chưa có lịch hẹn nào'**
  String get scheduleEmpty;

  /// No description provided for @scheduleEmptySubtitle.
  ///
  /// In vi, this message translates to:
  /// **'Thêm lịch hẹn bằng giọng nói, chữ viết tay hoặc nhập tay'**
  String get scheduleEmptySubtitle;

  /// No description provided for @scheduleToday.
  ///
  /// In vi, this message translates to:
  /// **'Hôm nay'**
  String get scheduleToday;

  /// No description provided for @scheduleTomorrow.
  ///
  /// In vi, this message translates to:
  /// **'Ngày mai'**
  String get scheduleTomorrow;

  /// No description provided for @scheduleThisWeek.
  ///
  /// In vi, this message translates to:
  /// **'Tuần này'**
  String get scheduleThisWeek;

  /// No description provided for @scheduleConfirmTitle.
  ///
  /// In vi, this message translates to:
  /// **'Xác nhận lịch hẹn'**
  String get scheduleConfirmTitle;

  /// No description provided for @scheduleConfirmSubtitle.
  ///
  /// In vi, this message translates to:
  /// **'Thông tin sau có đúng không?'**
  String get scheduleConfirmSubtitle;

  /// No description provided for @healthTitle.
  ///
  /// In vi, this message translates to:
  /// **'Sức khỏe'**
  String get healthTitle;

  /// No description provided for @healthLogBtn.
  ///
  /// In vi, this message translates to:
  /// **'Ghi chỉ số'**
  String get healthLogBtn;

  /// No description provided for @healthWeight.
  ///
  /// In vi, this message translates to:
  /// **'Cân nặng'**
  String get healthWeight;

  /// No description provided for @healthHeight.
  ///
  /// In vi, this message translates to:
  /// **'Chiều cao'**
  String get healthHeight;

  /// No description provided for @healthBloodPressure.
  ///
  /// In vi, this message translates to:
  /// **'Huyết áp'**
  String get healthBloodPressure;

  /// No description provided for @healthHeartRate.
  ///
  /// In vi, this message translates to:
  /// **'Nhịp tim'**
  String get healthHeartRate;

  /// No description provided for @healthSteps.
  ///
  /// In vi, this message translates to:
  /// **'Số bước chân'**
  String get healthSteps;

  /// No description provided for @healthSleep.
  ///
  /// In vi, this message translates to:
  /// **'Giấc ngủ'**
  String get healthSleep;

  /// No description provided for @healthUnitKg.
  ///
  /// In vi, this message translates to:
  /// **'kg'**
  String get healthUnitKg;

  /// No description provided for @healthUnitCm.
  ///
  /// In vi, this message translates to:
  /// **'cm'**
  String get healthUnitCm;

  /// No description provided for @healthUnitMmhg.
  ///
  /// In vi, this message translates to:
  /// **'mmHg'**
  String get healthUnitMmhg;

  /// No description provided for @healthUnitBpm.
  ///
  /// In vi, this message translates to:
  /// **'bpm'**
  String get healthUnitBpm;

  /// No description provided for @healthUnitSteps.
  ///
  /// In vi, this message translates to:
  /// **'bước'**
  String get healthUnitSteps;

  /// No description provided for @healthUnitHours.
  ///
  /// In vi, this message translates to:
  /// **'giờ'**
  String get healthUnitHours;

  /// No description provided for @healthWeeklyAvg.
  ///
  /// In vi, this message translates to:
  /// **'Trung bình tuần'**
  String get healthWeeklyAvg;

  /// No description provided for @healthNoData.
  ///
  /// In vi, this message translates to:
  /// **'Chưa có dữ liệu'**
  String get healthNoData;

  /// No description provided for @mealPlanTitle.
  ///
  /// In vi, this message translates to:
  /// **'Thực đơn của tôi'**
  String get mealPlanTitle;

  /// No description provided for @mealPlanGenerateBtn.
  ///
  /// In vi, this message translates to:
  /// **'Tạo thực đơn'**
  String get mealPlanGenerateBtn;

  /// No description provided for @mealPlanRegenerateBtn.
  ///
  /// In vi, this message translates to:
  /// **'Tạo lại'**
  String get mealPlanRegenerateBtn;

  /// No description provided for @mealPlanBreakfast.
  ///
  /// In vi, this message translates to:
  /// **'Bữa sáng'**
  String get mealPlanBreakfast;

  /// No description provided for @mealPlanLunch.
  ///
  /// In vi, this message translates to:
  /// **'Bữa trưa'**
  String get mealPlanLunch;

  /// No description provided for @mealPlanDinner.
  ///
  /// In vi, this message translates to:
  /// **'Bữa tối'**
  String get mealPlanDinner;

  /// No description provided for @mealPlanSnack.
  ///
  /// In vi, this message translates to:
  /// **'Bữa phụ'**
  String get mealPlanSnack;

  /// No description provided for @mealPlanSwapBtn.
  ///
  /// In vi, this message translates to:
  /// **'Đổi món'**
  String get mealPlanSwapBtn;

  /// No description provided for @mealPlanShoppingList.
  ///
  /// In vi, this message translates to:
  /// **'Danh sách mua sắm'**
  String get mealPlanShoppingList;

  /// No description provided for @mealPlanCalories.
  ///
  /// In vi, this message translates to:
  /// **'{cal} kcal'**
  String mealPlanCalories(int cal);

  /// No description provided for @mealPlanGenerating.
  ///
  /// In vi, this message translates to:
  /// **'Đang tạo thực đơn...'**
  String get mealPlanGenerating;

  /// No description provided for @mealPlanEmpty.
  ///
  /// In vi, this message translates to:
  /// **'Chưa có thực đơn'**
  String get mealPlanEmpty;

  /// No description provided for @mealPlanEmptySubtitle.
  ///
  /// In vi, this message translates to:
  /// **'Nhấn để tạo thực đơn cá nhân hóa dựa trên sức khỏe của bạn'**
  String get mealPlanEmptySubtitle;

  /// No description provided for @settingsTitle.
  ///
  /// In vi, this message translates to:
  /// **'Cài đặt'**
  String get settingsTitle;

  /// No description provided for @settingsProfile.
  ///
  /// In vi, this message translates to:
  /// **'Hồ sơ cá nhân'**
  String get settingsProfile;

  /// No description provided for @settingsNotifications.
  ///
  /// In vi, this message translates to:
  /// **'Thông báo'**
  String get settingsNotifications;

  /// No description provided for @settingsVoice.
  ///
  /// In vi, this message translates to:
  /// **'Giọng nói'**
  String get settingsVoice;

  /// No description provided for @settingsPrivacy.
  ///
  /// In vi, this message translates to:
  /// **'Quyền riêng tư'**
  String get settingsPrivacy;

  /// No description provided for @settingsTheme.
  ///
  /// In vi, this message translates to:
  /// **'Giao diện'**
  String get settingsTheme;

  /// No description provided for @settingsThemeLight.
  ///
  /// In vi, this message translates to:
  /// **'Sáng'**
  String get settingsThemeLight;

  /// No description provided for @settingsThemeDark.
  ///
  /// In vi, this message translates to:
  /// **'Tối'**
  String get settingsThemeDark;

  /// No description provided for @settingsThemeSystem.
  ///
  /// In vi, this message translates to:
  /// **'Theo hệ thống'**
  String get settingsThemeSystem;

  /// No description provided for @settingsAbout.
  ///
  /// In vi, this message translates to:
  /// **'Về ButlerX'**
  String get settingsAbout;

  /// No description provided for @settingsVersion.
  ///
  /// In vi, this message translates to:
  /// **'Phiên bản {version}'**
  String settingsVersion(String version);

  /// No description provided for @settingsLogout.
  ///
  /// In vi, this message translates to:
  /// **'Đăng xuất'**
  String get settingsLogout;

  /// No description provided for @settingsLogoutConfirm.
  ///
  /// In vi, this message translates to:
  /// **'Bạn có chắc chắn muốn đăng xuất?'**
  String get settingsLogoutConfirm;

  /// No description provided for @settingsDeleteAccount.
  ///
  /// In vi, this message translates to:
  /// **'Xóa tài khoản'**
  String get settingsDeleteAccount;

  /// No description provided for @settingsDeleteAccountConfirm.
  ///
  /// In vi, this message translates to:
  /// **'Hành động này không thể hoàn tác. Tất cả dữ liệu của bạn sẽ bị xóa vĩnh viễn.'**
  String get settingsDeleteAccountConfirm;

  /// No description provided for @reminderTitle.
  ///
  /// In vi, this message translates to:
  /// **'Nhắc nhở'**
  String get reminderTitle;

  /// No description provided for @reminderBefore.
  ///
  /// In vi, this message translates to:
  /// **'Trước {minutes} phút'**
  String reminderBefore(int minutes);

  /// No description provided for @reminderUpcoming.
  ///
  /// In vi, this message translates to:
  /// **'Sắp diễn ra'**
  String get reminderUpcoming;

  /// No description provided for @reminderMorningBriefing.
  ///
  /// In vi, this message translates to:
  /// **'Chương trình ngày hôm nay'**
  String get reminderMorningBriefing;

  /// No description provided for @permissionMicTitle.
  ///
  /// In vi, this message translates to:
  /// **'Quyền truy cập microphone'**
  String get permissionMicTitle;

  /// No description provided for @permissionMicMessage.
  ///
  /// In vi, this message translates to:
  /// **'ButlerX cần quyền truy cập microphone để lắng nghe giọng nói của bạn.'**
  String get permissionMicMessage;

  /// No description provided for @permissionNotifTitle.
  ///
  /// In vi, this message translates to:
  /// **'Quyền gửi thông báo'**
  String get permissionNotifTitle;

  /// No description provided for @permissionNotifMessage.
  ///
  /// In vi, this message translates to:
  /// **'Cho phép ButlerX gửi thông báo nhắc nhở lịch hẹn.'**
  String get permissionNotifMessage;

  /// No description provided for @permissionDeny.
  ///
  /// In vi, this message translates to:
  /// **'Từ chối'**
  String get permissionDeny;

  /// No description provided for @permissionAllow.
  ///
  /// In vi, this message translates to:
  /// **'Cho phép'**
  String get permissionAllow;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['vi'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'vi':
      return AppLocalizationsVi();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
