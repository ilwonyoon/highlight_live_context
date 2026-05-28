import Foundation

// MARK: - Live Context store
// Loads the mock Live Context from Resources/Mocks at launch:
//   • 7 hot raw streams (jsonl) → merged, time-sorted timeline
//   • reference data (persona, cast, notion index)
//   • the compressed 2-month history rollup
//
// Storage mirrors how Highlight actually holds raw: one append-only
// stream per Connection (per-source MCP servers), unified at read time.
// See Resources/Mocks/_research-dossier.md and _scenario-spine.md.

/// A type-erased item on the unified timeline (any source's event).
struct TimelineItem: Identifiable, Hashable {
    let id: String
    let source: BriefSourceTag
    let timestamp: Date
    let day: BriefDay
    let event: AnyLiveContextEvent

    /// Sensitive flag, if the underlying event carries one.
    var sensitive: SensitiveFlag? {
        switch event {
        case .slack(let m):  return m.sensitive
        case .email(let m):  return m.sensitive
        case .chrome(let v): return v.sensitive
        default:             return nil
        }
    }
}

/// Box so heterogeneous events can live in one array while staying Hashable.
enum AnyLiveContextEvent: Hashable {
    case meeting(Meeting)
    case transcript(TranscriptSegment)
    case slack(SlackMessage)
    case email(EmailMessage)
    case chrome(ChromeVisit)
    case github(GitHubEvent)
    case cursor(CursorEvent)
    case linear(LinearEvent)
}

@MainActor
final class LiveContextStore: ObservableObject {

    // Reference data
    @Published private(set) var persona: Persona?
    @Published private(set) var cast: CastFile?
    @Published private(set) var notion: NotionRefsFile?
    @Published private(set) var history: HistoryRollup?

    // Hot streams (typed)
    @Published private(set) var meetings: [Meeting] = []
    @Published private(set) var transcripts: [TranscriptSegment] = []
    @Published private(set) var slack: [SlackMessage] = []
    @Published private(set) var email: [EmailMessage] = []
    @Published private(set) var chrome: [ChromeVisit] = []
    @Published private(set) var github: [GitHubEvent] = []
    @Published private(set) var cursor: [CursorEvent] = []
    @Published private(set) var linear: [LinearEvent] = []

    /// All hot events from all sources, merged and sorted ascending by time.
    @Published private(set) var timeline: [TimelineItem] = []

    private(set) var loadErrors: [String] = []

    init(autoload: Bool = true) {
        if autoload { load() }
    }

    // MARK: Lookups

    /// Resolve a cast id to a Person (colleagues, candidates, externals).
    func person(_ id: String?) -> Person? {
        guard let id else { return nil }
        return cast?.byId[id]
    }

    /// Timeline filtered to one day, ascending.
    func timeline(for day: BriefDay) -> [TimelineItem] {
        timeline.filter { $0.day == day }
    }

    /// Meetings paired with their transcript segments (segments time-sorted).
    func meetingsWithTranscripts() -> [MeetingWithTranscript] {
        let byMeeting = Dictionary(grouping: transcripts, by: { $0.meetingId })
        return meetings
            .sorted { $0.timestamp < $1.timestamp }
            .map { m in
                let segs = (byMeeting[m.id] ?? []).sorted { $0.timestamp < $1.timestamp }
                return MeetingWithTranscript(meeting: m, segments: segs)
            }
    }

    /// Linear events grouped by issue key (each group time-sorted).
    func linearByIssue() -> [String: [LinearEvent]] {
        Dictionary(grouping: linear.sorted { $0.timestamp < $1.timestamp },
                   by: { $0.issueKey })
    }

    /// Rare captured items flagged sensitive (security leak / personal privacy),
    /// time-sorted. These are what the brief surfaces for one-tap removal —
    /// the assignment's "delete sensitive moments," inside the ritual.
    func sensitiveItems() -> [TimelineItem] {
        timeline.filter { $0.sensitive != nil }
    }

    // MARK: Load

    func load() {
        loadErrors.removeAll()
        let decoder = Self.makeDecoder()

        // Reference data (single JSON objects)
        persona = decodeObject(PersonaFile.self, "_persona", decoder)?.persona
        cast    = decodeObject(CastFile.self, "_cast", decoder)
        notion  = decodeObject(NotionRefsFile.self, "notion-refs", decoder)
        history = decodeObject(HistoryRollup.self, "history-rollup", decoder)

        // Hot streams (JSONL — one object per line)
        slack  = decodeLines(SlackMessage.self, "slack", decoder)
        email  = decodeLines(EmailMessage.self, "gmail", decoder)
        chrome = decodeLines(ChromeVisit.self, "chrome", decoder)
        github = decodeLines(GitHubEvent.self, "github", decoder)
        cursor = decodeLines(CursorEvent.self, "cursor", decoder)
        linear = decodeLines(LinearEvent.self, "linear", decoder)

        // Voice stream mixes meeting headers + transcript segments.
        loadVoiceStream(decoder)

        rebuildTimeline()
    }

    /// Split meetings.jsonl into the two kinds by their `kind` discriminator.
    private func loadVoiceStream(_ decoder: JSONDecoder) {
        guard let lines = bundleLines("meetings") else { return }
        var ms: [Meeting] = []
        var ts: [TranscriptSegment] = []
        for (i, line) in lines.enumerated() {
            guard let data = line.data(using: .utf8) else { continue }
            // Peek at kind, then decode the right type.
            guard let kind = try? decoder.decode(VoiceKind.self, from: data).kind else {
                loadErrors.append("meetings.jsonl:\(i + 1) missing kind")
                continue
            }
            do {
                switch kind {
                case "meeting":    ms.append(try decoder.decode(Meeting.self, from: data))
                case "transcript": ts.append(try decoder.decode(TranscriptSegment.self, from: data))
                default:           loadErrors.append("meetings.jsonl:\(i + 1) unknown kind \(kind)")
                }
            } catch {
                loadErrors.append("meetings.jsonl:\(i + 1) \(error)")
            }
        }
        meetings = ms
        transcripts = ts
    }

    /// Merge every hot source into one ascending timeline.
    private func rebuildTimeline() {
        var items: [TimelineItem] = []
        func add<E: LiveContextEvent>(_ events: [E], _ box: (E) -> AnyLiveContextEvent) {
            for e in events {
                items.append(TimelineItem(id: e.id, source: e.source,
                                          timestamp: e.timestamp, day: e.day,
                                          event: box(e)))
            }
        }
        add(meetings,    AnyLiveContextEvent.meeting)
        add(transcripts, AnyLiveContextEvent.transcript)
        add(slack,       AnyLiveContextEvent.slack)
        add(email,       AnyLiveContextEvent.email)
        add(chrome,      AnyLiveContextEvent.chrome)
        add(github,      AnyLiveContextEvent.github)
        add(cursor,      AnyLiveContextEvent.cursor)
        add(linear,      AnyLiveContextEvent.linear)
        timeline = items.sorted { $0.timestamp < $1.timestamp }
    }

    // MARK: Decoding helpers

    private struct VoiceKind: Codable { let kind: String }

    private static func makeDecoder() -> JSONDecoder {
        let d = JSONDecoder()
        // Raw timestamps are ISO8601 with offset, e.g. 2026-05-27T09:00:00-07:00.
        // Formatter is built inside the closure so nothing non-Sendable is
        // captured (ISO8601DateFormatter isn't Sendable).
        d.dateDecodingStrategy = .custom { decoder in
            let c = try decoder.singleValueContainer()
            let s = try c.decode(String.self)
            let iso = ISO8601DateFormatter()
            iso.formatOptions = [.withInternetDateTime]
            if let date = iso.date(from: s) { return date }
            throw DecodingError.dataCorruptedError(in: c,
                debugDescription: "Bad ISO8601 date: \(s)")
        }
        return d
    }

    private func decodeObject<T: Decodable>(_ type: T.Type, _ name: String, _ decoder: JSONDecoder) -> T? {
        guard let data = bundleData(name, ext: "json") else {
            loadErrors.append("\(name).json not found in bundle")
            return nil
        }
        do { return try decoder.decode(T.self, from: data) }
        catch { loadErrors.append("\(name).json \(error)"); return nil }
    }

    private func decodeLines<T: Decodable>(_ type: T.Type, _ name: String, _ decoder: JSONDecoder) -> [T] {
        guard let lines = bundleLines(name) else {
            loadErrors.append("\(name).jsonl not found in bundle")
            return []
        }
        var out: [T] = []
        for (i, line) in lines.enumerated() {
            guard let data = line.data(using: .utf8) else { continue }
            do { out.append(try decoder.decode(T.self, from: data)) }
            catch { loadErrors.append("\(name).jsonl:\(i + 1) \(error)") }
        }
        return out
    }

    // MARK: Bundle access

    /// Resources/Mocks is copied as a folder reference, so files live under
    /// a "Mocks" subdirectory of the bundle.
    private func bundleData(_ name: String, ext: String) -> Data? {
        guard let url = Bundle.main.url(forResource: name, withExtension: ext, subdirectory: "Mocks")
            ?? Bundle.main.url(forResource: name, withExtension: ext) else { return nil }
        return try? Data(contentsOf: url)
    }

    private func bundleLines(_ name: String) -> [String]? {
        guard let data = bundleData(name, ext: "jsonl"),
              let text = String(data: data, encoding: .utf8) else { return nil }
        return text
            .split(whereSeparator: \.isNewline)
            .map(String.init)
            .filter { !$0.trimmingCharacters(in: .whitespaces).isEmpty }
    }
}
