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

/// A privacy filter — automatic (read-only) or user-authored (editable).
struct PrivacyFilter: Identifiable, Equatable {
    let id = UUID()
    var statement: String       // the intent, in words (user's wish or a system line)
    var tags: [FilterTag]       // the keyword chips it screens on
    var duration: FilterDuration
    var filteredCount: Int      // how many times this filter caught something (P4)
    var editable: Bool          // ★ the only automatic/user difference
    var active: Bool = true     // user can pause without deleting (automatic always true)
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
    static let userMock: [PrivacyFilter] = [
        PrivacyFilter(
            statement: "Don't keep candidate compensation",
            tags: [FilterTag(label: "comp", count: 3),
                   FilterTag(label: "salary", count: 1)],
            duration: .days(30),
            filteredCount: 4,
            editable: true),
        PrivacyFilter(
            statement: "Keep a teammate's private family situation out",
            tags: [FilterTag(label: "family", count: 1),
                   FilterTag(label: "personal", count: 1)],
            duration: .permanent,
            filteredCount: 2,
            editable: true),
    ]
}
