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
    /// The domain plugged into this panel. The panel only ever talks to this.
    let scenario: any PanelScenario
    /// Close the whole panel (slide it out). Owned by the host.
    let onClose: () -> Void

    var cornerRadius: CGFloat = BriefRadius.panel

    @State private var nav = PanelNavStack()
    @State private var turns: [IdentifiedTurn] = []
    @State private var streamedIDs: Set<UUID> = []   // turns that have finished streaming once
    @State private var draft = ""
    @State private var isThinking = false
    @State private var seeded = false

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            header
            Divider().overlay(Color.briefHairlineSoft)
            content
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .background(Color.briefPaper)
        .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                .stroke(Color.briefHairlineSoft, lineWidth: 0.5)
        )
        .task { seedOpeningOnce() }
    }

    // MARK: Header — back (pop) · title (current route) · close (dismiss)

    private var header: some View {
        HStack(spacing: BriefSpacing.md) {
            if nav.canGoBack {
                HeaderIconButton(systemName: "chevron.left", help: "Back") {
                    withAnimation(.briefStandard) { nav.pop() }
                }
            }

            // Söhne, not the Family serif — a chat is a conversation surface, not
            // a document hero. (title3 = Söhne halbfett 17pt.)
            Text(currentTitle)
                .briefStyle(.title3)
                .foregroundStyle(Color.briefInkPrimary)

            Spacer(minLength: 0)

            HeaderIconButton(systemName: "xmark", help: "Close", action: onClose)
        }
        .padding(.horizontal, BriefSpacing.xxl)
        .padding(.vertical, BriefSpacing.xl)
    }

    private var currentTitle: String {
        switch nav.current {
        case .conversation:    return scenario.title
        case .detail(let id):  return destination(id)?.title ?? scenario.title
        }
    }

    // MARK: Content — conversation (root) or a pushed detail

    @ViewBuilder
    private var content: some View {
        switch nav.current {
        case .conversation:    conversation
        case .detail(let id):  detail(id)
        }
    }

    // MARK: Conversation — thread + pinned composer

    private var conversation: some View {
        VStack(spacing: 0) {
            thread
            PanelComposer(draft: $draft,
                          placeholder: scenario.composerPlaceholder,
                          isThinking: isThinking,
                          onSend: send)
        }
    }

    private var thread: some View {
        ScrollViewReader { proxy in
            ScrollView {
                LazyVStack(alignment: .leading, spacing: BriefSpacing.xl) {
                    ForEach(turns) { item in
                        TurnView(turn: item.turn,
                                 animate: !streamedIDs.contains(item.id),
                                 onStreamed: { streamedIDs.insert(item.id) },
                                 onAction: confirm)
                            .id(item.id)
                    }

                    // Drill-in destinations the scenario offers (e.g. "Automatic",
                    // "Your rules"). Rendered once, after the opening, as pushable
                    // rows — tapping pushes the detail route.
                    ForEach(scenario.detailDestinations()) { dest in
                        DestinationRow(title: dest.title) {
                            withAnimation(.briefStandard) { nav.push(.detail(destinationID: dest.id)) }
                        }
                    }
                }
                .padding(.horizontal, BriefSpacing.xxl)
                .padding(.top, BriefSpacing.xl)
                .padding(.bottom, BriefSpacing.xxl)
            }
            .scrollIndicators(.visible)
            // Keep the latest turn in view as the conversation grows.
            .onChange(of: turns.count) {
                if let last = turns.last {
                    withAnimation(.briefStandard) { proxy.scrollTo(last.id, anchor: .bottom) }
                }
            }
        }
    }

    // MARK: Detail — a pushed screen hosting the destination's card

    private func detail(_ id: UUID) -> some View {
        ScrollView {
            VStack(alignment: .leading, spacing: BriefSpacing.xl) {
                if let dest = destination(id) {
                    dest.card.erasedBody()
                }
            }
            .padding(.horizontal, BriefSpacing.xxl)
            .padding(.top, BriefSpacing.xl)
            .padding(.bottom, BriefSpacing.xxl)
        }
        .scrollIndicators(.visible)
    }

    // MARK: The loop

    private func seedOpeningOnce() {
        guard !seeded else { return }
        seeded = true
        append(scenario.openingTurns())
    }

    private func send(_ text: String) {
        append([.userText(text)])
        isThinking = true
        Task {
            let reply = await scenario.respond(to: text)
            isThinking = false
            append(reply)
        }
    }

    private func confirm(_ action: any PanelAction) {
        isThinking = true
        Task {
            let follow = await scenario.confirm(action)
            isThinking = false
            append(follow)
        }
    }

    private func append(_ newTurns: [PanelTurn]) {
        turns.append(contentsOf: newTurns.map(IdentifiedTurn.init))
    }

    // MARK: Lookups

    private func destination(_ id: UUID) -> PanelDestination? {
        scenario.detailDestinations().first { $0.id == id }
    }
}

// MARK: - IdentifiedTurn — a stable id so ForEach + "stream once" work
//
// PanelTurn is a plain enum (no identity). Wrapping each appended turn with a
// UUID lets the thread diff correctly and lets us record which turns have
// already streamed (so they don't re-animate on scroll/re-render).

private struct IdentifiedTurn: Identifiable {
    let id = UUID()
    let turn: PanelTurn
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
    let action: () -> Void
    @State private var hovering = false

    var body: some View {
        Button(action: action) {
            Image(systemName: systemName)
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(hovering ? Color.briefInkPrimary : Color.briefInkTertiary)
                .frame(width: 26, height: 26)
                .background(Circle().fill(hovering ? Color.briefSelectionRest : .clear))
                .contentShape(Circle())
        }
        .buttonStyle(.plain)
        .onHover { hovering = $0 }
        .animation(.briefHover, value: hovering)
        .help(help)
    }
}

// MARK: - ChatPanelSlideOver — the generic slide-over host
//
// Generic version of the old PrivacySlideOver: a ZStack over the whole window
// with a dimming scrim and a trailing move-transition. ZStack + .transition
// (NOT .overlay + .offset) so NavigationSplitView never clips it.

struct ChatPanelSlideOver: ViewModifier {
    @Binding var isPresented: Bool
    let scenario: any PanelScenario

    private let panelWidth: CGFloat = 400

    func body(content: Content) -> some View {
        ZStack(alignment: .trailing) {
            content

            if isPresented {
                Color.briefScrim
                    .ignoresSafeArea()
                    .onTapGesture { isPresented = false }
                    .transition(.opacity)

                ChatPanel(scenario: scenario, onClose: { isPresented = false })
                    .frame(width: panelWidth)
                    .frame(maxHeight: .infinity)
                    .transition(.move(edge: .trailing))
            }
        }
        .animation(isPresented ? .briefPanel : .briefPanelOut, value: isPresented)
    }
}

extension View {
    /// Slide a ChatPanel in from the trailing edge over this view.
    func chatPanelSlideOver(isPresented: Binding<Bool>, scenario: any PanelScenario) -> some View {
        modifier(ChatPanelSlideOver(isPresented: isPresented, scenario: scenario))
    }
}

// MARK: - Preview

#Preview("Chat panel — echo") {
    ZStack {
        Color.briefPaper
        Text("Window content behind the panel")
            .briefStyle(.body)
            .foregroundStyle(Color.briefInkTertiary)
    }
    .frame(width: 1000, height: 700)
    .chatPanelSlideOver(isPresented: .constant(true), scenario: EchoScenario())
}
