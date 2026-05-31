import Foundation

// MARK: - PrivacyIntent — the chat command vocabulary
//
// Every action the privacy assistant can take maps to one case. The parser
// (PrivacyIntentParser) produces these; the store (PrivacyStore.apply) consumes
// them. Keeping parse and apply separate means the store is deterministic and
// easily unit-tested independent of NLP quality.

enum PrivacyIntent: Equatable {
    // Layer 1 — block whole sources before capture
    case addAppSite(name: String)

    // Layer 2/3 — screen by topic or keyword within captures
    case addTopicFilter(statement: String)
    case addTag(label: String, toFilter: UUID)

    // Lifecycle on an existing filter
    case removeFilter(id: UUID)
    case pauseFilter(id: UUID)
    case resumeFilter(id: UUID)
    case updateStatement(id: UUID, text: String)
    case updateDuration(id: UUID, duration: FilterDuration)

    // Capture toggles
    case setScreenContext(Bool)
    case setSecureCapture(Bool)
    case setTelemetry(Bool)

    // Parser couldn't match — store does nothing, chat shows a clarification
    case unrecognized(raw: String)
}
