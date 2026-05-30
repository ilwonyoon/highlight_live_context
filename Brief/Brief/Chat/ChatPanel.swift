import SwiftUI

// MARK: - ChatPanel — the general conversational control surface
//
// A navigable chat panel that hosts ANY domain via a PanelScenario. It knows
// nothing about privacy (or memory, or connections) — it renders the scenario's
// turns, drives its conversation loop, and pushes its detail destinations.
//
// This is the generic shell extracted from the old privacy-specific panel:
//   • header — route-driven title + back (pop) + close (dismiss the panel)
//   • body   — the conversation thread (step 3) or a pushed detail screen
//   • composer — the pinned input (step 2)
//
// Step 1 establishes the shell + navigation. The thread and composer are stubbed
// here and filled in steps 2-3. The slide-over HOST (scrim + edge slide) is
// ChatPanelSlideOver below — the generic version of the old PrivacySlideOver.
//
// See PRIVACY_EXECUTION.md §3.

struct ChatPanel: View {
    /// The domain plugged into this panel. The panel only ever talks to this.
    let scenario: any PanelScenario
    /// Close the whole panel (slide it out). Owned by the host.
    let onClose: () -> Void

    var cornerRadius: CGFloat = BriefRadius.panel

    @State private var nav = PanelNavStack()

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            header
            Divider().overlay(Color.briefHairlineSoft)
            content
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        // Same warm reading-paper as the Live Context document body.
        .background(Color.briefPaper)
        .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                .stroke(Color.briefHairlineSoft, lineWidth: 0.5)
        )
    }

    // MARK: Header — back (pop) · title (current route) · close (dismiss)

    private var header: some View {
        HStack(spacing: BriefSpacing.md) {
            // Back — shown only when the stack is deeper than its root. Pops one
            // level. Distinct from close: this navigates WITHIN the panel.
            if nav.canGoBack {
                HeaderIconButton(systemName: "chevron.left", help: "Back") {
                    withAnimation(.briefStandard) { nav.pop() }
                }
            }

            Text(currentTitle)
                .briefStyle(.panelTitle)
                .foregroundStyle(Color.briefInkPrimary)

            Spacer(minLength: 0)

            // Close — slides the whole panel out, at any depth. An xmark (not a
            // chevron) so it never reads as "back".
            HeaderIconButton(systemName: "xmark", help: "Close", action: onClose)
        }
        .padding(.horizontal, BriefSpacing.xxl)
        .padding(.vertical, BriefSpacing.xl)
    }

    /// Title of the current route: the scenario at the root, the destination's
    /// own title when drilled in.
    private var currentTitle: String {
        switch nav.current {
        case .conversation:
            return scenario.title
        case .detail(let id):
            return destination(id)?.title ?? scenario.title
        }
    }

    // MARK: Content — conversation (root) or a pushed detail

    @ViewBuilder
    private var content: some View {
        switch nav.current {
        case .conversation:
            conversationBody
        case .detail(let id):
            detailBody(id)
        }
    }

    /// The conversation thread + composer. Stubbed in step 1; the thread lands in
    /// step 3 and the composer in step 2. For now it shows the opening turns as
    /// plain text and a temporary way to exercise push navigation.
    private var conversationBody: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: BriefSpacing.xl) {
                // TEMP (step 1): render opening turns as plain text so the shell
                // is visible. Replaced by the real thread renderer in step 3.
                ForEach(Array(scenario.openingTurns().enumerated()), id: \.offset) { _, turn in
                    StubTurnView(turn: turn)
                }

                // TEMP (step 1): a button per destination so back/pop can be
                // exercised before the bucket cards' chevrons exist (step 4).
                ForEach(scenario.detailDestinations()) { dest in
                    Button {
                        withAnimation(.briefStandard) { nav.push(.detail(destinationID: dest.id)) }
                    } label: {
                        HStack(spacing: BriefSpacing.sm) {
                            Text(dest.title).briefStyle(.bodyMedium)
                            Image(systemName: "chevron.right")
                                .font(.system(size: 11, weight: .semibold))
                        }
                        .foregroundStyle(Color.briefInkSecondary)
                    }
                    .buttonStyle(.briefPress)
                }
            }
            .padding(.horizontal, BriefSpacing.xxl)
            .padding(.top, BriefSpacing.xl)
            .padding(.bottom, BriefSpacing.xxl)
        }
        .scrollIndicators(.visible)
    }

    /// A pushed detail screen — hosts the destination's card.
    private func detailBody(_ id: UUID) -> some View {
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

    private func destination(_ id: UUID) -> PanelDestination? {
        scenario.detailDestinations().first { $0.id == id }
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

// MARK: - StubTurnView (step 1 only) — replaced by the real thread in step 3

private struct StubTurnView: View {
    let turn: PanelTurn

    var body: some View {
        switch turn {
        case .userText(let t):
            Text(t).briefStyle(.body).foregroundStyle(Color.briefInkPrimary)
        case .assistantText(let t):
            Text(t).briefStyle(.body).foregroundStyle(Color.briefInkBody)
                .fixedSize(horizontal: false, vertical: true)
        case .assistantThinking(let t):
            Text(t).briefStyle(.body).foregroundStyle(Color.briefInkTertiary)
        case .assistantCard(let card):
            card.erasedBody()
        }
    }
}

// MARK: - ChatPanelSlideOver — the generic slide-over host
//
// Generic version of the old PrivacySlideOver: a ZStack laid over the whole
// window with a dimming scrim and a trailing move-transition. Built as
// ZStack + .transition (NOT .overlay + .offset) so NavigationSplitView never
// clips it — the hard-won lesson carried over from the privacy panel.

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
