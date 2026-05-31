import Foundation

// MARK: - Clipboard, Screenshot, Chat sources
// These three round out the capture picture beyond the auto-synced
// Connections:
//   • clipboard — text the user copied; the system captures it. The most
//     natural place a secret leaks in (passwords, keys, connection strings).
//   • screenshot — captures the user took themselves (active, vs. chrome's
//     passive byproduct), represented as OCR'd text since we have no images.
//   • chat — the user's direct conversations with Highlight (the "interact
//     with AI" core). Session header + turns, like meetings + transcripts.

/// clipboard.jsonl — a copied text snippet captured by the system.
struct ClipboardEntry: LiveContextEvent, SensitiveFlaggable, Codable, Identifiable, Hashable {
    let id: String
    let source: BriefSourceTag
    let timestamp: Date
    let day: BriefDay
    let personId: String
    let text: String
    let charCount: Int
    let sourceApp: String?
    let sensitive: SensitiveFlag?

    private enum CodingKeys: String, CodingKey {
        case id, source, day, personId, text, charCount, sourceApp, sensitive
        case timestamp = "ts"
    }
}

/// screenshot.jsonl — a user-captured screenshot, stored as OCR text.
struct ScreenshotCapture: LiveContextEvent, SensitiveFlaggable, Codable, Identifiable, Hashable {
    let id: String
    let source: BriefSourceTag
    let timestamp: Date
    let day: BriefDay
    let personId: String
    let title: String
    let ocrText: String
    let capturedApp: String?
    let sensitive: SensitiveFlag?

    private enum CodingKeys: String, CodingKey {
        case id, source, day, personId, title, ocrText, capturedApp, sensitive
        case timestamp = "ts"
    }
}

// MARK: Calendar

/// calendar.jsonl — a calendar event captured via Google Calendar sync.
struct CalendarEvent: LiveContextEvent, SensitiveFlaggable, Codable, Identifiable, Hashable {
    let id: String
    let source: BriefSourceTag
    let timestamp: Date
    let day: BriefDay
    let title: String
    let startTs: Date
    let endTs: Date
    let durationMin: Int
    let organizer: String?
    let attendees: [String]
    let location: String?
    let status: String          // "confirmed" | "tentative" | "cancelled"
    let calendarId: String      // "work" | "personal"
    let description: String?
    let sensitive: SensitiveFlag?

    private enum CodingKeys: String, CodingKey {
        case id, source, day, title, startTs, endTs, durationMin,
             organizer, attendees, location, status, calendarId, description, sensitive
        case timestamp = "ts"
    }

    var isPersonal: Bool { calendarId == "personal" }
}

// MARK: Chat (user ↔ Highlight)

/// A chat session header (kind == "session").
struct ChatSession: LiveContextEvent, Codable, Identifiable, Hashable {
    let id: String
    let source: BriefSourceTag
    let timestamp: Date
    let day: BriefDay
    let title: String
    let turnCount: Int
    let summary: String

    private enum CodingKeys: String, CodingKey {
        case id, source, day, title, turnCount, summary
        case timestamp = "ts"
    }
}

/// A single chat turn (kind == "message"). `personId` is set on user turns.
struct ChatMessage: LiveContextEvent, Codable, Identifiable, Hashable {
    let id: String
    let source: BriefSourceTag
    let timestamp: Date
    let day: BriefDay
    let sessionId: String
    let role: String                // "user" | "assistant"
    let personId: String?
    let text: String

    private enum CodingKeys: String, CodingKey {
        case id, source, day, sessionId, role, personId, text
        case timestamp = "ts"
    }
}

/// A chat session paired with its turns, assembled by the loader.
struct ChatSessionWithMessages: Identifiable, Hashable {
    var id: String { session.id }
    let session: ChatSession
    let messages: [ChatMessage]
}
