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
            propertyRow(label: "Privacy") {
                PrivacyValue(privacy: privacy, action: onOpenPrivacy)
            }
        }
    }

    /// One property row: a small uppercase mono field-tag on the left, the value
    /// on the right. The tag reads as a label (a measured field), letting the
    /// value carry the data weight — no longer competing at the same size.
    private func propertyRow<Value: View>(label: String,
                                           @ViewBuilder value: () -> Value) -> some View {
        HStack(alignment: .center, spacing: BriefSpacing.md) {
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

    var body: some View {
        // The volume headline, as Söhne Mono (a measured value). A small chevron
        // is the affordance — it says "there's more here" without the old inline
        // row of icons. Click (or tap) opens the per-source breakdown; the whole
        // thing is one button so it works on touch too.
        Button { showBreakdown.toggle() } label: {
            HStack(spacing: BriefSpacing.xs) {
                Text("\(total) captured today")
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
                        .briefStyle(.monoBody)
                        .foregroundStyle(Color.briefInkSecondary)
                }

                Text("·")
                    .briefStyle(.monoBody)
                    .foregroundStyle(Color.briefInkTertiary)

                // Layer 2 — the user's own filters. Until set up, an active
                // invitation: brand-inked text that underlines on hover (no
                // arrow — the colour already reads as "actionable", and a mono
                // arrow sat awkwardly against the type).
                if privacy.userFiltersConfigured {
                    Text("\(privacy.rules.count) filters")
                        .briefStyle(.monoBody)
                        .foregroundStyle(Color.briefInkSecondary)
                } else {
                    Text("Add your filters")
                        .briefStyle(.monoBodyMedium)
                        .foregroundStyle(Color.briefHighlightInk)
                        .overlay(alignment: .bottom) {
                            Rectangle()
                                .fill(Color.briefHighlightInk)
                                .frame(height: 1)
                                .offset(y: 2)
                                .opacity(hovering ? 1 : 0)
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
