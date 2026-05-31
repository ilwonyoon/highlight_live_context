import Foundation

// MARK: - PrivacyFilter — the filter model for the settings surface
//
// One shape covers both automatic and user filters; only `editable` differs
// (PRIVACY_USER_CONTROL.md §3, P1). A filter is { what to keep out, for how long }
// plus the AI-extracted tags it actually screens on and the count proving it
// works.
//
// This is the doc's "target shape." It deliberately mirrors PrivacyRule
// ({ what→statement, retention→duration }) and will fold into the privacy domain
// later; kept here so the settings UI can be built without racing the domain
// model's owner.

/// How long a filter holds (PRIVACY_USER_CONTROL.md §3 / domain `Retention`).
enum FilterDuration: Equatable {
    case permanent          // never keep it — the strongest stance (all automatic)
    case days(Int)          // keep now, auto-forget after N days (user only)

    /// The card's duration line.
    var label: String {
        switch self {
        case .permanent:     return "Never kept"
        case .days(let n):   return "Forgets after \(n) days"
        }
    }
}

/// One AI-extracted keyword chip — the executable screening unit (P5). Its count
/// makes it falsifiable (P4). Removable in the UI iff the parent filter is editable.
struct FilterTag: Identifiable, Equatable {
    let id = UUID()
    let label: String       // "family", "salary"
    var count: Int          // times THIS tag caught something
}

/// Which layer of the defense-in-depth pipeline this filter operates on.
enum FilterLayer: Equatable {
    case appSite       // Layer 1 — block whole sources (apps, domains) before capture
    case topicKeyword  // Layer 2/3 — screen content by topic or keyword within captures

    var icon: String {
        switch self {
        case .appSite:      return "app.fill"
        case .topicKeyword: return "text.magnifyingglass"
        }
    }

    var label: String {
        switch self {
        case .appSite:      return "APPS & SITES"
        case .topicKeyword: return "TOPICS & KEYWORDS"
        }
    }
}

/// A privacy filter — automatic (read-only) or user-authored (editable).
struct PrivacyFilter: Identifiable, Equatable {
    let id = UUID()
    var statement: String       // the intent, in words (user's wish or a system line)
    var tags: [FilterTag]       // the keyword chips it screens on
    var duration: FilterDuration
    var filteredCount: Int      // how many times this filter caught something (P4)
    var editable: Bool          // ★ the only automatic/user difference
    var active: Bool = true     // user can pause without deleting (automatic always true)
    var layer: FilterLayer = .topicKeyword
}

// MARK: - Capture switches — the pipeline's master + source-block toggles
//
// These integrate Highlight's existing Data & Privacy toggles into the Brief's
// privacy surface, placed by where they sit in the defense-in-depth pipeline
// (PRIVACY_MODEL.md): Screen Context is the master capture switch (top); Secure
// Capture is the Layer-1 automatic source block; Send Telemetry is an orthogonal
// data-sharing control (bottom). Each is just { on/off } here — the policy lives
// in the system; the UI stays a sentence.

/// The three capture/data toggles carried over from Highlight's Data & Privacy.
struct CaptureSettings: Equatable {
    var screenContext: Bool   // master: observe the screen at all
    var secureCapture: Bool   // Layer-1 automatic: block banking/health/auth sources
    var telemetry: Bool       // share anonymized logs so the team can fix problems

    static let dani = CaptureSettings(screenContext: true,
                                      secureCapture: true,
                                      telemetry: true)
}

// MARK: - Mock — Dani Reyes (PRIVACY_USER_CONTROL.md §7)

extension PrivacyFilter {
    /// Automatic filters — read-only, shown for transparency (P2).
    static let automaticMock: [PrivacyFilter] = [
        PrivacyFilter(
            statement: "Secrets — API keys, tokens, passwords",
            tags: [FilterTag(label: "api key", count: 1),
                   FilterTag(label: "token", count: 1),
                   FilterTag(label: "password", count: 1)],
            duration: .permanent,
            filteredCount: 3,
            editable: false),
        PrivacyFilter(
            statement: "Personal health & finance",
            tags: [FilterTag(label: "health", count: 2),
                   FilterTag(label: "finance", count: 1),
                   FilterTag(label: "medical", count: 1)],
            duration: .permanent,
            filteredCount: 4,
            editable: false),
    ]

    /// User-authored filters — editable. (Dani's two planted rules.)
    ///
    /// The first card is the **source-level** block — Highlight's "Privacy Deny
    /// List" (apps & domains), folded into the same filter card. It blocks whole
    /// sources before capture (Layer 1); the keyword filters below it screen
    /// *within* what's allowed (Layer 3). Same card, same section — the tags are
    /// app/domain names instead of keywords.
    static let userMock: [PrivacyFilter] = [
        PrivacyFilter(
            statement: "Never capture these apps & sites",
            tags: [FilterTag(label: "1Password", count: 0),
                   FilterTag(label: "Messages", count: 12),
                   FilterTag(label: "Banking", count: 4),
                   FilterTag(label: "acorn-bank.com", count: 3)],
            duration: .permanent,
            filteredCount: 19,
            editable: true,
            layer: .appSite),
        PrivacyFilter(
            statement: "Don't keep candidate compensation",
            tags: [FilterTag(label: "comp", count: 3),
                   FilterTag(label: "salary", count: 1)],
            duration: .days(30),
            filteredCount: 4,
            editable: true,
            layer: .topicKeyword),
        PrivacyFilter(
            statement: "Keep a teammate's private family situation out",
            tags: [FilterTag(label: "family", count: 1),
                   FilterTag(label: "personal", count: 1)],
            duration: .permanent,
            filteredCount: 2,
            editable: true,
            layer: .topicKeyword),
    ]
}
