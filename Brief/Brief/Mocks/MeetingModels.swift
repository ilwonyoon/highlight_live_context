import Foundation

// MARK: - Voice source (meetings + transcripts)
// meetings.jsonl mixes two kinds on the same stream: a `meeting` header
// and its `transcript` segments (linked by meetingId). Both share the
// LiveContextEvent envelope.

/// A meeting header event (kind == "meeting").
struct Meeting: LiveContextEvent, Codable, Identifiable, Hashable {
    let id: String
    let source: BriefSourceTag
    let timestamp: Date
    let day: BriefDay
    let title: String
    let durationMin: Int
    let participants: [String]      // cast ids
    let location: String?
    let summary: String
    let transcriptId: String?
    /// Present on the in-progress "today" meeting.
    let status: String?

    private enum CodingKeys: String, CodingKey {
        case id, source, day, title, durationMin, participants, location, summary, transcriptId, status
        case timestamp = "ts"
    }
}

/// A single transcript line within a meeting (kind == "transcript").
struct TranscriptSegment: LiveContextEvent, Codable, Identifiable, Hashable {
    let id: String
    let source: BriefSourceTag
    let timestamp: Date
    let day: BriefDay
    let meetingId: String
    let personId: String            // speaker (cast id)
    let text: String

    private enum CodingKeys: String, CodingKey {
        case id, source, day, meetingId, personId, text
        case timestamp = "ts"
    }
}

/// A meeting paired with its transcript segments, assembled by the loader.
struct MeetingWithTranscript: Identifiable, Hashable {
    var id: String { meeting.id }
    let meeting: Meeting
    let segments: [TranscriptSegment]
}
