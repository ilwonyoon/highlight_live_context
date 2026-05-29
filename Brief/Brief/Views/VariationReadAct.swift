import SwiftUI

// MARK: - Variation C — Read | Act split
// Left/main: the reading brief (context, provenance). Right rail: a
// constrained "Today / Next" action list the assistant proposes, extracted
// out of the read flow. Selecting an action cross-highlights its supporting
// context in the brief. Cleanest physical separation of read vs. act.
//
// Stub for now — scaffold lands first, content next (task #11).

struct VariationReadAct: View {
    let privacyChip: AnyView

    var body: some View {
        VStack(alignment: .leading, spacing: BriefSpacing.xl) {
            Text("C · Read | Act split")
                .briefStyle(.title3)
                .foregroundStyle(Color.briefInkPrimary)
            Text("Two-pane: reading brief + a constrained action rail. Coming next.")
                .briefStyle(.body)
                .foregroundStyle(Color.briefInkSecondary)
        }
        .padding(BriefSpacing.huge)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }
}
