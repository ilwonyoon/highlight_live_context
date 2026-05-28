import Foundation

// MARK: - Linear source (launch-blocker view)
// linear.jsonl has three kinds on one stream: issue / comment / status_change.
// Dani watches Linear through a launch-blocker lens, so issues carry
// priority + state; comments/status changes track how blockers move.

struct LinearEvent: LiveContextEvent, Codable, Identifiable, Hashable {
    let id: String
    let source: BriefSourceTag
    let timestamp: Date
    let day: BriefDay
    let kind: String                // issue | comment | status_change
    let issueKey: String
    // issue fields
    let title: String?
    let project: String?
    let cycle: String?
    let priority: String?
    let state: String?
    let assigneeId: String?
    let reporterId: String?
    let labels: [String]?
    let description: String?
    let url: String?
    // comment fields
    let personId: String?
    let text: String?
    // status_change fields
    let from: String?
    let to: String?
    let field: String?              // "priority" | "state"

    private enum CodingKeys: String, CodingKey {
        case id, source, day, kind, issueKey
        case title, project, cycle, priority, state, assigneeId, reporterId, labels, description, url
        case personId, text
        case from, to, field
        case timestamp = "ts"
    }
}
