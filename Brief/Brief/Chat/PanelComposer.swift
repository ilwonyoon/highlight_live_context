import SwiftUI

// MARK: - PanelComposer — the chat panel's pinned input
//
// The bottom input the panel was missing. Borrows ChatComposer's anatomy (a
// plain TextField + a trailing send button that appears once there's a draft,
// the focus-ring wash) but NOT its context chip or copy action — those belong to
// the block-selection composer. This is a pure conversational input.
//
// It's a dumb, controlled view: the host owns `draft` and the send path. While
// the scenario is "thinking" the field is disabled so turns can't interleave.
//
// See PRIVACY_EXECUTION.md §3.3.

struct PanelComposer: View {
    @Binding var draft: String
    /// Scenario-flavored prompt ("Tell me what to keep private…").
    var placeholder: String
    /// True while the scenario is producing a reply — input is disabled.
    var isThinking: Bool
    var onSend: (String) -> Void

    @FocusState private var focused: Bool

    var body: some View {
        VStack(spacing: 0) {
            Divider().overlay(Color.briefHairlineSoft)

            HStack(spacing: BriefSpacing.sm) {
                TextField(placeholder, text: $draft)
                    .textFieldStyle(.plain)
                    .font(.briefBody)
                    .foregroundStyle(Color.briefInkPrimary)
                    .focused($focused)
                    .disabled(isThinking)
                    .onSubmit(send)

                // Send appears only when there's something to send (and we're not
                // mid-reply). Mirrors ChatComposer's idle→send swap.
                if !trimmed.isEmpty && !isThinking {
                    SendButton(action: send)
                        .transition(.scale.combined(with: .opacity))
                }
            }
            .padding(.horizontal, BriefSpacing.xxl)
            .padding(.vertical, BriefSpacing.lg)
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

// MARK: - SendButton — filled up-arrow, the one action in the composer

private struct SendButton: View {
    let action: () -> Void
    @State private var hovering = false

    var body: some View {
        Button(action: action) {
            Image(systemName: "arrow.up")
                .font(.system(size: 11, weight: .semibold))
                .foregroundStyle(Color.briefInkPrimary)
                .frame(width: 24, height: 24)
                .background(
                    Circle().fill(Color.briefHighlight.opacity(
                        hovering ? BriefOpacity.washHeavy : BriefOpacity.washSoft))
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
    .frame(width: 400, height: 200)
    .background(Color.briefPaper)
}
