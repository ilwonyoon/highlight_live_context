import Foundation

// MARK: - Reference data (not event streams)
// Persona, cast, Notion doc index, and the compressed 2-month history
// rollup. These are static objects the Brief reads for context, not
// minute-level events.

// MARK: Persona (_persona.json)

struct PersonaFile: Codable {
    let persona: Persona
}

struct Persona: Codable, Identifiable {
    let id: String
    let name: String
    let role: String
    let company: String
    let pronouns: String
    let location: String
    let currentGoal: PersonaGoal
    let timeline: PersonaTimeline
}

struct PersonaGoal: Codable {
    let headline: String
    let launchDate: String
    let launchLabel: String
    let today: String
    let daysToLaunch: Int
    let countdownLabel: String
    let subGoals: [PersonaSubGoal]
}

struct PersonaSubGoal: Codable, Identifiable {
    let id: String
    let label: String
    let detail: String
    let weight: String              // "primary" | "secondary"
}

struct PersonaTimeline: Codable {
    let days: [PersonaDay]
    let heroMoments: [String]
}

struct PersonaDay: Codable, Identifiable {
    var id: String { dayId }
    let dayId: String
    let date: String
    let weekday: String
    let label: String
    let approxHours: Int
    let heroSurface: String
}

// MARK: Cast (_cast.json)

struct CastFile: Codable {
    let colleagues: [Person]
    let candidates: [Person]
    let externalContacts: [Person]

    /// Flat lookup of everyone by id.
    var byId: [String: Person] {
        var map: [String: Person] = [:]
        for p in colleagues + candidates + externalContacts { map[p.id] = p }
        return map
    }
}

struct Person: Codable, Identifiable, Hashable {
    let id: String
    let name: String
    let role: String
    let initials: String?
    let email: String?
    let slackHandle: String?
    // optional flavor fields present on some entries
    let real: Bool?
    let relationToDani: String?
    let forRole: String?
    let stage: String?
    let background: String?
}

// MARK: Notion reference index (notion-refs.json)

struct NotionRefsFile: Codable {
    let workspace: String
    let docs: [NotionDoc]
}

struct NotionDoc: Codable, Identifiable, Hashable {
    let id: String
    let title: String
    let space: String
    let owner: String
    let url: String
    let lastEditedBy: String
    let lastEdited: String
    let summary: String
}

// MARK: Long-term history rollup (history-rollup.json)

struct HistoryRollup: Codable {
    let kind: String
    let personId: String
    let window: HistoryWindow
    let atAGlance: HistoryAtAGlance
    let productThinkingEvolution: [HistoryPhase]
    let relationships: [HistoryRelationship]
    let networkShape: String
    let recurringPatterns: [HistoryPattern]
}

struct HistoryWindow: Codable {
    let start: String
    let end: String
    let weeks: Int
    let label: String
}

struct HistoryAtAGlance: Codable {
    let tenureWeeks: Int
    let role: String
    let joinContext: String
    let arc: String
    let dominantThread: String
}

struct HistoryPhase: Codable, Identifiable {
    var id: String { phase }
    let phase: String
    let label: String
    let weeks: String
    let summary: String
}

struct HistoryRelationship: Codable, Identifiable {
    var id: String { personId }
    let personId: String
    let tie: String
    let summary: String
}

struct HistoryPattern: Codable, Identifiable {
    let id: String
    let label: String
    let detail: String
    let hotEcho: String?
}
