import Foundation

// MARK: - Privacy model (mock state for the panel)
//
// Typed version of the two-axis model in PRIVACY_MODEL.md, just enough to drive
// the panel UI from data (not hardcoded strings). Grounded in the 9 sensitive
// items planted across the mock sources (auto 7 + user 2).
//
//   Axis 1 — WHAT  : .automatic (system recognizes it) | .user (only you know)
//   Axis 2 — HOW LONG : .never | .forever | .days(N)
//
// The user only ever sees TWO buckets: 🛡 Automatic and ✋ Your rules. The
// silent/visible split inside Automatic is an attribution detail (echoSafe),
// never a user-facing choice — see `AutoCategory`.

// MARK: Retention (Axis 2)

enum Retention: Equatable {
    case never            // secrets — storing is itself the breach
    case forever          // durable work context (default)
    case days(Int)        // useful now, noise later — auto-expires

    var label: String {
        switch self {
        case .never:        return "Never stored"
        case .forever:      return "Kept"
        case .days(let n):  return "Forgets after \(n) days"
        }
    }
}

// MARK: Automatic protections (Axis 1 = .automatic)

/// The two categories the system handles on its own. Differ only in attribution
/// (`echoSafe`): secrets are dropped silently; personal items are protected and
/// the user is calmly told. Both are one engine, never a user choice.
enum AutoCategory: String, CaseIterable, Identifiable {
    case secrets          // API keys, passwords, tokens → silent, never stored
    case personal         // health, personal finance, family → kept out + told

    var id: String { rawValue }

    /// Whether the value may ever be echoed back. Secrets: never (re-leaks it).
    var echoSafe: Bool { self == .personal }

    var title: String {
        switch self {
        case .secrets:  return "Secrets"
        case .personal: return "Personal life"
        }
    }

    /// One calm line describing what this category does — the proactive brief.
    var summary: String {
        switch self {
        case .secrets:
            return "Dropped before anything is stored — never echoed back."
        case .personal:
            return "Kept out of your work context, and I tell you when."
        }
    }

    var sfSymbol: String {
        switch self {
        case .secrets:  return "key.fill"
        case .personal: return "heart.text.square"
        }
    }
}

/// One protected item the system caught automatically today. Mirrors a mock
/// `sensitive:{}` block. The `detail` is shown ONLY for `.personal` (echoSafe);
/// for `.secrets` it stays nil — naming the value would re-leak it.
struct AutoItem: Identifiable, Equatable {
    let id = UUID()
    let category: AutoCategory
    let label: String          // what kind of thing ("Doctor's appointment")
    let sourceLabel: String    // where it appeared ("Gmail", "Clipboard")
    var detail: String? = nil  // echo-safe specifics, personal only
}

// MARK: User rules (Axis 1 = .user)

/// A boundary only the user/org knows — authored in plain language, stored as a
/// rule. One rule covers infinite future items. `rule = { what, how-long }`.
struct PrivacyRule: Identifiable, Equatable {
    let id = UUID()
    let what: String           // "anything about the Acorn account"
    var scopeLabel: String?    // optional source scope ("Slack"), nil = all
    var retention: Retention = .forever  // .forever = exclude outright; .days = keep-then-forget

    /// Authored this session (drives the wish→rule materialize animation).
    var justAdded: Bool = false
}

// MARK: The whole panel state

/// Everything the panel renders. One mock instance (Dani's) is the source of
/// truth for the proactive brief AND the rule list — and the wish→rule
/// interaction appends to `rules`, immutably.
struct PrivacyState: Equatable {
    var autoItems: [AutoItem]
    var rules: [PrivacyRule]

    // Derived counts for the brief headline ("3 secrets, 4 personal today").
    var secretsCount: Int { autoItems.filter { $0.category == .secrets }.count }
    var personalCount: Int { autoItems.filter { $0.category == .personal }.count }
    func items(in category: AutoCategory) -> [AutoItem] {
        autoItems.filter { $0.category == category }
    }

    /// Immutable add — returns a new state with the rule appended & flagged new.
    func adding(_ rule: PrivacyRule) -> PrivacyState {
        var r = rule; r.justAdded = true
        return PrivacyState(autoItems: autoItems, rules: rules + [r])
    }
}

// MARK: Mock — Dani Reyes, grounded in the 9 planted sensitive items

extension PrivacyState {
    static let mock = PrivacyState(
        autoItems: [
            // .secrets — detection:auto, type:security (3). No detail (echoSafe=false).
            AutoItem(category: .secrets, label: "API key", sourceLabel: "Clipboard"),
            AutoItem(category: .secrets, label: "Database password", sourceLabel: "Clipboard"),
            AutoItem(category: .secrets, label: "Slack token", sourceLabel: "Slack"),
            // .personal — detection:auto, type:privacy (4). Detail is echo-safe.
            AutoItem(category: .personal, label: "Lab results", sourceLabel: "MyChart",
                     detail: "A health portal you had open mid-workday."),
            AutoItem(category: .personal, label: "Care-team message", sourceLabel: "Chrome",
                     detail: "A message to your care team."),
            AutoItem(category: .personal, label: "Lab-results email", sourceLabel: "Gmail",
                     detail: "A medical notification in your work inbox."),
            AutoItem(category: .personal, label: "Personal banking", sourceLabel: "Screenshot",
                     detail: "A personal banking tab behind a work screenshot."),
        ],
        rules: [
            // ✋ detection:user, type:confidential (2) — the lines Dani drew.
            PrivacyRule(what: "Candidate compensation", scopeLabel: "Slack"),
            PrivacyRule(what: "A teammate's private family situation", scopeLabel: "Meetings"),
        ]
    )
}
