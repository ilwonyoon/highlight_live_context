import Foundation

// MARK: - PrivacyIntentParser — keyword-based mock NLP
//
// A shallow pattern-matcher that turns user text into PrivacyIntent cases.
// Deliberately table-driven so it reads as a stand-in for a real model.
// Name→id resolution happens here (needs the store to read current filters),
// so the store's apply() stays a pure, dumb dispatcher.

struct PrivacyIntentParser {

    static func parse(_ text: String, store: PrivacyStore) -> PrivacyIntent {
        let raw = text
        let t = text.lowercased().trimmingCharacters(in: .whitespaces)

        // MARK: Capture toggles

        if matches(t, verbs: ["stop", "turn off", "disable", "don't"], nouns: ["screen", "watching", "capture screen", "screen capture"]) {
            return .setScreenContext(false)
        }
        if matches(t, verbs: ["start", "turn on", "enable", "resume"], nouns: ["screen", "watching", "screen capture"]) {
            return .setScreenContext(true)
        }
        if matches(t, verbs: ["stop", "turn off", "disable", "don't"], nouns: ["telemetry", "share", "sharing", "logs", "analytics"]) {
            return .setTelemetry(false)
        }
        if matches(t, verbs: ["start", "turn on", "enable"], nouns: ["telemetry", "sharing", "logs"]) {
            return .setTelemetry(true)
        }

        // MARK: Pause / resume existing filter

        if let (verb, fragment) = extractVerb(t, verbs: ["pause", "suspend", "disable filter"]) {
            _ = verb
            if let f = store.filter(named: fragment) {
                return .pauseFilter(id: f.id)
            }
        }
        if let (verb, fragment) = extractVerb(t, verbs: ["resume", "re-enable", "reactivate", "unpause"]) {
            _ = verb
            if let f = store.filter(named: fragment) {
                return .resumeFilter(id: f.id)
            }
        }

        // MARK: Remove filter

        if let (_, fragment) = extractVerb(t, verbs: ["delete", "remove", "get rid of"]) {
            if let f = store.filter(named: fragment) {
                return .removeFilter(id: f.id)
            }
        }

        // MARK: Duration update ("forget after N days")

        if let days = extractDays(t) {
            // If a filter name is also present, update its duration
            let knownVerbs = ["block", "never capture", "don't capture", "filter", "keep out",
                              "stop keeping", "don't keep", "filter out"]
            let stripped = stripVerbs(t, verbs: knownVerbs)
            if let f = store.filter(named: stripped) {
                return .updateDuration(id: f.id, duration: .days(days))
            }
            // Otherwise this is ambiguous — fall through to unrecognized
        }

        // MARK: Block app / domain (Layer 1)

        let appVerbs = ["never capture", "don't capture", "block", "exclude", "stop capturing"]
        if let (_, fragment) = extractVerb(t, verbs: appVerbs) {
            let name = fragment.trimmingCharacters(in: .whitespaces)
            if !name.isEmpty {
                return .addAppSite(name: nameCase(name))
            }
        }

        // MARK: Add topic filter (Layer 2/3)

        let topicVerbs = ["stop keeping", "don't keep", "filter out", "keep out",
                          "never keep", "hide anything about", "don't store"]
        if let (_, fragment) = extractVerb(t, verbs: topicVerbs) {
            let statement = buildStatement(fragment)
            if !statement.isEmpty {
                return .addTopicFilter(statement: statement)
            }
        }

        return .unrecognized(raw: raw)
    }

    // MARK: - Scan detection (P3)
    //
    // A scan request is "show me / take out everything about X" — the user wants
    // the assistant to SWEEP the Live Context and report what it found before any
    // filter is applied. Returns the cleaned topic, or nil if this isn't a scan.
    // Checked by the scenario BEFORE parse(), so it routes to a results card
    // instead of a blind propose.

    private static let scanTriggers = [
        "everything about", "anything about", "everything related to",
        "anything related to", "all about", "scan for", "search for",
        "look for", "find everything", "find anything", "find all",
        "what do you have about", "what do you have on",
        "sweep", "scan", "전부 빼", "다 빼", "모두 빼", "빼줘", "빼 줘",
        "지워줘", "찾아줘", "찾아",
    ]

    static func scanQuery(_ text: String) -> String? {
        let t = text.lowercased().trimmingCharacters(in: .whitespaces)
        guard scanTriggers.contains(where: { t.contains($0) }) else { return nil }

        // Strip the trigger phrases + a little filler to recover the bare topic.
        var topic = t
        for trigger in scanTriggers.sorted(by: { $0.count > $1.count }) {
            topic = topic.replacingOccurrences(of: trigger, with: " ")
        }
        for filler in ["take out", "remove", "delete", "hide", "keep out",
                       "anything", "everything", "all", "stuff", "talk", "얘기",
                       "관련", "관련된", "내용", "다", "모두", "전부", "please"] {
            topic = topic.replacingOccurrences(of: filler, with: " ")
        }
        topic = topic
            .components(separatedBy: .whitespacesAndNewlines)
            .filter { !$0.isEmpty }
            .joined(separator: " ")
            .trimmingCharacters(in: .whitespaces)
        return topic.isEmpty ? nil : topic
    }

    // MARK: - Helpers

    private static func matches(_ text: String, verbs: [String], nouns: [String]) -> Bool {
        let hasVerb = verbs.contains { text.contains($0) }
        let hasNoun = nouns.contains { text.contains($0) }
        return hasVerb && hasNoun
    }

    // Returns (matched verb, remainder after verb)
    private static func extractVerb(_ text: String, verbs: [String]) -> (String, String)? {
        for verb in verbs.sorted(by: { $0.count > $1.count }) {  // longest first
            if let range = text.range(of: verb) {
                let remainder = String(text[range.upperBound...])
                    .trimmingCharacters(in: .whitespaces)
                return (verb, remainder)
            }
        }
        return nil
    }

    private static func extractDays(_ text: String) -> Int? {
        // "after 7 days", "for 30 days", "7 days"
        let pattern = #"(?:after|for)?\s*(\d+)\s+days?"#
        guard let regex = try? NSRegularExpression(pattern: pattern),
              let match = regex.firstMatch(in: text, range: NSRange(text.startIndex..., in: text)),
              let range = Range(match.range(at: 1), in: text) else { return nil }
        return Int(text[range])
    }

    private static func stripVerbs(_ text: String, verbs: [String]) -> String {
        var result = text
        for verb in verbs {
            result = result.replacingOccurrences(of: verb, with: "")
        }
        return result.trimmingCharacters(in: .whitespaces)
    }

    // "slack" → "Slack", "acorn-bank.com" stays lowercase
    private static func nameCase(_ s: String) -> String {
        s.contains(".") ? s : s.prefix(1).uppercased() + s.dropFirst()
    }

    // "anything about salary and comp" → "Don't keep anything about salary and comp"
    private static func buildStatement(_ fragment: String) -> String {
        let f = fragment.trimmingCharacters(in: .whitespaces)
        guard !f.isEmpty else { return "" }
        return "Don't keep \(f)"
    }
}
