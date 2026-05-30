import SwiftUI

// MARK: - EchoScenario — a throwaway scenario for building the panel
//
// Proves the layering is real: the chat panel is developed and verified against
// THIS, with no privacy code present. It echoes the user, shows a "thinking"
// beat, renders one dummy card, and offers one drill-in destination — exercising
// every PanelScenario method the panel needs to render.
//
// Delete once PrivacyScenario lands (PRIVACY_EXECUTION.md §7, step 5).

@MainActor
struct EchoScenario: PanelScenario {
    var title: String { "Echo" }
    var composerPlaceholder: String { "Say something…" }

    func openingTurns() -> [PanelTurn] {
        [ .assistantText("This is the echo scenario. Whatever you type, I repeat — it's here to build the panel against, with no real domain attached."),
          .assistantCard(EchoCard(text: "A dummy card. The panel hosts me without knowing what I am.")) ]
    }

    func respond(to userText: String) async -> [PanelTurn] {
        [ .assistantThinking("Echoing…"),
          .assistantText("You said: \u{201C}\(userText)\u{201D}"),
          .assistantCard(EchoConfirmCard(text: userText)) ]
    }

    func confirm(_ action: any PanelAction) async -> [PanelTurn] {
        let label = (action as? EchoAction)?.label ?? "something"
        return [ .assistantText("Confirmed: \(label).") ]
    }

    func detailDestinations() -> [PanelDestination] {
        [ PanelDestination(title: "Details",
                           card: EchoCard(text: "A pushed detail screen. Back returns to the conversation.")) ]
    }
}

// MARK: Dummy action

struct EchoAction: PanelAction {
    let label: String
}

// MARK: Dummy cards

private struct EchoCard: PanelCard {
    let text: String
    func makeBody() -> some View {
        Text(text)
            .briefStyle(.body)
            .foregroundStyle(Color.briefInkSecondary)
            .fixedSize(horizontal: false, vertical: true)
            .padding(BriefSpacing.xl)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: BriefRadius.card, style: .continuous)
                    .fill(Color.briefPaperRaised)
                    .overlay(
                        RoundedRectangle(cornerRadius: BriefRadius.card, style: .continuous)
                            .stroke(Color.briefHairlineSoft, lineWidth: 1)
                    )
            )
    }
}

/// A card with a confirmable action — exercises the panel's CTA → confirm path.
private struct EchoConfirmCard: PanelCard {
    let text: String
    func makeBody() -> some View {
        VStack(alignment: .leading, spacing: BriefSpacing.md) {
            Text("Confirm echoing \u{201C}\(text)\u{201D}?")
                .briefStyle(.body)
                .foregroundStyle(Color.briefInkPrimary)
                .fixedSize(horizontal: false, vertical: true)
            // NOTE: the actual button wiring (tapping → scenario.confirm) is
            // added in step 3 when the panel owns the confirm path; this card
            // just shows the shape for now.
            Text("[ Confirm ]")
                .briefStyle(.monoLabel)
                .foregroundStyle(Color.briefInkTertiary)
        }
        .padding(BriefSpacing.xl)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: BriefRadius.card, style: .continuous)
                .fill(Color.briefPaperRaised)
                .overlay(
                    RoundedRectangle(cornerRadius: BriefRadius.card, style: .continuous)
                        .stroke(Color.briefHairlineSoft, lineWidth: 1)
                )
        )
    }
}
