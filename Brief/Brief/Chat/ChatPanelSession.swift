import SwiftUI
import Observation

// MARK: - ChatPanelSession — the shared state behind a chat panel
//
// Owns the conversation: the scenario, the thread of turns, the nav stack, the
// composer draft, and the thinking flag — plus the loop (seed / send / confirm).
//
// Pulled out of ChatPanel so TWO surfaces can share one conversation: the
// conversation panel (header + thread) and a SEPARATE input window (composer).
// Both observe and mutate the same ChatSession, so a message typed in the input
// window appears in the thread.
//
// See PRIVACY_EXECUTION.md §3-§4.

/// One turn with a stable id (PanelTurn is a plain enum). Lets the thread diff
/// and lets us record which turns have already streamed.
struct IdentifiedTurn: Identifiable {
    let id = UUID()
    let turn: PanelTurn
}

@MainActor
@Observable
final class ChatPanelSession {
    let scenario: any PanelScenario

    var nav = PanelNavStack()
    var turns: [IdentifiedTurn] = []
    var streamedIDs: Set<UUID> = []
    var draft = ""
    var isThinking = false

    private var seeded = false

    init(scenario: any PanelScenario) {
        self.scenario = scenario
    }

    // MARK: Loop

    func seedOpeningOnce() {
        guard !seeded else { return }
        seeded = true
        append(scenario.openingTurns())
    }

    func send(_ text: String) {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty, !isThinking else { return }
        append([.userText(trimmed)])
        draft = ""
        isThinking = true
        Task {
            let reply = await scenario.respond(to: trimmed)
            isThinking = false
            append(reply)
        }
    }

    func confirm(_ action: any PanelAction) {
        isThinking = true
        Task {
            let follow = await scenario.confirm(action)
            isThinking = false
            append(follow)
        }
    }

    func append(_ newTurns: [PanelTurn]) {
        turns.append(contentsOf: newTurns.map(IdentifiedTurn.init))
    }

    func markStreamed(_ id: UUID) {
        streamedIDs.insert(id)
    }

    // MARK: Nav

    func push(_ route: PanelRoute) {
        withAnimation(.briefStandard) { nav.push(route) }
    }

    func pop() {
        withAnimation(.briefStandard) { nav.pop() }
    }

    // MARK: Lookups

    var currentTitle: String {
        switch nav.current {
        case .conversation:    return scenario.title
        case .detail(let id):  return destination(id)?.title ?? scenario.title
        }
    }

    func destination(_ id: UUID) -> PanelDestination? {
        scenario.detailDestinations().first { $0.id == id }
    }
}
