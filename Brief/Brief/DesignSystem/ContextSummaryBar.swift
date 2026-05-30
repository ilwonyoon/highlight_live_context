import SwiftUI

// MARK: - ContextSummaryBar
//
// The header's data-governance block, as Notion-style property rows: a fixed
// label column on the left, the value on the right. Information hierarchy
// (Ilwon): what matters first is how much context was *captured* today (the
// value Highlight is accruing), with the *sources* as supporting detail; Privacy
// (control) sits beneath.
//
//   Context   207 captured today · from [▢][▢][▢] +7     ← volume leads; sources hover-expand
//   Privacy   Auto-screening on · Add your filters →
//
// The Context row shows the day's capture volume up front; the source chips
// (top few, then "+N") expand on hover to the full connected set + a ＋ to manage
// connections. Privacy says two things at once: automatic screening is always on
// (the calm default), and the user's own filters aren't set up yet (an active
// invitation to take more control).

struct ContextSummaryBar: View {
    var onOpenPrivacy: () -> Void = { PrivacyWindowController.shared.toggle() }
    var onManageConnections: () -> Void = {}

    private var privacy: PrivacyState { .mock }

    /// Width of the label column so both rows' values line up — just wide enough
    /// for the longer label ("Privacy") so the value isn't stranded far away.
    private let labelWidth: CGFloat = 62

    var body: some View {
        VStack(alignment: .leading, spacing: BriefSpacing.sm) {
            propertyRow(label: "Context") {
                CapturedValue(onManage: onManageConnections)
            }
            propertyRow(label: "Privacy") {
                PrivacyValue(privacy: privacy, action: onOpenPrivacy)
            }
        }
    }

    /// One property row: left label column (text only), right value. The label
    /// column is fixed-width so both rows' values left-align to the same x.
    private func propertyRow<Value: View>(label: String,
                                           @ViewBuilder value: () -> Value) -> some View {
        HStack(alignment: .center, spacing: BriefSpacing.md) {
            Text(label)
                .briefStyle(.body)
                .foregroundStyle(Color.briefInkTertiary)
                .frame(width: labelWidth, alignment: .leading)

            value()
        }
    }
}

// MARK: - Captured value (volume headline + hover-expanding source chips)

private struct CapturedValue: View {
    var onManage: () -> Void = {}
    @State private var expanded = false

    /// How many source chips show at rest before the "+N".
    private let restCount = 3

    private var allSources: [BriefSource] { BriefContent.connectedSources }
    private var total: Int { BriefContent.capturedTodayTotal }

    var body: some View {
        let shown = expanded ? allSources : Array(allSources.prefix(restCount))
        let overflow = allSources.count - restCount

        HStack(spacing: BriefSpacing.sm) {
            // Volume — the headline (plain text, not bold).
            Text("\(total) captured today")
                .briefStyle(.body)
                .foregroundStyle(Color.briefInkSecondary)

            Text("·")
                .briefStyle(.body)
                .foregroundStyle(Color.briefInkTertiary)

            // Sources — supporting detail. Top few; the rest expand on hover.
            HStack(spacing: BriefSpacing.xs) {
                ForEach(Array(shown.enumerated()), id: \.offset) { _, src in
                    SourceChip(source: src)
                }
                if expanded {
                    AddConnectionChip(action: onManage)
                } else if overflow > 0 {
                    Text("+\(overflow)")
                        .briefStyle(.monoMeta)
                        .foregroundStyle(Color.briefInkTertiary)
                }
            }
        }
        .contentShape(Rectangle())
        .onHover { expanded = $0 }
        .animation(.briefHover, value: expanded)
    }
}

// MARK: - Source chip (rounded white square, brand icon inset)

private struct SourceChip: View {
    let source: BriefSource
    private let chip: CGFloat = 22
    private let icon: CGFloat = 13   // inset — does not fill the chip

    var body: some View {
        BriefIcon(source, size: icon, rendering: source == .voice ? .template : .original)
            .foregroundStyle(source == .voice ? Color.briefHighlightDeep : Color.briefInkSecondary)
            .frame(width: chip, height: chip)
            .background(
                RoundedRectangle(cornerRadius: BriefRadius.chip - 2, style: .continuous)
                    .fill(Color.briefPaperRaised)
                    .overlay(
                        RoundedRectangle(cornerRadius: BriefRadius.chip - 2, style: .continuous)
                            .stroke(Color.briefHairline, lineWidth: BriefLayout.Card.strokeWidth)
                    )
            )
            .help(source.label)
    }
}

// MARK: - Add-connection chip (same chip, a ＋ — manage connections)

private struct AddConnectionChip: View {
    let action: () -> Void
    @State private var hovering = false
    private let chip: CGFloat = 22

    var body: some View {
        Button(action: action) {
            Image(systemName: "plus")
                .font(.system(size: 11, weight: .medium))
                .foregroundStyle(hovering ? Color.briefInkPrimary : Color.briefInkTertiary)
                .frame(width: chip, height: chip)
                .background(
                    RoundedRectangle(cornerRadius: BriefRadius.chip - 2, style: .continuous)
                        .fill(hovering ? Color.briefPaperRaised : Color.clear)
                        .overlay(
                            RoundedRectangle(cornerRadius: BriefRadius.chip - 2, style: .continuous)
                                .stroke(Color.briefHairline, lineWidth: BriefLayout.Card.strokeWidth)
                        )
                )
        }
        .buttonStyle(.plain)
        .onHover { hovering = $0 }
        .animation(.briefHover, value: hovering)
        .help("Manage connections")
    }
}

// MARK: - Privacy value (two layers: auto on + user filters to set up)

private struct PrivacyValue: View {
    let privacy: PrivacyState
    let action: () -> Void
    @State private var hovering = false

    var body: some View {
        Button(action: action) {
            HStack(spacing: BriefSpacing.sm) {
                // Layer 1 — automatic screening, always on. A green dot on the
                // left carries the "on" state (calmer than the word).
                HStack(spacing: BriefSpacing.xs) {
                    Circle()
                        .fill(Color.briefHighlightDeep)
                        .frame(width: 6, height: 6)
                    Text("Auto-screening")
                        .briefStyle(.body)
                        .foregroundStyle(Color.briefInkSecondary)
                }

                Text("·")
                    .briefStyle(.body)
                    .foregroundStyle(Color.briefInkTertiary)

                // Layer 2 — the user's own filters. Until set up, an active
                // invitation (brand-inked, with an arrow) to take more control.
                if privacy.userFiltersConfigured {
                    Text("\(privacy.rules.count) filters")
                        .briefStyle(.body)
                        .foregroundStyle(Color.briefInkSecondary)
                } else {
                    HStack(spacing: BriefSpacing.xs) {
                        Text("Add your filters")
                            .briefStyle(.bodyMedium)
                            .foregroundStyle(Color.briefHighlightInk)
                        Image(systemName: "arrow.right")
                            .font(.system(size: 9, weight: .semibold))
                            .foregroundStyle(Color.briefHighlightInk)
                    }
                }
            }
            // No leading inset → "Auto-screening" left-aligns with "207" above.
            // Hover capsule is drawn behind without shifting the text.
            .padding(.vertical, BriefSpacing.xs)
            .background(
                RoundedRectangle(cornerRadius: BriefRadius.chip, style: .continuous)
                    .fill(hovering ? Color.briefSelectionRest : Color.clear)
                    .padding(.horizontal, -BriefSpacing.sm)
            )
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .onHover { hovering = $0 }
        .animation(.briefHover, value: hovering)
        .help("Open data & privacy")
    }
}
