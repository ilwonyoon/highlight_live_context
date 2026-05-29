import SwiftUI

// MARK: - ChatComposer
// A minimal chat popover that appears beside a selected block. The input field
// is the main affordance — selecting a block invites you to "ask or act on this"
// directly, which makes the next move obvious without a row of buttons creating
// extra depth. Copy lives as a small icon at the input's right (option A); it's
// the one action that needs no conversation. Everything else (delete, reprioritize,
// draft an action…) is expressed by talking to the AI, so the intent is captured
// rather than scattered across buttons.
//
// Layout note: the popover is positioned by SelectionSurface so its right edge
// stays within the selected block's capsule (trailing-aligned, never overflowing).

struct ChatComposer: View {
    /// The selected text — shown as a context chip and used as the chat seed.
    let seedText: String

    @State private var draft = ""
    @State private var copied = false
    @FocusState private var draftFocused: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: BriefSpacing.sm) {
            // Context chip — what's being passed to the AI (the selected block).
            ContextChip(text: seedText)

            // Input row — the main affordance. Copy sits at the right while idle;
            // once you start typing it gives way to Send (you won't copy mid-draft).
            HStack(spacing: BriefSpacing.sm) {
                TextField("Ask or act on this…", text: $draft)
                    .textFieldStyle(.plain)
                    .font(.briefBodySmall)
                    .foregroundStyle(Color.briefInkPrimary)
                    .focused($draftFocused)
                    .onSubmit(submitAsk)

                if draft.isEmpty {
                    // Copy (option A): the only non-chat action — shown while idle.
                    InputIconButton(icon: copied ? "checkmark" : "doc.on.doc",
                                    tint: copied ? Color.briefHighlightInk : nil,
                                    help: "Copy text") { copy() }
                } else {
                    // Send — replaces Copy once there's a draft.
                    InputIconButton(icon: "arrow.up", filled: true, help: "Send") { submitAsk() }
                }
            }
        }
        .padding(BriefLayout.Composer.inset)
        .frame(width: BriefLayout.Composer.width, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: BriefRadius.card, style: .continuous)
                .fill(Color.briefPaper)
                .briefShadow(BriefShadow.floating)
        )
        .overlay(
            RoundedRectangle(cornerRadius: BriefRadius.card, style: .continuous)
                .stroke(draftFocused
                        ? Color.briefHighlight.opacity(BriefOpacity.washHeavy)
                        : Color.briefHairline,
                        lineWidth: draftFocused ? 1.5 : BriefLayout.Card.strokeWidth)
        )
        .animation(.briefHover, value: draftFocused)
        .animation(.briefHover, value: copied)
        .onAppear { draftFocused = true }
    }

    // MARK: - Actions

    private func submitAsk() {
        guard !draft.isEmpty else { return }
        print("Ask: \"\(draft)\" — context: \(seedText)")
        draft = ""
    }

    private func copy() {
        #if os(macOS)
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(seedText, forType: .string)
        #endif
        copied = true
        // Reset the check after a moment (no Timer in this layer — rely on the
        // next interaction; keep it simple: a brief async reset).
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.4) { copied = false }
    }
}

// MARK: - ContextChip
// Mirrors Highlight's `> cmux` chip — shows the selected content as a
// chevron-prefixed pill so the user knows what's being passed to the AI.

private struct ContextChip: View {
    let text: String

    var body: some View {
        HStack(spacing: BriefSpacing.xs) {
            Image(systemName: "chevron.right")
                .font(.system(size: 9, weight: .semibold))
                .foregroundStyle(Color.briefInkSecondary)
            Text(truncated)
                .briefStyle(.monoLabel)
                .foregroundStyle(Color.briefInkPrimary)
                .lineLimit(1)
        }
        .padding(.horizontal, BriefSpacing.sm)
        .padding(.vertical, BriefSpacing.xs)
        .background(
            Capsule()
                .fill(Color.briefPaperSunken)
                .overlay(
                    Capsule().stroke(Color.briefHairline, lineWidth: BriefLayout.Card.strokeWidth)
                )
        )
    }

    private var truncated: String {
        let limit = 34
        if text.count <= limit { return text }
        return String(text.prefix(limit)) + "…"
    }
}

// MARK: - InputIconButton
// Small icon button living inside the input row (copy, send).

private struct InputIconButton: View {
    let icon: String
    var filled: Bool = false
    var tint: Color? = nil
    let help: String
    let action: () -> Void
    @State private var hovering = false

    var body: some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.system(size: 11, weight: .semibold))
                .foregroundStyle(filled ? Color.briefInkPrimary
                                 : (tint ?? (hovering ? Color.briefInkPrimary : Color.briefInkSecondary)))
                .frame(width: 24, height: 24)
                .background(
                    Circle()
                        .fill(filled ? Color.briefHighlight.opacity(BriefOpacity.washHeavy)
                              : (hovering ? Color.briefHighlightWash : Color.clear))
                )
        }
        .buttonStyle(.plain)
        .onHover { hovering = $0 }
        .animation(.briefHover, value: hovering)
        .help(help)
    }
}
