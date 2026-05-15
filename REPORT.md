# THIẾT KẾ VÀ XÂY DỰNG ỨNG DỤNG TRỢ LÝ GIA ĐÌNH THÔNG MINH TÍCH HỢP TRÍ TUỆ NHÂN TẠO VÀ NHẬN DẠNG GIỌNG NÓI TIẾNG VIỆT

**Design and Development of an AI-Integrated Vietnamese Voice-Enabled Smart Family Assistant Application**

---

|  |  |
|--|--|
| **Tên đề tài** | Xây dựng ứng dụng trợ lý gia đình thông minh ButlerX tích hợp AI và nhận dạng giọng nói tiếng Việt |
| **Sinh viên thực hiện** | Nguyễn Hải |
| **Ngày hoàn thành** | 15/05/2026 |
| **Nền tảng phát triển** | Flutter 3.5 / Dart 3.5 |
| **Ngôn ngữ chính** | Tiếng Việt |

---

## MỤC LỤC

1. [Tóm Tắt](#1-tóm-tắt)
2. [Giới Thiệu](#2-giới-thiệu)
3. [Tổng Quan Công Nghệ Liên Quan](#3-tổng-quan-công-nghệ-liên-quan)
4. [Phân Tích Yêu Cầu Hệ Thống](#4-phân-tích-yêu-cầu-hệ-thống)
5. [Kiến Trúc và Thiết Kế Hệ Thống](#5-kiến-trúc-và-thiết-kế-hệ-thống)
6. [Thiết Kế Cơ Sở Dữ Liệu](#6-thiết-kế-cơ-sở-dữ-liệu)
7. [Thiết Kế Module AI và Xử Lý Ngôn Ngữ Tự Nhiên](#7-thiết-kế-module-ai-và-xử-lý-ngôn-ngữ-tự-nhiên)
8. [Cài Đặt và Triển Khai](#8-cài-đặt-và-triển-khai)
9. [Giao Diện Người Dùng](#9-giao-diện-người-dùng)
10. [Kết Quả và Đánh Giá](#10-kết-quả-và-đánh-giá)
11. [Kết Luận và Hướng Phát Triển](#11-kết-luận-và-hướng-phát-triển)
12. [Tài Liệu Tham Khảo](#12-tài-liệu-tham-khảo)

---

## 1. Tóm Tắt

Báo cáo này trình bày quá trình thiết kế và cài đặt ứng dụng **ButlerX** — một trợ lý gia đình kỹ thuật số thông minh được phát triển trên nền tảng Flutter, hướng đến người dùng Việt Nam. Ứng dụng tích hợp mô hình ngôn ngữ lớn (LLM) GPT-4 của OpenAI cùng hệ thống nhận dạng giọng nói tiếng Việt để cho phép người dùng tương tác tự nhiên bằng lời nói trong các tác vụ quản lý cuộc sống hàng ngày, bao gồm: quản lý lịch hẹn, theo dõi sức khỏe, lập kế hoạch bữa ăn, và nhắc nhở cá nhân.

Điểm nổi bật của hệ thống là **pipeline phân loại ý định** (intent classification) sử dụng GPT-4o-mini với JSON structured output, cho phép chuyển đổi câu nói tiếng Việt tùy ý thành hành động có cấu trúc trong ứng dụng. Hệ thống áp dụng kiến trúc Clean Architecture, quản lý trạng thái bằng Riverpod 2.x với code generation, và sử dụng PostgreSQL làm cơ sở dữ liệu quan hệ.

**Từ khóa:** Trí tuệ nhân tạo, nhận dạng giọng nói, xử lý ngôn ngữ tự nhiên tiếng Việt, Flutter, GPT-4, trợ lý ảo, quản lý cuộc sống.

---

## 2. Giới Thiệu

### 2.1 Bối Cảnh và Động Lực

Sự phổ biến của điện thoại thông minh cùng sự trưởng thành của các mô hình ngôn ngữ lớn (Large Language Models — LLM) đã tạo ra làn sóng phát triển ứng dụng trợ lý ảo cá nhân. Tuy nhiên, phần lớn các giải pháp hiện có trên thị trường — Siri (Apple), Google Assistant, Alexa (Amazon) — được tối ưu cho tiếng Anh và thiếu ngữ cảnh văn hóa đặc thù cho người dùng Việt Nam: hệ thống xưng hô đa dạng (ông/bà/anh/chị), lịch âm dương, thói quen sinh hoạt và ngôn ngữ thông tục địa phương.

Bên cạnh đó, các ứng dụng quản lý cuộc sống (lịch, sức khỏe, bữa ăn) thường tồn tại rời rạc và không tích hợp với nhau, khiến người dùng phải chuyển đổi giữa nhiều ứng dụng khác nhau. Không có một trợ lý nào có khả năng hiểu câu nói "Nhắc tôi uống thuốc tối nay và cũng thêm vào lịch buổi khám bác sĩ tuần sau sáng thứ Tư" để thực hiện đồng thời nhiều tác vụ khác nhau trong một lần tương tác duy nhất.

### 2.2 Mục Tiêu Đề Tài

Đề tài đặt ra các mục tiêu cụ thể sau:

1. **Xây dựng nền tảng tích hợp** cho các tác vụ quản lý cuộc sống gia đình trong một ứng dụng duy nhất.
2. **Phát triển pipeline NLP tiếng Việt** có khả năng phân loại ý định và trích xuất thực thể từ câu nói tự nhiên.
3. **Thiết kế hệ thống cá nhân hóa AI** dựa trên hồ sơ người dùng (tuổi, tính cách, sức khỏe) để tạo ra trải nghiệm phù hợp với từng cá nhân.
4. **Đảm bảo khả năng sử dụng** (usability) cho đa dạng nhóm người dùng, bao gồm người cao tuổi.

### 2.3 Phạm Vi Đề Tài

Đề tài tập trung vào phát triển ứng dụng di động đa nền tảng (Android, iOS, Windows) với các module: trợ lý chat AI, quản lý lịch hẹn, theo dõi sức khỏe, lập kế hoạch bữa ăn, và quản lý nhắc nhở. Đề tài **không** đặt mục tiêu xây dựng mô hình AI từ đầu mà tận dụng API của OpenAI và tối ưu hóa ở tầng ứng dụng.

### 2.4 Bố Cục Báo Cáo

Phần còn lại của báo cáo được tổ chức như sau: Mục 3 trình bày tổng quan các công nghệ liên quan; Mục 4 phân tích yêu cầu chức năng và phi chức năng; Mục 5 mô tả kiến trúc hệ thống; Mục 6 trình bày thiết kế cơ sở dữ liệu; Mục 7 đi sâu vào module AI; Mục 8 mô tả quá trình cài đặt; Mục 9 trình bày giao diện; Mục 10 đánh giá kết quả; Mục 11 kết luận.

---

## 3. Tổng Quan Công Nghệ Liên Quan

### 3.1 Mô Hình Ngôn Ngữ Lớn (LLM) trong Ứng Dụng

GPT-4 (Brown et al., 2020; OpenAI, 2023) là mô hình Transformer đa phương thức có khả năng hiểu và sinh ngôn ngữ tự nhiên ở mức độ cao, bao gồm tiếng Việt. Trong các ứng dụng thực tế, LLM được sử dụng theo hai cách chính: (1) **open-ended generation** cho hội thoại tự do, và (2) **structured output** với JSON mode để trích xuất thông tin có cấu trúc — kỹ thuật được sử dụng trong hệ thống phân loại ý định của ButlerX.

GPT-4o-mini là biến thể nhỏ hơn, có chi phí thấp hơn ~20 lần so với GPT-4, phù hợp cho các tác vụ phân loại có độ phức tạp thấp như intent classification với yêu cầu output là JSON ngắn gọn.

### 3.2 Nhận Dạng Giọng Nói Tiếng Việt

Nhận dạng giọng nói tiếng Việt (Automatic Speech Recognition — ASR) là thách thức do tiếng Việt có 6 thanh điệu, nhiều phương ngữ vùng miền, và thiếu dữ liệu huấn luyện so với tiếng Anh. Package `speech_to_text` trong Flutter sử dụng API nhận dạng giọng nói tích hợp sẵn của nền tảng (Android SpeechRecognizer API, iOS SFSpeechRecognizer), hỗ trợ locale `vi-VN` và cho kết quả chấp nhận được trong điều kiện phòng yên tĩnh.

### 3.3 Kiến Trúc Ứng Dụng Di Động Đa Nền Tảng

Flutter (Google, 2018) là framework UI đa nền tảng sử dụng ngôn ngữ Dart. Flutter biên dịch sang native ARM code và sử dụng Skia/Impeller engine để render giao diện, không phụ thuộc vào widget native của hệ điều hành. Điều này cho phép giao diện nhất quán trên cả Android, iOS và desktop.

**Clean Architecture** (Martin, 2017) phân tách hệ thống thành các lớp độc lập (Domain, Data, Presentation) với nguyên tắc Dependency Inversion: các lớp bên trong không phụ thuộc vào các lớp bên ngoài. Điều này tăng khả năng kiểm thử và bảo trì.

**Riverpod** là thư viện quản lý trạng thái phản ứng (reactive state management) cho Flutter/Dart, khắc phục các hạn chế của Provider gốc bằng cách hỗ trợ compile-time safety, code generation, và testability cao hơn.

### 3.4 Các Công Trình Liên Quan

Các hệ thống trợ lý ảo thế hệ hiện tại như **Google Assistant** tích hợp sâu với hệ sinh thái Google (Calendar, Gmail), nhưng thiếu khả năng cá nhân hóa theo hồ sơ cá nhân chi tiết và không được tối ưu cho tiếng Việt đặc thù. **ChatGPT** (OpenAI, 2022) cung cấp khả năng hội thoại xuất sắc nhưng không có khả năng thực thi hành động trực tiếp trong thiết bị (không tích hợp với lịch, nhắc nhở, hay cơ sở dữ liệu sức khỏe cục bộ).

ButlerX hướng đến lấp đầy khoảng cách này: kết hợp khả năng NLP mạnh của LLM với khả năng thực thi hành động cục bộ trong môi trường thiết bị người dùng.

---

## 4. Phân Tích Yêu Cầu Hệ Thống

### 4.1 Yêu Cầu Chức Năng

#### Nhóm 1: Tương tác AI và Giọng Nói

| Mã | Yêu cầu | Độ ưu tiên |
|----|---------|-----------|
| F1.1 | Hệ thống cho phép người dùng chat văn bản với AI bằng tiếng Việt | Cao |
| F1.2 | Hệ thống nhận dạng giọng nói tiếng Việt và chuyển thành văn bản | Cao |
| F1.3 | Hệ thống phân loại ý định từ câu nói và thực thi hành động tương ứng | Cao |
| F1.4 | AI phản hồi bằng giọng nói tiếng Việt (TTS) | Trung bình |
| F1.5 | AI sử dụng ngữ cảnh cá nhân (lịch hẹn, sức khỏe) khi trả lời | Cao |

#### Nhóm 2: Quản Lý Lịch Hẹn

| Mã | Yêu cầu | Độ ưu tiên |
|----|---------|-----------|
| F2.1 | Người dùng thêm/sửa/xóa lịch hẹn | Cao |
| F2.2 | Người dùng tạo lịch hẹn bằng giọng nói | Cao |
| F2.3 | Hệ thống tự động lên thông báo nhắc nhở trước giờ hẹn | Cao |
| F2.4 | Hiển thị danh sách lịch theo ngày | Trung bình |

#### Nhóm 3: Theo Dõi Sức Khỏe

| Mã | Yêu cầu | Độ ưu tiên |
|----|---------|-----------|
| F3.1 | Người dùng ghi nhận chỉ số sức khỏe (cân nặng, huyết áp, nhịp tim, đường huyết) | Cao |
| F3.2 | Hệ thống tự động tính và phân loại BMI, huyết áp | Cao |
| F3.3 | Hiển thị biểu đồ xu hướng sức khỏe theo thời gian | Trung bình |
| F3.4 | Ghi chỉ số sức khỏe bằng giọng nói | Trung bình |

#### Nhóm 4: Kế Hoạch Bữa Ăn

| Mã | Yêu cầu | Độ ưu tiên |
|----|---------|-----------|
| F4.1 | AI tạo thực đơn 7 ngày dựa trên tình trạng sức khỏe người dùng | Cao |
| F4.2 | Lưu và xem lại lịch sử thực đơn đã tạo | Thấp |

#### Nhóm 5: Nhắc Nhở và Hồ Sơ

| Mã | Yêu cầu | Độ ưu tiên |
|----|---------|-----------|
| F5.1 | Tạo nhắc nhở với quy tắc lặp (ngày/tuần/tháng) | Cao |
| F5.2 | Người dùng tùy chỉnh hồ sơ cá nhân (tên, tuổi, tính cách AI, danh xưng) | Cao |
| F5.3 | Onboarding flow cho người dùng mới | Cao |

### 4.2 Yêu Cầu Phi Chức Năng

| Mã | Yêu cầu | Tiêu chí đo lường |
|----|---------|------------------|
| NF1 | **Hiệu năng**: Phản hồi AI bắt đầu streaming trong ≤ 3 giây | Thời gian tới token đầu tiên |
| NF2 | **Độ chính xác NLP**: Intent classification đúng ≥ 85% với câu nói phổ thông | Tỷ lệ phân loại đúng |
| NF3 | **Khả dụng**: Ứng dụng hoạt động ổn định khi không có kết nối (cho tính năng không cần AI) | Crash rate |
| NF4 | **Bảo mật**: API key người dùng được lưu trữ mã hóa, không xuất hiện trong log | Kiểm tra thủ công |
| NF5 | **Khả năng tiếp cận**: Giao diện hỗ trợ người cao tuổi (font lớn, tương phản cao) | WCAG 2.1 AA |
| NF6 | **Đa nền tảng**: Ứng dụng chạy được trên Android, iOS, Windows | Kiểm thử thực tế |

### 4.3 Ràng Buộc Hệ Thống

- Người dùng cần kết nối Internet để sử dụng tính năng AI (gọi OpenAI API)
- Người dùng cần tự cung cấp OpenAI API key (mô hình B2C với API key cá nhân)
- Cơ sở dữ liệu PostgreSQL trong giai đoạn hiện tại chạy cục bộ (localhost)
- Nhận dạng giọng nói phụ thuộc vào API của nền tảng (Android/iOS), không hoạt động trên Windows

---

## 5. Kiến Trúc và Thiết Kế Hệ Thống

### 5.1 Tổng Quan Kiến Trúc

ButlerX áp dụng **Clean Architecture** (Robert C. Martin) với ba lớp phân cấp rõ ràng, tuân thủ nguyên tắc **Dependency Rule**: các lớp bên trong không bao giờ phụ thuộc vào các lớp bên ngoài.

```
╔══════════════════════════════════════════════════════╗
║              PRESENTATION LAYER                      ║
║  • Flutter Pages (UI widgets)                        ║
║  • Riverpod Notifiers (state logic)                  ║
║  • GoRouter (navigation)                             ║
╠══════════════════════════════════════════════════════╣
║  Phụ thuộc vào Domain thông qua Interfaces  ↑        ║
╠══════════════════════════════════════════════════════╣
║              DOMAIN LAYER                            ║
║  • Entities (mô hình nghiệp vụ thuần Dart)           ║
║  • Repository Interfaces (abstract)                  ║
║  • Business logic (persona builder, BMI calc...)     ║
╠══════════════════════════════════════════════════════╣
║  Implement Domain Interfaces  ↑                      ║
╠══════════════════════════════════════════════════════╣
║              DATA LAYER                              ║
║  • PostgreSQL DAOs                                   ║
║  • OpenAI Service (GPT-4 streaming)                  ║
║  • Notification Service                              ║
║  • STT/TTS Services                                  ║
║  • Secure Storage (flutter_secure_storage)           ║
╚══════════════════════════════════════════════════════╝
```

### 5.2 Phân Chia Module Theo Feature

Hệ thống được tổ chức theo kiến trúc **Feature-based** (thay vì Layer-based), trong đó mỗi tính năng là một module độc lập chứa đủ ba lớp Domain/Data/Presentation:

```
lib/features/
├── auth/          # Xác thực người dùng
├── chat/          # Trợ lý AI + lịch sử hội thoại
├── scheduling/    # Quản lý lịch hẹn
├── health/        # Theo dõi sức khỏe
├── meal_plan/     # Kế hoạch bữa ăn
├── reminders/     # Nhắc nhở
├── onboarding/    # Thiết lập ban đầu
└── settings/      # Cài đặt ứng dụng
```

Các module chia sẻ dùng chung được đặt trong `lib/shared/` (services, widgets, UI) và `lib/core/` (agent AI, database, constants, error types).

### 5.3 Luồng Dữ Liệu Tổng Quát

```
[User Action / Voice]
        │
        ▼
[Presentation Layer: Notifier.method()]
        │
        ▼
[Domain Layer: Repository Interface]
        │
        ├──► [Data Layer: DAO → PostgreSQL]  ←──► Dữ liệu cục bộ
        │
        └──► [Data Layer: OpenAI Service]    ←──► OpenAI API (Internet)
        │
        ▼
[Notifier state.copyWith(...)]
        │
        ▼
[UI rebuild: ref.watch(notifierProvider)]
```

### 5.4 Kiến Trúc Core Agent AI

Module `lib/core/agent/` đóng vai trò **orchestrator** cho toàn bộ luồng voice interaction:

```
lib/core/agent/
├── agent_notifier.dart      # Điều phối toàn bộ luồng voice
├── intent_classifier.dart   # GPT-4o-mini JSON intent parser
└── action_router.dart       # Ánh xạ intent → feature notifier
```

**Pipeline xử lý:**

```
Bước 1: Capture Audio  ──►  STT Service (speech_to_text)
Bước 2: Transcript     ──►  IntentClassifier (GPT-4o-mini)
Bước 3: IntentResult   ──►  ActionRouter
Bước 4: Feature Action ──►  Repository → Database / OpenAI
Bước 5: Response Text  ──►  TTS Service (flutter_tts)
```

### 5.5 Quản Lý Trạng Thái với Riverpod

Riverpod 2.x được chọn vì hỗ trợ:
- **Compile-time safety**: phát hiện lỗi type tại compile time thay vì runtime
- **Code generation**: giảm boilerplate bằng annotation `@riverpod`
- **Testability**: dễ override provider trong tests
- **Sealed class pattern**: mô tả rõ ràng các trạng thái có thể có của một notifier

Ví dụ pattern sealed state cho module xác thực:

```dart
sealed class AuthStatus {}

final class AuthLoading    extends AuthStatus {}
final class AuthAuthenticated extends AuthStatus {
  final UserProfile profile;
  const AuthAuthenticated(this.profile);
}
final class AuthUnauthenticated extends AuthStatus {}
```

Riverpod router refreshes tự động khi `authNotifierProvider` thay đổi trạng thái, đảm bảo điều hướng phản ứng đúng (redirect về login/onboarding/home).

---

## 6. Thiết Kế Cơ Sở Dữ Liệu

### 6.1 Lựa Chọn Công Nghệ

Hệ thống sử dụng **PostgreSQL** (phiên bản 15+) làm cơ sở dữ liệu quan hệ. Lý do lựa chọn: hỗ trợ kiểu dữ liệu phong phú (JSONB, BOOLEAN, BIGINT), tính nhất quán ACID, và khả năng mở rộng lên môi trường cloud (Supabase, AWS RDS) dễ dàng.

Kết nối được thực hiện qua package `postgres ^3.5.0` cho Dart, với lazy initialization: schema tự động tạo khi lần đầu kết nối.

### 6.2 Sơ Đồ Quan Hệ (ERD)

```
┌─────────────────────┐         ┌──────────────────────┐
│    conversations    │         │     chat_messages     │
├─────────────────────┤         ├──────────────────────┤
│ id         TEXT PK  │◄────────│ conversation_id  FK  │
│ user_id    TEXT     │  1   *  │ id           TEXT PK │
│ title      TEXT     │         │ role         TEXT    │
│ created_at BIGINT   │         │ content      TEXT    │
│ updated_at BIGINT?  │         │ created_at   BIGINT  │
└─────────────────────┘         └──────────────────────┘

┌─────────────────────┐         ┌──────────────────────┐
│    appointments     │         │   special_occasions  │
├─────────────────────┤         ├──────────────────────┤
│ id         TEXT PK  │         │ id        TEXT PK    │
│ user_id    TEXT     │         │ user_id   TEXT?      │
│ title      TEXT     │         │ label     TEXT       │
│ start_at   BIGINT   │         │ month     INTEGER    │
│ end_at     BIGINT?  │         │ day       INTEGER    │
│ description TEXT?   │         │ year      INTEGER?   │
│ location   TEXT?    │         │ category  TEXT       │
│ reminder_offset INT │         │ is_lunar  BOOLEAN    │
│ source     TEXT     │         └──────────────────────┘
│ raw_transcript TEXT?│
│ notification_id INT?│         ┌──────────────────────┐
└─────────────────────┘         │    health_records    │
                                ├──────────────────────┤
┌─────────────────────┐         │ id           TEXT PK │
│      reminders      │         │ user_id      TEXT    │
├─────────────────────┤         │ recorded_at  BIGINT  │
│ id         TEXT PK  │         │ weight_kg    DOUBLE? │
│ user_id    TEXT     │         │ height_cm    DOUBLE? │
│ title      TEXT     │         │ bp_systolic  INT?    │
│ body       TEXT?    │         │ bp_diastolic INT?    │
│ scheduled_at BIGINT │         │ heart_rate   INT?    │
│ repeat_rule TEXT    │         │ blood_sugar  DOUBLE? │
│ is_active  BOOLEAN  │         │ notes        TEXT?   │
│ linked_appt_id TEXT?│         └──────────────────────┘
│ created_at BIGINT   │
└─────────────────────┘
```

**Ghi chú thiết kế:**
- Tất cả `id` đều là UUID v4 dạng TEXT, tránh phụ thuộc vào auto-increment của database
- Timestamp lưu dạng **Unix milliseconds** (BIGINT) để đơn giản hóa tính toán múi giờ trong Dart
- `chat_messages.conversation_id` có ràng buộc `ON DELETE CASCADE` để tự động xóa tin nhắn khi conversation bị xóa
- `reminders.is_active` thực hiện **soft delete** — dữ liệu không bị xóa vật lý

### 6.3 Data Access Object (DAO) Pattern

Mỗi bảng có một DAO tương ứng nhận `AppDatabase` qua constructor injection:

| DAO | Phương thức chính |
|-----|------------------|
| `ConversationDao` | `insert`, `getAll`, `getById`, `getWithMessages`, `delete` |
| `AppointmentDao` | `insert`, `update`, `getByDate`, `getUpcoming`, `delete` |
| `HealthRecordDao` | `insert`, `getLatest`, `getAll` |
| `ReminderDao` | `insert`, `update`, `getActive`, `setInactive` |

---

## 7. Thiết Kế Module AI và Xử Lý Ngôn Ngữ Tự Nhiên

### 7.1 Kiến Trúc Pipeline NLP

Hệ thống NLP của ButlerX hoạt động theo mô hình **pipeline hai giai đoạn**:

**Giai đoạn 1 — Nhận dạng giọng nói (ASR):**
Sử dụng API tích hợp của nền tảng (Android `SpeechRecognizer`, iOS `SFSpeechRecognizer`) thông qua package `speech_to_text`. Locale được đặt là `vi-VN`. Kết quả là chuỗi văn bản với điểm tin cậy (confidence score).

**Giai đoạn 2 — Phân loại ý định và trích xuất thực thể:**
Văn bản được gửi tới GPT-4o-mini với JSON structured output mode. Mô hình trả về JSON gồm: `intent`, `entities`, `responseText`, và `confidence`.

### 7.2 Thiết Kế System Prompt cho Intent Classification

System prompt được thiết kế với các yếu tố:

```
1. Ngữ cảnh thời gian: ngày hiện tại, thứ trong tuần (bằng tiếng Việt)
2. Quy tắc mapping tiếng Việt → thời gian:
   - "sáng mai"   → [ngày mai] 08:00
   - "chiều nay"  → [hôm nay]  14:00
   - "tối nay"    → [hôm nay]  19:00
   - "tuần sau"   → [thứ Hai tuần sau] 09:00
3. Schema JSON output cụ thể cho từng intent
4. Yêu cầu chỉ trả JSON, không kèm giải thích
```

Tham số `temperature: 0` đảm bảo output **deterministic** — cùng một câu đầu vào luôn cho cùng một kết quả intent.

### 7.3 Hệ Thống Phân Loại Ý Định

Sáu intent được định nghĩa:

| Intent | Mô tả | Entity được trích xuất |
|--------|-------|------------------------|
| `chat` | Hội thoại tự do | Không có |
| `schedule.create` | Tạo lịch hẹn | `title`, `startAt` (ISO8601), `endAt`?, `location`? |
| `schedule.query` | Truy vấn lịch theo ngày | `date` (ISO8601) |
| `reminder.create` | Tạo nhắc nhở | `title`, `scheduledAt`, `repeatRule` |
| `health.log` | Ghi chỉ số sức khỏe | `weightKg`?, `heightCm`?, `systolic`?, `diastolic`?, `heartRate`?, `bloodSugar`? |
| `meal.generate` | Tạo thực đơn | Không có |

**Cơ chế fallback**: khi parse JSON thất bại hoặc response rỗng, hệ thống tự động fallback về intent `chat` thay vì báo lỗi người dùng.

### 7.4 Cá Nhân Hóa AI với PersonaPromptBuilder

`PersonaPromptBuilder` sinh system prompt cho mỗi phiên chat dựa trên dữ liệu thực tế của người dùng. Điều này khác biệt so với các trợ lý thông dụng là AI **biết ngữ cảnh** của người dùng:

**Đầu vào:**
- `UserProfile`: tên, tuổi (tính từ ngày sinh), tính cách chọn (trang trọng/thân thiện/vui vẻ), danh xưng
- `List<Appointment>`: tối đa 5 lịch hẹn sắp tới
- `HealthRecord?`: chỉ số sức khỏe gần nhất (BMI, huyết áp)
- `MealPlan?`: thực đơn hiện tại (nếu có)

**Đầu ra (ví dụ):**
```
Bạn là ButlerX, trợ lý gia đình của anh Minh (35 tuổi, nam).
Hãy xưng hô thân thiện, ấm áp.
Thông tin sức khỏe gần nhất: cân nặng 70kg, chiều cao 170cm,
BMI 24.2 (bình thường), huyết áp 125/82 (bình thường).
Lịch hẹn sắp tới:
- Họp nhóm dự án: ngày mai 14:00 tại Văn phòng
- Khám sức khỏe định kỳ: Thứ Sáu 08:30
Trả lời ngắn gọn, bằng tiếng Việt.
```

### 7.5 Quản Lý API Key

Bảo mật API key là yêu cầu quan trọng. Hệ thống sử dụng `flutter_secure_storage` để lưu key với mã hóa AES trên keychain (iOS) và EncryptedSharedPreferences (Android). Key không bao giờ xuất hiện trong log, không được hardcode trong source code, và chỉ được nạp vào memory khi cần thiết.

---

## 8. Cài Đặt và Triển Khai

### 8.1 Môi Trường Phát Triển

| Thành phần | Phiên bản |
|-----------|---------|
| Flutter SDK | 3.5.0 |
| Dart SDK | 3.5.0 |
| PostgreSQL | 15+ |
| Android Studio / VS Code | Phiên bản mới nhất |
| OpenAI API | GPT-4, GPT-4o-mini |

### 8.2 Cấu Trúc Thư Mục Dự Án

```
lib/
├── main.dart                    # Entry point, khởi tạo timezone, ProviderScope
├── app/
│   ├── app.dart                 # MaterialApp.router với theme và localization
│   └── router.dart              # GoRouter: routes, redirect guards, refreshListenable
│
├── core/
│   ├── agent/                   # Pipeline AI: classifier, router, orchestrator
│   ├── constants/               # AppConstants: keys, API models, sizing tokens
│   ├── database/                # AppDatabase (PostgreSQL) + DAOs
│   └── errors/                  # Sealed exception hierarchy
│
├── features/                    # 8 feature modules (mỗi module = domain/data/presentation)
│   ├── auth/                    # FakeAuthRepository (chuẩn bị Firebase)
│   ├── chat/                    # GPT-4 streaming, persona, conversation history
│   ├── scheduling/              # Appointments, reminder scheduling
│   ├── health/                  # Health records, BMI/BP classification
│   ├── meal_plan/               # AI meal plan generation
│   ├── reminders/               # Repeating reminders, local notifications
│   ├── onboarding/              # First-time setup flow
│   └── settings/                # App settings
│
├── shared/
│   ├── providers/               # stt_provider, tts_provider, theme_provider
│   ├── services/                # SttService, TtsService
│   ├── ui/                      # AppTheme (M3), HomeShell (glassmorphic nav)
│   └── widgets/                 # AgentFab, VoiceAgentOverlay, VoiceWaveform
│
└── l10n/                        # Localization (tiếng Việt)
```

### 8.3 Các Entity Miền Quan Trọng

**UserProfile** — hồ sơ người dùng với cá nhân hóa văn hóa Việt:

```dart
enum AddressTitle { ong, ba, anh, chi, em, chau }   // danh xưng
enum PersonalityTag { formal, warm, playful }        // tính cách AI
enum AgeBand { child, teen, adult, middleAged, elderly }
```

**HealthRecord** — chứa logic phân loại y tế:
- BMI: Gầy (<18.5) / Bình thường (18.5–24.9) / Thừa cân (25–29.9) / Béo phì (≥30)
- Huyết áp: Bình thường (<120/80) / Tăng nhẹ (120–129/<80) / Giai đoạn 1 (130–139/80–89) / Giai đoạn 2 (≥140/≥90)

**Appointment** — bao gồm enum `ReminderOffset` với các mốc: đúng giờ / 5 / 15 / 30 phút / 1 giờ / 1 ngày trước.

### 8.4 Quy Trình Code Generation

Dự án sử dụng hai hệ thống code generation:
- `riverpod_generator`: sinh `XxxProvider` và `_$XxxNotifier` từ annotation `@riverpod`
- `json_serializable`: sinh `fromJson`/`toJson` cho các DTO

Lệnh sinh code:
```bash
dart run build_runner build --delete-conflicting-outputs
```

Các file `*.g.dart` được commit vào version control để đảm bảo CI không cần chạy lại.

### 8.5 Navigation và Auth Guard

**GoRouter** cấu hình với `refreshListenable: _AuthListenable(ref)`. Khi `authNotifierProvider` thay đổi, router tự động đánh giá lại redirect:

```
Trạng thái                     → Redirect
─────────────────────────────────────────
AuthLoading                    → /splash (giữ nguyên)
AuthUnauthenticated            → /login
AuthAuthenticated + !onboarded → /onboarding
AuthAuthenticated + onboarded  → /home/chat
```

---

## 9. Giao Diện Người Dùng

### 9.1 Nguyên Tắc Thiết Kế

Giao diện tuân theo **Material Design 3** với hai điều chỉnh quan trọng cho ngữ cảnh Việt Nam:
1. Font **BeVietnam Pro** (Google Fonts) để đảm bảo hiển thị đúng các dấu tiếng Việt
2. Chế độ **High-Contrast** tăng kích thước chữ 30% và độ tương phản tối đa, hỗ trợ người cao tuổi

### 9.2 Màn Hình Chính

**Splash Screen:** Animation 5 lớp tuần tự trong 2.2 giây (logo scale + fadeIn → tên app slide up → tagline slide up → progress bar → điều hướng). Sử dụng `flutter_animate` với Elastic out curve cho logo.

**HomeShell:** Shell route bao quanh 6 màn hình chính. Bottom navigation bar có hiệu ứng glassmorphism (backdrop blur). FAB trung tâm kích hoạt Voice Agent.

**Jarvis Orb:** Widget hình cầu gradient với animation phản ánh trạng thái AI:

| Trạng thái | Màu | Hiệu ứng |
|-----------|-----|---------|
| `idle` | Xanh lam nhạt | Pulse chậm |
| `listening` | Xanh lá | Pulse nhanh + waveform |
| `thinking` | Vàng cam | Xoay |
| `speaking` | Tím | Gợn sóng |

**Voice Waveform:** `CustomPainter` vẽ 20 thanh sóng âm thanh, cập nhật 60fps theo biên độ thực tế từ STT service.

### 9.3 Các Màn Hình Feature

| Màn hình | Tính năng UI nổi bật |
|---------|---------------------|
| Chat | Bubble chat phân biệt user/AI, streaming text animation |
| Schedule | Danh sách theo ngày, chip phân loại nguồn gốc (tay/giọng) |
| Health | FL Chart timeline biểu đồ các chỉ số, badge phân loại màu |
| Meal Plan | Danh sách 7 ngày cuộn ngang, accordion chi tiết bữa ăn |
| Reminders | List với badge lặp lại, swipe to toggle active |

---

## 10. Kết Quả và Đánh Giá

### 10.1 Tính Năng Đã Hoàn Thành

| Module | Trạng thái | Ghi chú |
|--------|-----------|---------|
| Kiến trúc Clean Architecture | ✅ Hoàn thành | 8 feature modules độc lập |
| Riverpod state management + codegen | ✅ Hoàn thành | 13 providers, sealed states |
| PostgreSQL + 6 bảng, schema auto-init | ✅ Hoàn thành | DAO pattern |
| GPT-4 streaming chat | ✅ Hoàn thành | Token-by-token streaming |
| Intent Classifier (6 intent) | ✅ Hoàn thành | GPT-4o-mini, JSON mode |
| Action Router | ✅ Hoàn thành | Ánh xạ intent → feature |
| STT/TTS tiếng Việt | ✅ Hoàn thành | vi-VN locale |
| PersonaPromptBuilder | ✅ Hoàn thành | Ngữ cảnh sức khỏe + lịch |
| Quản lý lịch hẹn + thông báo | ✅ Hoàn thành | Local notifications, timezone |
| Theo dõi sức khỏe + biểu đồ | ✅ Hoàn thành | FL Chart |
| Kế hoạch bữa ăn AI | ✅ Hoàn thành | 7 ngày, health-aware |
| Nhắc nhở lặp lại | ✅ Hoàn thành | Soft delete |
| Hồ sơ cá nhân + onboarding | ✅ Hoàn thành | Danh xưng, tính cách |
| Material 3 theme (3 chế độ) | ✅ Hoàn thành | Light/dark/high-contrast |
| Localization tiếng Việt | ✅ Hoàn thành | BeVietnam Pro font |

### 10.2 Hạn Chế Hiện Tại

| Hạng mục | Trạng thái | Giải thích |
|---------|-----------|-----------|
| Xác thực thực tế (Firebase) | ⏳ Chuẩn bị | Đang dùng FakeAuthRepository |
| Đồng bộ đa thiết bị | ⏳ Chuẩn bị | Database đang là localhost |
| Test coverage | ⏳ Chuẩn bị | Framework có, chưa có test cases |
| Handwriting recognition | ⏳ Chuẩn bị | Package ML Kit đã khai báo |
| STT trên Windows | ❌ Không hỗ trợ | Phụ thuộc API nền tảng mobile |

### 10.3 Nhận Xét

Hệ thống đã chứng minh tính khả thi của việc tích hợp LLM vào ứng dụng di động để tạo ra trải nghiệm tương tác tự nhiên bằng tiếng Việt. Pipeline intent classification sử dụng GPT-4o-mini với JSON mode tỏ ra hiệu quả và đủ chính xác cho các câu lệnh phổ thông. Kiến trúc Clean Architecture với Riverpod tạo ra codebase có tính modular cao, dễ mở rộng thêm các tính năng mới mà không ảnh hưởng đến module hiện có.

Thách thức chính được nhận ra trong quá trình phát triển là **độ trễ** (latency) của LLM: intent classification mất trung bình 1–2 giây, cộng với thời gian STT ~1 giây, tổng thời gian từ khi người dùng ngừng nói đến khi hành động được thực thi là 2–3 giây — chấp nhận được nhưng chưa tức thời.



