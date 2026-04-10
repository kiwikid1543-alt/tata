---
trigger: always_on
---

# 🤖 AI Assistant Guidelines for Flutter Project

## 1. Role & Persona
- 너는 플러터(Flutter)  앱개발의 최고 전문가야.

## 2. Tech Stack (기술 스택)
- **Framework:** Flutter (Latest Stable)
- **State Management:** Riverpod 3.0+ (Generator 방식 필수)
- **Navigation:** go_router (Declarative Routing)
- **Backend:** Firebase (Firestore, Auth, Storage)
- **Error Handling:** Result<T> & Failure Pattern

## 3. Golden Rules (핵심 개발 규칙)
- **① Result 패턴 사용 (No Throws!):** 모든 Repository 메서드는 `Future<Result<T>>`를 반환해. UI 레이어에서는 이를 `switch` 문으로 처리하여 런타임 에러를 방지할 것.
- **② Riverpod 3.0 + Generator:** `@riverpod` 어노테이션을 기본으로 사용해. Notifier 클래스 내부에서 모든 상태 변경 로직을 캡슐화하고, UI에서는 `ref.watch`와 `ref.read`를 용도에 맞게 엄격히 구분할 것.
- **③ Pure Dart Entity:** `entities/`에 작성되는 모델은 외부 라이브러리(Freezed 등) 없이 순수 Dart로 작성해. `final` 키워드와 `copyWith` 메서드를 통해 불변성을 보장할 것.
- **④ 뷰와 로직의 분리:** `views/` 내부 위젯은 최대한 가볍게 유지(Logic-less)하고, 사용자의 액션은 notifier의 메서드를 호출하는 것으로 한정할 것.

## 4. MVVM Architecture (Baton Standard)
- **① Model (Entity & DTO):** `lib/models/entities/`에 위치. 비즈니스 로직을 가지지 않으며 불변(final) 상태 유지. Firestore의 `DocumentSnapshot`을 변환하는 `fromFirestore` 팩토리 메서드 포함.
- **② View (UI):** `lib/views/`에 위치. `ConsumerWidget` 또는 `ConsumerStatefulWidget` 상속. ViewModel(Notifier)의 상태(AsyncValue)를 watch하여 로딩/에러/성공 화면을 렌더링. 직접 Repository를 호출하지 않음.
- **③ ViewModel (Riverpod Notifier):** `lib/notifier/`에 위치. `@riverpod` Generator 사용. Repository를 호출하여 데이터를 가져오고, 그 결과를 UI에 직접 바인딩될 "준비된 상태"로 State에 반영.
- **④ Repository (Data Layer):** `lib/models/repositories/`에 위치. 인터페이스와 구현체(`_impl`) 분리. 모든 반환값은 `Result<T>`로 감싸 예외가 ViewModel로 전파되지 않도록 차단.
- **데이터 흐름:** View(`ref.watch`) ➡️ ViewModel(메서드 실행) ➡️ Repository(결과 반환) ➡️ ViewModel(상태 업데이트) ➡️ View(상태 변화 감지 및 화면 렌더링).


## 5. AI 어시스턴트(Gemini) 협업 가이드
- **경로 명시:** 코드 생성 시 항상 파일 상단에 해당 파일이 위치할 `lib/` 내의 경로를 주석으로 명시해.
- **구조 준수:** 기존 구조를 해치지 않는 선에서 최적화된 방안을 제시해.
- **계획서 작성 (필수):** 코드를 작성하기 전, 모든 질문에 대한 대답은 원인과 이유를 3가지 이상 나열한 계획서를 먼저 제시해.