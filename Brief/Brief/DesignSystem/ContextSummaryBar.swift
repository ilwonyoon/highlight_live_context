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
    // The host wires this to its slide-over trigger (see LiveContextView). The
    // default is a no-op so this view stays presentation-only — it neither knows
    // nor owns how the panel is shown.
    var onOpenPrivacy: () -> Void = {}
    var onManageConnections: () -> Void = {}

    private var privacy: PrivacyState { .mock }

    /// Width of the label column so both rows' values line up. The labels are
    /// small mono field-tags now, so this is narrower than the old body width.
    private let labelWidth: CGFloat = 58

    var body: some View {
        VStack(alignment: .leading, spacing: BriefSpacing.sm) {
            propertyRow(label: "Context") {
                CapturedValue(onManage: onManageConnections)
            }
            propertyRow(label: "Privacy", alignment: .firstTextBaseline) {
                PrivacyValue(privacy: privacy, action: onOpenPrivacy)
            }
        }
    }

    /// One property row: a small uppercase mono field-tag on the left, the value
    /// on the right. The tag reads as a label (a measured field), letting the
    /// value carry the data weight — no longer competing at the same size.
    /// `alignment` lets a multi-line value (Privacy: CTA + status) baseline-align
    /// its label to the first line instead of centering against the whole block.
    private func propertyRow<Value: View>(label: String,
                                          alignment: VerticalAlignment = .center,
                                          @ViewBuilder value: () -> Value) -> some View {
        HStack(alignment: alignment, spacing: BriefSpacing.md) {
            Text(label.uppercased())
                .briefStyle(.monoLabel)
                .foregroundStyle(Color.briefInkTertiary)
                .frame(width: labelWidth, alignment: .leading)

            value()
        }
    }
}

// MARK: - Captured value (volume headline → hover reveals a per-source breakdown)

private struct CapturedValue: View {
    var onManage: () -> Void = {}
    @State private var showBreakdown = false
    @State private var hovering = false

    private var total: Int { BriefContent.capturedTodayTotal }
    /// How many sources are contributing today — the breadth half of the headline.
    private var connectedCount: Int { BriefContent.capturedToday.count }

    var body: some View {
        // One measured line: volume (how much) · breadth (how many apps) — both
        // describe the same thing (your incoming context), so they share ONE
        // target. The ⌄ says "expand here": click opens the per-source breakdown.
        Button { showBreakdown.toggle() } label: {
            HStack(spacing: BriefSpacing.xs) {
                Text("\(total) captured today")
                    .briefStyle(.monoBody)
                    .foregroundStyle(Color.briefInkSecondary)
                Text("·")
                    .briefStyle(.monoBody)
                    .foregroundStyle(Color.briefInkTertiary)
                Text("\(connectedCount) apps connected")
                    .briefStyle(.monoBody)
                    .foregroundStyle(Color.briefInkSecondary)
                Image(systemName: "chevron.down")
                    .font(.system(size: 9, weight: .semibold))
                    .foregroundStyle(hovering || showBreakdown
                                     ? Color.briefInkSecondary : Color.briefInkTertiary)
            }
            .padding(.vertical, BriefSpacing.xs)
            .padding(.horizontal, BriefSpacing.sm)
            .background(
                RoundedRectangle(cornerRadius: BriefRadius.chip, style: .continuous)
                    .fill(hovering || showBreakdown ? Color.briefSelectionRest : Color.clear)
            )
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .onHover { hovering = $0 }
        .animation(.briefHover, value: hovering)
        .animation(.briefHover, value: showBreakdown)
        .popover(isPresented: $showBreakdown, arrowEdge: .bottom) {
            CaptureBreakdownPopover(onManage: onManage)
        }
    }
}

// MARK: - Capture breakdown popover (per-source bars + connect more)

private struct CaptureBreakdownPopover: View {
    var onManage: () -> Void = {}

    /// Connected sources with today's counts, busiest first.
    private var connected: [(source: BriefSource, count: Int)] {
        BriefContent.capturedToday.sorted { $0.count > $1.count }
    }
    /// Connectors not yet contributing today — the invitation to connect more.
    private var unconnected: [BriefSource] {
        let active = Set(BriefContent.capturedToday.map(\.source))
        return BriefSource.allCases.filter { !active.contains($0) }
    }
    private var maxCount: Int { connected.map(\.count).max() ?? 1 }

    var body: some View {
        VStack(alignment: .leading, spacing: BriefSpacing.lg) {
            // Header — total + what this is.
            VStack(alignment: .leading, spacing: 2) {
                Text("Captured today")
                    .briefStyle(.bodyMedium)
                    .foregroundStyle(Color.briefInkPrimary)
                Text("Where your context is accruing right now.")
                    .briefStyle(.bodySmall)
                    .foregroundStyle(Color.briefInkTertiary)
            }

            // Per-source bars.
            VStack(alignment: .leading, spacing: BriefSpacing.sm) {
                ForEach(Array(connected.enumerated()), id: \.offset) { _, entry in
                    SourceBar(source: entry.source, count: entry.count, maxCount: maxCount)
                }
            }

            // Connect more — unconnected connectors + the manage action.
            if !unconnected.isEmpty {
                Divider().overlay(Color.briefHairlineSoft)
                VStack(alignment: .leading, spacing: BriefSpacing.sm) {
                    Text("NOT CONNECTED")
                        .briefStyle(.monoMeta)
                        .foregroundStyle(Color.briefInkTertiary)
                    // The dormant connectors, as muted chips, + a manage button.
                    FlowChips(sources: unconnected, onManage: onManage)
                }
            }
        }
        .padding(BriefSpacing.xl)
        .frame(width: 280)
        .background(Color.briefPaper)
    }
}

// MARK: - One source row: icon · name · bar · count

private struct SourceBar: View {
    let source: BriefSource
    let count: Int
    let maxCount: Int

    private let track: CGFloat = 96

    var body: some View {
        HStack(spacing: BriefSpacing.sm) {
            BriefIcon(source, size: 13, rendering: source == .voice ? .template : .original)
                .foregroundStyle(source == .voice ? Color.briefHighlightDeep : Color.briefInkSecondary)
                .frame(width: 16)

            Text(source.label)
                .briefStyle(.bodySmall)
                .foregroundStyle(Color.briefInkPrimary)
                .lineLimit(1)
                .frame(width: 104, alignment: .leading)

            // Proportional bar.
            ZStack(alignment: .leading) {
                Capsule().fill(Color.briefInkPrimary.opacity(0.06))
                    .frame(width: track, height: 5)
                Capsule().fill(Color.briefHighlightDeep.opacity(0.7))
                    .frame(width: max(4, track * CGFloat(count) / CGFloat(maxCount)), height: 5)
            }

            Text("\(count)")
                .briefStyle(.monoMeta)
                .foregroundStyle(Color.briefInkSecondary)
                .frame(minWidth: 20, alignment: .trailing)
        }
    }
}

// MARK: - Unconnected connectors as muted chips + a manage (+) button

private struct FlowChips: View {
    let sources: [BriefSource]
    var onManage: () -> Void = {}

    var body: some View {
        // A simple wrapping row. The set is small (a few connectors), so an
        // HStack with a trailing manage button reads cleanly.
        HStack(spacing: BriefSpacing.xs) {
            ForEach(Array(sources.enumerated()), id: \.offset) { _, src in
                BriefIcon(src, size: 13, rendering: src == .voice ? .template : .original)
                    .foregroundStyle(Color.briefInkTertiary)
                    .frame(width: 22, height: 22)
                    .background(
                        RoundedRectangle(cornerRadius: BriefRadius.chip - 2, style: .continuous)
                            .fill(Color.briefPaperSunken)
                            .overlay(
                                RoundedRectangle(cornerRadius: BriefRadius.chip - 2, style: .continuous)
                                    .stroke(Color.briefHairline, lineWidth: BriefLayout.Card.strokeWidth)
                            )
                    )
                    .help("Connect \(src.label)")
            }
            AddConnectionChip(action: onManage)
        }
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

// MARK: - Privacy value (one line, one target → privacy panel)
//
// Both protection layers on a single measured line, mirroring the Context row.
// The two layers ask opposite things, so the line carries that as HIERARCHY, not
// as separate controls: the user's OWN filters lead (amber, lightly-cautioned —
// the one safety action only they can take, and here haven't), and automatic
// screening trails as the calm "basics are handled" reassurance. The whole line
// is ONE target — the ⟩ opens the privacy panel, where both are managed.

private struct PrivacyValue: View {
    let privacy: PrivacyState
    let action: () -> Void
    @State private var hovering = false

    /// The user-action CTA copy. Kept here so it's a one-line swap.
    private let filtersCTA = "Add your own filters"

    var body: some View {
        Button(action: action) {
            HStack(spacing: BriefSpacing.sm) {
                // HERO — the user's own filters (only they can set these).
                if privacy.userFiltersConfigured {
                    dotted(text: "\(privacy.rules.count) of your filters",
                           color: Color.briefInkSecondary)
                } else {
                    HStack(spacing: BriefSpacing.xs) {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .font(.system(size: 9, weight: .semibold))
                            .foregroundStyle(Color.briefCaution)
                        Text(filtersCTA)
                            .briefStyle(.monoBody)
                            .foregroundStyle(Color.briefCaution)
                    }
                }

                Text("·")
                    .briefStyle(.monoBody)
                    .foregroundStyle(Color.briefInkTertiary)

                // SUPPORT — automatic screening, the calm reassurance (trails).
                dotted(text: "Auto-screening on", color: Color.briefInkTertiary)

                // Line-level affordance: ⟩ opens the privacy panel.
                Image(systemName: "chevron.right")
                    .font(.system(size: 8, weight: .semibold))
                    .foregroundStyle(hovering ? Color.briefInkSecondary : Color.briefInkTertiary)
            }
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
        .help("Set up the filters only you can — comp, deals, private confidences. Secrets, health & finance are screened automatically.")
    }

    /// A green-dot + mono label pair (the "on" indicator used for both layers).
    private func dotted(text: String, color: Color) -> some View {
        HStack(spacing: BriefSpacing.xs) {
            Circle().fill(Color.briefHighlightDeep).frame(width: 6, height: 6)
            Text(text)
                .briefStyle(.monoBody)
                .foregroundStyle(color)
        }
    }
}
