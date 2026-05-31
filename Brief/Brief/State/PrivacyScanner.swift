import Foundation

// MARK: - PrivacyScanner — read-only intelligence over the Live Context
//
// Pure functions the privacy assistant uses to be PROACTIVE (surface what it
// already caught) and to SCAN on demand ("take out anything about comp"). It
// only reads the timeline — never mutates. Applying a result goes through the
// normal propose→confirm→PrivacyStore.apply path, so this stays side-effect free
// and unit-testable.

// MARK: Models

/// A data-grounded suggestion the assistant offers up front. Confirming it
/// applies `intent` through the usual store path.
struct ProactiveSuggestion: Identifiable {
    let id: String
    let title: String
    let detail: String
    let intent: PrivacyIntent?      // nil = informational only (no action)
    let confirmLabel: String?
    let matchCount: Int
}

/// The result of scanning the timeline for a topic the user named.
struct ScanResult {
    let query: String
    let items: [TimelineItem]

    var count: Int { items.count }

    /// Per-source counts, highest first — e.g. [(slack, 2), (calendar, 1)].
    var bySource: [(source: BriefSourceTag, count: Int)] {
        Dictionary(grouping: items, by: { $0.source })
            .map { (source: $0.key, count: $0.value.count) }
            .sorted { $0.count > $1.count }
    }

    /// "Slack 2, Calendar 1" — a human breakdown of where matches live.
    var sourceSummary: String {
        bySource.map { "\($0.source.label) \($0.count)" }.joined(separator: ", ")
    }
}

// MARK: Scanner

enum PrivacyScanner {

    // MARK: Proactive — what the assistant caught without being asked

    /// Build up-front suggestions from items the system already flagged
    /// sensitive, grouped into the categories a user reasons about.
    static func proactiveSuggestions(from timeline: [TimelineItem]) -> [ProactiveSuggestion] {
        let flagged = timeline.filter { $0.sensitive != nil }
        guard !flagged.isEmpty else { return [] }

        // Bucket each flagged item into one category (first match wins).
        var buckets: [Category: [TimelineItem]] = [:]
        for item in flagged {
            buckets[category(for: item), default: []].append(item)
        }

        // Emit in a fixed priority order so the briefing reads consistently.
        return Category.allCases.compactMap { cat in
            guard let items = buckets[cat], !items.isEmpty else { return nil }
            return cat.suggestion(count: items.count)
        }
    }

    // MARK: On-demand scan

    /// Find timeline items whose text matches any keyword in `query`.
    static func scan(_ timeline: [TimelineItem], for query: String) -> ScanResult {
        let keywords = keywordize(query)
        guard !keywords.isEmpty else { return ScanResult(query: query, items: []) }
        let hits = timeline.filter { item in
            let text = searchableText(item)
            return keywords.contains { text.contains($0) }
        }
        return ScanResult(query: query, items: hits)
    }

    // MARK: - Hiding (P4) — which timeline items the active filters keep out

    /// The timeline items that the given filters would remove from the work
    /// context: Layer-1 app/site blocks by source, Layer-2/3 topic filters by
    /// keyword. Paused filters are ignored. This is the connection between the
    /// privacy controls and the Live Context — what "filtering" actually hides.
    static func hiddenItems(in timeline: [TimelineItem],
                            under filters: [PrivacyFilter]) -> [TimelineItem] {
        let active = filters.filter { $0.active }
        guard !active.isEmpty else { return [] }

        var seen = Set<String>()
        var hidden: [TimelineItem] = []
        for item in timeline {
            let text = searchableText(item)
            let sourceLabel = item.source.label.lowercased()
            let isHidden = active.contains { filter in
                switch filter.layer {
                case .appSite:
                    return filter.tags.contains { tag in
                        let t = tag.label.lowercased()
                        return !t.isEmpty && (sourceLabel.contains(t) || text.contains(t))
                    }
                case .topicKeyword:
                    return filterKeywords(filter).contains { text.contains($0) }
                }
            }
            if isHidden, seen.insert(item.id).inserted { hidden.append(item) }
        }
        return hidden
    }

    /// Keywords a topic filter screens on: its tag labels plus the significant
    /// words of its statement (boilerplate like "don't keep" stripped).
    private static func filterKeywords(_ filter: PrivacyFilter) -> [String] {
        var words = filter.tags.map { $0.label.lowercased() }
        var statement = filter.statement.lowercased()
        for boilerplate in ["don't keep anything about", "don't keep", "never capture",
                            "don't capture", "keep out", "filter out", "anything about"] {
            statement = statement.replacingOccurrences(of: boilerplate, with: " ")
        }
        words.append(contentsOf: keywordize(statement))
        return words.filter { $0.count >= 3 }
    }

    // MARK: - Category model

    private enum Category: CaseIterable, Hashable {
        case medical, comp, finance, security, personal

        func suggestion(count: Int) -> ProactiveSuggestion {
            switch self {
            case .medical:
                return ProactiveSuggestion(
                    id: "medical",
                    title: "Medical & health details",
                    detail: "I caught \(count) personal health \(count == 1 ? "item" : "items") in your context — including a doctor's appointment on launch morning. These aren't work.",
                    intent: .addTopicFilter(statement: "Don't keep medical or health details"),
                    confirmLabel: "Keep health private",
                    matchCount: count)
            case .comp:
                return ProactiveSuggestion(
                    id: "comp",
                    title: "Compensation & offers",
                    detail: "\(count) \(count == 1 ? "message mentions" : "messages mention") candidate comp and salary bands. Sensitive in a hiring context — easy to leak by accident.",
                    intent: .addTopicFilter(statement: "Don't keep compensation or salary details"),
                    confirmLabel: "Filter comp talk",
                    matchCount: count)
            case .finance:
                return ProactiveSuggestion(
                    id: "finance",
                    title: "Personal finances",
                    detail: "A personal financial milestone (equity vesting) is in your Live Context — not work context.",
                    intent: .addTopicFilter(statement: "Don't keep personal financial details"),
                    confirmLabel: "Keep finances out",
                    matchCount: count)
            case .security:
                return ProactiveSuggestion(
                    id: "security",
                    title: "Leaked credential — already handled",
                    detail: "I automatically removed an API token that was pasted in chat. Nothing for you to do — flagging it for transparency.",
                    intent: nil,
                    confirmLabel: nil,
                    matchCount: count)
            case .personal:
                return ProactiveSuggestion(
                    id: "personal",
                    title: "Personal moments",
                    detail: "\(count) personal \(count == 1 ? "item" : "items") slipped into your work context.",
                    intent: .addTopicFilter(statement: "Don't keep personal, non-work details"),
                    confirmLabel: "Keep them out",
                    matchCount: count)
            }
        }
    }

    private static func category(for item: TimelineItem) -> Category {
        if item.sensitive?.type == .security { return .security }
        let text = searchableText(item)
        if containsAny(text, medicalKeywords) { return .medical }
        if item.sensitive?.type == .confidential { return .comp }
        if containsAny(text, financeKeywords) { return .finance }
        return .personal
    }

    private static let medicalKeywords = [
        "medical", "doctor", "dr.", "physician", "appointment", "lab results",
        "hospital", "clinic", "health", "follow-up call", "patient",
    ]
    private static let financeKeywords = [
        "equity", "vesting", "cliff", "401k", "bank", "carta", "financial",
        "compensation", "salary",
    ]

    // MARK: - Text extraction

    /// A lowercased searchable blob for one timeline item, pulling the text
    /// fields off whichever event it carries, plus any sensitive reason.
    static func searchableText(_ item: TimelineItem) -> String {
        var parts: [String] = []
        switch item.event {
        case .meeting(let m):     parts = [m.title, m.location ?? "", m.summary]
        case .transcript(let t):  parts = [t.text]
        case .slack(let m):       parts = [m.channel, m.text]
        case .email(let m):       parts = [m.subject, m.snippet]
        case .chrome(let v):      parts = [v.title, v.url]
        case .github(let g):      parts = [g.title ?? "", g.summary, g.url]
        case .cursor(let c):      parts = [c.summary]
        case .linear(let l):      parts = [l.title ?? "", l.description ?? "", l.text ?? ""]
        case .clipboard(let c):   parts = [c.text, c.sourceApp ?? ""]
        case .screenshot(let s):  parts = [s.title, s.ocrText, s.capturedApp ?? ""]
        case .chatSession(let s): parts = [s.title, s.summary]
        case .chatMessage(let m): parts = [m.text]
        case .calendar(let e):    parts = [e.title, e.description ?? "", e.location ?? ""]
        }
        if let reason = item.sensitive?.reason { parts.append(reason) }
        return parts.joined(separator: " ").lowercased()
    }

    // MARK: - Keyword helpers

    private static func containsAny(_ text: String, _ keywords: [String]) -> Bool {
        keywords.contains { text.contains($0) }
    }

    /// Reduce a free-text query to significant lowercased keywords, dropping
    /// filler so "take out anything about comp" → ["comp"].
    private static func keywordize(_ query: String) -> [String] {
        let stopwords: Set<String> = [
            "the", "a", "an", "about", "anything", "everything", "all", "any",
            "my", "me", "of", "on", "in", "to", "and", "or", "stuff", "things",
            "remove", "take", "out", "delete", "hide", "keep", "scan", "find",
            "search", "for", "show", "what", "do", "you", "have", "related",
            "please", "everything's", "let's",
        ]
        let tokens = query.lowercased()
            .components(separatedBy: CharacterSet.alphanumerics.inverted)
            .filter { $0.count >= 2 && !stopwords.contains($0) }
        return Array(Set(tokens))
    }
}
