import SwiftUI

// MARK: - Variation D — Conversational brief
// A clean ranked reading doc + an adjacent AI chat rail (Granola model) that
// has the doc as context. The doc surfaces *what matters*; the chat is *how
// you act* — "draft the follow-up for #2", "what changed", "re-rank".
// Selecting a line scopes the chat to it. The doc never grows buttons.
//
// Stub for now — scaffold lands first, content next (task #12).

struct VariationConversational: View {
    let privacyChip: AnyView

    var body: some View {
        VStack(alignment: .leading, spacing: BriefSpacing.xl) {
            Text("D · Conversational brief")
                .briefStyle(.title3)
                .foregroundStyle(Color.briefInkPrimary)
            Text("Reading doc + an AI chat rail that acts on it. Coming next.")
                .briefStyle(.body)
                .foregroundStyle(Color.briefInkSecondary)
        }
        .padding(BriefSpacing.huge)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }
}
