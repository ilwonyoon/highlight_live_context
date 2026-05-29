import SwiftUI

// MARK: - Privacy slide-over panel
//
// The privacy control surface. Crucially, this is NOT a window or a
// NavigationSplitView column — it's a slide-OVER that lives on top of the main
// window, parked off the right edge and sliding LEFT into view. (Ilwon's
// constraint: "윈도우의 우측 밖에서 좌측 안으로 들어오는 패널".)
//
// Why an overlay and not a window/column:
//   • It must float *over* the Live Context surface with a dimming scrim, so it
//     reads as a focused, dismissable control surface — not a permanent pane.
//   • Motion is asymmetric (house rule): slides IN with a spring (`.briefPanel`),
//     slides OUT faster (`.briefPanelOut`). Dismissal never lingers.
//
// Composition:
//   • `PrivacySlideOver` — the host modifier: scrim + right-anchored container,
//     `.offset(x:)`-driven. Attach to any view with `.privacySlideOver(isPresented:)`.
//   • `PrivacyPanel` — the panel content. Step 1 is a placeholder body; the
//     proactive state brief, conversation, and composer land in later steps.
//
// This file is intentionally just the shell + mechanics for now.

// MARK: Host modifier

/// Presents `PrivacyPanel` as a slide-over anchored to the trailing window edge.
/// Apply at the window root (over the whole content) so the scrim covers it all.
///
/// Built as a `ZStack` + `.transition(.move(edge: .trailing))`, NOT an
/// `.overlay` + `.offset`. The offset approach gets clipped by
/// `NavigationSplitView` (the panel is pushed past the container's trailing edge
/// and the split view clips its own bounds). A ZStack laid over the whole window
/// with a move transition is the clean slide-over and never clips.
struct PrivacySlideOver: ViewModifier {
    @Binding var isPresented: Bool

    /// Panel width. Wide enough for the two-bucket brief + a chat thread,
    /// narrow enough to keep the window readable behind the scrim.
    private let panelWidth: CGFloat = 400

    func body(content: Content) -> some View {
        ZStack(alignment: .trailing) {
            content

            if isPresented {
                // Scrim — tap to dismiss. Covers the whole window.
                Color.briefScrim
                    .ignoresSafeArea()
                    .onTapGesture { dismiss() }
                    .transition(.opacity)

                // The panel — slides in from / out to the trailing edge.
                PrivacyPanel(onDismiss: dismiss)
                    .frame(width: panelWidth)
                    .frame(maxHeight: .infinity)
                    .transition(.move(edge: .trailing))
            }
        }
        // Asymmetric motion: spring in, quick out.
        .animation(isPresented ? .briefPanel : .briefPanelOut, value: isPresented)
    }

    private func dismiss() { isPresented = false }
}

extension View {
    /// Slide the Privacy panel in from the trailing edge over this view.
    func privacySlideOver(isPresented: Binding<Bool>) -> some View {
        modifier(PrivacySlideOver(isPresented: isPresented))
    }
}

// MARK: - Panel content

struct PrivacyPanel: View {
    let onDismiss: () -> Void
    /// Corner radius of the panel surface. The screen-edge floating window
    /// rounds all four corners; an in-window slide-over could pass 0.
    var cornerRadius: CGFloat = BriefRadius.panel

    /// The privacy state this panel reads and edits. Mock for now; the wish→rule
    /// interaction appends to `state.rules` (step 5).
    @State private var state = PrivacyState.mock

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            header
            Divider()
                .overlay(Color.briefHairlineSoft)

            // The proactive brief — on entry the assistant has ALREADY laid out
            // how protection is working right now (not a passive settings list).
            ScrollView {
                VStack(alignment: .leading, spacing: BriefSpacing.xl) {
                    assistantOpening
                    PrivacyBucketCard(kind: .automatic, state: state)
                    PrivacyBucketCard(kind: .yourRules, state: state)
                    Spacer(minLength: BriefSpacing.lg)
                }
                .padding(.horizontal, BriefSpacing.xxl)
                .padding(.top, BriefSpacing.xl)
                .padding(.bottom, BriefSpacing.xxl)
            }
            .scrollIndicators(.visible)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        // Same warm reading-paper as the Live Context document body (Ilwon: the
        // chat panel should match Live Context's background, not float as glass).
        .background(Color.briefPaper)
        // Clip the surface to rounded corners — the host window is transparent,
        // so the panel owns its own shape.
        .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
        // A whisper edge so the surface reads as defined, not a bleed.
        .overlay(
            RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                .stroke(Color.briefHairlineSoft, lineWidth: 0.5)
        )
    }

    // MARK: Header — identity + dismiss (the merged-nav top row, Option A)

    private var header: some View {
        HStack(spacing: BriefSpacing.md) {
            Image(systemName: "checkmark.shield")
                .font(.system(size: 15, weight: .regular))
                .foregroundStyle(Color.briefInkPrimary)
            // The one Family (serif) title for this surface — sized for a panel
            // header (smaller than the 28pt hero used on full documents).
            Text("Privacy")
                .briefStyle(.panelTitle)
                .foregroundStyle(Color.briefInkPrimary)
            Spacer(minLength: 0)
            DismissButton(action: onDismiss)
        }
        .padding(.horizontal, BriefSpacing.xxl)
        .padding(.vertical, BriefSpacing.xl)
    }

    // MARK: Assistant opening — the proactive, conversational lede

    /// The first "turn": a plain-language summary so the otherwise-invisible
    /// model (Automatic protections) is legible the moment you arrive — and a
    /// nudge that you can change any of it just by saying so.
    private var assistantOpening: some View {
        VStack(alignment: .leading, spacing: BriefSpacing.sm) {
            Text("Here's how I'm protecting you right now.")
                .briefStyle(.title3)
                .foregroundStyle(Color.briefInkPrimary)
                .fixedSize(horizontal: false, vertical: true)
            Text("Two things I handle automatically, and the lines you've drawn yourself. Tell me what to change — you don't have to touch a setting.")
                .briefStyle(.body)
                .foregroundStyle(Color.briefInkSecondary)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}

// MARK: - Dismiss button (slide back out)

private struct DismissButton: View {
    let action: () -> Void
    @State private var hovering = false

    var body: some View {
        Button(action: action) {
            Image(systemName: "chevron.right")
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(hovering ? Color.briefInkPrimary : Color.briefInkTertiary)
                .frame(width: 26, height: 26)
                .background(
                    Circle().fill(hovering ? Color.briefSelectionRest : .clear)
                )
                .contentShape(Circle())
        }
        .buttonStyle(.plain)
        .onHover { hovering = $0 }
        .animation(.briefHover, value: hovering)
        .help("Close")
    }
}

#Preview("Privacy slide-over") {
    ZStack {
        Color.briefPaper
        Text("Window content behind the panel")
            .briefStyle(.body)
            .foregroundStyle(Color.briefInkTertiary)
    }
    .frame(width: 1000, height: 700)
    .privacySlideOver(isPresented: .constant(true))
}
