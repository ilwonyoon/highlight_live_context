import SwiftUI

// MARK: - ChatPanel — the general conversational control surface
//
// A navigable chat panel that hosts ANY domain via a PanelScenario. It knows
// nothing about privacy (or memory, or connections) — it renders the scenario's
// turns, drives its conversation loop, and pushes its detail destinations.
//
//   header   — route-driven title + back (pop) + close (dismiss the panel)
//   thread   — the conversation: streamed assistant text, a "thinking" shimmer,
//              hosted domain cards, right-aligned user turns
//   composer — the pinned bottom input
//
// The loop is deliberately indifferent: on send it appends the user's turn, asks
// the scenario to respond, and renders whatever turns come back. It never
// branches on what the text means or what a card is.
//
// See PRIVACY_EXECUTION.md §3-§4.

struct ChatPanel: View {
    /// The shared conversation state (scenario, thread, nav). Owned by the host
    /// so a separate input window can share it. ChatPanel renders header+thread.
    @Bindable var session: ChatPanelSession

    var cornerRadius: CGFloat = BriefRadius.panel

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            header
            Divider().overlay(Color.briefHairlineSoft)
            content
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .background(Color.briefPaper)
        .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
        // No outline — the floating panel's shadow (NSPanel.hasShadow) carries
        // "this surface is lifted" on its own. A stroke on top reads heavy.
        .task { session.seedOpeningOnce() }
    }

    // MARK: Header — back (pop) · title (current route)

    private var header: some View {
        HStack(spacing: BriefSpacing.md) {
            // Back is always present on the left (the panel reads as one screen
            // in a stack). At the root it has nothing to pop, so it's quiet;
            // inside a detail it pops. No close button — the panel
            // light-dismisses on Esc / click-outside.
            HeaderIconButton(systemName: "chevron.left",
                             help: "Back",
                             enabled: session.nav.canGoBack) {
                session.pop()
            }

            Text(session.currentTitle)
                .briefStyle(.title3Medium)
                .foregroundStyle(Color.briefInkPrimary)

            Spacer(minLength: 0)
        }
        .padding(.horizontal, BriefSpacing.xxl)
        .padding(.vertical, BriefSpacing.xl)
    }

    // MARK: Content — conversation (root) or a pushed detail

    @ViewBuilder
    private var content: some View {
        switch session.nav.current {
        case .conversation:    conversation
        case .detail(let id):  detail(id)
        }
    }

    // MARK: Conversation — the thread (composer now lives in a separate window)

    private var conversation: some View {
        thread
    }

    private var thread: some View {
        ScrollViewReader { proxy in
            ScrollView {
                LazyVStack(alignment: .leading, spacing: BriefSpacing.xl) {
                    ForEach(session.turns) { item in
                        TurnView(turn: item.turn,
                                 animate: !session.streamedIDs.contains(item.id),
                                 onStreamed: { session.markStreamed(item.id) },
                                 onAction: { session.confirm($0) })
                            .id(item.id)
                    }

                    // Drill-in destinations the scenario offers (e.g. "Automatic",
                    // "Your rules"). Rendered once, after the opening, as pushable
                    // rows — tapping pushes the detail route.
                    ForEach(session.scenario.detailDestinations()) { dest in
                        DestinationRow(title: dest.title) {
                            session.push(.detail(destinationID: dest.id))
                        }
                    }
                }
                .padding(.horizontal, BriefSpacing.xxl)
                .padding(.top, BriefSpacing.xl)
                .padding(.bottom, BriefSpacing.xxl)
            }
            .scrollIndicators(.visible)
            // Keep the latest turn in view as the conversation grows.
            .onChange(of: session.turns.count) {
                if let last = session.turns.last {
                    withAnimation(.briefStandard) { proxy.scrollTo(last.id, anchor: .bottom) }
                }
            }
        }
    }

    // MARK: Detail — a pushed screen hosting the destination's card

    private func detail(_ id: UUID) -> some View {
        ScrollView {
            VStack(alignment: .leading, spacing: BriefSpacing.xl) {
                if let dest = session.destination(id) {
                    dest.card.erasedBody()
                }
            }
            .padding(.horizontal, BriefSpacing.xxl)
            .padding(.top, BriefSpacing.xl)
            .padding(.bottom, BriefSpacing.xxl)
        }
        .scrollIndicators(.visible)
    }
}

// MARK: - TurnView — renders one turn with the chat-kit primitives

private struct TurnView: View {
    let turn: PanelTurn
    /// True until this turn has streamed once (assistant text only).
    let animate: Bool
    let onStreamed: () -> Void
    let onAction: (any PanelAction) -> Void

    var body: some View {
        switch turn {
        case .userText(let text):
            userBubble(text)

        case .assistantText(let text):
            StreamingText(fullText: text,
                          token: .body,
                          color: .briefInkBody,
                          animated: animate,
                          onComplete: onStreamed)

        case .assistantThinking(let label):
            Text(label)
                .briefStyle(.body)
                .foregroundStyle(Color.briefInkTertiary)
                .briefShimmer()

        case .assistantCard(let card):
            CardHost(card: card, onAction: onAction)
        }
    }

    private func userBubble(_ text: String) -> some View {
        HStack {
            Spacer(minLength: BriefSpacing.xxl)
            Text(text)
                .briefStyle(.body)
                .foregroundStyle(Color.briefInkPrimary)
                .fixedSize(horizontal: false, vertical: true)
                .multilineTextAlignment(.leading)
                .padding(.horizontal, BriefSpacing.lg)
                .padding(.vertical, BriefSpacing.sm)
                .background(
                    RoundedRectangle(cornerRadius: BriefRadius.card, style: .continuous)
                        .fill(Color.briefPaperSunken)
                        .overlay(
                            RoundedRectangle(cornerRadius: BriefRadius.card, style: .continuous)
                                .stroke(Color.briefHairline, lineWidth: BriefLayout.Card.strokeWidth)
                        )
                )
        }
    }
}

// MARK: - CardHost — hosts an opaque PanelCard + exposes its action to the panel
//
// The panel can't see inside a card, so a card that wants a confirmable action
// can't call back directly. The scenario sets `PanelCard.primaryAction` (default
// nil); if present, the host renders a CTA row below the card that routes to the
// panel's confirm(). Cards with no action just render.

private struct CardHost: View {
    let card: any PanelCard
    let onAction: (any PanelAction) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: BriefSpacing.md) {
            card.erasedBody()

            if let action = card.primaryAction {
                HStack {
                    Spacer(minLength: 0)
                    Button(action.label) { onAction(action.action) }
                        .buttonStyle(.briefPress)
                        .padding(.horizontal, BriefSpacing.lg)
                        .padding(.vertical, BriefSpacing.sm)
                        .background(Capsule().fill(Color.briefSurfaceDark))
                        .foregroundStyle(Color.briefInkInverse)
                }
            }
        }
    }
}

// MARK: - DestinationRow — a pushable drill-in row (chevron-right)

private struct DestinationRow: View {
    let title: String
    let onTap: () -> Void
    @State private var hovering = false

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: BriefSpacing.sm) {
                Text(title)
                    .briefStyle(.bodyMedium)
                    .foregroundStyle(Color.briefInkPrimary)
                Spacer(minLength: 0)
                Image(systemName: "chevron.right")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(Color.briefInkTertiary)
            }
            .padding(.horizontal, BriefSpacing.lg)
            .padding(.vertical, BriefSpacing.md)
            .background(
                RoundedRectangle(cornerRadius: BriefRadius.card, style: .continuous)
                    .fill(hovering ? Color.briefSelectionRest : Color.briefPaperRaised)
                    .overlay(
                        RoundedRectangle(cornerRadius: BriefRadius.card, style: .continuous)
                            .stroke(Color.briefHairlineSoft, lineWidth: 1)
                    )
            )
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .onHover { hovering = $0 }
        .animation(.briefHover, value: hovering)
    }
}

// MARK: - HeaderIconButton — back / close, hover-lit

private struct HeaderIconButton: View {
    let systemName: String
    let help: String
    var enabled: Bool = true
    let action: () -> Void
    @State private var hovering = false

    var body: some View {
        Button(action: action) {
            Image(systemName: systemName)
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(tint)
                .frame(width: 26, height: 26)
                .background(Circle().fill(hovering && enabled ? Color.briefSelectionRest : .clear))
                .contentShape(Circle())
        }
        .buttonStyle(.plain)
        .disabled(!enabled)
        .onHover { hovering = $0 }
        .animation(.briefHover, value: hovering)
        .help(help)
    }

    private var tint: Color {
        if !enabled { return Color.briefInkTertiary.opacity(0.4) }   // quiet when disabled
        return hovering ? Color.briefInkPrimary : Color.briefInkTertiary
    }
}

// MARK: - Preview

#Preview("Chat panel — echo") {
    ChatPanel(session: ChatPanelSession(scenario: EchoScenario()))
        .frame(width: 400, height: 600)
        .background(Color.briefPaperSunken)
}
