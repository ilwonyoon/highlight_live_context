import SwiftUI

// MARK: - Privacy trust chip
// The always-visible "here's what I protected" signal (P0 hero). A calm,
// recurring trust cue — aggregate counts only, never the protected content.
//
// Behavior (the antivirus/membership model): on first appearance it states
// the full protection ("Protected 2 secrets, 4 personal items, 2 rules this
// session"), then settles to a compact two-word resting state ("Protected ·
// 8"). Hovering re-expands it. Dark background for weight/trust.

struct PrivacyChip: View {
    var secrets: Int = 2
    var personal: Int = 4
    var rules: Int = 2

    @State private var expanded = true       // starts expanded, then settles
    @State private var hovering = false

    private var total: Int { secrets + personal + rules }
    private var isOpen: Bool { expanded || hovering }

    private var fullText: String {
        "Protected \(secrets) secrets · \(personal) personal · \(rules) rules this session"
    }
    private var compactText: String {
        "Protected · \(total)"
    }

    var body: some View {
        HStack(spacing: BriefSpacing.sm) {
            Image(systemName: "checkmark.shield.fill")
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(Color.briefHighlightDeep)
            Text(isOpen ? fullText : compactText)
                .briefStyle(.monoLabel)
                .foregroundStyle(.white)
                .fixedSize(horizontal: true, vertical: false)
        }
        .padding(.horizontal, BriefSpacing.lg)
        .padding(.vertical, BriefSpacing.sm)
        .background(
            Capsule(style: .continuous)
                .fill(Color.briefInkPrimary)
        )
        .contentShape(Capsule())
        .onHover { hovering = $0 }
        .animation(.briefHover, value: isOpen)
        .task {
            // Show the full protection, then settle to the compact resting state.
            try? await Task.sleep(nanoseconds: 2_600_000_000)
            expanded = false
        }
    }
}

#Preview {
    PrivacyChip()
        .padding(40)
        .background(Color.briefPaper)
}
