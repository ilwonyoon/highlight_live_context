import SwiftUI

// MARK: - PanelScenario — the chat panel's bridge to a domain
//
// The AI chat panel is a GENERAL conversational control surface. It renders and
// drives a conversation WITHOUT knowing the domain. A domain (privacy first,
// memory / connections later) plugs in by implementing `PanelScenario`.
//
// This is the only contact point between the two. The panel imports zero domain
// types; a domain imports only this file. Get the contract right and the two
// sides never touch again.
//
// See PRIVACY_EXECUTION.md §2 for the full rationale.

// MARK: Card — domain-rendered rich content, opaque to the panel

/// A unit of rich content the assistant can "speak" without the panel knowing
/// its type — the two bucket cards, a scan proposal, a confirmation. The domain
/// supplies the view; the panel just hosts it (wrapped in `AnyView`, since
/// `card.makeBody()` erases to `any View` at the existential boundary).
@MainActor
protocol PanelCard {
    associatedtype Body: View
    @ViewBuilder func makeBody() -> Body
}

extension PanelCard {
    /// The panel hosts every card through this — the one unavoidable erasure.
    /// `any View` can't satisfy a `some View` return, so we wrap once here and
    /// scenario authors still write `some View` in `makeBody()`.
    @MainActor func erasedBody() -> AnyView { AnyView(makeBody()) }
}

// MARK: Action — a confirmable choice surfaced in a card, opaque to the panel

/// Something the user can confirm from a card (e.g. "Keep it out"). The panel
/// hands the chosen action back to the scenario via `confirm(_:)`; what it
/// carries is the domain's business.
protocol PanelAction {}

// MARK: Turn — one entry in the thread

/// One conversation turn. `.userText` / `.assistantText` / `.assistantThinking`
/// are all the panel understands directly; a card's contents stay the domain's.
enum PanelTurn {
    case userText(String)
    case assistantText(String)
    case assistantThinking(String)        // a shimmered label while the scenario works
    case assistantCard(any PanelCard)     // domain-rendered rich content
}

// MARK: Destination — a pushable drill-in screen the scenario offers

/// A detail screen the scenario exposes (e.g. "Automatic", "Your rules"). The
/// panel renders it as a pushable route with this title; the body is a card.
struct PanelDestination: Identifiable {
    let id = UUID()
    let title: String
    let card: any PanelCard
}

// MARK: PanelScenario — what the chat panel asks of ANY domain

/// The contract. Privacy is the first implementation; memory / connections are
/// future ones. The panel calls these methods; it never reaches into the
/// domain's state.
@MainActor
protocol PanelScenario {
    /// The conversation's title, shown in the header ("Privacy", "Memory", …).
    var title: String { get }

    /// Placeholder for the bottom composer, flavored per scenario
    /// ("Tell me what to keep private…"). A default is provided.
    var composerPlaceholder: String { get }

    /// The proactive opening — turns the assistant has "already" prepared on
    /// entry (e.g. the privacy brief), rendered before the user types anything.
    func openingTurns() -> [PanelTurn]

    /// The user said something. The scenario interprets it and returns the
    /// assistant's response turns (which may include a thinking turn followed by
    /// a card). Async so a scenario can mock latency / actually scan.
    func respond(to userText: String) async -> [PanelTurn]

    /// The user confirmed an action surfaced in a card. The scenario applies it
    /// (creates a rule, mutates its own state) and returns follow-up turns.
    func confirm(_ action: any PanelAction) async -> [PanelTurn]

    /// Optional drill-in destinations (e.g. "Automatic", "Your rules"). The panel
    /// renders these as pushable detail screens. Default: none.
    func detailDestinations() -> [PanelDestination]
}

// MARK: Sensible defaults — keep simple scenarios terse

extension PanelScenario {
    var composerPlaceholder: String { "Ask or tell me what to change…" }
    func detailDestinations() -> [PanelDestination] { [] }
}
