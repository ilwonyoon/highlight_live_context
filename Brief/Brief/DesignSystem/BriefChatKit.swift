import SwiftUI

// MARK: - Brief chat kit — shared primitives for the AI chat UI
//
// The invisible environment the chat components build on (Phase A of
// AI_CHAT_PLAN): a token-true streaming text view, a "thinking" shimmer, and a
// press-feedback button style. All tuned for the warm-paper editorial system —
// motion is a whisper, not a flourish.

// MARK: 1. StreamingText — word-by-word reveal
//
// An AI chat panel streams its answer (Ilwon: "기본적으로 streaming effect가
// 있어야함, 단어 단위로"). This reveals `fullText` one WORD at a time on a timer,
// so any Text-styled content animates in as if generated live. Once a turn has
// finished streaming once, pass `animated: false` so re-renders show it whole
// (no re-streaming on scroll).

struct StreamingText: View {
    let fullText: String
    /// Style applied to the revealed text.
    var token: BriefTypeToken = .body
    var color: Color = .briefInkBody
    /// Seconds between words. ~0.022s ≈ a brisk, natural generation cadence.
    var wordInterval: Double = 0.022
    /// When false, render `fullText` immediately (already-streamed turns).
    var animated: Bool = true
    /// Fired once the last word lands.
    var onComplete: (() -> Void)? = nil

    @State private var shownWordCount = 0
    @State private var started = false

    private var words: [Substring] { fullText.split(separator: " ", omittingEmptySubsequences: false) }

    private var shownText: String {
        guard animated else { return fullText }
        return words.prefix(shownWordCount).joined(separator: " ")
    }

    var body: some View {
        Text(shownText)
            .briefStyle(token)
            .foregroundStyle(color)
            .fixedSize(horizontal: false, vertical: true)
            .frame(maxWidth: .infinity, alignment: .leading)
            .onAppear(perform: startIfNeeded)
    }

    private func startIfNeeded() {
        guard animated, !started else { return }
        started = true
        revealNext()
    }

    private func revealNext() {
        guard shownWordCount < words.count else { onComplete?(); return }
        shownWordCount += 1
        DispatchQueue.main.asyncAfter(deadline: .now() + wordInterval) {
            revealNext()
        }
    }
}

// MARK: 2. Shimmer — the "thinking" sheen
//
// A moving highlight band swept across the content via a gradient mask — the
// canonical AI "Thinking…" affordance. Per research: shimmer the LABEL, not a
// skeleton box; band = paper color (a sheen, not a white streak); slow (~1.5s)
// so it stays quiet. Implemented as a mask because SwiftUI has no
// background-clip: text.

struct BriefShimmer: ViewModifier {
    var active: Bool = true
    var duration: Double = 1.5

    @State private var phase: CGFloat = -1

    func body(content: Content) -> some View {
        if active {
            content.overlay(sheen.mask(content)).onAppear { animate() }
        } else {
            content
        }
    }

    private var sheen: some View {
        GeometryReader { geo in
            let w = geo.size.width
            LinearGradient(
                colors: [.clear, Color.briefPaper.opacity(0.9), .clear],
                startPoint: .leading, endPoint: .trailing
            )
            .frame(width: w * 0.6)
            .offset(x: phase * w * 1.6)
            .blendMode(.plusLighter)
        }
        .allowsHitTesting(false)
    }

    private func animate() {
        phase = -1
        withAnimation(.linear(duration: duration).repeatForever(autoreverses: false)) {
            phase = 1
        }
    }
}

extension View {
    /// Sweep a soft paper-colored sheen across this view while `active`
    /// (the AI "thinking" affordance). Apply to a Text label.
    func briefShimmer(active: Bool = true, duration: Double = 1.5) -> some View {
        modifier(BriefShimmer(active: active, duration: duration))
    }
}

// MARK: 3. Press style — tactile feedback for chips / CTAs
//
// Tokenizes the duplicated `scaleEffect(0.97) + briefInstant` recipe so every
// chat button/chip presses the same way.

struct BriefPressStyle: ButtonStyle {
    var scale: CGFloat = 0.97
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? scale : 1.0)
            .opacity(configuration.isPressed ? 0.9 : 1.0)
            .animation(.briefInstant, value: configuration.isPressed)
    }
}

extension ButtonStyle where Self == BriefPressStyle {
    static var briefPress: BriefPressStyle { BriefPressStyle() }
}

#Preview("Chat kit") {
    VStack(alignment: .leading, spacing: BriefSpacing.xl) {
        Text("Thinking…")
            .briefStyle(.body)
            .foregroundStyle(Color.briefInkTertiary)
            .briefShimmer()

        StreamingText(fullText: "This answer is being revealed one word at a time, the way a live model would generate it.")

        Button("Create rule") {}
            .buttonStyle(.briefPress)
            .padding(.horizontal, BriefSpacing.lg)
            .padding(.vertical, BriefSpacing.sm)
            .background(Capsule().fill(Color.briefSurfaceDark))
            .foregroundStyle(Color.briefInkInverse)
    }
    .padding(BriefSpacing.xxl)
    .frame(width: 360)
    .background(Color.briefPaper)
}
