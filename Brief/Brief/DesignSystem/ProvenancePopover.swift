import SwiftUI

// MARK: - Provenance preview content
// Lightweight model used by the hover popover. Real sources will provide
// richer data; this struct is what the popover view actually renders.

struct ProvenancePreview {
    let source: BriefSource
    let timeLabel: String       // e.g. "Friday at 9:01am" or "2h ago"
    let title: String           // primary heading inside the popover
    let snippet: String         // 2-4 line excerpt
    let openLabel: String       // e.g. "Open in Gmail", "Open Linear issue"

    /// Convenience for placeholder previews used in the specimen.
    static func placeholder(for source: BriefSource, phrase: String) -> ProvenancePreview {
        switch source {
        case .voice:
            return .init(
                source: .voice,
                timeLabel: "Friday at 9:01am",
                title: "Interview with Sergei Sorokin",
                snippet: "Sergei is CEO and cofounder of Highlight; ~20 years in consumer products; described Highlight as his effort to build a better place to work.",
                openLabel: "Open meeting"
            )
        case .gmail:
            return .init(
                source: .gmail,
                timeLabel: "2h ago",
                title: "Re: Follow up on Founding Designer role",
                snippet: "Hi Ilwon, thanks for the great chat today. Wanted to confirm the next step is the take-home exercise. Sending it now — let me know if you have any questions.",
                openLabel: "Open in Gmail"
            )
        case .github:
            return .init(
                source: .github,
                timeLabel: "yesterday",
                title: "feat: v2 onboarding flow refactor",
                snippet: "PR #284 by @maya. Splits the onboarding flow into three discrete steps. Adds optimistic auth handoff. Awaiting review.",
                openLabel: "Open PR"
            )
        case .notion:
            return .init(
                source: .notion,
                timeLabel: "1d ago",
                title: "Team strategy doc — Q2 priorities",
                snippet: "Section 3: Ownership matrix. Founding designer owns brand + product surface; engineering owns infra; PM owns growth experiments.",
                openLabel: "Open in Notion"
            )
        case .docs:
            return .init(
                source: .docs,
                timeLabel: "3h ago",
                title: "Customer call notes — Acme Inc.",
                snippet: "Acme is rolling out across three more regions this quarter. They flagged onboarding friction as the main blocker; want a partnership conversation by end of week.",
                openLabel: "Open doc"
            )
        case .slack:
            return .init(
                source: .slack,
                timeLabel: "12m ago",
                title: "#product · paris",
                snippet: "Quick note — Sergei wants the v2 cutover locked for Thursday morning. I'll handle the rollout comms. Let's sync at 4pm.",
                openLabel: "Open thread"
            )
        case .linear:
            return .init(
                source: .linear,
                timeLabel: "updated 12m ago",
                title: "ENG-284 · v2 onboarding refactor",
                snippet: "In Progress · assigned to Maya. Three sub-tasks. Sprint: v2 cutover. Blocked by ENG-279 (auth handoff).",
                openLabel: "Open Linear issue"
            )
        case .cursor:
            return .init(
                source: .cursor,
                timeLabel: "yesterday",
                title: "Migration script — sources table",
                snippet: "Drafted a Postgres migration adding a sources column with an enum constraint. Backfill estimated at 2 minutes. Reviewed with Maya.",
                openLabel: "Open Cursor session"
            )
        case .gcal, .outlook:
            // Calendar connectors — not yet a body source; generic placeholder.
            return .init(
                source: source,
                timeLabel: "today",
                title: "\(source.label)",
                snippet: "Connected calendar. Meetings and events from \(source.label) feed your context.",
                openLabel: "Open \(source.label)"
            )
        }
    }
}

// MARK: - Popover view
// Light paper theme, ~360pt wide, 3-line snippet, expand button top-right.

struct ProvenancePopoverView: View {
    let preview: ProvenancePreview
    var onOpen: () -> Void = {}

    @State private var popoverHovered = false

    var body: some View {
        Button(action: onOpen) {
            VStack(alignment: .leading, spacing: BriefSpacing.md) {
                // Header — source identity + timestamp + external link on one line.
                // Width is set wide enough to fit the longest expected timestamp.
                HStack(alignment: .firstTextBaseline, spacing: BriefSpacing.sm) {
                    BriefIcon(preview.source, size: BriefLayout.InlineIcon.small, rendering: preview.source == .voice ? .template : .original)
                        .foregroundStyle(preview.source == .voice ? Color.briefHighlightDeep : Color.briefInkPrimary)
                        .alignmentGuide(.firstTextBaseline) { d in d[VerticalAlignment.center] + BriefSpacing.xs }
                    Text(preview.source.label)
                        .briefStyle(.monoLabel)
                        .foregroundStyle(Color.briefInkSecondary)
                    Text("·")
                        .briefStyle(.monoLabel)
                        .foregroundStyle(Color.briefInkTertiary)
                    Text(preview.timeLabel)
                        .briefStyle(.monoMeta)
                        .foregroundStyle(Color.briefInkTertiary)
                        .lineLimit(1)
                    Spacer(minLength: 0)
                    // External-link icon — animates up-right when the whole
                    // popover is hovered, signaling "click anywhere here to open"
                    Image(systemName: "arrow.up.right.square")
                        .font(.system(size: BriefLayout.InlineIcon.regular, weight: .regular))
                        .foregroundStyle(popoverHovered
                                         ? Color.briefInkPrimary
                                         : Color.briefInkSecondary)
                        .offset(x: popoverHovered ? BriefSpacing.xxs : 0,
                                y: popoverHovered ? -BriefSpacing.xxs : 0)
                        .scaleEffect(popoverHovered ? 1.08 : 1.0)
                        .animation(.briefStandard, value: popoverHovered)
                }

                // Title
                Text(preview.title)
                    .briefStyle(.bodySmall)
                    .foregroundStyle(Color.briefInkPrimary)
                    .fixedSize(horizontal: false, vertical: true)
                    .multilineTextAlignment(.leading)

                // Snippet — wrapped in ellipsis bookends + paper fades top/bottom
                // to signal this excerpt is FROM THE MIDDLE of a larger document.
                SnippetExcerpt(text: preview.snippet)
            }
            .padding(BriefLayout.Popover.inset)
            .frame(width: BriefLayout.Popover.width, alignment: .leading)
            .contentShape(Rectangle())  // entire popover area is hit-testable
        }
        .buttonStyle(.plain)
        .onHover { popoverHovered = $0 }
        .help(preview.openLabel)
        // No custom background — system NSPopover panel provides chrome.
    }
}

// MARK: - Snippet excerpt
// Snippet content rendered with ellipsis bookends and paper fade-outs at
// the top and bottom edges. Communicates "this is excerpted from the
// middle of a larger document" without extra labels.

struct SnippetExcerpt: View {
    let text: String

    var body: some View {
        Text("… \(text) …")
            .briefStyle(.snippet)
            .foregroundStyle(Color.briefInkSecondary)
            .lineLimit(6)
            .fixedSize(horizontal: false, vertical: true)
            .multilineTextAlignment(.leading)
            .mask(
                LinearGradient(
                    gradient: Gradient(stops: [
                        .init(color: .black.opacity(BriefOpacity.washHeavy), location: 0.0),
                        .init(color: .black,                                 location: 0.18),
                        .init(color: .black,                                 location: 0.82),
                        .init(color: .black.opacity(BriefOpacity.washHeavy), location: 1.0),
                    ]),
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
    }
}

// (DelayedHover moved to InteractionState.swift)
