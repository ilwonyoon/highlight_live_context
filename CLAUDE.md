# Brief — project instructions

## Interaction

- **Do NOT use the AskUserQuestion tool in this repo.** When you need a
  decision from Ilwon, just write the options/question inline in your reply as
  plain text and let him answer in chat. No multiple-choice tool UI.
- Answer in Korean, keep responses short and direct.

## Project

SwiftUI macOS app (`Brief/`) for the Highlight take-home — reframed as the
**Brief**, a Chief-of-Staff briefing surface over the user's **Live Context**.

```bash
# Build
cd Brief && xcodegen generate
xcodebuild -project Brief.xcodeproj -scheme Brief -configuration Debug \
  -destination 'platform=macOS' -derivedDataPath /tmp/brief-dd build

# Run
open /tmp/brief-dd/Build/Products/Debug/BriefPrivacy.app
```

Design decisions, naming, scope, and window-chrome rules live in the auto-memory
under `~/.claude/projects/-Users-ilwonyoon-Documents-highlight-live-context/memory/`.

---

## Work Log

### Session 2026-05-31 — Privacy Settings + Chat Bridge

#### 완료된 작업

**Privacy Settings UI (`Brief/Brief/Views/`)**
- `PrivacySettingsView.swift` — 완전 재구성
  - 타이틀: "Data & Privacy"
  - 섹션: CAPTURE → BLOCKED APPS & SITES → FILTERS → DATA SHARING
  - BLOCKED APPS & SITES: 별도 listBox 컨테이너
  - FILTERS: automatic (lock) 상단 고정, user editable 아래, "+ Add a filter" 맨 하단
  - listDivider: 0.5pt Rectangle, opacity 40%, horizontal inset
- `FilterCard.swift`
  - `inList: Bool` — listBox 안에서는 card background 안 그림
  - `lock.fill` 아이콘 — `editable == false` 인 automatic 필터에 표시
  - statement font: `.bodySmall` (13pt)
  - `AppSiteRow` — apps & sites expanded 시 macOS settings 스타일 행
  - vertical padding: `inList ? .md : .xl`
- `CaptureToggleRow.swift` — title font `.bodyMedium` 복원
- `SecureCaptureDetail.swift` — 완전 재작성
  - `SecureCaptureVariation` enum: `.A` (scan line sweep), `.D` (border trace)
  - B/C 기각됨
  - 애니메이션 state가 outer VStack에 있어서 expanded 영역 전체에 적용
  - "What's protected?" disclosure가 "Always on" 자리에 (trailing)
  - `SecureCaptureBannerTestView` — 사이드바 "Banner Test" 항목
- `PrivacyFilter.swift`
  - `FilterLayer` enum: `.appSite` / `.topicKeyword`
  - `PrivacyFilter`에 `layer` 프로퍼티 추가
  - `CaptureSettings` struct 추가

**State Substrate (`Brief/Brief/State/`)**
- `PrivacyStore.swift` — ObservableObject, single source of truth
  - `@Published var userFilters`, `capture`, `newlyAddedID`
  - `let automaticFilters` (read-only, never mutated)
  - add/remove/update/pause/resume/capture toggle 메서드
  - `apply(_ intent:) -> PrivacyActionResult`
- `PrivacyIntent.swift` — chat 명령 vocabulary enum
- `PrivacyIntentParser.swift` — keyword-based mock NLP
  - `parse(_ text:, store:) -> PrivacyIntent`

**Chat Bridge (`Brief/Brief/Chat/`)**
- `PrivacyScenario.swift` — 완전 재작성
  - `init(store: PrivacyStore)` — store 주입
  - `respond(to:)` — parser → PrivacyProposal 카드 반환 (직접 apply 안 함)
  - `confirm(_ action:)` — 사용자 확인 후 `store.apply(intent)`
  - `CurrentStateCard` — opening brief에 현재 상태 요약
  - `ProposalCard` — 영향 설명 + confirm 버튼
- `PrivacyWindowController.swift`
  - `configure(store:)` 메서드 추가 — LiveContextView에서 주입
- `LiveContextView.swift`
  - `@StateObject var privacyStore = PrivacyStore()`
  - `.onAppear { PrivacyWindowController.shared.configure(store: privacyStore) }`
  - `PrivacySettingsView(store: privacyStore)` 주입
  - `ContextView.secureCaptureTest` — Banner Test 사이드바 항목

**Mock Data (`Brief/Brief/Resources/Mocks/`)**
- `calendar.jsonl` (신규)
  - 12개 이벤트: work(standup, 1:1, hiring, launch) + personal(sensitive)
  - Dr. Patel follow-up (day1 저녁) — auto-detected medical
  - Carta vesting cliff (Jun 1) — auto-detected financial
  - Naomi onsite Tue Jun 3 + Wed Jun 4 (런칭 5일 전)
  - **Dr. Patel results review Jun 9 11am** — 런칭 당일 의료 예약 (핵심 demo moment)
- `slack.jsonl` — Slack DM 추가
  - `dm:sergei`: Naomi comp ($215k + 0.4%) 협상 4개 메시지 (confidential)
  - `dm:sarah`: Vasudev 가족 상황 relay + Naomi 온사이트 logistics
- Swift 모델: `CalendarEvent` struct + `BriefSourceTag.calendar` + Store wiring

---

## 다음에 이어갈 작업 (Priority 순)

### P0 — Secure Capture 배너 variation 확정
- Banner Test 사이드바에서 A vs D 비교
- A: 다크 + scan line sweep + shield pulse
- D: 다크 + border trace + shield pulse
- **결정 후**: `PrivacySettingsView`의 `SecureCaptureBanner()` 호출에 variation 고정

### P1 — Privacy Chat 진입점별 context 설계 + 구현
설계 합의된 내용:
```swift
enum PrivacyChatEntry {
    case global          // 방패 아이콘 / Live Context
    case addAppSite      // "+ Add app or site" 버튼
    case addTopicFilter  // "+ Add a filter" 버튼
    case editFilter(id: UUID)  // 특정 filter row
}
```
- `PrivacyWindowController.present(entry:)` 오버로드
- `PrivacyScenario.init(store:, entry:)` — 진입점별 opening + placeholder
- 각 Add 버튼 → `PrivacyWindowController.shared.present(entry: .addAppSite)` 연결

### P2 — Proactive AI suggestions (데이터 기반 먼저 제안)
새로 추가한 mock 데이터 활용:
- **Dr. Patel Jun 9** → "런칭 당일 오전 11시 의료 예약 있어요. 팀에 공유하거나 일정 조정할까요?"
- **Naomi onsite Jun 3-4** → "런칭 5일 전 3시간씩 온사이트. 런칭 번다운과 겹쳐요."
- **Slack DM comp** → "Sergei DM에서 Naomi 연봉 정보 감지. 'Candidate comp' 필터에 추가할까요?"
- **Carta vesting** → "주식 베스팅 일정이 Live Context에 있어요. 개인 금융 정보 — 필터링할까요?"

구현 위치: `PrivacyScenario.openingTurns()`에 `proactiveSuggestions()` 추가

### P3 — User-initiated scan 시나리오
"투자 라운드 얘기 다 빼줘" → AI가 실제 데이터 스캔 → "Slack 2건, 미팅 1건에서 찾았어요" 형식
- `PrivacyIntentParser`에서 scan intent 추가
- `PrivacyStore`에 `scan(for:) -> [TimelineItem]` (LiveContextStore 연결 필요)

### P4 — LiveContextStore ↔ PrivacyStore 연결
현재: 두 store가 독립적
목표: PrivacyStore가 필터링 적용 시 LiveContextStore timeline에서 해당 항목 숨김
- `LiveContextView`에서 두 store를 같이 들고 있어서 연결 가능
- `PrivacyStore.apply(.addAppSite("Slack"))` → `LiveContextStore`에서 source==slack 항목 hide

---

## 파일 구조 (현재 상태)

```
Brief/
├── Brief.xcodeproj          # xcodegen generate로 재생성
├── project.yml              # xcodegen 설정
└── Brief/
    ├── BriefApp.swift
    ├── Chat/
    │   ├── ChatPanel.swift
    │   ├── ChatPanelSession.swift
    │   ├── EchoScenario.swift
    │   ├── PanelComposer.swift
    │   ├── PanelRoute.swift
    │   ├── PanelScenario.swift
    │   └── PrivacyScenario.swift     ← store 주입, propose→confirm 플로우
    ├── DesignSystem/                 ← BriefFont, BriefColor, tokens 등
    ├── Mocks/                        ← Swift 모델 (LiveContextStore, CaptureModels 등)
    ├── Resources/
    │   └── Mocks/                    ← .jsonl raw data
    │       ├── calendar.jsonl        ← 신규
    │       ├── slack.jsonl           ← DM 추가됨
    │       └── ...
    ├── State/
    │   ├── PrivacyIntent.swift       ← 신규
    │   ├── PrivacyIntentParser.swift ← 신규
    │   └── PrivacyStore.swift        ← 신규
    └── Views/
        ├── LiveContextView.swift     ← privacyStore StateObject + onAppear wiring
        ├── PrivacyFilter.swift       ← FilterLayer enum 추가
        ├── PrivacySettingsView.swift ← store 주입, 두 컨테이너 구조
        ├── FilterCard.swift          ← inList, lock icon, AppSiteRow
        ├── CaptureToggleRow.swift    ← 신규
        ├── SecureCaptureDetail.swift ← A/D variations, Banner Test page
        ├── PrivacyWindowController.swift ← configure(store:) 추가
        └── ...
```
