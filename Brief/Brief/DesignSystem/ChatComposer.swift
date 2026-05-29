import SwiftUI

// MARK: - ChatComposer
// Two-state floating composer that appears next to a selected line.
//
//   Collapsed (rest):   small chat icon, hint of presence
//   Expanded  (hover):  Ask input + 4 quick action chips
//
// The user can:
//   - Type into the Ask field and Enter to start a chat
//   - Click any chip: Ask / Task / Summarize / Copy / Share
//
// Actions are stubbed — they print for now and will route to real handlers
// once chat / task creation are wired up.

struct ChatComposer: View {
    let seedText: String

    @State private var expanded = false
    @State private var draft = ""
    @FocusState private var draftFocused: Bool

    var body: some View {
        Group {
            if expanded {
                expandedView
            } else {
                collapsedView
            }
        }
        .animation(.briefStandard, value: expanded)
        .onHover { hovering in
            if hovering {
                expanded = true
            } else if !draftFocused {
                expanded = false
                draft = ""
            }
        }
    }

    // MARK: - Collapsed

    private var collapsedView: some View {
        Button {
            expanded = true
            draftFocused = true
        } label: {
            Image(systemName: "bubble.left")
                .font(.system(size: 13, weight: .medium))
                .foregroundStyle(Color.briefHighlightInk)
                .frame(width: 28, height: 28)
                .background(
                    Circle()
                        .fill(Color.briefHighlightWash)
                        .overlay(Circle().stroke(Color.briefHighlight.opacity(BriefOpacity.washHeavy), lineWidth: 1))
                )
        }
        .buttonStyle(.plain)
        .help("Ask Highlight about this")
    }

    // MARK: - Expanded
    // Follows Highlight's chat pattern: context chip row → input row → action row.

    private var expandedView: some View {
        VStack(alignment: .leading, spacing: BriefSpacing.md) {
            // Row 1 — context chip(s) + add button
            HStack(spacing: BriefSpacing.sm) {
                ContextChip(text: seedText)
                Button {
                    // future: open context picker
                } label: {
                    Image(systemName: "plus")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundStyle(Color.briefInkSecondary)
                        .frame(width: 22, height: 22)
                        .background(
                            Circle()
                                .stroke(Color.briefHairline, lineWidth: BriefLayout.Card.strokeWidth)
                        )
                }
                .buttonStyle(.plain)
                .help("Add context")
                Spacer(minLength: 0)
            }

            // Row 2 — input + voice + mention
            HStack(spacing: BriefSpacing.md) {
                TextField("Draft an action or ask a question…", text: $draft)
                    .textFieldStyle(.plain)
                    .font(.briefBodySmall)
                    .foregroundStyle(Color.briefInkPrimary)
                    .focused($draftFocused)
                    .onSubmit(submitAsk)
                Spacer(minLength: 0)
                UtilityButton(icon: "mic", action: { perform(.voice) })
                UtilityButton(icon: "at",  action: { perform(.mention) })
                if !draft.isEmpty {
                    UtilityButton(icon: "return", action: submitAsk)
                }
            }

            // Row 3 — quick action chips, divider above
            Divider().background(Color.briefHairline)
            HStack(spacing: BriefSpacing.sm) {
                ActionChip(icon: "checklist",            label: "Make task",  onTap: { perform(.makeTask) })
                ActionChip(icon: "text.aligncenter",     label: "Summarize",  onTap: { perform(.summarize) })
                ActionChip(icon: "doc.on.doc",           label: "Copy",       onTap: { perform(.copy) })
                ActionChip(icon: "square.and.arrow.up",  label: "Share",      onTap: { perform(.share) })
            }
        }
        .padding(BriefSpacing.lg)
        .frame(width: 420, alignment: .leading)
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
    }

    // MARK: - Actions

    enum ComposerAction { case makeTask, summarize, copy, share, ask, voice, mention }

    private func submitAsk() {
        guard !draft.isEmpty else { return }
        perform(.ask)
    }

    private func perform(_ action: ComposerAction) {
        switch action {
        case .ask:        print("Ask: \"\(draft)\" — context: \(seedText)")
        case .makeTask:   print("Make task from: \(seedText)")
        case .summarize:  print("Summarize: \(seedText)")
        case .copy:
            #if os(macOS)
            NSPasteboard.general.clearContents()
            NSPasteboard.general.setString(seedText, forType: .string)
            #endif
            print("Copied: \(seedText)")
        case .share:      print("Share: \(seedText)")
        case .voice:      print("Voice input — not implemented")
        case .mention:    print("Mention picker — not implemented")
        }
        // Collapse after action (except voice/mention which open further UI)
        if action != .voice && action != .mention {
            draft = ""
            expanded = false
            draftFocused = false
        }
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
        .padding(.horizontal, BriefSpacing.md)
        .padding(.vertical, BriefSpacing.xs + 1)
        .background(
            Capsule()
                .fill(Color.briefPaperSunken)
                .overlay(
                    Capsule().stroke(Color.briefHairline, lineWidth: BriefLayout.Card.strokeWidth)
                )
        )
    }

    private var truncated: String {
        let limit = 36
        if text.count <= limit { return text }
        return String(text.prefix(limit)) + "…"
    }
}

// MARK: - UtilityButton
// Circular icon-only button used in the input row (mic, @, return).

private struct UtilityButton: View {
    let icon: String
    let action: () -> Void
    @State private var hovering = false

    var body: some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.system(size: 11, weight: .medium))
                .foregroundStyle(hovering ? Color.briefInkPrimary : Color.briefInkSecondary)
                .frame(width: 26, height: 26)
                .background(
                    Circle()
                        .fill(hovering ? Color.briefHighlightWash : Color.briefPaperSunken.opacity(0.5))
                        .overlay(Circle().stroke(Color.briefHairline, lineWidth: BriefLayout.Card.strokeWidth))
                )
        }
        .buttonStyle(.plain)
        .onHover { hovering = $0 }
        .animation(.briefHover, value: hovering)
    }
}

// MARK: - ActionChip

private struct ActionChip: View {
    let icon: String
    let label: String
    let onTap: () -> Void

    @State private var hovering = false

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: BriefSpacing.xs) {
                Image(systemName: icon)
                    .font(.system(size: 10, weight: .medium))
                Text(label)
                    .briefStyle(.label)
            }
            .foregroundStyle(hovering ? Color.briefInkPrimary : Color.briefInkSecondary)
            .padding(.horizontal, BriefSpacing.md)
            .padding(.vertical, BriefSpacing.sm - 1)
            .background(
                Capsule()
                    .fill(hovering ? Color.briefHighlightWash : Color.briefPaperSunken)
                    .overlay(
                        Capsule().stroke(Color.briefHairline, lineWidth: BriefLayout.Card.strokeWidth)
                    )
            )
        }
        .buttonStyle(.plain)
        .onHover { hovering = $0 }
        .animation(.briefHover, value: hovering)
    }
}
