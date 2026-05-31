import SwiftUI

// MARK: - PanelComposer — the chat panel's pinned input
//
// A two-row composer, modeled on Highlight's chat box:
//
//   ┌─────────────────────────────────────────────┐
//   │  › Privacy   +                               │  context row: scope chip + attach
//   │  Tell me what to keep private…      🎤  ⊙     │  input row: text · voice · model
//   └─────────────────────────────────────────────┘
//
// • Context row — a scope chip (what this chat is about) + a "+" to attach more
//   (apps / tabs / meetings in the full product; a stub here).
// • Input row — the text field, a voice (mic) button, and a model-picker button.
//   Once there's a draft, a circular SEND button (dark fill, brand-coloured up
//   arrow) takes the model-picker's place.
//
// It's a controlled view: the host owns `draft` and the send path.

struct PanelComposer: View {
    @Binding var draft: String
    var placeholder: String
    var isThinking: Bool
    var onSend: (String) -> Void
    /// Label for the scope chip (the conversation's context).
    var contextLabel: String = "Privacy"

    @FocusState private var focused: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: BriefSpacing.sm) {
            // Context row — scope chip + attach.
            HStack(spacing: BriefSpacing.sm) {
                ScopeChip(label: contextLabel)
                AttachButton {}
                Spacer(minLength: 0)
            }
            .padding(.horizontal, BriefSpacing.xxl)
            .padding(.top, BriefSpacing.lg)

            // Input row — field + send. Send appears only once there's a draft;
            // idle leaves the field clean (no voice / model controls — they had no
            // wired behaviour yet and only added noise).
            HStack(spacing: BriefSpacing.sm) {
                TextField(placeholder, text: $draft)
                    .textFieldStyle(.plain)
                    .font(.briefBody)
                    .foregroundStyle(Color.briefInkPrimary)
                    .focused($focused)
                    .disabled(isThinking)
                    .onSubmit(send)

                if !trimmed.isEmpty && !isThinking {
                    SendButton(action: send)
                        .transition(.scale.combined(with: .opacity))
                }
            }
            .padding(.horizontal, BriefSpacing.xxl)
            .padding(.bottom, BriefSpacing.lg)
        }
        .background(Color.briefPaper)
        .animation(.briefHover, value: trimmed.isEmpty)
        .animation(.briefHover, value: isThinking)
    }

    private var trimmed: String {
        draft.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private func send() {
        let text = trimmed
        guard !text.isEmpty, !isThinking else { return }
        onSend(text)
        draft = ""
    }
}

// MARK: - ComposerHost — the input window's content (composer on a panel surface)
//
// Drives PanelComposer from the shared session and wraps it in the same warm
// rounded surface as the conversation panel, so the separate input window reads
// as a sibling card below it.

struct ComposerHost: View {
    @Bindable var session: ChatPanelSession
    var cornerRadius: CGFloat = BriefRadius.panel

    var body: some View {
        PanelComposer(draft: $session.draft,
                      placeholder: session.scenario.composerPlaceholder,
                      isThinking: session.isThinking,
                      onSend: { session.send($0) },
                      contextLabel: session.scenario.title)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            .background(Color.briefPaper)
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
    }
}

// MARK: - Scope chip (› Privacy) — what this chat is about

private struct ScopeChip: View {
    let label: String
    var body: some View {
        HStack(spacing: BriefSpacing.xs) {
            Image(systemName: "chevron.right")
                .font(.system(size: 9, weight: .semibold))
                .foregroundStyle(Color.briefInkSecondary)
            Text(label)
                .briefStyle(.monoLabel)
                .foregroundStyle(Color.briefInkPrimary)
        }
        .padding(.horizontal, BriefSpacing.sm)
        .padding(.vertical, BriefSpacing.xs)
        .background(
            Capsule()
                .fill(Color.briefPaperSunken)
                .overlay(Capsule().stroke(Color.briefHairline, lineWidth: BriefLayout.Card.strokeWidth))
        )
    }
}

// MARK: - Attach (+) — add apps / tabs / meetings (stub)

private struct AttachButton: View {
    let action: () -> Void
    @State private var hovering = false
    var body: some View {
        Button(action: action) {
            Image(systemName: "plus")
                .font(.system(size: 11, weight: .semibold))
                .foregroundStyle(hovering ? Color.briefInkPrimary : Color.briefInkSecondary)
                .frame(width: 24, height: 24)
                .background(
                    Capsule().stroke(Color.briefHairline, lineWidth: BriefLayout.Card.strokeWidth)
                )
        }
        .buttonStyle(.plain)
        .onHover { hovering = $0 }
        .animation(.briefHover, value: hovering)
        .help("Add context")
    }
}

// MARK: - Send — circular dark fill, brand-coloured up arrow

private struct SendButton: View {
    let action: () -> Void
    @State private var hovering = false
    var body: some View {
        Button(action: action) {
            Image(systemName: "arrow.up")
                .font(.system(size: 13, weight: .bold))
                .foregroundStyle(Color.briefHighlight)        // brand-coloured glyph
                .frame(width: 30, height: 30)
                .background(
                    Circle().fill(Color.briefSurfaceDark)
                        .opacity(hovering ? 0.9 : 1.0)
                )
        }
        .buttonStyle(.briefPress)
        .onHover { hovering = $0 }
        .animation(.briefHover, value: hovering)
        .help("Send")
    }
}

// MARK: - Preview

#Preview("Composer") {
    @Previewable @State var draft = ""
    return VStack {
        Spacer()
        PanelComposer(draft: $draft,
                      placeholder: "Tell me what to keep private…",
                      isThinking: false,
                      onSend: { _ in })
    }
    .frame(width: 400, height: 220)
    .background(Color.briefPaper)
}
