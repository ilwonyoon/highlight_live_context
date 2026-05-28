import Foundation

// MARK: - Live Context event protocol
// Every raw event from any Connection shares a common envelope:
// a stable id, the source it came from, a timestamp, and which day it
// belongs to. Source-specific payloads live on the concrete types
// (Meeting, SlackMessage, …). The loader merges all sources into one
// time-sorted timeline via this protocol.
// See Resources/Mocks/_research-dossier.md for why storage is per-source.

/// Which day of the scenario an event belongs to.
/// `prior` = a few setup events that predate the two-day hot window
/// (e.g. Linear issues created on 5/25–5/26).
enum BriefDay: String, Codable, Hashable, CaseIterable {
    case prior
    case day1
    case day2
}

/// Common envelope shared by every raw event across all sources.
/// `source` is a `BriefSourceTag` (superset of BriefSource that also
/// covers chrome). Defined below.
protocol LiveContextEvent {
    var id: String { get }
    var source: BriefSourceTag { get }
    var timestamp: Date { get }
    var day: BriefDay { get }
}

// MARK: - Sensitive flag
// A few rare events carry captured data that shouldn't persist: an
// accidental secret leak (security) or personal life bleeding into work
// capture (privacy). The system surfaces these for one-tap removal during
// the brief — the assignment's "delete sensitive moments" verb, living
// inside the ritual rather than in a separate privacy panel.

enum SensitiveKind: String, Codable, Hashable {
    case security   // a credential / secret captured by accident
    case privacy    // personal (e.g. medical) content that isn't work
}

enum SensitiveAction: String, Codable, Hashable {
    case forget     // remove from Live Context
    case rotate     // (security) also advise rotating the leaked credential
}

struct SensitiveFlag: Codable, Hashable {
    let type: SensitiveKind
    let reason: String
    let suggestedAction: SensitiveAction
    /// Extra advice beyond the primary action (e.g. "rotate token").
    let alsoAdvise: String?

    private enum CodingKeys: String, CodingKey {
        case type, reason, suggestedAction, alsoAdvise
    }
}

/// Events that may carry a sensitive flag conform to this.
protocol SensitiveFlaggable {
    var sensitive: SensitiveFlag? { get }
}

// MARK: - BriefSource decoding

// Raw streams carry `source` as a lowercase string ("voice", "slack",
// "chrome", …). BriefSource already enumerates the 8 Connections; we add
// `chrome` here as the 9th raw source (browsing history), which is a raw
// signal rather than a branded Connection card.
//
// To avoid editing the design-system enum, the loader maps the raw
// `source` string through `BriefSourceTag` below, which is a superset of
// BriefSource that includes chrome.

/// Superset of BriefSource that also covers `chrome` (raw browsing history).
/// Decoded from the `source` field of every raw event.
enum BriefSourceTag: String, Codable, Hashable, CaseIterable {
    case voice
    case gmail
    case github
    case notion
    case docs
    case slack
    case linear
    case cursor
    case chrome

    /// The design-system BriefSource, when one exists (everything except chrome).
    var briefSource: BriefSource? { BriefSource(rawValue: rawValue) }

    var label: String {
        if let s = briefSource { return s.label }
        return "Chrome"
    }
}
