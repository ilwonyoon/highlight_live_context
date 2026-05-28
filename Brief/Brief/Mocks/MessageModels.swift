import Foundation

// MARK: - Slack, Gmail, Chrome, GitHub, Cursor sources
// Conversational / activity streams. Each is one event per line.

/// slack.jsonl — a channel message.
struct SlackMessage: LiveContextEvent, SensitiveFlaggable, Codable, Identifiable, Hashable {
    let id: String
    let source: BriefSourceTag
    let timestamp: Date
    let day: BriefDay
    let channel: String
    let personId: String
    let text: String
    let threadId: String?
    let reactions: [SlackReaction]?
    let sensitive: SensitiveFlag?

    private enum CodingKeys: String, CodingKey {
        case id, source, day, channel, personId, text, threadId, reactions, sensitive
        case timestamp = "ts"
    }
}

struct SlackReaction: Codable, Hashable {
    let emoji: String
    let count: Int
}

/// gmail.jsonl — an email in a thread.
struct EmailMessage: LiveContextEvent, SensitiveFlaggable, Codable, Identifiable, Hashable {
    let id: String
    let source: BriefSourceTag
    let timestamp: Date
    let day: BriefDay
    let threadId: String
    let subject: String
    let fromId: String              // cast id (or no-reply sender id)
    let fromName: String?
    let toIds: [String]
    let direction: String           // "sent" | "received"
    let snippet: String
    let labels: [String]
    let unread: Bool
    let sensitive: SensitiveFlag?

    private enum CodingKeys: String, CodingKey {
        case id, source, day, threadId, subject, fromId, fromName, toIds, direction, snippet, labels, unread, sensitive
        case timestamp = "ts"
    }
}

/// chrome.jsonl — a browsing-history visit.
struct ChromeVisit: LiveContextEvent, SensitiveFlaggable, Codable, Identifiable, Hashable {
    let id: String
    let source: BriefSourceTag
    let timestamp: Date
    let day: BriefDay
    let personId: String
    let url: String
    let title: String
    let visitType: String           // "typed" | "link"
    let sensitive: SensitiveFlag?

    private enum CodingKeys: String, CodingKey {
        case id, source, day, personId, url, title, visitType, sensitive
        case timestamp = "ts"
    }
}

/// github.jsonl — a PR/review notification (low volume; Dani is a reviewer).
struct GitHubEvent: LiveContextEvent, Codable, Identifiable, Hashable {
    let id: String
    let source: BriefSourceTag
    let timestamp: Date
    let day: BriefDay
    let kind: String                // pr_opened | pr_merged | review_requested | review_submitted
    let personId: String
    let repo: String
    let prNumber: Int
    let title: String?
    let summary: String
    let url: String
    let state: String?
    let reviewState: String?
    let requestedReviewerId: String?
    let linkedIssue: String?

    private enum CodingKeys: String, CodingKey {
        case id, source, day, kind, personId, repo, prNumber, title, summary, url, state, reviewState, requestedReviewerId, linkedIssue
        case timestamp = "ts"
    }
}

/// cursor.jsonl — a cloud-agent run or a doc edit.
struct CursorEvent: LiveContextEvent, Codable, Identifiable, Hashable {
    let id: String
    let source: BriefSourceTag
    let timestamp: Date
    let day: BriefDay
    let kind: String                // agent_run | doc_edit
    let personId: String
    let summary: String
    // agent_run fields
    let agent: String?
    let repo: String?
    let branch: String?
    let prompt: String?
    let status: String?
    let durationSec: Int?
    let artifacts: [String]?
    // doc_edit fields
    let doc: String?
    let section: String?
    let wordsAdded: Int?

    private enum CodingKeys: String, CodingKey {
        case id, source, day, kind, personId, summary
        case agent, repo, branch, prompt, status, durationSec, artifacts
        case doc, section, wordsAdded
        case timestamp = "ts"
    }
}
